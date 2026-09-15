@description('Name of the Key Vault. Must be globally unique.')
param vaultName string

@description('Azure region')
param location string = resourceGroup().location

@description('Microsoft Entra tenant ID')
param tenantId string = subscription().tenantId

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId

    // RBAC, not the legacy access-policy model — integrates with the
    // same role assignments as the rest of the subscription.
    enableRbacAuthorization: true

    // Without purge protection, a deleted vault or secret can be
    // permanently purged before the retention window ends by anyone
    // with delete rights. This is the setting that matters most.
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

output vaultId string = vault.id
output vaultUri string = vault.properties.vaultUri
