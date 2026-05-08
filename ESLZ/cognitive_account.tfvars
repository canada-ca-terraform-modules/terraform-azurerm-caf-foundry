cognitive_accounts = {
  # Minimal example — OpenAI kind with public access
  openai01 = {
    serverType     = "CNA"     # 3-char code used in the resource name (default: CNA)
    resource_group = "Project" # Resource group name from resource_groups map, or full ARM ID
    kind           = "OpenAI"  # Required: service type (OpenAI, AIServices, Face, etc.)
    sku_name       = "S0"      # Required: SKU name (S0, F0, S1, etc.)

    # custom_subdomain_name = "myopenai"   # Required when network_acls or private endpoint is used
    # local_auth_enabled    = true         # Optional: disable for Entra ID-only auth
    # public_network_access_enabled = true # Optional: set false for private-only access

    # Optional: resource-specific tags merged with global tags
    # tags = {
    #   CostCentre = "12345"
    # }
  }

  # Full example — AIServices kind with network restrictions and identity
  # aisvc01 = {
  #   serverType     = "AIS"
  #   resource_group = "Project"
  #   kind           = "AIServices"
  #   sku_name       = "S0"
  #
  #   custom_subdomain_name             = "myaiservice"  # Required for network_acls
  #   local_auth_enabled                = false          # Entra ID-only auth
  #   public_network_access_enabled     = false
  #   outbound_network_access_restricted = true
  #   project_management_enabled        = true           # AIServices only
  #
  #   identity = {
  #     type         = "SystemAssigned"
  #     # identity_ids = []             # Required for UserAssigned or both
  #   }
  #
  #   network_acls = {
  #     default_action = "Deny"
  #     bypass         = "AzureServices"   # Only for OpenAI, AIServices, TextAnalytics
  #     ip_rules       = ["203.0.113.0/24"]
  #     virtual_network_rules = [
  #       {
  #         subnet_id                            = "/subscriptions/.../subnets/my-subnet"
  #         ignore_missing_vnet_service_endpoint = false
  #       }
  #     ]
  #   }
  #
  #   # network_injection — AIServices only; agent subnet must use 172.* or 192.*
  #   # network_injection = {
  #   #   scenario  = "agent"
  #   #   subnet_id = "/subscriptions/.../subnets/agent-subnet"
  #   # }
  #
  #   # customer_managed_key — requires UserAssigned identity
  #   # customer_managed_key = {
  #   #   key_vault_key_id   = "/subscriptions/.../keys/my-key/version"
  #   #   identity_client_id = "00000000-0000-0000-0000-000000000000"
  #   # }
  #
  #   # storage — not supported for OpenAI kind
  #   # storage = [
  #   #   {
  #   #     storage_account_id = "/subscriptions/.../storageAccounts/mystorage"
  #   #     identity_client_id = "00000000-0000-0000-0000-000000000000"
  #   #   }
  #   # ]
  #
  #   tags = {
  #     CostCentre = "12345"
  #   }
  # }
}
