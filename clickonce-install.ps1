<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$setupFullPath = "\\SOMEUNCPATH\setup.exe"
[String]$processName = "SomeClickOne.exe"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function GetScriptDir {
    [String]$scriptDir = $PSScriptRoot
    return $scriptDir
}
function InstallClickOnce {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$setupFullPath,
        [Parameter(Position = 2, Mandatory = $true)]
        [string]$processName
    )

    $pInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $pInfo.FileName = $setupFullPath
    $pInfo.UseShellExecute = $true
    $pInfo.WorkingDirectory = (GetScriptDir)
    $pInfo.WindowStyle = 'Maximized'

    $p = New-Object -TypeName System.Diagnostics.Process
    $p.StartInfo = $pInfo
    $p.Start() | Out-Null

    [double]$timeout = 120.00 #seconds
    $started = Get-Date
    Do {
        Start-Sleep -Milliseconds 500
        [double]$duration = New-TimeSpan -Start $started -End (Get-Date) | Select-Object -ExpandProperty TotalSeconds
    } Until ( [String](Get-Process -Name dfsvc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty MainWindowTitle) -match "Application Install - Security Warning" -or $duration -ge $timeout)

    $wshShell = New-Object -ComObject WScript.Shell
    $wshShell.AppActivate("Application Install - Security Warning") | Out-Null
    $wshShell.SendKeys("%I")
    Do {
        Start-Sleep -Seconds 1
        $launcher = Get-WmiObject -Class Win32_Process -File "Name = '$processName'" -ErrorAction SilentlyContinue
    } Until ($null -ne $launcher)
    
    if ($null -ne $p) { return $p.ExitCode } else { return [int]-1 }
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$exitCode = InstallClickOnce -setupFullPath $setupFullPath -processName $processName
[System.Environment]::Exit($exitCode)
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>