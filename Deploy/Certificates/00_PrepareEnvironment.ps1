# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-powershell-install
# Check PS Version. It should be higher than 5.0
$PSVersionTable.PSVersion

# Enable PowerShell Gallery
Import-Module -Name PowerShellGet -ErrorAction Stop
Import-Module -Name PackageManagement -ErrorAction Stop
Get-PSRepository -Name "PSGallery"
# Make PS gallery trusted (run in Admin PS)
Register-PsRepository -Default
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Uninstall old MAS modules
Get-Module -Name Azs.* -ListAvailable | Uninstall-Module -Force -Verbose
Get-Module -Name Azure* -ListAvailable | Uninstall-Module -Force -Verbose

# Azure Stack 1901 or later
# Install and import the API Version Profile required by Azure Stack into the current PowerShell session.
Install-Module AzureRM -RequiredVersion 2.4.0
Install-Module -Name AzureStack -RequiredVersion 1.7.0

# Enable additional storage features
    # Install the Azure.Storage module version 4.5.0
    Install-Module -Name Azure.Storage -RequiredVersion 4.5.0 -Force -AllowClobber
    # Install the AzureRm.Storage module version 5.0.4
    Install-Module -Name AzureRM.Storage -RequiredVersion 5.0.4 -Force -AllowClobber
    # Remove incompatible storage module installed by AzureRM.Storage
    Uninstall-Module Azure.Storage -RequiredVersion 4.6.1 -Force
    # Load the modules explicitly specifying the versions
    Import-Module -Name Azure.Storage -RequiredVersion 4.5.0
    Import-Module -Name AzureRM.Storage -RequiredVersion 5.0.4

# Change directory to the root directory. 
cd \

# Download the tools archive.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile "$ENV:USERPROFILE\Downloads\master.zip"
# Expand the downloaded files.
expand-archive "$ENV:USERPROFILE\Downloads\master.zip" -DestinationPath . -Force
# Change to the tools directory.
cd AzureStack-Tools-master