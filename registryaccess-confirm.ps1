<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$groupName = "BUILTIN\Users"
[String]$keyName = 'HKLM:\SOFTWARE\WOW6432Node\Bloomberg L.P.'
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function ConfirmRegistryAccess {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$groupName,
        [Parameter(Position = 2, Mandatory = $true)]
        [String]$keyName,
        [Parameter(Position = 3, Mandatory = $true)]
        [ValidateSet("ChangePermissions","FullContronl","ReadPermissions",IgnoreCase = $true)]
        [System.Security.AccessControl.RegistryRights]$permission
    )

    [bool]$successful = $false
    if ( (Test-Path -Path $keyName -PathType Container) -eq $true ) {
        $idRef = [System.Security.Principal.NTAccount]($groupName)
        $acls = Get-Acl -Path $keyName -ErrorAction SilentlyContinue -ErrorVariable aclError | Select-Object -ExpandProperty Access
        if ($null -ne $acls -and -not $aclError) {
            $results = $acls | Where-Object { $_.IdentityReference -eq $idRef -and $_.RegistryRights -match $permission }
            if ($null -ne $results) { 
                $successful = $true
            }
        }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
# Grant local users access to Bloomberg Registry Key
$registryPermissioned = ConfirmRegistryAccess -groupName $groupName -keyName $keyName -permission ChangePermissions
if ($registryPermissioned) { return $true }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>