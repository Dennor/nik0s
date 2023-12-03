use std::{
    ffi::OsStr,
    io::Result,
    marker::PhantomData,
    path::Path,
    process::{Command as ProcessCommand, CommandArgs},
};

pub trait Runner<TChild> {
    fn spawn(&self, cmd: &mut ProcessCommand) -> Result<TChild>;
}

pub struct RemoteCommand<TChild, TRunner: Runner<TChild>> {
    imp: ProcessCommand,
    runner: TRunner,
    _pd_child: PhantomData<TChild>,
}

impl<TChild, TRunner> RemoteCommand<TChild, TRunner>
where
    TRunner: Runner<TChild>,
{
    pub fn new<S>(runner: TRunner, program: S) -> Self
    where
        S: AsRef<OsStr>,
    {
        Self {
            imp: ProcessCommand::new(program),
            runner,
            _pd_child: PhantomData,
        }
    }
    pub fn spawn(&mut self) -> Result<TChild> {
        self.runner.spawn(&mut self.imp)
    }

    pub fn arg<S>(&mut self, arg: S) -> &mut Self
    where
        S: AsRef<OsStr>,
    {
        self.imp.arg(arg);
        self
    }
    pub fn args<I, S>(&mut self, args: I) -> &mut Self
    where
        I: IntoIterator<Item = S>,
        S: AsRef<OsStr>,
    {
        self.imp.args(args);
        self
    }
    pub fn get_args(&self) -> CommandArgs {
        self.imp.get_args()
    }

    pub fn current_dir<P: AsRef<Path>>(&mut self, dir: P) -> &mut Self {
        self.imp.current_dir(dir);
        self
    }
    pub fn get_current_dir(&self) -> Option<&Path> {
        self.imp.get_current_dir()
    }
    pub fn env<K, V>(&mut self, key: K, val: V) -> &mut Self
    where
        K: AsRef<OsStr>,
        V: AsRef<OsStr>,
    {
        self.imp.env(key, val);
        self
    }
    pub fn env_clear(&mut self) -> &mut Self {
        self.imp.env_clear();
        self
    }
    pub fn env_remove<K: AsRef<OsStr>>(&mut self, key: K) -> &mut Self {
        self.imp.env_remove(key);
        self
    }
    pub fn envs<I, K, V>(&mut self, vars: I) -> &mut Self
    where
        I: IntoIterator<Item = (K, V)>,
        K: AsRef<OsStr>,
        V: AsRef<OsStr>,
    {
        self.imp.envs(vars);
        self
    }
    pub fn get_program(&self) -> &OsStr {
        self.imp.get_program()
    }
}
