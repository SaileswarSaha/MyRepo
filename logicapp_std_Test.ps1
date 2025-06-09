#Connect-AzAccount

#$logicApps = Get-AzLogicApp -ResourceGroupName "rg-aais-sndbox-eastus" -Name "lapp-greetings-sndbox-eastus"

$logicApps = Get-AzWebApp -ResourceGroupName "rg-aais-sndbox-eastus"

Write-Output $logicApps

Get-AzVirtualNetwork | Where-Object { $_.Name -eq "vnet-eastus-001" }

$privateEndpoints = Get-AzPrivateEndpoint -ResourceGroupName "rg-aais-sndbox-eastus"

            # Find Private Endpoint associated with the Storage Account
$pe = $privateEndpoints | Where-Object { $_.Name -eq "rgaaissndboxeastusa7d0-pe" }

#(/subscriptions/6fe7e674-b159-4456-bf7c-12aae5967beb/resourceGroups/rg-aais-sndbox-eastus/providers/Microsoft.Network/privateEndpoints/rgaaissndboxeastusa7d0-pe)

$privateEndpointConnectionId = "/subscriptions/6fe7e674-b159-4456-bf7c-12aae5967beb/resourceGroups/rg-aais-sndbox-eastus/providers/Microsoft.Storage/storageAccounts/rgaaissndboxeastusa7d0/privateEndpointConnections/rgaaissndboxeastusa7d0-pe"

$peConnection = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $privateEndpointConnectionId

Write-Output $peConnection

$storageAccount = Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq 'rgaaissndboxeastusa7d0' }

$existingPrivateEndpoint = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $storageAccount.Id

Write-Output $existingPrivateEndpoint

# Fetch all Private Endpoints in the Resource Group
$privateEndpoints = Get-AzPrivateEndpoint -ResourceGroupName 'rg-aais-sndbox-eastus'

# Find Private Endpoint associated with the Storage Account
$pe = $privateEndpoints | Where-Object { $_.Name -eq 'rgaaissndboxeastusa7d0-pe' }

$existingPrivateEndpoint = $pe.PrivateLinkServiceConnections | Where-Object { $_.PrivateLinkServiceId -eq $storageAccount.Id }

if ($null -ne $existingPrivateEndpoint -and $existingPrivateEndpoint.PrivateLinkServiceConnectionState.Status -ne "Disconnected") {
    Write-Host "Private endpoint '$($storageAccount.StorageAccountName)-pe' already exists for $storageAccountName. Skipping....." -ForegroundColor Blue
}
else {
    Write-Host "Private endpoint '$($storageAccount.StorageAccountName)-pe' doesn't exists. Creating.........."
}

$logicApps = Get-AzWebApp -ResourceGroupName $ResourcegroupName | Where-Object { 
    $_.Kind -eq "Stateful" -or $_.Kind -eq "Stateless" -or $_.Kind -eq "functionapp,workflowapp"
}

foreach ($logicApp in $logicApps) {
    Write-Output $logicApp.VirtualNetworkSubnetId
}

if($logicApp.VirtualNetworkSubnetId -eq $null)
{
    Write-Output "not integrated"
}
else {
    Write-Output "Vnet integrated"
}

$vnet = Get-AzVirtualNetwork -Name 'vnet-eastus-001' -ResourceGroupName 'rg-aais-sndbox-eastus'
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'snet-lapp-001' -VirtualNetwork $vnet
$isdelegated = Get-AzDelegation -Subnet $subnet

Write-Output $isdelegated.Name

=====================================================

# Variables - Update these before running
$subscriptionId = "<your-subscription-id>"
$resourceGroup = "<your-logicapp-rg>"
$logicAppName = "<your-logicapp-name>"
$storageAccountName = "<your-storage-account-name>"

# Connect to Azure (If not already logged in)
Connect-AzAccount
Set-AzContext -SubscriptionId $subscriptionId

# Get Logic App's Managed Identity (MSI) Principal ID
$logicApp = Get-AzResource -ResourceType "Microsoft.Logic/workflows" -ResourceGroupName $resourceGroup -Name $logicAppName
$logicAppMSI = $logicApp.Properties.identity.principalId

if (-not $logicAppMSI) {
    Write-Host "❌ Managed Identity not enabled for the Logic App. Enable System-Assigned Identity and try again."
    exit
}

# Get the Storage Account Object
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

if (-not $storageAccount) {
    Write-Host "❌ Storage Account not found. Check the name and resource group."
    exit
}

# Assign "Storage Blob Data Contributor" Role to Logic App Identity
New-AzRoleAssignment -ObjectId $logicAppMSI `
                     -RoleDefinitionName "Storage Blob Data Contributor" `
                     -Scope $storageAccount.Id

Write-Host "✅ Successfully assigned 'Storage Blob Data Contributor' role to Logic App's Managed Identity."

