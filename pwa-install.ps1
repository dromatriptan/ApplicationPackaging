<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
$icon = '' #Some b64 encoded string representing an ICO file
[String]$shortcutName = "Slack"
[String]$shortcutLocation = "${env:AppData}\Microsoft\Windows\Start Menu\Programs"
[String]$shortcutArguments = '--app=https://app.slack.com'
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function CreateShortcut {
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

    [bool]$successful = $false
    $startTime = Get-Date
    $objShell  = New-Object -ComObject WScript.Shell
    $shortcut = $objShell.CreateShortcut("$location\$name.lnk")
    $shortcut.TargetPath = $target
    $shortcut.Arguments = $arguments
    $shortcut.IconLocation = $iconFilePath
    $shortcut.WindowStyle = "1"
    $shortcut.WorkingDirectory = ""
    $shortcut.Description = ""
    $shortcut.HotKey = ""
    $shortcut.Save()

    if ($runAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes("$location\$name.lnk")
        $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes("$location\$name.lnk")
    }
    $lastWriteTime = Get-ChildItem -Path "$location\$name.lnk" -ErrorAction SilentlyContinue -ErrorVariable NotFound | Select-Object -ExpandProperty LastWriteTime
    if ($null -ne $lastWriteTime) {
        if ($lastWriteTime -ge $startTime) { $successful = $true }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$iconLocation = "${env:Public}\Pictures\$shortcutName.ico"
$iconFile = [System.Convert]::FromBase64String($icon)
$iconFile | Set-Content -Path $iconLocation -Encoding byte -Force
[String]$shortcutTarget = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

$created = CreateShortcut -location $shortcutLocation -name $shortcutName -target $shortcutTarget -iconFilePath $iconLocation -arguments $shortcutArguments

if ($created) { [System.Environment]::Exit(0) } else { [System.Environment]::Exit(-1) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>