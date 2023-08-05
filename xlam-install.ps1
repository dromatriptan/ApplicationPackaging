<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$xlamFullPath = "${env:ProgramFiles}\BidFx\BidFx Excel\Bidfx-public-excel.xlam"
[String]$xlamTitle = "Bidfx-public-Excel"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function InstallXlam {
    param (
        [Parameter(Position =  1, Mandatory = $true)]
        [String]$xlamPath,
        [Parameter(Position =  2, Mandatory = $true)]
        [String]$xlamTitle
    )
    
    [bool]$successful = $false
    Copy-Item -Path $xlamPath -Destination "${env:AppData}\Microsoft\Adins" -Force -Error SilentlyContinue -ErrorVariable copyError
    if (-not $copyError) {
        try {
            $xl = New-Object -ComObject excel.application
            $xl.addins | Where-Object { $_.Title -match $xlamTitle } | ForEach-Object { $_.Installed = $true }
            $xl.Quit()
            Get-Process -name excel -ErrorAction SilentlyContinue | Stop-Process
            $successful = $true
        }
        catch {
            <# Just catch the exception generated from COM #>
        }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$installed = InstallXlam -xlamPath $xlamFullPath -xlamTitle $xlamTitle
if ($installed) { [System.Environment]::Exit(0) } else { [System.Environment]::Exit(-1) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>