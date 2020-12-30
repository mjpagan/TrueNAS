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

$vmName = "TN-Test05"
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_B2ms"

$rgname = "Lab_RG"
$vnetName = "lab-ncus-vnet"
$location = "northcentralus"

$osDiskName = "TrueNAS05"

$vnet = Get-azvirtualnetwork -Name $vnetName


$nicName = $vmName+"-nic"
$nic = New-AzNetworkInterface -Name $nicName `
    -ResourceGroupName $rgname `
    -Location $location -SubnetId $vnet.Subnets[0].Id `

## fix the subnet thing

$osDisk = Get-AzDisk -Name $osDiskName

$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -StorageAccountType Standard_LRS `
    -DiskSizeInGB 32 -CreateOption Attach -Linux

New-AzVM -ResourceGroupName $rgname -Location $location -VM $vm