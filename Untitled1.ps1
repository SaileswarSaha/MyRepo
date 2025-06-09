#Connect-AzAccount

#Get-AzPrivateEndpointConnection -ResourceGroupName "rg-eas-aais-sbox-eastus" -ServiceName "stadfsboxeastus001" -Name "mpe-to-storage-adf-int-sbox-eastus-001" -PrivateLinkResourceType "Microsoft.Storage/storageAccounts"

#Get-AzStorageAccount -ResourceGroupName "rg-eas-aais-sbox-eastus" -Name "stadfsboxeastus001"

$connections = Get-AzPrivateEndpointConnection -ResourceGroupName "rg-eas-aais-sbox-eastus" -ServiceName "kv-adf-sbox-eastus-001" -PrivateLinkResourceType "Microsoft.KeyVault/vaults" # -Name "stadfsboxeastus001.6a00bc85-61ce-4252-85e2-0b6218b0b8c3"

foreach ($connection in $connections) {
    Write-Host "Processing connection: $($connection.Name)" -ForegroundColor Cyan
    
    $status = $connection.PrivateLinkServiceConnectionState.Status
    $reason = $connection.PrivateLinkServiceConnectionState.Description
    $actionRequired = $connection.PrivateLinkServiceConnectionState.ActionsRequired

    Write-Host "Name is:- $($connection.PrivateEndpoint.Id)"
    Write-Host "Status is:- $($connection.PrivateLinkServiceConnectionState.Status)"

    if ($connection.PrivateLinkServiceConnectionState.Status -eq "Pending" -and $connection.PrivateEndpoint.Id -like "*mpe-to-keyvault-adf-int-sbox-eastus-001*")
    {
        Write-Host "Working................"
        Write-Host "Name is:- $($connection.PrivateEndpoint.Id)"
        Write-Host "Name is:- $($connection.PrivateEndpoint.Id.Split('/')[-1])"
        Write-Host "Connection id:- $($connection.Id)"

        #Approve-AzPrivateEndpointConnection -ResourceId $connection.Id
        
    }
}