@description('A short environment name used to build resource names, e.g. "lab" or "prod"')
param environmentName string = 'lab'

@description('Azure region for all resources')
param location string = resourceGroup().location

module logAnalytics 'log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    workspaceName: 'log-security-${environmentName}'
    location: location
  }
}

module keyVault 'key-vault.bicep' = {
  name: 'key-vault-deployment'
  params: {
    vaultName: 'kv-security-${environmentName}-${uniqueString(resourceGroup().id)}'
    location: location
  }
}

module firewall 'firewall.bicep' = {
  name: 'firewall-deployment'
  params: {
    vnetName: 'vnet-hub-${environmentName}'
    firewallName: 'fw-hub-${environmentName}'
    location: location
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output keyVaultUri string = keyVault.outputs.vaultUri
output firewallPrivateIp string = firewall.outputs.firewallPrivateIp
