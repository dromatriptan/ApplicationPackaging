<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[Array]$registryEntries = @(
    [PSCustomObject]@{
        path  = [String]"SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown"
        value = [String]"bUpater"
        type  = [Microsoft.Win32.RegistryValueKind]::Dword
        data  = [int32]0
    }
)
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function UninstallRegEntries {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateSet("HKU", "HKLM", IgnoreCase = $true)]
        [String]$root,
        [Parameter(Position = 2, Mandatory = $true)]
        [Array]$regEntries
    )

    $successful = $true
    if ($root -like 'hku') {
        New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue -ErrorVariable driveError | Out-Null
        if (-not $driveError) {
            $userKeys = Get-ChildItem -Path 'HKU:\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-1-5-21' -and $_.Name -notlike '*_Classes' }
            foreach ($u in $userKeys) {
                foreach ($r in $regEntries) {
                    $regKey = Join-Path -Path $u.PSPath -ChildPath $r.path
                    $regValue = Get-ItemProperty -Path $regKey -Name $r.value -ErrorAction SilentlyContinue -ErrorVariable getError
                    if ($null -ne $regValue) {
                        Remove-ItemProperty -Path $regKey -Name $r.value -Force -ErrorAction SilentlyContinue -ErrorVariable regError
                        if ($regError) { $successful = $false }
                    }                    
                }
            }
            Remove-PSDrive -Name HKU -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }
    elseif ($root -like 'hklm') {
        foreach ($r in $regEntries) {
            $regKey = Join-Path -Path 'HKLM:\' -ChildPath $r.Path
            $regKey = Join-Path -Path $u.PSPath -ChildPath $r.path
            $regValue = Get-ItemProperty -Path $regKey -Name $r.value -ErrorAction SilentlyContinue -ErrorVariable getError
            if ($null -ne $regValue) {
                Remove-ItemProperty -Path $regKey -Name $r.value -Force -ErrorAction SilentlyContinue -ErrorVariable regError
                if ($regError) { $successful = $false }
            }
        }
    }
    return $successful
}
function InstallRegEntries {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateSet("HKU", "HKLM", IgnoreCase = $true)]
        [String]$root,
        [Parameter(Position = 2, Mandatory = $true)]
        [Array]$regEntries
    )

    $successful = $true
    if ($root -like 'hku') {
        New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue -ErrorVariable driveError | Out-Null
        if (-not $driveError) {
            $userKeys = Get-ChildItem -Path 'HKU:\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-1-5-21' -and $_.Name -notlike '*_Classes' }
            foreach ($u in $userKeys) {
                foreach ($r in $regEntries) {
                    $regKey = Join-Path -Path $u.PSPath -ChildPath $r.path
                    if ( (Test-Path -Path $regKey -PathType Container) -eq $false ) {
                        New-Item -Path (Split-Path -Path $regKey -Parent) -Name (Split-Path -Path $regKey -Leaf) -Force -ErrorAction SilentlyContinue -ErrorVariable RegError | Out-Null
                        if ($regError) { $successful = $false }
                    }
                    New-ItemProperty -Path $regKey -Name $r.value -PropertyType $r.data -Value $r.data -Force -ErrorAction SilentlyContinue -ErrorVariable RegError | Out-Null
                    if ($regError) { $successful = $false }
                }
            }
            Remove-PSDrive -Name HKU -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }
    elseif ($root -like 'hklm') {
        foreach ($r in $regEntries) {
            $regKey = Join-Path -Path 'HKLM:\' -ChildPath $r.Path
            if ( (Test-Path -Path $regKey -PathType Container) -eq $false ) {
                New-Item -Path (Split-Path $regKey -Parent) -Name (Split-Path -Path $regKey -Leaf) -Force -ErrorAction RegError | Out-Null
                if ($regError) { $successful = $false }
            }
            New-ItemProperty -Path $regKey -Name $r.value -PropertyType $r.type -Value $r.data -ErrorAction SilentlyContinue -ErrorVariable RegError | Out-Null
            if ($regError) { $successful = $false }
        }
    }
    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
# Assuming application is installed, let us incorporate some policy settings to enforce a particular configuration throughout this product's lifecycle
$regEntriesInstalled = InstallRegEntries -root HKLM -regEntries $registryEntries
if ($regEntriesInstalled) { return [System.Environment]::Exit(0) } else { return [System.Environment]::Exit(-1) }
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>