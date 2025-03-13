function Test-IsElevated {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-Elevated {
    param (
        [string]$ScriptBlock
    )
    $scriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
    Set-Content -Path $scriptPath -Value $ScriptBlock
    Write-Host "Requesting elevated PowerShell..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
}

function Add-FirewallRule {
    param (
        [int]$Port
    )

    if (-not (Test-IsElevated)) {
        Write-Host "Not elevated. Requesting elevated PowerShell to add firewall rule for port $Port..."
        Start-Elevated -ScriptBlock "Import-Module '$($MyInvocation.MyCommand.Module.Path)'; Add-FirewallRule -Port $Port; Read-Host 'Press Enter to exit...'"
        return
    }

    $ruleName = "WSL2_Port_$Port"
    if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
        Write-Host "Creating firewall rule for port $Port..."
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port
        Write-Host "Created firewall rule for port $Port"
    } else {
        Write-Host "Firewall rule for port $Port already exists."
    }
}

function Remove-FirewallRule {
    param (
        [int]$Port
    )

    if (-not (Test-IsElevated)) {
        Write-Host "Not elevated. Requesting elevated PowerShell to remove firewall rule for port $Port..."
        Start-Elevated -ScriptBlock "Import-Module '$($MyInvocation.MyCommand.Module.Path)'; Remove-FirewallRule -Port $Port; Read-Host 'Press Enter to exit...'"
        return
    }

    $ruleName = "WSL2_Port_$Port"
    Write-Host "Removing firewall rule for port $Port..."
    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    Write-Host "Removed firewall rule for port $Port"
}

function Add-WSLForward {
    param (
        [int]$ListenPort,
        [int]$ConnectPort = $ListenPort,
        [switch]$NoFirewallRule
    )

    if (-not $PSBoundParameters.ContainsKey('ListenPort') -or $ListenPort -eq 0) {
        Write-Host "Usage: WSLForward -Command add -ListenPort <port> [-ConnectPort <port>] [-NoFirewallRule]"
        return
    }

    if (-not (Test-IsElevated)) {
        Write-Host "Not elevated. Requesting elevated PowerShell to add WSL forward for listen port $ListenPort and connect port $ConnectPort..."
        $noFirewallRuleParam = if ($NoFirewallRule) { "-NoFirewallRule" } else { "" }
        Start-Elevated -ScriptBlock "Import-Module '$($MyInvocation.MyCommand.Module.Path)'; Add-WSLForward -ListenPort $ListenPort -ConnectPort $ConnectPort $noFirewallRuleParam; Read-Host 'Press Enter to exit...'"
        return
    }

    # Fetch the WSL IP dynamically
    Write-Host "Fetching WSL IP address..."
    $wslIp = ((wsl hostname -I).Trim() -split '\s+')[0]

    # Construct and execute the netsh command
    $command = "netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=$ListenPort connectaddress=$wslIp connectport=$ConnectPort"
    Write-Host "Executing: $command"
    Invoke-Expression $command

    if (-not $NoFirewallRule) {
        Write-Host "Adding firewall rule for port $ListenPort..."
        Add-FirewallRule -Port $ListenPort
    }
}

function Remove-WSLForward {
    param (
        [int]$ListenPort
    )

    if (-not $PSBoundParameters.ContainsKey('ListenPort') -or $ListenPort -eq 0) {
        Write-Host "Usage: WSLForward -Command remove -ListenPort <port>"
        return
    }

    if (-not (Test-IsElevated)) {
        Write-Host "Not elevated. Requesting elevated PowerShell to remove WSL forward for listen port $ListenPort..."
        Start-Elevated -ScriptBlock "Import-Module '$($MyInvocation.MyCommand.Module.Path)'; Remove-WSLForward -ListenPort $ListenPort; Read-Host 'Press Enter to exit...'"
        return
    }

    # Construct and execute the netsh command
    $command = "netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=$ListenPort"
    Write-Host "Executing: $command"
    Invoke-Expression $command

    Write-Host "Removing firewall rule for port $ListenPort..."
    Remove-FirewallRule -Port $ListenPort
}

function List-WSLForward {
    Write-Host "Listing all WSL port forwards..."
    netsh interface portproxy show all
}

function WSLForward {
    param (
        [ValidateSet("add", "remove", "list")]
        [string]$Command,
        [int]$ListenPort,
        [int]$ConnectPort,
        [switch]$NoFirewallRule
    )

    switch ($Command) {
        "add" {
            Add-WSLForward -ListenPort $ListenPort -ConnectPort $ConnectPort -NoFirewallRule:$NoFirewallRule
        }
        "remove" {
            Remove-WSLForward -ListenPort $ListenPort
        }
        "list" {
            List-WSLForward
        }
        default {
            Write-Host "Usage: WSLForward -Command <add|remove|list> [-ListenPort <port>] [-ConnectPort <port>] [-NoFirewallRule]"
        }
    }
}

Export-ModuleMember -Function WSLForward, Add-WSLForward, Remove-WSLForward, List-WSLForward
