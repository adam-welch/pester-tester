# # Clone Module Repo
$tempDir = "$env:TEMP\TerraPester"

if(-not (Test-Path -Path $tempDir)){
  New-Item -ItemType Directory -Path $tempDir
}

git clone https://github.com/adam-welch/TerraPester.git $tempDir

# Update module from filepath
Remove-Module -Name TerraPester
if(-not (Get-Module -Name TerraPester)){
  Import-Module -Name "$tempDir\TerraPester.psm1"
}

$terraformOptions = @{
  Vars = @{
      "website_name"   = "testwebsiteaaa"
  }
  #VarFiles     = "./tf_1.tfvars","./tf_2.tfvars"
  #PlanFileName = "terraform.tfplan"
  TerraformDir = "./fixtures/v1/"
}

Invoke-PesterTests -TerraformOptions $terraformOptions -TestFixtures './tests'