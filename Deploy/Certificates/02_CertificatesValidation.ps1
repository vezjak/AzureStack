Install-Module Microsoft.AzureStack.ReadinessChecker -force 

#region CreateStructure
#Create required structure
New-Item C:\Certificates -ItemType Directory

$directories = 'ACSBlob','ACSQueue','ACSTable','Admin Portal','ARM Admin','ARM Public','KeyVault','KeyVaultInternal','Public Portal','Admin Extension Host','Public Extension Host'
$destination = 'C:\Certificates'
$directories | % { New-Item -Path (Join-Path $destination $PSITEM) -ItemType Directory -Force}

$pfxPassword = Read-Host -Prompt "Enter PFX Password" -AsSecureString 
#endregion

#Before that step you must put your certificates in the associated folders (more info https://docs.microsoft.com/en-us/azure-stack/operator/azure-stack-pki-certs)
Invoke-AzsCertificateValidation -CertificatePath C:\MAS\Certificates -pfxPassword $pfxPassword -RegionName azuremb -FQDN posta.si -IdentitySystem AAD
