# Clone Module Repo
$tempDir = "$env:TEMP\TerraPester"

if(-not (Test-Path -Path $tempDir)){
  New-Item -ItemType Directory -Path $tempDir
}
else {
  Remove-Item -Path $tempDir -Recurse -Force
}

git clone https://github.com/adam-welch/TerraPester.git $tempDir

# Update module from filepath
if(Get-Module -Name TerraPester){
  Remove-Module -Name TerraPester
}
Import-Module -Name "$tempDir\TerraPester.psm1"

$terraformOptions = @{
  Vars = @{
      "website_name"   = "testwebsiteaaa"
  }
  #VarFiles     = "./tf_1.tfvars","./tf_2.tfvars"
  #PlanFileName = "terraform.tfplan"
  TerraformDir = "./fixtures/v1/"
}

# Remember to Authenticate to azure first!
# See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs for more information.


# As a helper I have added a couple functions to add\remove environment variables from file to the TerraPester module.
# I prefer this so that I can keep my credentials out of my scripts and prevent them from being added to source control.

# Usage:
# Set-EnvVariablesFromFile -filePath "$PSScriptRoot/azure.env"
# azure.env contents should look like:
# ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
# ARM_CLIENT_ID       = "<CLIENT_ID>"
# ARM_CLIENT_SECRET   = "<CLIENT_SECRET>"
# ARM_TENANT_ID       = "<TENANT_ID>"

# Set environment variables from input.env file
Set-EnvVariablesFromFile -filePath "$PSScriptRoot/azure.env"

# WARNING: Do NOT include these in you scripts like this as too easy to forget and end up committing in to source control.. u
Invoke-PesterTests -TerraformOptions $terraformOptions -TestFixtures './tests'

Clear-EnvVariablesFromFile -filePath "$PSScriptRoot/azure.env"
