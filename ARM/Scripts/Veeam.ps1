Param (
    [string]$StorageAccountSASTokenB64,
    [string]$storageAccountName,
    [string]$VeeamFile,
    [string]$VeeamLicFile
)

New-Item .\log.txt
Set-Content .\log.txt $StorageAccountSASTokenB64
Set-Content .\log.txt $storageAccountName
Set-Content .\log.txt $VeeamFile
Set-Content .\log.txt $VeeamLicFile

# Copy content to local drive using AzCopy
$StorageAccountSASToken = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($StorageAccountSASTokenB64))
New-Item -Path "C:\PostDeploymentContent" -ItemType Directory 
$SourcePath = "https://$storageAccountName.blob.core.windows.net/postdeployment/Veeam/*$StorageAccountSASToken"
.\azcopy.exe copy "$SourcePath" "C:\PostDeploymentContent" --recursive=true --check-md5=NoCheck

# Install Veeam Agent
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
	param([string]$zipfile, [string]$outpath)

	[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

$VeeamFilePath="C:\PostDeploymentContent\"+$VeeamFile+".zip"
$VeeamInstPath="C:\PostDeploymentContent\Veeam\"+$VeeamFile+".exe"
$VeeamLicFilePath="C:\PostDeploymentContent\"+$VeeamLicFile+".lic"

#Unzip files
& Unzip -zipfile $VeeamFilePath -outpath "C:\PostDeploymentContent\Veeam\"

#Install Veeam
& $VeeamInstPath /silent /accepteula /acceptthirdpartylicenses

#Import Veeam license
Start-Sleep -Seconds 300
& "C:\Program Files\Veeam\Endpoint Backup\veeam.agent.configurator.exe" -license /f:$VeeamLicFilePath /w
