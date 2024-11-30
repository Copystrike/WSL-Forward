# WSL-Forward

This PowerShell module provides a set of functions to manage Windows Subsystem for Linux (WSL) port forwarding and firewall rules. The module includes functions to add, remove, and list port forwards, as well as to add and remove firewall rules.

## Table of Contents
- [Example Use Case](#example-use-case)
- [Usage Examples](#usage-examples)
- [Installation](#installation)
- [Commands](#commands)
- [Notes](#notes)
- [Exported Functions](#exported-functions)

## Example Use Case

1. If you're developing a web app on WSL and want to test it on your phone, you can forward the web server port (e.g., 3000) from WSL to your host, then access the app via the host machine’s IP address.
2. If you want to expose a shell or command-line interface running on WSL to external devices via port 21, you can forward this port for access.

## Usage Examples

1. **Add a WSL Port Forward**
   ```powershell
   WSLForward -Command add -ListenPort 3000 -ConnectPort 3000 -NoFirewallRule
   ```

1. **Add a WSL Port Forward without adding a firewall rule**
   ```powershell
   WSLForward -Command add -ListenPort 3000 -ConnectPort 3000 -NoFirewallRule
   ```

2. **Remove a WSL Port Forward**
   ```powershell
   WSLForward -Command remove -ListenPort 3000
   ```

3. **List All WSL Port Forwards**
   ```powershell
   WSLForward -Command list
   ```
   
## Installation

To install the `WSLTools` module on your system, follow these steps:

### Quick One-Liner (Recommended)

The easiest way to install and automatically import the module in every PowerShell session is to run the following command:

```powershell
iex "& { $(Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Copystrike/WSL-Forward/master/Install-WSLTools.ps1') }"
```

This command will:

Download and install the WSLTools module.
Automatically import it in your current session.
Add the import to your PowerShell profile, ensuring it loads automatically in future sessions.

### Steps to Install the Module manually

1. **Download the Module**
   - Save the `WSLTools.psm1` file to a directory on your system. For example:  
     `C:/Users/yourusername/PowerShell/Modules/WSLTools/`.

2. **Import the Module**
   - Open PowerShell and run the following command to import the module:
     ```powershell
     Import-Module 'C:/Users/yourusername/PowerShell/Modules/WSLTools/WSLTools.psm1'
     ```

   Alternatively, to have the module imported automatically in every PowerShell session, add the following line to your PowerShell profile script (`$PROFILE`):

   ```powershell
   if (Test-Path 'C:/Users/yourusername/PowerShell/Modules/WSLTools/WSLTools.psm1') { Import-Module 'C:/Users/yourusername/PowerShell/Modules/WSLTools/WSLTools.psm1' }
   ```

   This will ensure that the module is loaded automatically each time you open PowerShell.

3. **Verify the Module**
   - To verify that the module has been imported correctly, run:
     ```powershell
     Get-Module -Name WSLTools -ListAvailable
     ```

4. **Use the Functions**
   - You can now use the functions provided by the module as described in the usage examples above.

By following these steps, you will have the `WSLTools` module installed and ready to use on your system.

## Commands

1. **Add-WSLForward**
   - Adds a port forward from the host to the WSL instance.
   - Parameters:
     - `ListenPort` (int): The port number on the host to listen on.
     - `ConnectPort` (int, optional): The port number on the WSL instance to connect to. Defaults to the same as `ListenPort`.
     - `NoFirewallRule` (switch): If specified, will not add a firewall rule for the `ListenPort`.

2. **Remove-WSLForward**
   - Removes a port forward from the host to the WSL instance.
   - Parameters:
     - `ListenPort` (int): The port number on the host to stop listening on.

3. **List-WSLForward**
   - Lists all current port forwards from the host to the WSL instance.

4. **WSLForward**
   - Main function to manage WSL port forwards.
   - Parameters:
     - `Command` (string): The command to execute (`add`, `remove`, `list`).

## Notes

- The module automatically requests elevated privileges when necessary.
- The `Start-Elevated` function ensures that the elevated process does not close immediately after execution, allowing you to see the output and any potential errors.
- The `Read-Host 'Press Enter to exit...'` command is used to pause the elevated PowerShell window, so you can review the output before it closes.

## Exported Functions

- `WSLForward`
- `Add-WSLForward`
- `Remove-WSLForward`
- `List-WSLForward`
```

### Key Changes:
- The **quick one-liner** for adding the module to the PowerShell profile is now listed **first** in the **Add to PowerShell Profile** section as the easiest method.
- The longer, more detailed version is still available for users who prefer it.
