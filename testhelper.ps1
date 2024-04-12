function Invoke-TerraformInitAndPlan {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [object]$TerraformOptions
  )

  $planFile = "tf.plan"
  if($null -ne $TerraformOptions.PlanFileName)
  {
    $planFile = $TerraformOptions.PlanFileName
  }

  $jsonFile = "tfplan.json"
  if($null -ne $TerraformOptions.JsonFileName)
  {
    $jsonFile = $TerraformOptions.JsonFileName
  }

  if($null -eq $TerraformOptions.TerraformDir){
    throw "Terraform Directory not supplied!"
  }

  if(-not (Test-Path -Path $TerraformOptions.TerraformDir -PathType Container))
  {
    throw "Terraform Directory not found!"
  }

  $currentDir = Get-Location
  Push-Location $currentDir
  Set-Location $TerraformOptions.TerraformDir

  try {

    $terraformCommand = "terraform init"
    Invoke-Expression $terraformCommand

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Terraform init failed."
    }

    $terraformCommand = "terraform -chdir=`"{0}`" plan -out=`"$planFile`"" -f (Get-Location)

    # append any var args
    if($TerraformOptions.Vars.Length -gt 0) {
      foreach ($key in $TerraformOptions.Vars.Keys) {
        $value = $TerraformOptions.Vars[$key]
        $terraformCommand += " -var `"$key=$value`""
      }
    }

    # appends any var-file args
    if($TerraformOptions.VarFiles.Length -gt 0) {
      foreach ($val in $TerraformOptions.VarFiles) {
        $terraformCommand += " -var-file=`"$val`""
      }
    }

    Invoke-Expression $terraformCommand    

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Terraform plan failed."
    }

    #### Convert plan file to json ####
    $jsonFilePath = Join-Path (Get-Location) $jsonFile
    $terraformCommand = "terraform -chdir=`"{0}`" show -json `"$planFile`""  -f (Get-Location)         
    Invoke-Expression $terraformCommand | Out-File -FilePath $jsonFilePath
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Converting plan to json failed."
    }
  } 
  catch 
  {
    if ($Error.Count -gt 0) {
      Write-Output $Error[0].ToString()
    }
  }
  Pop-Location 
}

<#
  Description: Converts a terraform execution plan to a json.
#>
function Invoke-TerraformShowJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [object]$TerraformOptions,
    [Parameter(Mandatory=$true)]
    [string]$JsonFileName
  )

  $planFile = "tf.plan"
  if($null -ne $TerraformOptions.PlanFileName)
  {
    $planFile = $TerraformOptions.PlanFileName
  }

  $jsonFile = "tfplan.json"
  if($null -ne $TerraformOptions.JsonFileName)
  {
    $jsonFile = $TerraformOptions.JsonFileName
  }

  
  if($null -eq $TerraformOptions.TerraformDir){
    throw "Terraform Directory not supplied!"
  }

  if(-not (Test-Path -Path $TerraformOptions.TerraformDir -PathType Container))
  {
    throw "Terraform Directory not found!"
  }

  # Store current working directory before switching tf dir
  $currentDir = Get-Location
  Push-Location $currentDir
  Set-Location $TerraformOptions.TerraformDir

  try {
    $jsonFilePath = Join-Path (Get-Location) $jsonFile

    # Run terraform show with json flag
    $terraformCommand = "terraform -chdir=`"{0}`" show -json `"$planFile`""  -f (Get-Location) 
        
    Invoke-Expression $terraformCommand | Out-File -FilePath $jsonFilePath

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Terraform show failed!"
    }
  } 
  catch 
  {
    if ($Error.Count -gt 0) {
      Write-Output $Error[0].ToString()
    }
  }
  # Restore original location
  Pop-Location 
}

function Invoke-PesterTests {

  Param(
    [Parameter(Mandatory=$true)]
    [object]$TerraformOptions,    
    [Parameter(Mandatory = $true)]
    [string] $TestFixtures
  )

  try {

    if (-not (Test-Path $TestFixtures)) {
        throw "Unable to find test folder '$TestFixtures'."
    }
  
    # Check that Pester module is imported
    if (-not (Get-Module "Pester")) {
      Import-Module Pester
    }
  
    # Run the plan
    Invoke-TerraformInitAndPlan -TerraformOptions $TerraformOptions

    # 
    $configuration = [PesterConfiguration] @{
      Run    = @{ Path = $TestFixtures; PassThru = $true }
      Output = @{ Verbosity = "Detailed"; RenderMode = "Plaintext" }
    }

    # Switch ErrorActionPreference to Stop temporary to make sure that tests will fail on silent errors too
    $backupErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    $results = Invoke-Pester -Configuration $configuration
    $ErrorActionPreference = $backupErrorActionPreference
    
    # Fail in case if no tests are run
    if (-not ($results -and ($results.FailedCount -eq 0) -and (($results.PassedCount + $results.SkippedCount) -gt 0))) {
      $results
      throw "Test run has failed"
    }
  }
  catch {
    if ($Error.Count -gt 0) {
      Write-Output $Error[0].ToString()
    }
  }

}

$terraformOptions = @{
  Vars = @{
      "website_name"   = "testwebsiteaaa"
  }
  #VarFiles     = "./tf_1.tfvars","./tf_2.tfvars"
  #PlanFileName = "terraform.tfplan"
  TerraformDir = "./fixtures/v1/"
  #JsonFileName = "tfplan.json"
}

Invoke-PesterTests -TerraformOptions $terraformOptions -TestFixtures './tests'