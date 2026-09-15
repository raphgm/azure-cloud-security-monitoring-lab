@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Azure region')
param location string = resourceGroup().location

@description('Retention in days. 90 covers most incident-investigation windows; regulated environments often need 365+.')
param retentionInDays int = 90

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
  }
}

output workspaceId string = workspace.id
output workspaceCustomerId string = workspace.properties.customerId
