<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$xlamTitle = "Bidfx-public-Excel"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function UninstallXlam {
    param (
        [Parameter(Position =  1, Mandatory = $true)]
        [String]$xlamTitle
    )
    [bool]$successful = $false
    Get-Process -Name Excel -ErrorAction SilentlyContinue | Stop-Process -Force
    try {
        $xl = New-Object -ComObject excel.application
        $xl.addins | Where-Object { $_.Title -match $xlamTitle } | ForEach-Object { $_.Installed = $false; Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue -ErrorVariable RemovalError }
        $xl.Quit()
        Get-Process -name excel -ErrorAction SilentlyContinue | Stop-Process
        $successful = $true
    }
    catch {
        <# Just catch the exception generated from COM #>
    }
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$installed = InstallXlam -xlamPath $xlamFullPath -xlamTitle $xlamTitle
return $installed
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>