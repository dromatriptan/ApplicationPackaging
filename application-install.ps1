<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Variables vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
[String]$msiName = "Some.msi"
[String]$mspName = "Some.msp"
[String]$mstName = "Some.mst"
[String]$msiOptions = "PROPERTY=`"SOME`""

[String]$exeName = "Some.exe"
[String]$exeInstallSwitches = "/S /InstallationType=AllUsers /RegisterPython=1 /AddToPath=1 /D=${env:ProgramData}\Anaconda3"

[Array]$processesToStop = @("process1.exe", "process2.exe")
[Array]$ServicesToStop = @("service1", "service2")

[Array]$fileAssociations = @(
    [PSCustomObject]@{
        Name            = "Association"
        Identifier      = ".pdf"
        ProgId          = "Acrobat.Document.DC"
        ApplicationName = "Adobe Acrobat DC"
    }
)
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Variables ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Functions vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>
function StopProcess {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$processName
    )

    [bool]$stopped = $true
    $name = $processName.Split('.')[0]
    $processIds = Get-Process -Name $name -ErrorAction SilentlyContinue -ErrorVariable GetError | Select-Object -ExpandProperty Id
    foreach ($id in $processIds) {
        Stop-Process -Id $id -Force -ErrorAction SilentlyContinue -ErrorVariable stopError
        if ($stopError) { $stopped = $false }

    }
    return $stopped
}
function StopService {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$serviceName
    )

    [bool]$stopped = $true
    $name = $serviceName.Split('.')[0]
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue -ErrorVariable GetError
    if ($null -ne $service) {
        Stop-Service -InputObject $service -Force -ErrorAction SilentlyContinue -ErrorVariable stopError
        if ($stopError) { $stopped = $false }

    }
    return $stopped
}
function InstallMsi {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$msiPath,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$mspPath = $null,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$mstPath = $null,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$msiOptions = $null
    )
    [String]$argumentList = $null
    $installer = $null
    if ( (Test-Path -Path $msiPath -PathType Leaf) -eq $true) {
        if ($null -ne $mspPath) {
            if ($null -ne $mstPath) {
                $argumentList = "/i `"$msiPath`" PATCH=`"$mspPath`" TRANSFORMS=`"$mstPath`" /quiet /norestart"
            }
            else {
                $argumentList = "/i `"$msiPath`" PATCH=`"$mspPath`" /quiet /norestart"
            }
        }
        elseif ($null -ne $mstPath) {
            $argumentList = "/i `"$msiPath`" TRANSFORMS=`"$mstPath`" /quiet /norestart"
            
        }
        else { 
            $argumentList = "/i `"$msiPath`" /quiet /norestart"
        }
        $installParameters = @{
            FilePath     = "${env:WinDir}\System32\msiexec.exe"
            ArgumentList = $argumentList
            Wait         = $true
            PassThru     = $true
            WindowStyle  = "Hidden"
        }
        $installer = Start-Process @installParameters
    }
    if ($null -ne $installer) {
        return [int]($installer.ExitCode)
    }
    else {
        return [int](-1)
    }
}
function InstallExe {
    param(
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$exePath,
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$exeOptions = $null
    )   
    $installer = $null
    if ( (Test-Path -Path $exePath -PathType Leaf) -eq $true ) {
        if ($null -ne $exeOptions) { 
            $argumentList = $exeOptions
        }
        else {
            $argumentList = ""
        }
        $installParameters = @{
            FilePath     = $exePath
            ArgumentList = $argumentList
            Wait         = $true
            PassThru     = $true
            WindowStyle  = "Hidden"
        }
        $installer = Start-Process @installParameters
    }
    if ($null -ne $installer) {
        return [int]($installer.ExitCode)
    }
    else {
        return [int](-1)
    }
}
function DisableOutlookAddin {
    param( 
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$regAddinPath 
    )
    $successful = $false
    $loadBehavior = Get-ItemProperty -Path $regAddinPath -Name LoadBehavior -ErrorAction SilentlyContinue
    if ($null -ne $loadBehavior) {
        Set-ItemProperty -Path $regAddinPath -Name LoadBehavior -Value 0 -Force -ErrorAction SilentlyContinue -ErrorVariable SetError
        if (-not $setError) { $successful = $true }
    }

    return $successful
}
function SaveAssociations {
    param([Array]$associations)

    $startTime = Get-Date
    [bool]$successful = $false
    $docXml = New-Object -TypeName Xml
    $declaration = $docXml.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $defaultAssociations = $docXml.CreateElement("DefaultAssociations")

    foreach ($association in $associations) {
        $element = $docXml.CreateElement($association.Name)
        $element.SetAttribute("Identifier", $association.Identifier)
        $element.SetAttribute("ProgId", $association.ProgId)
        $element.SetAttribute("ApplicationName", $association.ApplicationName)
        $defaultAssociations.AppendChild($element) | Out-Null
    }

    $docXml.AppendChild($declaration) | Out-Null
    $docXml.AppendChild($defaultAssociations) | Out-Null

    try {
        $docXml.Save("${env:WinDir}\System32\defaultassociations.xml")
        $lastWriteTime = Get-ChildItem -Path "${env:WinDir}\System32\defaultassociations.xml" -ErrorAction SilentlyContinue -ErrorVariable NotFound | Select-Object -ExpandProperty LastWriteTime
        if ($null -ne $lastWriteTime) {
            if ($lastWriteTime -ge $startTime) { $successful = $true }
        }
    }
    catch { <#just catch the exception generated by save method #> }

    return $successful
}
<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>
<# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Main Program vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #>

# Construct the variables we need to install the MSI with all customizations
$msiFullPath = Join-Path -Path $scriptDir -ChildPath $msiName
$mspFullPath = Join-Path -Path $scriptDir -ChildPath $mspName
$mstFullPath = Join-Path -Path $scriptDir -ChildPath $mstName

$exeFullPath = Join-Path -Path $scriptDir -ChildPath $exeName

# Stop any services related to any existing instance of this app BEFORE attempting the installation
[bool]$serivcesStopped = $true
$ServicesToStop.ForEach({ if ( (StopService -serviceName $_) -eq $false ) { $serivcesStopped = $false } })

# Stop any processes related to any existing instance of this app BEFORE attempting the installation
$processesStopped = $true
$processesToStop.ForEach({ if ( (StopProcess -processName $_) -eq $false) { $processesStopped = $false } })

# Install the application
$installerExitCode = InstallMsi -msiPath $msiFullPath -mspPath $mspFullPath -mstPath $mstFullPath -msiOptions $msiOptions
$installerExitCode = InstallExe -exePath $exeFullPath -exeOptions $exeInstallSwitches

# Assuming application is installed, let us disable the Outlook COM object add-in
$addinDisabled = DisableOutlookAddin -regAddinPath "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\AdobeAcroOutlook.SendAsLink"

# Let's modify the pre-existing default associations XML file we enforce via Group Policy
$associationsSaved = SaveAssociations -associations $fileAssociations

[System.Environment]::Exit($uninstallerExitCode)

<# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Main Program ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #>