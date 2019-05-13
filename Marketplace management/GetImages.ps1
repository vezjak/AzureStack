Function Get-AzSItems{
<#
	.SYNOPSIS
		Function that check and download images/extensions from Azure Marketplace.
	.DESCRIPTION
		Function that check and download images/extensions from Azure Marketplace.

		The extenstions must be specified in .txt file and determined by the parameter (-Extensions).
		The images must be specified in .csv file and determined by the parameter (-Images).

		The endpoint is pre-defined and may be amended by the parameter (-Endpoint).
		The tenand ID is pre-defined and may be amended by the parameter (-TenentID).
	.EXAMPLE
		PS C:\> Get-AzSItems -Extensions ".\ExtensionsList.txt" -Images ".\Images.csv"
	.EXAMPLE
		PS C:\> Get-AzSItems -Extensions ".\ExtensionsList.txt" -Images ".\Images.csv" -Endpoint "https://adminmanagement.azregion.domain.com/" -TenantID "00000000-0000-0000-0000-000000000000"
#>
Param(
    [parameter(Mandatory=$true)]
    [string]$Extensions,
    [parameter(Mandatory=$true)]
    [string]$Images,
    [parameter()]
    [string]$Endpoint="https://adminmanagement.azregion.domain.com/",
    [parameter()]
    [string]$TenantID="00000000-0000-0000-0000-00000000000"
)
    $cred = Get-Credential 

    Add-AzureRMEnvironment -Name "AzSAdmin" -ArmEndpoint $Endpoint -ErrorAction Stop 
    Login-AzureRmAccount -Environment "AzSAdmin" -Credential $cred -TenantId $TenantID

    $activationRG = "azurestack-activation"
    $bridgeactivation = Get-AzsAzureBridgeActivation -ResourceGroupName $activationRG 
    $activationName = $bridgeactivation.Name

    #region GetExtensions
    $getExtensions = Get-Content $Extensions

    foreach ($extension in $getExtensions) 
    {
        Write-Output "Checking for $extension"
        if (!$(Get-AzsAzureBridgeDownloadedProduct -Name $extension -ActivationName $activationName -ResourceGroupName $activationRG -ErrorAction SilentlyContinue))
        { 
            Write-Output "** Didn't find $extension in your gallery. Downloading from the Azure Stack Marketplace **"
            Invoke-AzsAzureBridgeProductDownload -ActivationName $activationName -Name $extension -ResourceGroupName $activationRG -Force -Confirm:$false
        }
    }
    #endregion

    #region GetImages
    $imagesRequired = Import-Csv $Images

    $getAllImages = Get-AzsAzureBridgeProduct -ActivationName $activationName -ResourceGroupName $activationRG | Where-Object {($_.ProductKind -eq "virtualMachine")}
    foreach ($image in $imagesrequired)
    {
        Write-Output "Checking for $($image.Offer)-$($image.Sku)"
        #Need to check the name of the latest
        $templist = $getAllImages | Where-Object {$_.PublisherDisplayName -eq $image.PublisherDisplayName -and $_.Offer -eq $image.Offer -and $_.Sku -eq $image.Sku -and $_.DisplayName}
        $templist = $templist | Sort-Object -Property ProductProperties -Descending
        $imagename = $templist[0].Name -replace "default/", ""  #is the latest
        #Write-Output "Checking for name $imagename"
        if (!$(Get-AzsAzureBridgeDownloadedProduct -ActivationName $activationName -ResourceGroupName $activationRG -Name $imagename -ErrorAction SilentlyContinue))
        { 
            Write-Output "** Didn't find image in your gallery. Downloading from the Azure Stack Marketplace **"
            Invoke-AzsAzureBridgeProductDownload -ActivationName $activationName -Name $imagename -ResourceGroupName $activationRG -Force -Confirm:$false
        }
    }
    #endregion

    #region CleanOldones
    #Get what is installed
    $allinstalled = Get-AzsAzureBridgeDownloadedProduct -ActivationName $activationName -ResourceGroupName $activationRG
    $allinstalled = $allinstalled | Sort-Object -Property DisplayName, ProductProperties -Descending #want newest first as we'll look for matching and remove the second

    $prevDisplayName = "Not going to match"
    $prevEntry = $null
    foreach($installed in $allinstalled)
    {
        #see if name matches the previous, i.e. same image
        if($installed.DisplayName -eq $prevDisplayName)
        {
            #Lets remove it 
            Write-Output "** Found an older version of $($installed.DisplayName) **"
            Write-Output "   Previous version is $($installed.ProductProperties.Version) - $($installed.Name)"
            Write-Output "   Current version is $($prevEntry.ProductProperties.Version) - $($prevEntry.Name)"
            $Readhost = Read-Host " Do you want to delete previous version ($($installed.ProductProperties.Version)) (y/n)?"
            Switch ($ReadHost) 
            { 
                Y {Write-host " Yes, Removing old version"; Remove-AzsAzureBridgeDownloadedProduct -Name $installed.Name -ActivationName $activationName -ResourceGroupName $activationRG -Force -Confirm:$false -ErrorAction Continue} 
                N {Write-Host " No, Not removing"} 
                Default {Write-Host " Default, Not removing"} 
            }

            Write-Output ""
        }
        $prevDisplayName = $installed.DisplayName
        $prevEntry = $installed
    }
    #endregion
}