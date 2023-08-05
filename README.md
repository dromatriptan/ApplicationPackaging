# ApplicationPackaging
Scripts used with Microsoft Configuration Manager as the basis for all install, uninstall, detection, and repair of deployments that users regularly pull from Software Center.

## Scripts prefixed with application-

**Overview** These scripts are companion scripts to packages for Microsoft Endpoint Configuration Manager. They provide the logic needed to install, uninstall, detect applications published in Software Center. These scripts are modularized to handle application installers from Microsoft (*.msi) and common 3rd party installers (*.exe)

## Scripts prefixed with certificate-

**Overview** These scripts are companion scripts to packages for Microsoft Endpoint Configuration Manager. They provide the logic needed to install, uninstall, detect applications published in Software Center. These scripts are modularized to handle certifcates.

## Scripts prefixed with clickonce-

**Overview** These scripts are companion scripts to packages for Microsoft Endpoint Configuration Manager. They provide the logic needed to install, uninstall, detect applications published in Software Center. These scripts are modularized to handle clickonce applications. Oftentimes, developers package their products with this technology and fail to code-sign them. I put tother some rudimentary UI automation to auto-click on popups in an effort to guide the user towards a successful installation while minimizing calls to the helpdesk for popups that, in all honesty, are cause for concern in today's security-minded world.

## b64IconTool.ps1

**Overview** This was an exercise to figure out how to embed small graphics (i.e., icon files) to powershell scripts and avoid external file dependencies at run-time.

## detect-office.ps1

**Overview** Microsoft turned the IT world upside down when they abandoned their MSI installers for Office products. I needed a fool-proof way to detect Office installations successfully. This was the result.

## download-bloomberg.ps1

**Overview** I don't know what it is about in-place upgrades of a bloomberg terminal installation, but it can take (literally) hours on even the best systems (Dell Precision Tower 34xx series). I found it easier to *scrape* the Bloomberg downloads page, download the version needed, and install over the existing version. This was a huge win with my trading users.

## Scripts Prefixed with folderaccess- and registryaccess-

**Overview** I am not a fan of using pre-compiled executables that make promises of modifying low-level operating system security ACLs (i.e., SetACL.exe and others). The last thing I need is for someone within InfoSec to identify something *calling home* and leaking proprietary data and telemtry to some offshore organization. So, I figured out how to manage ACLs for folders and the registry using .NET Framework libraries within powershell.

## Scripts prefixed with pwa-

**Overview** These scripts are companion scripts to packages for Microsoft Endpoint Configuration Manager. They provide the logic needed to install, uninstall, detect applications published in Software Center. These scripts are modularized to create *web apps* that can be defined in the Start Menu and Desktop as a shortcut for end users. Some organizations do not allow Microsoft store to run internally, but are *ok* with the web-based versions of things like Microsoft To Do. So, these scripts can create web apps for these browser-based applications.

## Scripts prefixed with vsto-

**Overview** These scripts are companion scripts to packages for Microsoft Endpoint Configuration Manager. They provide the logic needed to install, uninstall, detect applications published in Software Center. These scripts are modularized to install Microsoft Visual Studio Tools for Office (i.e., VSTO) applications.

## Scripts prefixed with xlam-

**Overview** These scripts are companion scripts to packages for Microsoft Endpoint Configuration Manager. They provide the logic needed to install, uninstall, detect applications published in Software Center. These scripts are modularized to install Excel addins.