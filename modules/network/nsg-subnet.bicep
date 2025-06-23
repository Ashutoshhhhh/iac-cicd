param nsgName string
param tier string
param location string
param asgId object

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: concat(
      tier == 'web' ? [
        {
          name: 'AllowSSH'
          properties: {
            priority: 400
            sourceAddressPrefix: 'Internet'
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgId.web
              }
            ]
            destinationPortRange: '22'
            protocol: 'Tcp'
            access: 'Allow'
            direction: 'Inbound'
          }
        }
        {
          name: 'AllowHTTPFromAppGateway'
          properties: {
            priority: 300
            direction: 'Inbound'
            access: 'Allow'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'ApplicationGateway'
            destinationApplicationSecurityGroups: [
              {
                id: asgId.web
              }
            ]
          }
        }
      ] : [],
      tier == 'app' ? [
        {
          name: 'AllowFromWeb'
          properties: {
            priority: 400
            sourceApplicationSecurityGroups: [
              {
                id: asgId.web
              }
            ]
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgId.app
              }
            ]
            destinationPortRange: '*'
            protocol: 'Tcp'
            access: 'Allow'
            direction: 'Inbound'
          }
        }
        {
          name: 'DenyVnet'
          properties: {
            priority: 800
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgId.app
              }
              
            ]
            destinationPortRange: '*'
            protocol: '*'
            access: 'Deny'
            direction: 'Inbound'
          }
        }
      ] : [],
      tier == 'db' ? [
        {
          name: 'AllowFromApp'
          properties: {
            priority: 400
            sourceApplicationSecurityGroups: [
              {
                id: asgId.app
              }
            
            ]
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgId.db
              }
            ]
            destinationPortRange: '*'
            protocol: 'Tcp'
            access: 'Allow'
            direction: 'Inbound'
          }
        }
        {
          name: 'DenyVnet'
          properties: {
            priority: 800
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgId.db
              }
            ]
            destinationPortRange: '*'
            protocol: '*'
            access: 'Deny'
            direction: 'Inbound'
          }
        }
      ] : []
    )
  }
}

output nsgIds array = [
  nsg.id
]
