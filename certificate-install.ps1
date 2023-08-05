<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$certName = "Some.cer"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
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
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$certInstalled = InstallCertificate -fileName $certName
if ($certInstalled) { [System.Environment]::Exit(0) } else { [System.Environment]::Exit(0) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>