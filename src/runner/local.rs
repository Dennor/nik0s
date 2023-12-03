use std::{
    io::{Read, Result, Write},
    process::{Child as ProcessChild, Command},
};

use super::{
    command::Runner,
    pipe::{pipe, Child, ChildPipe, Pipe},
};

pub struct LocalRunner {}

impl Child for ProcessChild {
    fn wait(&mut self) -> Result<std::process::ExitStatus> {
        self.wait()
    }
}

impl<TStdout, TStderr, TStdin> ChildPipe<TStdout, TStderr, TStdin, ProcessChild> for ProcessChild
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
    ) -> Result<std::process::ExitStatus> {
        let mut stdout = self.stdout.take().map(|src| Pipe { src, dst: stdout });
        let mut stderr = self.stderr.take().map(|src| Pipe { src, dst: stderr });
        let mut stdin = self.stdin.take().map(|dst| Pipe { src: stdin, dst });
        pipe(self, &mut stdout, &mut stderr, &mut stdin)
    }
}

impl Runner<ProcessChild> for LocalRunner {
    fn spawn(&self, cmd: &mut Command) -> Result<ProcessChild> {
        cmd.stdout(std::process::Stdio::piped());
        cmd.stderr(std::process::Stdio::piped());
        cmd.stdin(std::process::Stdio::piped());
        cmd.spawn()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use std::io;

    #[test]
    fn executes_command_locally() {
        let runner = LocalRunner {};
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
