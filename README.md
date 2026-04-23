# supervisor-windows

## Table of Contents

1. [Setting up in Windows](#setting-up-in-windows)
2. [Managing processes](#managing-processes)

## Setting up in Windows

### 1. Install `supervisor-win` in a virtual environment

Create the folder where you want to install `supervisor-win` (recommended: `%USERPROFILE%/Projects/supervisord-win/`) and run the below commandline in `powershell` terminal:

```powershell
> uv init --python 3.11
> uv add "supervisor-win==4.7.0"
```

> **NOTE**: As of 2026/03/08, `python==3.11` works with `supervisor-win==4.3.0`.

It already setup a virtual Python environment and installed `supervisor`. How easy!
Make sure the core executable files for `supervisor` exists:

```powershell
# in the folder that supervisor has been installed:
> ls .\.venv\Scripts\
```

There should be two files:

- `supervisorctl.exe`: a command to control `supervisor'`. i.e., a CLI interface of `supervisor`.
- `supervisord.exe`: main app of `supervisor` to be installed as a Windows Service.

`supervisorctl` can be tested running:

```powershell
> .\.venv\Scripts\supervisorctl.exe
http://localhost:9001 refused connection
supervisor>
```

Entering `exit` will let you go back to powershell prompt.

### 2. Configure `supervisor-win`

Download `\windows\supervisor\` in the repo and copy the `supervisor` folder into the `C:\` folder in the computer in which you want to install `supervisor`.

Make sure the `supervisor` folder contains all of the below:

- `conf.d` folder
- `logs` folder
- `supervisord.conf.template.conf.windows` file

Change `supervisord.conf.template.conf.windows` file's name to `supervisord.conf` (i.e., drop the `.template.conf.windows` extension), open the file and update the password at `<PASSWORD>` placeholder (and save it).

<!-- ### 3. Create a Symlink

Make a symlink for `supervisorctl` in conda to the local `PATH` (so you can run `supervisorctl` globally just by typing it):

```powershell
# replace <VENVPATH> below with the path used in the last step
$ sudo ln -s <VENVPATH>/bin/supervisorctl /usr/local/bin/supervisorctl
```

For example, if `supervisor` was installed in `~/Projects/supervisord/`,
`<VENVPATH>` should be replaced by `/home/<USERNAME>/Projects/supervisord/.venv/`.

> **NOTE**: command `ln` doesn't work with relative path.

It allows to call `supervisorctl` by just with the `supervisorctl` command in terminal

```powershell
sudo supervisorctl
``` -->

### 3. Install `supervisord` as a Windows Service

Test if `supervisor` can run in terminal:

```powershell
> uv run python -m supervisor.supervisorctl -c C:\supervisor\supervisord.conf status
```

If it works fine, open a `powershell` with "**Run as Administrator**" and run the below:

```powershell
> uv run python -m supervisor.services install -c C:\supervisor\supervisord.conf
```

The Windows Service named "Supervisor Py3.11 process monitor" shoul be created. Run the below to startup the service after boot.

```powershell
Set-Service -Name "Supervisor Pyv3.11" -StartupType Automatic
```

The service can be managed in `Services` GUI (`services.msc`) or through the below `powershell` commands:

```powershell
> Get-Service *Supervisor*
> Start-Service "Supervisor Pyv3.11"
> Get-Service "Supervisor Pyv3.11" | Select-Object Name, Status, StartType
> Restart-Service "Supervisor Pyv3.11"
> Stop-Service "Supervisor Pyv3.11"
```

Go to `http://localhost:9001` in a web browser and see if the web control page shows up. Type username and password set under `[inet_http_server]` in `C:\supervisor\supervisord.conf` file.

### 4. Configure Windows Defender Firewall

The below procedure opens the port 9002 for `multivisor-rpc` to talk to the `multivisor-web`:

Open Windows Defender firewall. Then go to Advanced settings --(new window)--> Inbound Rules -> New Rule... --(new window)--> Port -> Choose "TCP" and "Specific local ports" option and input 9002 -> Choose "Allow the connection" option -> check all the checkboxes: "Domain", "Private", and "Public" -> Input multivisor-rpc as name -> Finish.

### 5. Multivisor Integration (Optional)

Install `multivisor[rpc]` package in the `supervisor`'s folder installed above.

```bash
> uv add "multivisor[rpc]==6.0.1"
```

> **NOTE**: As of 2026/04/03, multivisor[rpc]==6.0.2 or 6.0.3 (latest) contain onlylinux dependency; see [here](https://github.com/tiagocoutinho/multivisor/issues/101)

Test if `multivisor[rpc]` has been installed and can be properly called.

```bash
> uv run python -c "from multivisor.rpc import make_rpc_interface; print('RPC import OK')"
RPC import OK
```

Then uncomment the below lines in `C:\supervisor\supervisord.conf` to connect the supervisor to multivisor:

```ini
[rpcinterface:multivisor]
supervisor.rpcinterface_factory = multivisor.rpc:make_rpc_interface
bind=\*:9002
```

Restart `Supervisor Pyv3.11` Windows Service to load the new configuration.

```bash
> Restart-Service "Supervisor Pyv3.11"
```

### 6. Adding apps in `supervisor-win`

1. In the repo folder, use `\windows\supervisor\conf.d\[APPNAME].conf.template.windows.TBD` or, to run python scripts, `[APPNAME].conf.template.windows.python` to create `<APPNAME>.conf` files in the folder of an app you want to manage by `supervisor`.
2. Edit the `<APPNAME>.conf` accordingly.
3. Copy it to `C:\supervisor\conf.d\` folder. Keep the original copy in the app folder for bookkeeping and sharing purpose.

---

## Managing processes

### Configuring `<APPNAME>.conf` files further

The `.conf` file for each program introduced above is just simple examples. More advanced features like restrat policy when apps fail or dependencies between apps can be setup in the configuration file. Find the full detail in the [official documentation](https://supervisord.org/configuration.html) with a particular focus on `[program:x]` and `[group:x]` Section Settings.

### Running python scripts with `supervisor`

#### Helper package

`/python/supervisor/` contains package that may be necessary or useful to run python apps with `supervisor`. Copy the `supervisor/` folder into the project's folder and import, for instance, `supervisor_helper.py` module as below:

```python
from supervisor.supervisor_helper import *
```

For instance, `log()`, `log_error()`, and , `log_warn()` in `supervisor_helper.py` will be important in particular as `supervisor` display and log the `stdout` for normal output and `stderr` for errors separately.

#### Launching script

It will be convenient to use the Lauching script `Startup.ps1` in `/python/` folder here. Then call or execute the launching script in the `command=` section in `<APPNAME>.conf` files.
In Windows, the `Startup.ps1` file should be called via `powershell`'s `-File` option; see `\windows\supervisor\conf.d\[APPNAME].conf.template.windows.python`.

The default script file that the lauching scripts run is `main.py`. Update the script name assigned to `$pyPath` in `Startup.ps1` to run other script.


## Developer's note

- This repository was split from [supervisor-setting](https://github.com/SinclairQuantumLab/supervisor-setting.git) at commit d1f44233a3bccc7364d7ea797976f2e0ddf3d9c7.