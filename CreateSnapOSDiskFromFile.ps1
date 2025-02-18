# Login to Azure
Connect-AzAccount

# Define the subscription
$subscriptionName = "xxxxxxxxx"

# Set the subscription context
Set-AzContext -SubscriptionName $subscriptionName

# Import the CSV file
$vmList = Import-Csv -Path "vmexport.csv"

# Loop through each VM in the list and take a snapshot of the OS disk
foreach ($vm in $vmList) {
    $vmName = $vm.VMName
    $resourceGroupName = $vm.ResourceGroupName
    $vmDetails = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

    if ($vmDetails) {
        $osDisk = $vmDetails.StorageProfile.OsDisk
        $snapshotConfig = New-AzSnapshotConfig -SourceUri $osDisk.ManagedDisk.Id -Location $vmDetails.Location -CreateOption Copy
        $snapshot = New-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName "Snapshot-$vmName" -Snapshot $snapshotConfig
        Write-Output "Snapshot for $vmName in $resourceGroupName created successfully."
    } else {
        Write-Output "VM $vmName not found in $resourceGroupName."
    }
}
