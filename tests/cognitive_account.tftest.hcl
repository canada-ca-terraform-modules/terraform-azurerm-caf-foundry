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

# ── Naming convention ────────────────────────────────────────────────────────
run "naming_convention" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.name == "DevCNA-test"
    error_message = "Name must follow {env}{serverType}-{userDefinedString} convention. Got: ${azurerm_cognitive_account.cognitive_account.name}"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.kind == "OpenAI"
    error_message = "Kind must be OpenAI"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.sku_name == "S0"
    error_message = "SKU must be S0"
  }
}

# ── Custom serverType override in name ───────────────────────────────────────
run "custom_server_type" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "AIServices"
      sku_name       = "S0"
      serverType     = "AIS"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.name == "DevAIS-test"
    error_message = "Custom serverType must appear in name. Got: ${azurerm_cognitive_account.cognitive_account.name}"
  }
}

# ── Explicit name override pins existing resource ─────────────────────────────
run "name_override" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
      name           = "my-existing-cognitive-account"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.name == "my-existing-cognitive-account"
    error_message = "Explicit name override must be used as-is"
  }
}

# ── Default values ───────────────────────────────────────────────────────────
run "default_values" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "Face"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.local_auth_enabled == true
    error_message = "local_auth_enabled must default to true"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.public_network_access_enabled == true
    error_message = "public_network_access_enabled must default to true"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.outbound_network_access_restricted == false
    error_message = "outbound_network_access_restricted must default to false"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.project_management_enabled == false
    error_message = "project_management_enabled must default to false"
  }
}

# ── Identity block ───────────────────────────────────────────────────────────
run "with_identity" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "AIServices"
      sku_name       = "S0"
      identity = {
        type = "SystemAssigned"
      }
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.identity) > 0
    error_message = "Identity block must be rendered when identity is set"
  }
}

# ── Without identity — no identity block emitted ─────────────────────────────
run "no_identity" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.identity) == 0
    error_message = "Identity block must not be rendered when identity is not set"
  }
}

# ── network_acls block ───────────────────────────────────────────────────────
run "with_network_acls" {
  command = plan

  variables {
    cognitive_account = {
      resource_group        = "Project"
      kind                  = "OpenAI"
      sku_name              = "S0"
      custom_subdomain_name = "myopenai"
      network_acls = {
        default_action = "Deny"
        ip_rules       = ["203.0.113.10"]
      }
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.network_acls) > 0
    error_message = "network_acls block must be rendered when network_acls is set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.custom_subdomain_name == "myopenai"
    error_message = "custom_subdomain_name must be set"
  }
}

# ── Without network_acls — no network_acls block emitted ─────────────────────
run "no_network_acls" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.network_acls) == 0
    error_message = "network_acls block must not be rendered when network_acls is not set"
  }
}

# ── customer_managed_key block ───────────────────────────────────────────────
run "with_customer_managed_key" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi"]
      }
      customer_managed_key = {
        key_vault_key_id   = "https://myvault.vault.azure.net/keys/mykey/00000000000000000000000000000000"
        identity_client_id = "00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.customer_managed_key) > 0
    error_message = "customer_managed_key block must be rendered when set"
  }
}

# ── Tags merge ───────────────────────────────────────────────────────────────
run "tags_merge" {
  command = plan

  variables {
    tags = { Environment = "Dev" }
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
      tags           = { CostCentre = "12345" }
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.tags["Environment"] == "Dev"
    error_message = "Global tags must appear in merged tags"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.tags["CostCentre"] == "12345"
    error_message = "Resource-level tags must appear in merged tags"
  }
}
