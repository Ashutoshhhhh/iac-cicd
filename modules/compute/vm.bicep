param vmName string
param vmSize string
param zones string
param location string
param publicIpEnabled bool
param adminUserName string
param asgId string
param subnetId string
@secure()
param adminPassword string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-07-01' = if(publicIpEnabled) {
  name:'${vmName}-pip'
  sku: {
    name: 'Standard'
  }
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: publicIpEnabled ? {id:publicIp.id}:null
          privateIPAllocationMethod: publicIpEnabled ? 'Static' : 'Dynamic'
          privateIPAddress: publicIpEnabled ? '172.172.1.4' : null
          applicationSecurityGroups: [
            {
              id: asgId
            }
          ]
        }
      }
    ]
    
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: vmName
  location: location
  zones: [zones]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }

}

resource nginxExtension 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = if(publicIpEnabled){
  parent: vm
  name: 'nginxExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extension'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://github.com/Ashutoshhhhh/bicepfirst/blob/main/third/nginx.sh'
      ]
      commandToExecute: 'bash nginx.sh'
    }
  }
}
