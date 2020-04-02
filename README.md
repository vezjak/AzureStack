# AzureStack
This repo contains scripts and other files that can help you with administration of Azure Stack Hub.

## Marketplace management
Scripts for managing items from a marketplace portal.
- GetImages.ps1 (script for download items from marketplace portal which you specify in the files - separated file for images and extensions)

## Deploy
Scripts that can help you during deploy of Azure Stack Hub.

### Certificates
- Prepare environment (download required modules and other stuff)
- Generate CSR files for required certificates
- Certificates validation (create required folders structure and validation of certificates)

### ARM
ARM templates for Azure Stack Hub

Contains:
- VirtualNetwork: Create a virtual network
- PublicIP: Create a publicIP
- WindowsVM: Create a standalone Windows VM (without network)
- LinuxVM: Create a standalone Linux VM (without network)
