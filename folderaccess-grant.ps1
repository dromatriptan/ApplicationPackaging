<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$groupName = "BUILTIN\Users"
[String]$folderName = "${env:SystemDrive}\blp"
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function GrantFolderAccess {
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
        $inhFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
        $prFlags = [System.Security.AccessControl.PropagationFlags]::None
        $acType = [System.Security.AccessControl.AccessControlType]::Allow

        $fileRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($idRef,$permission,$inhFlags, $prFlags, $acType)

        $fileAcl = Get-Acl -Path $folderName
        $fileAcl.AddAccessRule($fileRule)
        $fileAcl.SetAccessRule($fileRule)
        $fileAcl | Set-Acl -Path $folderName

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
$folderPermissioned = GrantFolderAccess -groupName $groupName -folderName $folderName -permission Modify
if ($folderPermissioned) { [System.Environment]::Exit(0) } else { [System.Environment]::Exit(0) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>