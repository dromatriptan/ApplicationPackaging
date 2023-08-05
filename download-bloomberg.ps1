<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$mainUrl = 'https://www.bloomberg.com/professional/support/software-updates/'
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function GetScriptDir {
    [String]$scriptDir = $PSScriptRoot
    return $scriptDir
}

function DownloadBloomberg {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$uri
    )
    [String]$installerName = $null
    [String]$scriptDir = GetScriptDir
    $webRequest = Invoke-WebRequest -UseBasicParsing -Uri $uri
    if ($webRequest.StatusCode -eq 200) {
        $downloadUrl = $webRequest.links | `
        Where-Object {
            $_.href -like '*sotr*.exe' -and `
            $_.href -notlike '*sotr*_lite.exe' -and `
            $_.href -notlike '*sotr*_upgrade.exe'
        } | `
        Select-Object -ExpandProperty href -Unique -First 1

        if ($null -ne $downloadUrl) {
            [Array]$tmpArray = $downloadUrl.Split('/')
            [int]$tmpIndex = $tmpArray.GetUpperBound(0)
            [String]$uncomfirmedName = $tmpArray[$tmpIndex]
            [String]$installerFullPath = Join-Path -Path $scriptDir -ChildPath $uncomfirmedName

            if ( (Test-Path -Path $installerFullPath -PathType Leaf -ErrorAction SilentlyContinue) -eq $true) {
                $installerName = $uncomfirmedName
            }
            else {
                Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $installerFullPath
                if ( (Test-Path -Path $installerFullPath -PathType Leaf -ErrorAction SilentlyContinue) -eq $true ) {
                    $installerName = $uncomfirmedName
                }
            }
        }
    }
    return $installerName
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$installerName = DownloadBloomberg -uri $mainUrl
[String]$scriptDir = GetScriptDir
[String]$installerHash = $null
[String]$installerVersion = $null
if ($null -ne $installerName) {
    $installerFile = Get-ChildItem -Path (Join-Path -Path $scriptDir -ChildPath $installerName) -ErrorAction SilentlyContinue
    if ($null -ne $installerFile) {
        $installerHash = Get-FileHash -Path $installerFile.FullName -Algorithm MD5 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Hash -ErrorAction SilentlyContinue
        $installerVersion = $installerName.Replace('sotr','').Replace('.exe','').Replace('_','.')
    }
}

$results = @()
$results += [PSCustomObject]@{
    Date = [String](Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    InstallerPath = $scriptDir
    InstallerName = $installerName
    InstallerHash = $installerHash
    InstallerVersion = $installerVersion
}

if ( (Test-Path -Path "$scriptDir\bloomberg-downloads.json" -PathType Leaf) -eq $True ) {
    # I need to compare the json file to a pre-existing schema to err on the safe side, but that is still not done yet.
    $results += Get-Content -Path "$scriptDir\bloomber-downloads.json" | ConvertFrom-Json
}

$results | ConvertTo-Json -Depth 99 | Out-File -FilePath "$scriptDir\bloomberg-downloads.json" -Encoding utf8 -Force -ErrorAction SilentlyContinue -ErrorVariable WriteError
if (-not $writeError) { [System.Environment]::Exit(0) } else { [System.Environment]::Exit(0) }