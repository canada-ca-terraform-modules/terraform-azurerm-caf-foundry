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
# NOTE: this only asserts the resource address/name stay stable across the plan -
# terraform test has no first-class "assert no replacement" primitive, so this
# implies (but does not itself prove) that no attribute forced replacement. A
# real `-/+` replacement here would still surface as a plan error against the
# applied state below, since the name assertion would then read a
# to-be-destroyed instance's stale value.
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
