resource "azurerm_cognitive_account" "cognitive_account" {
  name                = local.cognitive_account_name
  location            = var.location
  resource_group_name = local.resource_group_name
  kind                = var.cognitive_account.kind
  sku_name            = try(var.cognitive_account.sku_name, "S0")

  # Optional top-level arguments
  custom_subdomain_name                       = try(var.cognitive_account.custom_subdomain_name, null)
  dynamic_throttling_enabled                  = try(var.cognitive_account.dynamic_throttling_enabled, null)
  fqdns                                       = try(var.cognitive_account.fqdns, null)
  local_auth_enabled                          = try(var.cognitive_account.local_auth_enabled, true)
  metrics_advisor_aad_client_id               = try(var.cognitive_account.metrics_advisor_aad_client_id, null)
  metrics_advisor_aad_tenant_id               = try(var.cognitive_account.metrics_advisor_aad_tenant_id, null)
  metrics_advisor_super_user_name             = try(var.cognitive_account.metrics_advisor_super_user_name, null)
  metrics_advisor_website_name                = try(var.cognitive_account.metrics_advisor_website_name, null)
  outbound_network_access_restricted          = try(var.cognitive_account.outbound_network_access_restricted, false)
  project_management_enabled                  = try(var.cognitive_account.project_management_enabled, false)
  public_network_access_enabled               = try(var.cognitive_account.public_network_access_enabled, true)
  qna_runtime_endpoint                        = try(var.cognitive_account.qna_runtime_endpoint, null)
  custom_question_answering_search_service_id = try(var.cognitive_account.custom_question_answering_search_service_id, null)
  # custom_question_answering_search_service_key is marked `sensitive` in the
  # azurerm provider's own resource schema (verified via `terraform providers
  # schema -json`), so Terraform already redacts it from plan/apply output and
  # state diffs without any extra handling here.
  custom_question_answering_search_service_key = try(var.cognitive_account.custom_question_answering_search_service_key, null)

  # identity block — required when customer_managed_key is set
  dynamic "identity" {
    for_each = try(var.cognitive_account.identity, null) != null ? [1] : []
    content {
      type         = var.cognitive_account.identity.type
      identity_ids = try(var.cognitive_account.identity.identity_ids, [])
    }
  }

  # network_acls — requires custom_subdomain_name when set
  dynamic "network_acls" {
    for_each = try(var.cognitive_account.network_acls, null) != null ? [1] : []
    content {
      bypass         = try(var.cognitive_account.network_acls.bypass, null)
      default_action = var.cognitive_account.network_acls.default_action
      ip_rules       = try(var.cognitive_account.network_acls.ip_rules, null)

      dynamic "virtual_network_rules" {
        for_each = local.vnet_rules
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, false)
        }
      }
    }
  }

  # network_injection — only applicable when kind = "AIServices"
  dynamic "network_injection" {
    for_each = try(var.cognitive_account.network_injection, null) != null ? [1] : []
    content {
      scenario  = var.cognitive_account.network_injection.scenario
      subnet_id = var.cognitive_account.network_injection.subnet_id
    }
  }

  # customer_managed_key — requires identity block with UserAssigned type
  dynamic "customer_managed_key" {
    for_each = try(var.cognitive_account.customer_managed_key, null) != null ? [1] : []
    content {
      key_vault_key_id   = var.cognitive_account.customer_managed_key.key_vault_key_id
      identity_client_id = try(var.cognitive_account.customer_managed_key.identity_client_id, null)
    }
  }

  # storage — not supported for kind = "OpenAI"
  dynamic "storage" {
    for_each = local.storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = try(storage.value.identity_client_id, null)
    }
  }

  tags = merge(var.tags, try(var.cognitive_account.tags, {}))
}
