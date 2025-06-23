
param location string
param vnetName string
param vnetAddressPrefix string
param subnetName array
param subnetAddressPrefix array

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnets 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = [
  for i in range(0, length(subnetName)): {
    name: subnetName[i]
    parent: vnet
    properties: {
      addressPrefix: subnetAddressPrefix[i]
      routeTable: null
      networkSecurityGroup: null // Set to null if no NSG is associated
    }
  }
]

output vnetId string = vnet.id
output subnetsIds array = [for subnet in subnetName: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnet)]
