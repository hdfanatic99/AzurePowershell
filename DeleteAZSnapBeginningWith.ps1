$subscriptionName = "Azure subscription 1"

# Set the subscription context
Set-AzContext -SubscriptionName $subscriptionName

# Get all snapshots in the subscription.  Update line #7 with your naming convention
$snapshots = Get-AzSnapshot -ResourceGroupName * | Where-Object { $_.Name.StartsWith("xxxxxx") }

# Start jobs to delete snapshots concurrently
$jobs = @()
foreach ($snapshot in $snapshots) {
    $jobs += Start-Job -ScriptBlock {
        param ($rgName, $snapName)

        function Remove-Snapshot {
            param (
                [string]$ResourceGroupName,
                [string]$SnapshotName
            )
            Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $SnapshotName -Force
            Write-Output "Snapshot $SnapshotName deleted successfully."
        }

        Remove-Snapshot -ResourceGroupName $rgName -SnapshotName $snapName
    } -ArgumentList $snapshot.ResourceGroupName, $snapshot.Name
}

# Wait for all jobs to complete
$jobs | ForEach-Object { $_ | Wait-Job | Receive-Job }

Write-Output "All snapshots have been deleted successfully."
