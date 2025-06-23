//module for the vnet and subnets
param location string
param vnetName string
param vnetAddressPrefix string
param subnetName array
param subnetAddressPrefix array

module vnet 'modules/network/vnet.bicep' = {
  name: 'vnet-${vnetName}'
  params:{
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
  }
}

// module fot the asg

param asgName array

module asg 'modules/network/asg.bicep'={
  name: 'asg-${vnetName}'
  params: {
    asgName:  asgName
    location: location
  }
}
// module for appGW

param appGwName string
param publicIpName string
param appGwsubnetName string

module appGw 'modules/network/appgateway.bicep' = {
  name: 'appGw-${appGwName}'
  params: {
    appGwName: appGwName
    publicIpName: publicIpName
    appGwsubnetName: appGwsubnetName
    location: location
    vnetName: vnetName
    
  }
}



// moduel for the nsg 

param nsgName array 
param tier array
var asgIds object = {
  web: asg.outputs.asgIds[0]
  app: asg.outputs.asgIds[1]
  db:  asg.outputs.asgIds[2]

}


module nsg 'modules/network/nsg-subnet.bicep' = [
  for i in range(0, length(nsgName)): {
    name: 'nsg-${nsgName[i]}'
    params: {
      nsgName: nsgName[i]
      location: location
      tier: tier[i]
      asgId: asgIds
      

    }
  }
]
var nsgIds array = [nsg[0].outputs.nsgIds[0],nsg[1].outputs.nsgIds[0],nsg[2].outputs.nsgIds[0]]
resource nsgSubnetAssociation 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = [
  for i in range(0, length(nsgName)): {
    name: '${vnetName}/${subnetName[i]}'
    properties:{
      addressPrefix: subnetAddressPrefix[i]
      networkSecurityGroup:{
        id: nsgIds[i]
      }
    }
  }
]
// keyvault that was created 
param keyVaultName string
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: keyVaultName
}

// module for the vm's

param vmName array
param vmSize string
param zones string
param publicIpEnabled array
param adminUserName string
var asgId array = asg.outputs.asgIds
var subnetId array = vnet.outputs.subnetsIds

module vm 'modules/compute/vm.bicep' = [
  for i in range(0, length(vmName)): {
    name: 'vm-${vmName[i]}'
    params: {
      vmName: vmName[i]
      vmSize: vmSize
      location: location
      zones: zones
      publicIpEnabled: publicIpEnabled[i]
      adminUserName: adminUserName
      asgId: asgId[i]
      subnetId: subnetId[i]
      adminPassword: keyVault.getSecret('vmAdminPassword')
      
    }
  }
]
