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

# ── storage block (single object format) ─────────────────────────────────────
run "with_storage_single_object" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "AIServices"
      sku_name       = "S0"
      storage = {
        storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/mystorage"
        identity_client_id = "00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.storage) == 1
    error_message = "storage block must be rendered from a single object"
  }

  assert {
    condition     = tolist(azurerm_cognitive_account.cognitive_account.storage)[0].identity_client_id == "00000000-0000-0000-0000-000000000000"
    error_message = "storage.identity_client_id must be set from the single object format"
  }
}

# ── storage block (list format) ───────────────────────────────────────────────
run "with_storage_list" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "AIServices"
      sku_name       = "S0"
      storage = [
        {
          storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/mystorage"
        }
      ]
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.storage) == 1
    error_message = "storage block must be rendered from a list"
  }
}

# ── Without storage — no storage block emitted ────────────────────────────────
run "no_storage" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.storage) == 0
    error_message = "storage block must not be rendered when storage is not set"
  }
}

# ── network_injection block (AIServices only) ─────────────────────────────────
run "with_network_injection" {
  command = plan

  variables {
    cognitive_account = {
      resource_group        = "Project"
      kind                  = "AIServices"
      sku_name              = "S0"
      custom_subdomain_name = "myaiservice"
      network_injection = {
        scenario  = "agent"
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/agent-subnet"
      }
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.network_injection) > 0
    error_message = "network_injection block must be rendered when network_injection is set"
  }
}

# ── Without network_injection — no network_injection block emitted ───────────
run "no_network_injection" {
  command = plan

  variables {
    cognitive_account = {
      resource_group = "Project"
      kind           = "OpenAI"
      sku_name       = "S0"
    }
  }

  assert {
    condition     = length(azurerm_cognitive_account.cognitive_account.network_injection) == 0
    error_message = "network_injection block must not be rendered when network_injection is not set"
  }
}

# ── network_acls.virtual_network_rules — subnet looked up by name ────────────
run "with_virtual_network_rules_by_name" {
  command = plan

  variables {
    subnets = {
      OZ = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/OZ" }
    }
    cognitive_account = {
      resource_group        = "Project"
      kind                  = "OpenAI"
      sku_name              = "S0"
      custom_subdomain_name = "myopenai"
      network_acls = {
        default_action = "Deny"
        virtual_network_rules = {
          subnet_id = "OZ"
        }
      }
    }
  }

  assert {
    condition     = tolist(tolist(azurerm_cognitive_account.cognitive_account.network_acls)[0].virtual_network_rules)[0].subnet_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/OZ"
    error_message = "virtual_network_rules.subnet_id must resolve a subnet name via var.subnets"
  }
}

# ── network_acls.virtual_network_rules — subnet passed as ARM ID ─────────────
run "with_virtual_network_rules_by_id" {
  command = plan

  variables {
    cognitive_account = {
      resource_group        = "Project"
      kind                  = "OpenAI"
      sku_name              = "S0"
      custom_subdomain_name = "myopenai"
      network_acls = {
        default_action = "Deny"
        virtual_network_rules = {
          subnet_id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/OZ"
          ignore_missing_vnet_service_endpoint = true
        }
      }
    }
  }

  assert {
    condition     = tolist(tolist(azurerm_cognitive_account.cognitive_account.network_acls)[0].virtual_network_rules)[0].subnet_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/OZ"
    error_message = "virtual_network_rules.subnet_id must pass through a full ARM ID unchanged"
  }

  assert {
    condition     = tolist(tolist(azurerm_cognitive_account.cognitive_account.network_acls)[0].virtual_network_rules)[0].ignore_missing_vnet_service_endpoint == true
    error_message = "virtual_network_rules.ignore_missing_vnet_service_endpoint must be set"
  }
}

# ── Remaining scalar optional arguments ───────────────────────────────────────
run "with_optional_scalars" {
  command = plan

  variables {
    cognitive_account = {
      resource_group                               = "Project"
      kind                                         = "TextAnalytics"
      sku_name                                     = "S0"
      dynamic_throttling_enabled                   = true
      fqdns                                        = ["example.com"]
      qna_runtime_endpoint                         = "https://example.qnamaker.ai"
      custom_question_answering_search_service_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Search/searchServices/mysearchservice"
      custom_question_answering_search_service_key = "search-service-key"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.dynamic_throttling_enabled == true
    error_message = "dynamic_throttling_enabled must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.fqdns[0] == "example.com"
    error_message = "fqdns must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.qna_runtime_endpoint == "https://example.qnamaker.ai"
    error_message = "qna_runtime_endpoint must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.custom_question_answering_search_service_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Search/searchServices/mysearchservice"
    error_message = "custom_question_answering_search_service_id must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.custom_question_answering_search_service_key == "search-service-key"
    error_message = "custom_question_answering_search_service_key must be set"
  }
}

# ── metrics_advisor_* arguments (kind = MetricsAdvisor) ───────────────────────
run "with_metrics_advisor" {
  command = plan

  variables {
    cognitive_account = {
      resource_group                  = "Project"
      kind                            = "MetricsAdvisor"
      sku_name                        = "S0"
      metrics_advisor_aad_client_id   = "00000000-0000-0000-0000-000000000000"
      metrics_advisor_aad_tenant_id   = "11111111-1111-1111-1111-111111111111"
      metrics_advisor_super_user_name = "admin"
      metrics_advisor_website_name    = "myadvisor"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.metrics_advisor_aad_client_id == "00000000-0000-0000-0000-000000000000"
    error_message = "metrics_advisor_aad_client_id must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.metrics_advisor_aad_tenant_id == "11111111-1111-1111-1111-111111111111"
    error_message = "metrics_advisor_aad_tenant_id must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.metrics_advisor_super_user_name == "admin"
    error_message = "metrics_advisor_super_user_name must be set"
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.metrics_advisor_website_name == "myadvisor"
    error_message = "metrics_advisor_website_name must be set"
  }
}
