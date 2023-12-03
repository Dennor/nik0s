use core::time;
use libssh_rs::{Channel, Session};
use shell_quote::{QuoteExt, Sh};
use std::{
    ffi::OsString,
    io::{self, Write},
    io::{Error, Read},
    os::unix::process::ExitStatusExt,
    process::ExitStatus,
    sync::mpsc::{channel, Receiver, SendError, Sender},
    thread::JoinHandle,
};

use super::{
    command::Runner,
    pipe::{pipe, Child, ChildPipe, Pipe},
};

struct ChannelRead {
    channel: Receiver<(usize, [u8; 512])>,
    buf: [u8; 512],
    len: usize,
    cursor: usize,
    done: bool,
}

impl Read for ChannelRead {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        if self.done {
            return Ok(0);
        }
        let buf_offset = 0;
        let mut copied = 0;
        while copied < buf.len() {
            if self.len <= self.cursor {
                (self.len, self.buf) = self
                    .channel
                    .recv()
                    .map_err(|err| Error::new(std::io::ErrorKind::Other, err))?;
                self.cursor = 0;
                if self.len == 0 {
                    self.done = true;
                    return Ok(copied);
                }
            }
            let amt = std::cmp::min(self.len - self.cursor, buf.len());
            buf[buf_offset..amt].copy_from_slice(&self.buf[self.cursor..self.cursor + amt]);
            copied += amt;
            self.cursor += amt;
        }
        Ok(copied)
    }
}

struct ChannelWrite {
    channel: Sender<(usize, [u8; 512])>,
}

impl Write for ChannelWrite {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        let mut buf_view = &buf[..];
        let mut total = 0;
        while buf_view.len() > 0 {
            let mut send_buf: [u8; 512] = [0u8; 512];
            let amt = std::cmp::min(512, buf_view.len());
            send_buf[0..amt].copy_from_slice(&buf_view[0..amt]);
            self.channel
                .send((amt, send_buf))
                .map_err(|err| Error::new(io::ErrorKind::Other, err))?;
            buf_view = &buf_view[amt..];
            total += amt;
        }
        Ok(total)
    }
    fn flush(&mut self) -> io::Result<()> {
        Ok(())
    }
}

pub struct SSHChild {
    exit_status: Receiver<ExitStatus>,
    stdout: Option<ChannelRead>,
    stderr: Option<ChannelRead>,
    stdin: Option<ChannelWrite>,
    handle: Option<JoinHandle<()>>,
}

impl Drop for SSHChild {
    fn drop(&mut self) {
        if let Some(handle) = self.handle.take() {
            if let Err(_) = handle.join() {
                println!("could not join ssh io thread")
            }
        }
    }
}

impl Child for SSHChild {
    fn wait(&mut self) -> io::Result<ExitStatus> {
        self.exit_status
            .recv()
            .map_err(|err| Error::new(io::ErrorKind::Other, err))
    }
}

impl<TStdout, TStderr, TStdin> ChildPipe<TStdout, TStderr, TStdin, SSHChild> for SSHChild
where
    TStdout: Write + std::marker::Send,
    TStderr: Write + std::marker::Send,
    TStdin: Read + std::marker::Send,
{
    fn pipe(
        self: &mut Self,
        stdout: &mut TStdout,
        stderr: &mut TStderr,
        stdin: &mut TStdin,
    ) -> io::Result<std::process::ExitStatus> {
        let mut stdout = self.stdout.take().map(|src| Pipe { src, dst: stdout });
        let mut stderr = self.stderr.take().map(|src| Pipe { src, dst: stderr });
        let mut stdin = self.stdin.take().map(|dst| Pipe { src: stdin, dst });
        pipe(self, &mut stdout, &mut stderr, &mut stdin)
    }
}

pub struct SSHRunner {
    pub session: Session,
}

enum StreamError {
    SshError(libssh_rs::Error),
    SendError(SendError<(usize, [u8; 512])>),
}

fn read_stream(
    buf: &mut [u8; 512],
    ssh_channel: &Channel,
    is_stderr: bool,
    sender: &Sender<(usize, [u8; 512])>,
) -> Result<usize, StreamError> {
    ssh_channel
        .read_timeout(
            &mut buf[..],
            is_stderr,
            Some(time::Duration::from_millis(1)),
        )
        .map_err(|err| StreamError::SshError(err))
        .and_then(|n| match n {
            n if n > 0 => {
                let mut bind: [u8; 512] = [0u8; 512];
                buf.swap_with_slice(&mut bind);
                sender
                    .send((n, bind))
                    .map(|_| n)
                    .map_err(|err| StreamError::SendError(err))
            }
            _ => Ok(n),
        })
}

impl<'a> Runner<SSHChild> for SSHRunner {
    fn spawn(&self, cmd: &mut std::process::Command) -> std::io::Result<SSHChild> {
        let mut script: OsString = cmd.get_program().into();
        for arg in cmd.get_args() {
            script.push(" ");
            script.push_quoted(Sh, arg);
        }
        // TODO: Proper error handling
        let cmd = script.into_string().unwrap();
        let (status_sender, status_receiver) = channel();
        let (stdout_sender, stdout_receiver) = channel();
        let (stderr_sender, stderr_receiver) = channel();
        let (stdin_sender, stdin_receiver) = channel::<(usize, [u8; 512])>();
        let ssh_channel = self.session.new_channel()?;
        ssh_channel.open_session()?;
        ssh_channel.request_exec(cmd.as_str())?;
        ssh_channel.send_eof()?;
        let mut buf: [u8; 512] = [0u8; 512];
        let streams = vec![(false, stdout_sender), (true, stderr_sender)];
        let handle = std::thread::spawn(move || loop {
            if !ssh_channel.is_closed() {
                for stream in &streams {
                    if let Err(err) = read_stream(&mut buf, &ssh_channel, stream.0, &stream.1) {
                        match err {
                            StreamError::SshError(err) => {
                                if ssh_channel.is_closed() {
                                    break;
                                }
                                println!("error reading stream {}", err);
                            }
                            StreamError::SendError(err) => println!("error reading stream {}", err),
                        }
                    }
                }
            }
            if let Ok(data) = stdin_receiver.try_recv() {
                println!("stdin not implemented {}", data.0);
            }
            if let Some(status) = ssh_channel.get_exit_status() {
                if let Err(err) = status_sender.send(ExitStatus::from_raw(status)) {
                    println!("error sending exit status {}", err);
                }
                if !ssh_channel.is_closed() {
                    for stream in &streams {
                        loop {
                            match read_stream(&mut buf, &ssh_channel, stream.0, &stream.1) {
                                Ok(n) => {
                                    if n == 0 {
                                        break;
                                    }
                                }
                                Err(_) => break,
                            }
                        }
                        if let Err(err) = stream.1.send((0, [0u8; 512])) {
                            println!("error closing stream {}", err);
                        }
                    }
                }
                return;
            }
        });
        let child = SSHChild {
            exit_status: status_receiver,
            stdout: Some(ChannelRead {
                channel: stdout_receiver,
                buf: [0u8; 512],
                len: 0,
                cursor: 0,
                done: false,
            }),
            stderr: Some(ChannelRead {
                channel: stderr_receiver,
                buf: [0u8; 512],
                len: 0,
                cursor: 0,
                done: false,
            }),
            stdin: Some(ChannelWrite {
                channel: stdin_sender,
            }),
            handle: Some(handle),
        };
        Ok(child)
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use libssh_rs::{AuthMethods, AuthStatus, Error, SshOption, SshResult};
    use std::io;
    use sysinfo::{Pid, ProcessExt, System, SystemExt};
    use tempfile::tempdir;
    use which::which;

    fn authenticate(sess: &Session, user_name: Option<&str>) -> SshResult<()> {
        match sess.userauth_none(user_name)? {
            AuthStatus::Success => return Ok(()),
            _ => {}
        }

        loop {
            let auth_methods = sess.userauth_list(user_name)?;

            if auth_methods.contains(AuthMethods::PUBLIC_KEY) {
                match sess.userauth_public_key_auto(None, None)? {
                    AuthStatus::Success => return Ok(()),
                    _ => {}
                }
            }

            return Err(Error::Fatal("unhandled auth case".to_string()));
        }
    }

    struct SSHDGuard {
        pid_file: String,
        log_file: String,
    }
    impl Drop for SSHDGuard {
        fn drop(&mut self) {
            if let Some(log) = std::fs::read_to_string(self.log_file.as_str()).ok() {
                println!("Server logs:");
                println!("{log}");
            }
            if let Some(pid) = std::fs::read_to_string(self.pid_file.as_str())
                .and_then(|mut pid| {
                    pid.pop();
                    pid.parse::<usize>()
                        .map_err(|err| io::Error::new(io::ErrorKind::Other, err))
                })
                .ok()
            {
                let s = System::new_all();
                if let Some(process) = s.process(Pid::from(pid)) {
                    process.kill();
                }
            }
        }
    }

    // This test requires that user running the test can ssh into itself
    // It binds sshd to localhost:10022, so you might want to kill it after
    // the test in case something went wrong.
    #[test]
    fn executes_command_over_ssh() {
        let dir = tempdir().unwrap();
        let temp_dir = dir.path().to_str().unwrap().to_string();
        let mut host_key = temp_dir.clone();
        host_key.push_str("/test_host_key");
        let mut sshd_guard = SSHDGuard {
            pid_file: temp_dir.clone(),
            log_file: temp_dir.clone(),
        };
        sshd_guard.pid_file.push_str("/sshd.pid");
        sshd_guard.log_file.push_str("/sshd.log");
        let mut sshd_pid_opt = String::new();
        sshd_pid_opt.push_str("PidFile=");
        sshd_pid_opt.push_str(&sshd_guard.pid_file.as_str());
        let ssh_keygen = which("ssh-keygen").unwrap();
        let keygen_handle = std::process::Command::new(ssh_keygen.as_path().to_str().unwrap())
            .args(["-q", "-N", "", "-t", "ed25519", "-f", host_key.as_str()])
            .output()
            .unwrap();
        assert_eq!(keygen_handle.status.success(), true);
        let sshd = which("sshd").unwrap();
        let sshd_handle = std::process::Command::new(sshd.as_path().to_str().unwrap())
            .args([
                "-o",
                "ListenAddress=127.0.0.1",
                "-o",
                sshd_pid_opt.as_str(),
                "-p",
                "10022",
                "-E",
                sshd_guard.log_file.as_str(),
                "-h",
                host_key.as_str(),
            ])
            .output()
            .unwrap();
        assert_eq!(sshd_handle.status.success(), true);
        let runner = SSHRunner {
            session: Session::new().unwrap(),
        };

        runner
            .session
            .set_option(SshOption::Hostname("localhost".to_string()))
            .unwrap();
        runner.session.set_option(SshOption::Port(10022)).unwrap();
        runner.session.options_parse_config(None).unwrap();
        runner.session.connect().unwrap();
        authenticate(&runner.session, None).unwrap();
        let mut cmd = std::process::Command::new("echo");
        cmd.arg("Hello world!");
        let mut child = runner.spawn(&mut cmd).unwrap();
        let mut stdout_buf = Vec::new();
        let mut stdout = io::Cursor::new(&mut stdout_buf);
        let mut stderr_buf = Vec::new();
        let mut stderr = io::Cursor::new(&mut stderr_buf);
        let mut stdin = io::Cursor::new(Vec::new());
        child.pipe(&mut stdout, &mut stderr, &mut stdin).unwrap();
        let stdout_result = String::from_utf8(stdout_buf).unwrap();
        assert_eq!(stdout_result.as_str(), "Hello world!\n");
        let stderr_result = String::from_utf8(stderr_buf).unwrap();
        assert_eq!(stderr_result.as_str(), "");
    }
}
