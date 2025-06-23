param keyVaultName string
param location string
param objectId string 
@secure()
param keyVaultSecret string
param secretName string = 'vmAdminPassword'

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: { 
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          secrets: [
            'get'
            'set'
            'delete'
            'list'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
  }
  

}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview'={
  parent: keyVault
 name: secretName
  properties: {
    value: keyVaultSecret
    contentType: 'text/plain'
  }
}

output keyVaultId string = keyVault.id
output secretId string = secret.id
