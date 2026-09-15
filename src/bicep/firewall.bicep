@description('Name of the hub VNet')
param vnetName string = 'vnet-hub'

@description('Name of the Azure Firewall resource')
param firewallName string = 'fw-hub'

@description('Azure region')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        // Must be named exactly "AzureFirewallSubnet", minimum /26.
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-${firewallName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: 'fw-policy-${firewallName}'
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: firewallName
  location: location
  properties: {
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: '${firewallName}-ipconfig'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: '${vnet.id}/subnets/AzureFirewallSubnet'
          }
        }
      }
    ]
  }
}

output firewallId string = firewall.id
output firewallPolicyId string = firewallPolicy.id
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
