# Create TrueNAS VM from uploaded VHD
#
# Assumptions: 
# You have the following resources created:
#  -Resourcegroup
#  -Virtual network w/subnet
#  -Virtual network gateway deployed and VPN tunnel created
#
# Step 1: Upload the VHD to your subscription as a managed disk (not into a storage account). I used Azure Storage Explorer for this task. 
#
# Step 2: Fill in your information and copy and paste this into Cloud Shell or Azure PowerShell. It will prompt you to enter credentials, but they do not actually apply to the OS so they will not be used.
#
# Step 3: Wait for the VM to be created. You should not have to wait for the progress bar to complete as it not recognizing that the resoruces have been created. It will eventually timeout and throw and error.
#
# Step 4: Modify or delete the inbound NSG rule allowing HTTPS depending on your security requirements.
#
# Step 5: Connect to TrueNAS server via the "internal" IP address and configure to your needs.
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------
#
# Setting the table
$rgName = "Lab_RG"
$uploadedVHD = "TrueNAS_12.0_RC1"

# Image Settings
$imageName = 'TrueNAS_Core_12.0_RC1'
$disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $uploadedVHD

# VM Settings
$vmName = "TrueNAS05"
$vmSize = "Standard_B2ms"
$vmVnet = "lab-ncus-vnet"
$vmSubnet = "lab-ncus-snet-1"
$vmLocation = "North Central US"
$AdminUserName = 'truenasadmin'
$AdminPassword = ConvertTo-SecureString 'XLLBaNH7LJt2eUNr' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($AdminUserName, $AdminPassword)
$openPorts = 443

# Make things
$imageConfig = New-AzImageConfig `
   -Location $vmlocation

$imageConfig = Set-AzImageOsDisk `
   -Image $imageConfig `
   -OsType Linux `
   -OsState Generalized `
   -ManagedDiskId $disk.Id

$image = New-AzImage `
   -ImageName $imageName `
   -ResourceGroupName $rgName `
   -Image $imageConfig

New-AzVm `
   -ResourceGroupName $rgName `
   -Name $vmName `
   -Image $image.Id `
   -Location $vmlocation `
   -Size $vmSize `
   -VirtualNetworkName $vmVnet `
   -SubnetName $vmSubnet `
   -SecurityGroupName "$($vmName)-nsg" `
   -PublicIpAddressName "$($vmName)-1-pip" `
   -Credential $Credential `
   -OpenPorts $OpenPorts