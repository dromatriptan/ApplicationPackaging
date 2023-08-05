<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$certName = "Some.cer"
[String]$uri = "https://toolkit.canalyst.com/releases/excel-addin/CanalystToolkitAddin.vsto"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function GetScriptDir {
    [String]$scriptDir = $PSScriptRoot
    return $scriptDir
}
function InstallCertificate {
    param( [Parameter(Position = 1, Mandatory = $true)][String]$fileName )

    [bool]$successful = $false
    [String]$scriptDir = GetScriptDir
    [String]$certFullPath = Join-Path -Path $scriptDir -ChildPath $fileName

    $certFile = Get-ChildItem -Path $certFullPath -ErrorAction SilentlyContinue -ErrorVariable fileError

    if (-not $fileError -and $null -ne $certFile) {
        $results = Import-Certificate -FilePath $certFile.FullName -CertStoreLocation 'Cert:\CurrentUser\TrustedPublisher'
        $installedCerts = Get-ChildItem -Path 'Cert:\CurrentUser\TrustedPublisher' -ErrorAction SilentlyContinue -ErrorVariable certError
        if (-not $certError -and $null -ne $installedCerts) {
            $returnValue = $installedCerts | Where-Object -Property ThumbPrint -eq $results.ThumbPrint | Select-Object -ExpandProperty Subject
            if ($null -ne $returnValue) { $successful = $true }
        }
    }
    return $successful
}
function InstallVsto {
    param([Parameter(Position = 1, Mandatory = $true)][String]$uri)

    $installer = $null
    $vstoFullPath = "${env:CommonProgramFiles}\Microsoft Shared\VSTO\10.0\VSTOInstaller.exe"
    if ( (Test-Path -Path $vstoFullPath -PathType Leaf) -eq $true) {
        $installParameters = @{
            FilePath = $vstoFullPath
            ArgumentList = "/install `"$uri`" /silent"
            WindowStyle = "Hidden"
            Wait = $true
            PassThru = $true
        }
        $installer = Start-Process @installParameters
    }
    if ($null -ne $installer) { return $installer.ExitCode } else { return [int]-1 }
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$certInstalled = InstallCertificate -fileName $certName
if ($certInstalled) {
    $vstoInstalled = InstallVsto -uri $uri
    [System.Environment]::Exit($vstoInstalled)
} 
else {
    [System.Environment]::Exit(-2)
}