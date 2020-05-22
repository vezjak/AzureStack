Param (
    [string]$StorageAccountSASTokenB64,
    [string]$storageAccountName
)

# Copy content to local drive using AzCopy
$StorageAccountSASToken = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($StorageAccountSASTokenB64))
New-Item -Path "C:\PostDeploymentContent" -ItemType Directory 
$SourcePath = "https://$storageAccountName.blob.core.windows.net/postdeployment/*$StorageAccountSASToken"
.\azcopy.exe copy "$SourcePath" "C:\PostDeploymentContent" --recursive=true --check-md5=NoCheck

# Install Veeam Agent
Add-Type -AssemblyName System.IO.Compression.FileSystem
	function Unzip
	{
	    param([string]$zipfile, [string]$outpath)

	    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
	}

	#Unzip files
	Unzip "C:\PostDeploymentContent\Veeam\VeeamAgentWindows.zip" "C:\PostDeploymentContent\Veeam\"

	#Install Veeam
	C:\PostDeploymentContent\Veeam\VeeamAgentWindows.exe /silent /accepteula /acceptthirdpartylicenses

	#Import Veeam license
	Start-Sleep -Seconds 300
	& "C:\Program Files\Veeam\Endpoint Backup\veeam.agent.configurator.exe" -license /f:"C:\PostDeploymentContent\Veeam\Veeam.lic" /w

	# Remove license
	#& rm "C:\PostDeploymentContent\Veeam\Veeam.lic"

	# Import configuration
	#& "C:\Program Files\Veeam\Endpoint Backup\veeam.agent.configurator.exe" -import /f:"C:\PostDeploymentContent\Veeam\configuration.xml"
	
	# Export configuration
	#& "C:\Program Files\Veeam\Endpoint Backup\veeam.agent.configurator.exe" -export /f:C:\PostDeploymentContent\Veeam\configuration.xml
