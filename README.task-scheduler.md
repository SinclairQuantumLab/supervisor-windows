# `supervisor` in Windows

This repo contains a `uv` project and templates to run [`supervisor-win`](https://pypi.org/project/supervisor-win/) on Windows.


## Table of Contents

1. [How to use `supervisor`](#how-to-use-supervisor)
2. [Adding an app to `supervisor`](#adding-an-app-to-supervisor)
3. [Quick installation with `uv`](#quick-installation-with-uv)
4. [One-shot setup script](#one-shot-setup-script)
5. [Task Scheduler GUI setup](#task-scheduler-gui-setup)
6. [Uninstalling `supervisor`](#uninstalling-supervisor)
7. [Remove an old Windows Service install](#remove-an-old-windows-service-install)
8. [Developer's note](#developers-note)

## How to use `supervisor`

### Startup `supervisor`

The `supervisor` task in Windows Task Scheduler should run automatically after starting up the computer and logging into the Windows account.

To startup `supervisor` task manually, run the commandline below in a Powershell terminal to startup `supervisord` installed as a task in Windows Task Scheduler:

   ```powershell
   Start-ScheduledTask -TaskName "supervisor"
   ```

### Monitoring & Managing processes

There are Web UI and CLI to monitor and manage the processes registered in `supervisor`.
They will requires logging in; use the `username` and `password` set in the `[inet_http_server]` section in `supervisord.conf` file.

#### Web UI

Open `http://localhost:9001` in a browser to use the Supervisor web UI and it will show the statuses of the registered processes and control them.

[`multivisor`](https://github.com/SinclairQuantumLab/multivisor-web.git) provides a nice centeralized monitoring and control Web dashboard if the `supervisor` is setup for it (see the relevant step in [Quick installation with uv](#quick-installation-with-uv) section) and registered to a `multivisor` server.

#### CLI

In a Powershell terminal, run:

```powershell
supervisorctl -u "<USERNAME>" -p "<PASSWORD>"
```

One can ether establish a supervisor control session with `supervisor>` prompt without `[option]` listed below, or directly call the below `supervisorctl` commands without getting into the `supervisor` session as like the example below:

```powershell
supervisorctl -u "<USERNAME>" -p "<PASSWORD>" status
```

##### `supervisorctl` commands

Check the statuses of registered processes:

```powershell
supervisor> status
```

Start, stop, or restart one app:

```powershell
supervisor> start myapp
supervisor> stop myapp
supervisor> restart myapp
```

### Shutdown `supervisor`

   ```powershell
   Stop-ScheduledTask -TaskName "supervisor"
   ```

   > **NOTE**: `supervisorctl`'s `shutdown` command doesn't work in `supervisor-win==4.7.0`.

## Adding an app to `supervisor`

1. Copy the app config template in `%USERPROFILE%\Projects\supervisor\conf.d\` folder:

   ```powershell
   cd $HOME\Projects\supervisor
   Copy-Item -LiteralPath ".\conf.d\[APPNAME].conf.template" -Destination ".\conf.d\<APPNAME>.conf"
   ```

   Replace: `<APPNAME>` with the name of the app in `supervisor`.

2. Edit the `.conf` above.

   Replace:

   - `<APPNAME>` with the Supervisor app name
   - `command=` with the real app startup command

      For a Python app, 
      1. copy the `python\Startup.ps1` in the app project folder and configure it; Espcially, update the location to the python script file to run in `$pyPath` variable.
      2. In the `.conf` file, set the below:
      ```
      command="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%(ENV_USERPROFILE)s\Projects\%(program_name)s\Startup.ps1"
      ```
      In `supervisor`, `%(ENV_USERPROFILE)s` and `%(program_name)s` refer to the `%USERPROFILE` and the app's name set in the `.conf` file.

   Add further configuration item found in https://supervisord.org/configuration.html#program-x-section-settings or https://supervisord.org/configuration.html#group-x-section-settings as needed.

   > **NOTE**: Some of the configuration items in the `supervisor` are not implemented
;     in `supervisor-win` and should be added in trial-and-error manner.

3. Update `supervisor` with the new `.conf` file (see [CLI](#cli) section above):

   ```powershell
   supervisorctl -u "<USERNAME>" -p "<PASSWORD>" update
   ```

   Check if the new app appears in `supervisor` interface; see [Monitoring & Managing processes](#monitoring--managing-processes)

## Quick installation with `uv`

If this computer already has an old `supervisor-win` installed as a Windows Service, remove it first. See [Remove an old Windows Service install](#remove-an-old-windows-service-install) section.

1. If `uv` has not been installed, do it following [the official installation guide](https://docs.astral.sh/uv/getting-started/installation/).
   **Close and reopen PowerShell after installing `uv`**.

2. Open PowerShell and clone this repo in `%USERPROFILE\Projects\` folder:

   ```powershell
   cd $HOME\Projects
   git clone https://github.com/SinclairQuantumLab/supervisor-windows.git supervisor
   ```

3. Go to the created folder and run `uv sync`:

   ```powershell
   cd supervisor
   uv sync
   ```

4. Make `supervisorctl` available from PowerShell.

   ```powershell
   Start-Process powershell -Verb RunAs -ArgumentList '-NoExit -ExecutionPolicy Bypass -Command New-Item -ItemType SymbolicLink -Path $HOME\.local\bin\supervisorctl.exe -Target $HOME\Projects\supervisor\.venv\Scripts\supervisorctl.exe -Force'
   ```

   > **NOTE**: This opens a separate Administrator PowerShell window to create a symlink.

5. Create the `supervisord` config file from the template:

   ```powershell
   Copy-Item .\supervisord.conf.template .\supervisord.conf
   ```

6. Open `supervisord.conf` file and replace the `<PASSWORD>` placeholder with our usual password.

7. Register `supervisord` as a Task Scheduler task for the current user. This opens a separate Administrator PowerShell window for Task Scheduler setup:

   ```powershell
   Start-Process powershell -Verb RunAs -ArgumentList '-NoExit -ExecutionPolicy Bypass -Command cd $HOME\Projects\supervisor; powershell -ExecutionPolicy Bypass -File .\mount-supervisord-task-scheduler.ps1'
   ```

   This creates a Task Scheduler task named `supervisor`.

8. (Optional) regiser the installed `supervisor` to `multivisor`.

   ```powershell
   uv run python -c "from multivisor.rpc import make_rpc_interface; print('RPC import OK')"
   ```

   If using Multivisor, confirm the `[rpcinterface:multivisor]` section in `supervisord.conf` and open the required firewall port for the environment.

That's it. `supervisord` should now start automatically when this Windows user logs in.

## One-shot setup script

Copy and paste the below script to PowerShell opened with **Run as Administrator**.

```powershell
# install supervisor-windows in %%
cd "$HOME\Projects"
git clone https://github.com/SinclairQuantumLab/supervisor-windows.git supervisor
cd supervisor
uv sync
# create symbolic link for supervisorctl.exe in user `bin` folder
New-Item -ItemType SymbolicLink -Path "$HOME\.local\bin\supervisorctl.exe" -Target "$HOME\Projects\supervisor\.venv\Scripts\supervisorctl.exe" -Force
# create `supervisord.conf` file from the template
Copy-Item .\supervisord.conf.template .\supervisord.conf -Force
# create `supervisor` task in Windows Task Scheduler to run supervisord.exe
powershell -ExecutionPolicy Bypass -File .\mount-supervisord-task-scheduler.ps1
```

**Make sure to replace the `<PASSWORD>` placeholder with our usual password in the `supervisord.conf` file.**

## Task Scheduler GUI setup

While the PowerShell script in [Quick installation with uv](#quick-installation-with-uv) provides a quick way to setup `supervisor` task, the GUI of Windows Task Schedular is also useful because it shows the Windows settings directly.

1. Open Task Scheduler: Run (Win+R) -> taskschd.msc

2. Click **Create Task...**.

3. In the **General** tab:

   - Name: `supervisor`
   - User account: the Windows desktop user
   - Select **Run only when user is logged on**
   - Select **Run with highest privileges**

4. In the **Triggers** tab:

   - Click **New...**
   - Begin the task: **At log on**
   - Specific user: the same Windows desktop user

5. In the **Actions** tab:

   - Click **New...**
   - Action: **Start a program**
   - Program/script:

     ```powershell
     powershell.exe
     ```

   - Add arguments:

     ```powershell
     -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Users\<USERNAME>\Projects\supervisor\Startup_supervisord.ps1"
     ```

   - Start in:

     ```powershell
     C:\Users\<USERNAME>\Projects\supervisor
     ```

6. In the **Conditions** tab:

   - Disable power restrictions if the task should run on battery.
   - Keep network conditions only if the supervised apps need network availability before startup.

7. In the **Settings** tab:

   - Enable **Allow task to be run on demand**
   - Enable **Run task as soon as possible after a scheduled start is missed**
   - Optionally enable restart on failure

8. Right-click the task and click **Run**.

## Uninstalling `supervisor`

You many need to open a PowerShell terminal with **Run as Administrator** for some of the steps below.

1. [Shutdown running `supervisor` instance](#shutdown-supervisor), if any.
2. Delete `supervisor` task created in Windows Task Scheduler in its GUI or, equivalently, by running:

   ```powershell
   Unregister-ScheduledTask -TaskName "supervisor" -Confirm:$false
   ```

3. Remove `supervisor` project folder:

   ```powershell
   Remove-Item -Recurse -Force "$HOME\Projects\supervisor"
   ```

4. Remove the symlink to `supervisorctl.exe` in the user bin folder:

   ```powershell
   Remove-Item -Force "$HOME\.local\bin\supervisorctl.exe"
   ```

## Remove an old Windows Service install

Use this only if the computer already has `supervisord` installed as a Windows Service.

Open PowerShell with **Run as Administrator** for this section.

Check the old service `Name`:

```powershell
Get-Service *Supervisor*
```

Note the value from the `Name` column. In this example, the service name is `Supervisor Pyv3.11`.

Kill the process started by the old Windows Service:

```powershell
cd "$HOME\Projects\supervisor"
powershell -ExecutionPolicy Bypass -File .\kill-service.ps1 "Supervisor Pyv3.11" -Yes
```

Delete the old Windows Service:

```powershell
sc.exe delete "Supervisor Pyv3.11"
```

## Developer's note

- This repository was split from [supervisor-setting](https://github.com/SinclairQuantumLab/supervisor-setting.git) Github repo at commit d1f44233a3bccc7364d7ea797976f2e0ddf3d9c7.

- The high-level flow of launching `supervisor` and registered apps:

   > Task Scheduler -> Startup_supervisord.ps1 -> supervisord -> apps in conf.d/*.conf

- Why moved from Windows Service to Task Scheduler to run `supervisord.exe`?

   A normal Windows Service runs in Session 0. The logged-in user's desktop is usually Session 1 or higher.
   Running `supervisord` from Task Scheduler at logon avoids the common problem where a service-launched GUI process is not part of the visible desktop session.
   This matters when child programs may need:

  - GUI windows
  - the logged-in user's environment
  - access to the visible desktop session
  - behavior closer to a normal background desktop app
