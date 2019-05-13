# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-get-pki-certs
# Install AzsReadinessChecker
Install-Module Microsoft.AzureStack.ReadinessChecker

# Configure certificate
$subjectHash = [ordered]@{"OU"="AzS";"O"="Company";"L"="City";"S"="City";"C"="CO"}
$outputDirectory = "$ENV:USERPROFILE\DocumentsAzSCSR"
new-item -Path "$ENV:USERPROFILE\Documents\DocumentsAzSCSR" -ItemType Directory
$IdentitySystem = "AAD"
$regionName = 'region'
$externalFQDN = 'company.com'
# Generate CSR (included -IncludePaaS switch)
New-AzsCertificateSigningRequest -RegionName $regionName -FQDN $externalFQDN -subject $subjectHash -OutputRequestPath $OutputDirectory -IdentitySystem $IdentitySystem -IncludePaaS