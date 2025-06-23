param asgName array
param location string
resource asg 'Microsoft.Network/applicationSecurityGroups@2024-07-01'= [ 
  for name in asgName:{
    name: name
    location: location

  }
]

output asgIds array = [for name in asgName: resourceId('Microsoft.Network/applicationSecurityGroups', name)]
