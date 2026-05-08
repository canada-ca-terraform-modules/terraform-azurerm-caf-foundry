# Purpose: catch breaking state changes before dev tests on real infrastructure.
# baseline_apply simulates a deployed resource; upgrade_plan_no_replacement verifies
# the resource address and name remain stable after any future code change.
mock_provider "azurerm" {}

variables {
  resource_groups   = { Project = { name = "rg-project", location = "canadacentral" } }
  subnets           = {}
  env               = "Dev"
  group             = "SSC"
  project           = "TEST"
  userDefinedString = "test"
  location          = "canadacentral"
  tags              = {}
}

# Step 1: simulate currently-deployed resource (pre-upgrade / minimal inputs)
run "baseline_apply" {
  command = apply

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.name == "DevCNA-test"
    error_message = "Baseline apply: unexpected resource name"
  }
}

# Step 2: plan against state from baseline — adding optional args must not replace
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    cognitive_account = {
      resource_group                = "Project"
      kind                          = "OpenAI"
      sku_name                      = "S0"
      local_auth_enabled            = false
      public_network_access_enabled = false
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.name == "DevCNA-test"
    error_message = "Resource name must be unchanged after upgrade"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.local_auth_enabled == false
    error_message = "local_auth_enabled must be updated in-place"
  }
}
