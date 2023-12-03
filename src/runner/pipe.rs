use std::{
    io::{self, Read, Result, Write},
    process::ExitStatus,
};

pub trait ChildPipe<TStdout, TStderr, TStdin, TChild>
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
    ) -> Result<ExitStatus>;
}

pub trait Child {
    fn wait(&mut self) -> Result<ExitStatus>;
}

pub struct Pipe<TRead, TWrite>
where
    TRead: Read + std::marker::Send,
    TWrite: Write + std::marker::Send,
{
    pub src: TRead,
    pub dst: TWrite,
}

impl<TRead, TWrite> Pipe<TRead, TWrite>
where
    TRead: Read + std::marker::Send,
    TWrite: Write + std::marker::Send,
{
    fn pipe(&mut self) -> Result<()> {
        io::copy(&mut self.src, &mut self.dst)?;
        Ok(())
    }
}

pub fn pipe<TSrcStdout, TDstStdout, TSrcStderr, TDstStderr, TDstStdin, TSrcStdin, TChild>(
    child: &mut TChild,
    stdout: &mut Option<Pipe<TSrcStdout, TDstStdout>>,
    stderr: &mut Option<Pipe<TSrcStderr, TDstStderr>>,
    _stdin: &mut Option<Pipe<TSrcStdin, TDstStdin>>,
) -> Result<ExitStatus>
where
    TChild: Child + std::marker::Send,
    TSrcStdout: Read + std::marker::Send,
    TDstStdout: Write + std::marker::Send,
    TSrcStderr: Read + std::marker::Send,
    TDstStderr: Write + std::marker::Send,
    TDstStdin: Write + std::marker::Send,
    TSrcStdin: Read + std::marker::Send,
{
    let mut exit_status: Option<ExitStatus> = None;
    std::thread::scope(|s| {
        s.spawn(|| {
            match child.wait() {
                Ok(status) => exit_status = Some(status),
                Err(err) => println!("could not get exit status {}", err),
            };
        });
        s.spawn(|| {
            if let Some(stdout) = stdout {
                if let Err(err) = stdout.pipe() {
                    println!("error reading from stdout {}", err);
                }
            }
        });
        s.spawn(|| {
            if let Some(stderr) = stderr {
                if let Err(err) = stderr.pipe() {
                    println!("error reading from stderr {}", err);
                }
            }
        });
    });
    exit_status.ok_or(std::io::Error::new(
        std::io::ErrorKind::Other,
        "unknown status",
    ))
}
