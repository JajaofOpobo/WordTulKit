<#
.SYNOPSIS
  Read-only environment reporter for Word Toolkit Phase 0.

.DESCRIPTION
  Reports Windows/Word/Visual Studio/.NET/OpenCode facts needed for
  ADR-0001 without changing anything. This script MUST NOT edit registry
  values, install packages, activate Office, change macro/add-in trust
  settings, launch Word, or elevate privileges. All checks are read-only:
  OS properties, file existence, registry READS (Windows only), and
  version probes of already-installed tools.

  Runs on Windows PowerShell 5.1 and cross-platform PowerShell 7+.
  On non-Windows hosts, Windows-only checks report as N/A with the reason.

.EXAMPLE
  pwsh -NoProfile -File scripts/check-environment.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Write-Section {
    param([string]$Name)
    Write-Output ""
    Write-Output "=== $Name ==="
}

function Get-CommandVersion {
    param([string]$Command, [string[]]$VersionArgs = @('--version'))
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if ($null -eq $cmd) { return 'NOT FOUND' }
    try {
        $out = & $Command @VersionArgs 2>&1 | Select-Object -First 2
        return "$($cmd.Source) :: $($out -join ' ')"
    } catch {
        return "$($cmd.Source) :: (version probe failed: $($_.Exception.Message))"
    }
}

Write-Section "OS and architecture"
Write-Output "IsWindows : $IsWindows"
Write-Output "IsLinux   : $IsLinux"
Write-Output "IsMacOS   : $IsMacOS"
Write-Output "OS        : $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
Write-Output "Arch      : $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
Write-Output "Framework : $([System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription)"

Write-Section "Git"
Write-Output (Get-CommandVersion 'git' @('--version'))
try {
    $top = git rev-parse --show-toplevel 2>&1
    Write-Output "Repo top : $top"
    git status -sb 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Output "status   : $_" }
} catch {
    Write-Output "Repo top : (not inside a git repository)"
}

Write-Section ".NET SDK / runtimes (dotnet CLI)"
Write-Output (Get-CommandVersion 'dotnet' @('--info'))
if ($IsWindows) {
    # Read-only registry inspection for .NET Framework release key.
    try {
        $rel = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release -ErrorAction Stop
        Write-Output ".NET Framework release key (read-only): $($rel.Release)"
    } catch {
        Write-Output ".NET Framework release key: NOT DETECTED ($($_.Exception.Message))"
    }
} else {
    Write-Output ".NET Framework registry check: N/A (Windows only)"
}

Write-Section "Visual Studio / build tooling"
Write-Output (Get-CommandVersion 'msbuild' @('-version'))
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if ($IsWindows -and (Test-Path $vsWhere)) {
    try {
        & $vsWhere -products * -format wide 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output $_ }
    } catch {
        Write-Output "vswhere probe failed: $($_.Exception.Message)"
    }
} else {
    Write-Output "vswhere: N/A (Windows with Visual Studio installer only)"
}

Write-Section "Desktop Word (detected WITHOUT launching Word)"
if ($IsWindows) {
    # Read-only registry reads only. Never creates COM objects or starts Word.
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WINWORD.EXE',
        'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
    )
    foreach ($p in $paths) {
        try {
            $item = Get-ItemProperty -Path $p -ErrorAction Stop
            Write-Output "$p :: $item"
        } catch {
            Write-Output "$p :: NOT DETECTED"
        }
    }
    $winword = Get-Command 'winword.exe' -ErrorAction SilentlyContinue
    if ($null -ne $winword) {
        try {
            $ver = (Get-Item $winword.Source).VersionInfo
            Write-Output "WINWORD.EXE :: $($winword.Source) :: $ver"
        } catch {
            Write-Output "WINWORD.EXE :: $($winword.Source) :: (version read failed)"
        }
    } else {
        Write-Output "WINWORD.EXE on PATH: NOT FOUND"
    }
    Write-Output "Launch test: NOT PERFORMED by this script (read-only by design)."
} else {
    Write-Output "Desktop Word checks: N/A (Windows only; this host cannot validate Word integration)."
    Write-Output (Get-CommandVersion 'soffice' @('--version'))
    Write-Output "Note: LibreOffice is not a substitute for desktop Word integration tests."
}

Write-Section "Solution / project files"
try {
    $roots = @((git rev-parse --show-toplevel 2>$null))
    if ([string]::IsNullOrWhiteSpace($roots[0])) { $roots = @((Get-Location).Path) }
    $found = Get-ChildItem -Path $roots[0] -Recurse -Include '*.sln','*.csproj','*.vbproj' -ErrorAction SilentlyContinue | Select-Object -First 20
    if ($found) { $found | ForEach-Object { Write-Output $_.FullName } }
    else { Write-Output "No .sln / .csproj / .vbproj files found (expected in Phase 0)." }
} catch {
    Write-Output "Project file scan failed: $($_.Exception.Message)"
}

Write-Section "Editors and orchestration"
Write-Output (Get-CommandVersion 'code' @('--version'))
Write-Output (Get-CommandVersion 'opencode' @('--version'))

Write-Section "Test tooling (informational)"
Write-Output (Get-CommandVersion 'pytest' @('--version'))
try {
    $docx = python3 -c "import docx; print('python-docx ' + docx.__version__)" 2>&1
    Write-Output $docx
} catch {
    Write-Output "python-docx: NOT DETECTED"
}

Write-Output ""
Write-Output "Done. No changes were made (read-only checks only)."
