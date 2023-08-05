<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$groupName = "BUILTIN\Users"
[String]$folderName = "${env:SystemDrive}\blp"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function ConfirmFolderAccess {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$groupName,
        [Parameter(Position = 2, Mandatory = $true)]
        [String]$folderName,
        [Parameter(Position = 3, Mandatory = $true)]
        [ValidateSet("Modify","FullContronl","ReadPermissions",IgnoreCase = $true)]
        [System.Security.AccessControl.FileSystemRights]$permission
    )

    [bool]$successful = $false
    if ( (Test-Path -Path $folderName -PathType Container) -eq $true ) {
        $idRef = [System.Security.Principal.NTAccount]($groupName)

        $acls = Get-Acl -Path $folderName -ErrorAction SilentlyContinue -ErrorVariable aclError | Select-Object -ExpandProperty Access

        if ($null -ne $acls -and -not $aclError) {
            $results = $acls | Where-Object { $_.IdentityReference -eq $idRef -and $_.FileSystemRights -match $permission }
            if ($null -ne $results) { 
                $successful = $true
            }
        }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
# Grant local users access to Bloomberg installation directory
$folderPermissioned = ConfirmFolderAccess -groupName $groupName -folderName $folderName -permission Modify
if ($folderPermissioned) { return $true }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>