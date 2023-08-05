<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$xlamTitle = "Bidfx-public-Excel"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function DetectXlam {
    param (
        [Parameter(Position =  1, Mandatory = $true)]
        [String]$xlamTitle
    )
    [bool]$successful = $false
    Get-Process -Name Excel -ErrorAction SilentlyContinue | Stop-Process -Force
    try {
        $xl = New-Object -ComObject excel.application
        $addins = $xl.addins | Where-Object { $_.Title -match $xlamTitle }
        $xl.Quit()
        Get-Process -name excel -ErrorAction SilentlyContinue | Stop-Process
        if ($null -ne $addins) { $successful = $true }
    }
    catch {
        <# Just catch the exception generated from COM #>
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$detected = DetectXlam -xlamTitle $xlamTitle
return $detected
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>