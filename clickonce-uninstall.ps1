<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$productName = 'SOME CLICKONCE APP NAME'
[String]$productVendor = 'Adobe'
[Version]$productVersion = '23.01.20064'
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function GetScriptDir {
    [String]$scriptDir = $PSScriptRoot
    return $scriptDir
}
function GetInstallations {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateSet("LocalMachine", "CurrentUser", IgnoreCase = $true)]
        [Microsoft.Win32.RegistryHive]$hive
    )

    $keyPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    $productList = @()
    $products = @{}

    $reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, [Microsoft.Win32.RegistryView]::Registry32)
    $key = $reg.OpenSubKey($keyPath)
    $uninstalls = $key.GetSubKeyNames()
    foreach ($uninstall in $uninstalls) {
        $product = $reg.OpenSubKey("$keyPath\$uninstall")
        $displayName = $product.GetValue("DisplayName")
        $displayVersion = $product.GetValue("DisplayVersion")
        if ($displayName.length -gt 0 -and $displayVersion -gt 0) {
            if (-not $products.ContainsKey($displayName)) {
                $products.Add($displayName, $displayVersion)
                $productDetails = [PSCustomObject]@{
                    Path            = [String]$(Split-Path -Path $product.Name -Leaf)
                    Vendor          = [String]$($product.GetValue('Publisher'))
                    Name            = [String]$($product.GetValue('DisplayName'))
                    Version         = [String]$($product.GetValue('DisplayVersion'))
                    InstallDate     = [String]$($product.GetValue('InstallDate'))
                    InstallSource   = [String]$($product.GetValue('InstallSource'))
                    UninstallString = [String]$($product.GetValue('UninstallString'))
                }
                $productList += $productDetails
            }
        }
    }

    $uninstalls = $null
    $key.Close()
    $reg.Close()

    $reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, [Microsoft.Win32.RegistryView]::Registry64)
    $key = $reg.OpenSubKey($keyPath)
    $uninstalls = $key.GetSubKeyNames()
    foreach ($uninstall in $uninstalls) {
        $product = $reg.OpenSubKey("$keyPath\$uninstall")
        $displayName = $product.GetValue("DisplayName")
        $displayVersion = $product.GetValue("DisplayVersion")
        if ($displayName.length -gt 0 -and $displayVersion -gt 0) {
            if (-not $products.ContainsKey($displayName)) {
                $products.Add($displayName, $displayVersion)
                $productDetails = [PSCustomObject]@{
                    Path            = [String]$(Split-Path -Path $product.Name -Leaf)
                    Vendor          = [String]$($product.GetValue('Publisher'))
                    Name            = [String]$($product.GetValue('DisplayName'))
                    Version         = [String]$($product.GetValue('DisplayVersion'))
                    InstallDate     = [String]$($product.GetValue('InstallDate'))
                    InstallSource   = [String]$($product.GetValue('InstallSource'))
                    UninstallString = [String]$($product.GetValue('UninstallString'))
                }
                $productList += $productDetails
            }
        }
    }

    $uninstalls = $null
    $key.Close()
    $reg.Close()

    return $productList
}
function UninstallClickOnce {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$productName,
        [Parameter(Position = 2, Mandatory = $true)]
        [string]$argumentList
    )

    $pInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $pInfo.FileName = "rundll32.exe"
    $pInfo.Arguments = $argumentList
    $pInfo.UseShellExecute = $false
    $pInfo.WorkingDirectory = (GetScriptDir)
    $pInfo.Verb = 'runasuser'
    $pInfo.WindowStyle = 'Maximized'

    $p = New-Object -TypeName System.Diagnostics.Process
    $p.StartInfo = $pInfo
    $p.Start() | Out-Null

    [double]$timeout = 120.00 #seconds
    $started = Get-Date
    Do {
        Start-Sleep -Milliseconds 500
        [double]$duration = New-TimeSpan -Start $started -End (Get-Date) | Select-Object -ExpandProperty TotalSeconds
    } Until ( [String](Get-Process -Name dfsvc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty MainWindowTitle) -like "$productName*" -or $duration -ge $timeout)

    $wshShell = New-Object -ComObject WScript.Shell
    $wshShell.AppActivate("Maintenance") | Out-Null
    $wshShell.SendKeys("%O")

    Start-Sleep -Seconds 10 #Took the lazy way out here.
    if ($null -ne $p) { return $p.ExitCode } else { return [int]-1 }
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$installations = GetInstallations -hive CurrentUser | Where-Object { $_.Name -like $productName -and $_.vendor -like $productVendor }

foreach ($installation in $installations) {
    [Version]$version = $installation | Select-Object -ExpandProperty Version
    if ($version -ge $productVersion -and $version -lt [Version]"$($productVersion.Major + 1).0.0.0") {
        # If we get this far, the application is already installed. 
        if ($installation.uninstallString -match "msiexec") {
            #$exitCode = UninstallMsi -appGuid $installation.path
        }
        elseif ($installation.UninstallString -match "rundll32") {
            [String]$argumentList = $installation.UninstallString.Replace("rundll32.exe","").Trim()
            $exitCode = UninstallClickOnce -argumentList $argumentList
        }
        else {
            #$index = $($installation.UninstallString).IndexOf('.exe')
            #$uninstallString = $($installation.UninstallString).SubString(0,[int]($index +4)).Replace('"','')
            #$exitCode = UninstallExe -exePath $uninstallString -exeOptions "/VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /NORESTART"
        }
    }
}
if ($null -ne $exitCode) { [System.Environment]::Exit($exitCode) } else { [System.Environment]::Exit(-1) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>