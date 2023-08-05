param(
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateSet("ToB64","ToIco",IgnoreCase = $true)]
    [String]$mode,
    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    $pathToFile
)

$parentDir = Split-Path -Path $pathToFile -Parent
$fileName = Split-Path -Path $pathToFile -Leaf

switch ($mode.ToLower()) {
    'tob64' {
        $b64FileName = "$($fileName.Split('.')[0])" + ".b64"
        $content = Get-Content -Path $pathToFile -Encoding byte
        $base64 = [System.Convert]::ToBase64String($content)
        $base64 | Out-File -FilePath (Join-Path -Path $parentDir -ChildPath $b64FileName) -Force
    }
    'toico' {
        $icoFileName = "$($fileName.Split('.')[0])" + "_b64.ico"
        $content = Get-Content -Path $pathToFile
        $base64 = [System.Convert]::FromBase64String($content)
        $base64 | Set-Content -Encoding byte -Path (Join-Path -Path $parentDir -ChildPath $icoFileName) -Force
    }
}