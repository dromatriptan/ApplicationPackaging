<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[Array]$certificates = @(
    [PSCustomObject]@{ Subject = ""; ThumbPrint = "" }
)
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function PullThumbPrintFromCertFile {
    param([Parameter(Position = 1, Mandatory = $true)][String]$certFullPath)
    # This is just a helper function to employ for quickly pulling the ThumbPrint out of a cert file without the need of a UI

    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($certFullPath)
    return $cert.Thumbprint
}
function UninstallCert {
    param(
        [Parameter(Position = 1, Mandatory = $true)][ValidateSet("Computer","User",IgnoreCase = $true)][String]$certStore,
        [Parameter(Position = 2, Mandatory = $true)][ValidateSet("Root","Intermediate","TrustedPeople","TrustedPublisher",IgnoreCase = $true)][String]$certLocation,
        [Parameter(Position = 2, Mandatory = $true)][String]$certSubject,
        [Parameter(Position = 3, Mandatory = $true)][String]$certThumbPrint
    )
    [bool]$successful = $true
    $certPath = $null
    switch ($certStore.ToLower()) {
        "computer" {
            $certPath = "Cert:\Computer\"
        }
        "user" {
            $certPath = "Cert:\User\"
        }
        default { }
    }
    switch ($certLocation.ToLower()) {
        "root" {
            $certPath += "Root"
        }
        "intermediate" {
            $certPath += "CA"
        }
        "trustedpeople" {
            $certPath += "TrustedPeople"
        }
        "trustedpublisher" {
            $certPath += "TrustedPublisher"
        }
        default { }
    }
    if ($null -ne $certPath) {
        $certs = Get-ChildItem -Path $certPath -ErrorAction SilentlyContinue -ErrorVariable certError
        if (-not $certError -and $null -ne $certs) {
            $certsToRemove = $certs | Where-Object { $_.ThumbPrint -eq $certThumbPrint -and $_.Subject -eq $certSubject }
            if ($null -ne $certsToRemove) {
                foreach ($c in $certsToRemove) {
                    $c | Remove-Item -Force -ErrorAction SilentlyContinue -ErrorVariable removalError
                    if ($removalError) { $successful = $false }
                }
            }
        }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[int]$certCount = 0

foreach ($c in $certificates) {
    $uninstalled = UninstallCert -certStore Computer -certLocation Intermediate -certSubject $c.Subject -certThumbPrint $c.ThumbPrint
    if ($uninstalled) { $certCount++ }
}

if ($certCount -eq $certificates.Count) { return $true }

<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>