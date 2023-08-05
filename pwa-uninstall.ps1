<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$shortcutName = "Slack"
[String]$shortcutLocation = "${env:AppData}\Microsoft\Windows\Start Menu\Programs"
[String]$shortcutArguments = '--app=https://app.slack.com'
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function RemoveShortcut {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$location,
        [Parameter(Position = 2, Mandatory = $true)]
        [String]$name,
        [Parameter(Position = 3, Mandatory = $true)]
        [String]$target,
        [Parameter(Position = 4, Mandatory = $true)]
        [String]$iconFilePath,
        [Parameter(Position = 5, Mandatory = $true)]
        [String]$arguments,
        [Parameter(Position = 6, Mandatory = $false)]
        [Switch]$runAsAdmin
    )

    [bool]$successful = $true

    $shortcutFile = Get-ChildItem -Path "$location\$name.lnk" -ErrorAction SilentlyContinue -ErrorVariable NotFound 
    if ($null -ne $shortcutFile) {
        $objShell  = New-Object -ComObject WScript.Shell
        $shortcut = $objShell.CreateShortcut("$location\$name.lnk")
        
        if (
            $shortcut.TargetPath -like $target -and `
            $shortcut.Name -like $name -and `
            $shortcut.iconFilePath -like $iconFilePath -and `
            $shortcut.Arguments -like $arguments
            ) {
                Remove-Item -Path $shortcutFile.FullName -Force -ErrorAction SilentlyContinue -ErrorVariable removalError
                if ($removalError) { $successful = $false }
            }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$iconLocation = "${env:Public}\Pictures\$shortcutName.ico"
[String]$shortcutTarget = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

$removed = RemoveShortcut -location $shortcutLocation -name $shortcutName -target $shortcutTarget -iconFilePath $iconLocation -arguments $shortcutArguments

if ($removed) { [System.Environment]::Exit(0) } else { [System.Environment]::Exit(-1) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>