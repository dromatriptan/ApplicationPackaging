<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$productName = 'Adobe Acrobat (64-bit)'
[String]$productVendor = 'Adobe'
[Version]$productVersion = '23.01.20064'

[String]$exeName = "Some.exe"
[String]$exeUninstallSwitches = "/SILENT"

[Array]$processesToStop = @("process1.exe", "process2.exe")
[Array]$ServicesToStop = @("service1", "service2")

<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function UninstallMsi {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$appGuid
    )

    $uninstaller = $null

    $uninstallParameters = @{
        FilePath = "${env:WinDir}\System32\msiexec.exe"
        ArgumentList = "/x $appGuid /quiet /norestart"
        Wait = $true
        PassThru = $true
        WindowStyle = "Hidden"
    }

    $uninstaller = Start-Process @uninstallParameters

    if ($null -ne $uninstaller) {
        return [int]($uninstaller.ExitCode)
    }
    else {
        return [int](-1)
    }
}
function UninstallExe {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$exePath,
        [Parameter(Position = 2, Mandatory = $true)]
        [String]$exeOptions
    )

    $uninstaller = $null

    $uninstallParameters = @{
        FilePath = $filePath
        ArgumentList = $exeOptions
        Wait = $true
        PassThru = $true
        WindowStyle = "Hidden"
    }

    $uninstaller = Start-Process @uninstallParameters

    if ($null -ne $uninstaller) {
        return [int]($uninstaller.ExitCode)
    }
    else {
        return [int](-1)
    }
}
function StopProcess {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$processName
    )

    [bool]$stopped = $true
    $name = $processName.Split('.')[0]
    $processIds = Get-Process -Name $name -ErrorAction SilentlyContinue -ErrorVariable GetError | Select-Object -ExpandProperty Id
    foreach ($id in $processIds) {
        Stop-Process -Id $id -Force -ErrorAction SilentlyContinue -ErrorVariable stopError
        if ($stopError) { $stopped = $false }

    }
    return $stopped
}
function StopService {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$serviceName
    )

    [bool]$stopped = $true
    $name = $serviceName.Split('.')[0]
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue -ErrorVariable GetError
    if ($null -ne $service) {
        Stop-Service -InputObject $service -Force -ErrorAction SilentlyContinue -ErrorVariable stopError
        if ($stopError) { $stopped = $false }

    }
    return $stopped
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
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$installations = GetInstallations -hive LocalMachine | Where-Object { $_.Name -like $productName -and $_.vendor -like $productVendor }

if ($null -ne $installations) {
    # Stop any services related to any existing instance of this app BEFORE attempting the installation
    [bool]$serivcesStopped = $true
    $ServicesToStop.ForEach({ if ( (StopService -serviceName $_) -eq $false ) {$serivcesStopped = $false } })
    
    # Stop any processes related to any existing instance of this app BEFORE attempting the installation
    [bool]$processesStopped = $true
    $processesToStop.ForEach({ if ( (StopProcess -processName $_) -eq $false) { $processesStopped = $false } })
}

foreach ($installation in $installations) {
    [Version]$version = $installation | Select-Object -ExpandProperty Version
    if ($version -ge $productVersion -and $version -lt [Version]"$($productVersion.Major + 1).0.0.0") {
        # If we get this far, the application is already installed. 
        if ($installation.uninstallString -match "msiexec") {
            $exitCode = UninstallMsi -appGuid $installation.path
        }
        else {
            $index = $($installation.UninstallString).IndexOf('.exe')
            $uninstallString = $($installation.UninstallString).SubString(0,[int]($index +4)).Replace('"','')
            $exitCode = UninstallExe -exePath $uninstallString -exeOptions "/VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /NORESTART"
        }
    }
}
if ($null -ne $exitCode) { [System.Environment]::Exit($exitCode) } else { [System.Environment]::Exit(-2) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>