function Discover {
    param(
        [Parameter(Position = 1, Mandatory = $true)]    
        [ValidateSet("O365ProRetail", "ProjectStdXVolume", "VisioStdXVolume", "ProjectProXVolume", "VisioProXVolume", IgnoreCase = $true)]
        [String]$productReleaseId,
        [Parameter(Position = 2, Mandatory = $true)]
        [Version]$minimumVersion,
        [Parameter(Position = 3, Mandatory = $true)]
        [ValidateSet("Current", "CurrentPreview", "SemiAnnual", "SemiAnnualPreview", "MonthlyEnterprise", IgnoreCase = $true)]
        [String]$updateChannel,
        [Parameter(Position = 4, Mandatory = $true)]
        [ValidateSet("x86", "x64", IgnoreCase = $true)]
        [String]$platform
    )
    Switch ($updateChannel.ToLower()) {
        "current" { $CDNBaseUrl = "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60" }
        "currentPreview" { $CDNBaseUrl = "http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be" }
        "monthlyenterprise" { $CDNBaseUrl = "http://officecdn.microsoft.com/pr/55336b82-a18d-4dd6-b5f6-9e5095c314a6" }
        "semiannual" { $CDNBaseUrl = "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114" }
        "semiannualpreview" { $CDNBaseUrl = "http://officecdn.microsoft.com/pr/5440fd1f-7ecb-4221-8110-145efaa6372f" }
    }

    [bool]$discovered = $false
    [Version]$installedVersionToReport = Get-ItemProperty -Path $path -Name 'VersionToReport' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'VersionToReport'
    [String]$installedProductReleaseIds = Get-ItemProperty -Path $path -Name 'ProductReleaseIds' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'ProductReleaseIds'
    [String]$installedChannel = Get-ItemProperty -Path $path -Name 'CDNBaseUrl' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CDNBaseUrl'
    [String]$installedPlatform = Get-ItemProperty -Path $path -Name 'Platform' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'Platform'

    if ($null -ne $installedProductReleaseId -and $null -ne $installedVersionToReport -and $null -ne $installedChannel) {
        if ($productReleaseId -in ($installedProductReleaseIds.Split(",")) ) {
            if ($installedChannel -like $CDNBaseUrl) {
                if ($installedVersionToReport -ge $expectedVersionToReport) {
                    if ($installedPlatform -like $expectedPlatform) {
                        $discovered = $true
                    }
                }
            }
        }
    }
    return $discovered
}

Discover -productReleaseId O365ProRetail -minimumVersion "16.0.16026.20146" -updateChannel Current -platform x64