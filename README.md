# supervisor-setting

## Overview

This repository provides instructions and templates to set up `supervisor` for managing background processes (daemons) in Linux and Windows environments.

The main architecture and goals of this setup are:

- **Conda Environment Isolation:** Instead of installing supervisor globally via `apt`, it is installed in an isolated Conda environment to keep Python dependencies safe and manageable.
- **Systemd Daemonization:** The Conda-installed supervisor is registered as a native systemd service. This ensures it starts automatically on boot and runs reliably in the background.
- **Collaboration-Friendly Permissions:** By changing the group ownership of `/etc/supervisor/` to `users`, multiple researchers or developers (e.g., connecting via SSH or VS Code Server) can easily add, edit, or manage their own `.conf` files without requiring root (`sudo`) privileges.
- **Integration to [`multivisor`](https://github.com/SinclairQuantumLab/multivisor)** (optional): a centralized web UI for monitoring `supervisor`s in different computers.

> **Developer's Note:** the above configuration is from the consideration on that `supervisor` is no longer actively maintained and the highest Python version is limited at 3.13 (for `supervisor-4.3.0` as of 2026/03/08; see [Changelog](https://supervisord.org/changes.html) to check the latest update) (cf. backward compatibility holds down to Python 2). Because of it, it is avoided to install `supervisor` via standard package managers (e.g., `apt` in Debian-based Linux) as it used the system Python which version is often of limited control. Therefore installing `supervisor` in a virtual environment with a compatible python version and manually create a system daemon are taken as an alternative approach.

### Relevant materials

- Official documentation: https://supervisord.org/
- Github: https://github.com/Supervisor/supervisor
- PyPI: https://pypi.org/project/supervisor/
- Changelog: https://supervisord.org/changes.html
- Issue tracker: https://github.com/Supervisor/supervisor/issues

---

## Linux

### 1. Install `supervisor` in a virtual environment

Create the folder where you want to install `supervisor` (recommended: `~/Projects/supervisord/`) and run the below commandline in `bash` terminal: 

```bash
$ uv init --python 3.13
$ uv add "supervisor==4.3.0"
```

> **NOTE**: As of 2026/03/08, `python==3.13` works with `supervisor-4.3.0`.

It already setup a virtual Python environment and installed `supervisor`. How easy!
Make sure the core executable files for `supervisor` exists:

```bash
# in the folder that supervisor has been installed:
$ ls ./.venv/bin/
```

There should be two files:

- `supervisorctl`: a command to control `supervisor'`. i.e., a CLI interface of `supervisor`.
- `supervisord`: main app of `supervisor` to be installed as a `systemd` daemon.

`supervisorctl` can be tested running:

```bash
$ ./.venv/bin/supervisorctl
unix:///etc/supervisor/run/supervisor.sock no such file
supervisor> 
```

Entering `exit` will let you go back to bash prompt.

### 2. Configure `supervisor`

Download `/linux/etc/supervisor/` in the repo and copy the `supervisor` folder in the `/etc/` folder in the computer in which you want to install `supervisor`. 

```bash
$ sudo mkdir /etc/supervisor
$ sudo cp -r /path/to/repo/linux/etc/supervisor/. /etc/supervisor
```

Make sure the `supervisor` folder contains all of the below:

- `conf.d` folder
- `logs` folder
- `run` folder
- `supervisord.conf.template` file

Change `supervisord.conf.template` file's name to `supervisord.conf` (i.e., drop the `.template` extension), open the file and update the password at `<PASSWORD>` placeholder (and save it).


<!-- 
    > **Note:** If they don't exist, create them or supervisor will not work. Below is the stdout of `sudo systemctl status --no-pager supervisor` when supervisor was installed as a systemd service daemon via `sudo apt install supervisor` but failed due to missing folders:

    ```text
    ● supervisor.service - Supervisor process control system for UNIX
        Loaded: loaded (/usr/lib/systemd/system/supervisor.service; enabled; preset: enabled)
        Active: activating (auto-restart) (Result: exit-code) since Mon 2025-03-10 15:40:12 MDT; 6s ago
        Docs: http://supervisord.org
        Process: 3156719 ExecStart=/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf (code=exited, status=2)
    Main PID: 3156719 (code=exited, status=2)
        Tasks: 21 (limit: 38053)
        Memory: 34.5M (peak: 230.7M)
            CPU: 112ms
        CGroup: /system.slice/supervisor.service
                └─3156573 python ./main.py
    ``` 
-->

### 3. Create a Symlink

Make a symlink for `supervisorctl` in conda to the local `PATH` (so you can run `supervisorctl` globally just by typing it):

```bash
# replace <VENVPATH> below with the path used in the last step 
$ sudo ln -s <VENVPATH>/bin/supervisorctl /usr/local/bin/supervisorctl
```
For example, if `supervisor` was installed in `~/Projects/supervisord/`,
`<VENVPATH>` should be replaced by `/home/<USERNAME>/Projects/supervisord/.venv/`.

> **NOTE**: command `ln` doesn't work with relative path.

It allows to call `supervisorctl` by just with the `supervisorctl` command in terminal

```bash
$ sudo supervisorctl
```


### 4. Install `supervisord` as a `systemd` Service

Copy `/linux/etc/systemd/system/supervisor.service.template` file in this repo into the computer's `/linux/etc/systemd/system/` foler and drop `.template` extension.

```bash
$ sudo mkdir -p /etc/systemd/system/
$ sudo cp -r /path/to/repo/linux/etc/systemd/system/supervisor.service.template /etc/systemd/system/supervisor.service
```

> **cf.** By default, the `.service` files for system-wide services are placed in `/lib/systemd/system/`, while the custom services in `/etc/systemd/system/` override the system-wide services.

Open `supervisor.service` file and replace the `<VENVPATH>` placeholders with the path to the hidden `.venv/` folder in the installed `supervisor`'s folder.

```bash
$ sudo nano /etc/systemd/system/supervisor.service
```


Now, let's install the `supervisor.service` to be a `systemd` daemon.

```bash
$ sudo systemctl daemon-reload # scan and register supervisor.service
$ sudo systemctl start supervisor.service # start the daemon process
$ sudo systemctl enable supervisor # enable autostart on boot
```

Check if the daemon is running and `enabled`.

```bash
$ systemctl is-active supervisor
active
$ systemctl is-enabled supervisor
enabled
```

The below command lines would be helpful to see the status and debug issues.

```bash
$ systemctl status supervisor
$ journalctl -u supervisor.service
$ journalctl -u supervisor.service -n <# logs to show>
$ journalctl -u supervisor.service -f # real-time streaming
$ systemctl cat supervisor # printing supervisor.service script
```

Also, go to `http://localhost:9001` in a web browser and see if the web control page shows up. Type username and password set under `[inet_http_server]` in `/etc/supervisor/supervisor.conf` file.

### 5. Setup Group Permissions

Change group to `users` and give read, write & file create group permissions to `/etc/supervisor/` and its subfiles/folders. This allows users to edit them without `sudo` (e.g., through SSH or vscode tunnel).

```bash
$ sudo chown -R :users /etc/supervisor
$ sudo chmod -R g+rwx /etc/supervisor
```

Verify the change:

```bash
$ ls -l /etc | grep supervisor
drwxrwxr--  <number>  root  users   ...<some text>...   supervisor
```

### 6. Multivisor Integration (Optional)

Install `multivisor[rpc]` package in the `supervisor`'s folder installed above.

```bash
$ uv add "multivisor[rpc]==6.0.3"
```

> **NOTE**: As of 2026/03/08, `python==3.13` (unofficially) works with `multivisor[rpc]-6.0.3`.

Test if `multivisor[rpc]` has been installed and can be properly called.

```bash
$ uv run python -c "from multivisor.rpc import make_rpc_interface; print('RPC import OK')"
RPC import OK
```

Then uncomment the below lines in `/etc/supervisor/supervisord.conf` to connect the supervisor to multivisor:

```ini
[rpcinterface:multivisor]
supervisor.rpcinterface_factory = multivisor.rpc:make_rpc_interface
bind=\*:9002
```

Restart `supervisor` daemon to load the new configuration.

```bash
sudo systemctl restart supervisor
```

### 7. Adding Supervised Programs

1. In the repo folder, use `/linux/etc/supervisor/conf.d/[APPNAME].conf.template` to create `<APPNAME>.conf` files in the folder of an app you want to manage by `supervisor`.
2. Edit the `<APPNAME>.conf` accordingly.
3. Copy it to `/etc/supervisor/conf.d/` folder. Keep the original copy in the app folder for bookkeeping and sharing purpose.


---

## Windows

Place the `supervisor` folder in `C:\supervisor`
