#Install-Module -Name Pester -Force -SkipPublisherCheck

Describe "Terraform Plan Validation" {
  BeforeAll {
      # Load the Terraform plan JSON
      $planPath = "./fixtures/v1/tfplan.json"
      $planContent = Get-Content -Path $planPath -Raw
      $plan = $planContent | ConvertFrom-Json

      # Extract resources from the plan
      $resources = $plan.planned_values.root_module.child_modules.resources
  }

  It "Should have an Azure Storage Account with the name 'testwebsiteaaa'" {
      $storageAccount = $resources | Where-Object { $_.type -eq "azurerm_storage_account" -and $_.name -eq "main" }
      $storageAccount.values.name | Should -Be "testwebsiteaaa"
  }

  It "Azure Storage Account min_tls_version should be set to 'TLS1_2'" {
      $storageAccount = $resources | Where-Object { $_.type -eq "azurerm_storage_account" -and $_.name -eq "main" }
      $storageAccount.values.min_tls_version | Should -Be "TLS1_1"
  }

  It "Should have an Azure Resource Group with the name 'testwebsiteaaa-staging-rg'" {
      $resourceGroup = $resources | Where-Object { $_.type -eq "azurerm_resource_group" -and $_.name -eq "main" }
      $resourceGroup.values.name | Should -Be "testwebsiteaaa-staging-rg"
  }
}


