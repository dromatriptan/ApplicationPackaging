<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$productName = 'Adobe Acrobat (64-bit)'
[String]$productVendor = 'Adobe'
[Version]$productVersion = '23.01.20064'
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
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
$isInstalled = $false
$installations = GetInstallations -hive LocalMachine | Where-Object { $_.Name -like $productName -and $_.vendor -like $productVendor }

foreach ($installation in $installations) {
    [Version]$version = $installation | Select-Object -ExpandProperty Version
    if ($version -ge $productVersion -and $version -lt [Version]"$($productVersion.Major + 1).0.0.0") {
        # If we get this far, the application is already installed. 
        $isInstalled = $true
    }
}
if ($isInstalled) { return $true }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>