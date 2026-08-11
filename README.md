# terraform-azurerm-caf-cognitive_account

Deploys an Azure Cognitive Services Account following the SSC CAF naming and tagging standard. Supports all service kinds (OpenAI, AIServices, Face, ComputerVision, Speech, TextAnalytics, etc.) with configurable network ACLs, managed identity, customer-managed keys, and associated storage.

## Usage

### ESLZ module block (`ESLZ/cognitive_account.tf`)

```hcl
module "cognitive_accounts" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-foundry.git?ref=v1.1.0"
  for_each = var.cognitive_accounts

  location          = var.location
  env               = var.env
  group             = var.group
  project           = var.project
  userDefinedString = each.key
  cognitive_account = each.value
  resource_groups   = local.resource_groups_all
  subnets           = local.subnets
  tags              = var.tags
}
```

### ESLZ tfvars pattern (`ESLZ/cognitive_account.tfvars`)

```hcl
cognitive_accounts = {
  openai01 = {
    serverType     = "CNA"       # 3-char code in resource name (default: CNA)
    resource_group = "Project"   # Name from resource_groups map, or full ARM ID
    kind           = "OpenAI"    # Required: service type
    sku_name       = "S0"        # Required: SKU name
  }

  # Full example with network isolation
  aisvc01 = {
    serverType                    = "AIS"
    resource_group                = "Project"
    kind                          = "AIServices"
    sku_name                      = "S0"
    custom_subdomain_name         = "myaiservice"
    local_auth_enabled            = false
    public_network_access_enabled = false
    identity = {
      type = "SystemAssigned"
    }
    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
      ip_rules       = ["203.0.113.0/24"]
    }
  }
}
```

## Naming convention

Resource names follow the SSC CAF pattern: `{env}{serverType}-{userDefinedString}`

| Variable | Source | Length |
|---|---|---|
| `env` | `var.env` | First 4 characters |
| `serverType` | `var.cognitive_account.serverType` (default: `CNA`) | First 3 characters |
| `userDefinedString` | `var.userDefinedString` (= `each.key` in ESLZ) | First 7 characters |

Example: `env = "Dev"`, `serverType = "CNA"`, `userDefinedString = "openai01"` → `DevCNA-openai0`

Override `cognitive_account.name` to pin an existing resource to a specific name without destroy/recreate.

## TFVAR parameters

### Main block

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `serverType` | string | No | `CNA` | 3-char code for the resource name |
| `resource_group` | string | Yes | — | Resource group name or ARM resource ID |
| `kind` | string | Yes | — | Service type (OpenAI, AIServices, Face, etc.) |
| `sku_name` | string | Yes | `S0` | SKU name (S0, F0, S1, etc.) |
| `name` | string | No | generated | Override generated name to pin existing resources |
| `custom_subdomain_name` | string | No | null | Required when `network_acls` is set |
| `dynamic_throttling_enabled` | bool | No | null | Cannot be set for OpenAI or AIServices |
| `fqdns` | list(string) | No | null | Allowed FQDNs |
| `local_auth_enabled` | bool | No | `true` | Set `false` for Entra ID-only auth |
| `outbound_network_access_restricted` | bool | No | `false` | Restrict outbound access |
| `project_management_enabled` | bool | No | `false` | AIServices only |
| `public_network_access_enabled` | bool | No | `true` | Set `false` for private-only |
| `qna_runtime_endpoint` | string | No | null | QnA Maker runtime URL |
| `custom_question_answering_search_service_id` | string | No | null | TextAnalytics only |
| `custom_question_answering_search_service_key` | string | No | null | TextAnalytics only |
| `tags` | map(string) | No | `{}` | Merged with global `var.tags` |

### `identity` block

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `type` | string | Yes | — | `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned` |
| `identity_ids` | list(string) | No | `[]` | Required for UserAssigned type |

### `network_acls` block

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `default_action` | string | Yes | — | `Allow` or `Deny` |
| `bypass` | string | No | null | `None` or `AzureServices` (OpenAI, AIServices, TextAnalytics only) |
| `ip_rules` | list(string) | No | null | CIDR blocks or IP addresses |
| `virtual_network_rules` | list(object) | No | `[]` | See below |

### `network_acls.virtual_network_rules` block

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `subnet_id` | string | Yes | — | ARM resource ID of the subnet |
| `ignore_missing_vnet_service_endpoint` | bool | No | `false` | Skip missing service endpoint error |

### `network_injection` block (AIServices only)

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `scenario` | string | Yes | — | Must be `agent` |
| `subnet_id` | string | Yes | — | Agent subnet (must be in 172.\* or 192.\* range) |

### `customer_managed_key` block

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `key_vault_key_id` | string | Yes | — | Full versioned Key Vault key ID |
| `identity_client_id` | string | No | null | Client ID of the User Assigned Identity with key access |

### `storage` block (not supported for OpenAI)

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `storage_account_id` | string | Yes | — | Full ARM resource ID of the storage account |
| `identity_client_id` | string | No | null | Client ID of the managed identity for storage access |

## Outputs

| Name | Description | Sensitive |
|---|---|---|
| `cognitive_account_id` | Resource ID of the Cognitive Services Account | No |
| `cognitive_account_name` | Name of the Cognitive Services Account | No |
| `cognitive_account_endpoint` | Service endpoint URL | No |
| `cognitive_account_primary_access_key` | Primary API access key | Yes |
| `cognitive_account_secondary_access_key` | Secondary API access key | Yes |
| `cognitive_account_object` | Full resource object | Yes |

## Testing

```bash
terraform fmt -recursive && terraform init -backend=false && terraform validate && terraform test
```

Expected: all test runs pass with `0 failed`.

## CI

GitHub Actions at `.github/workflows/terraform-ci.yml` runs fmt, init, validate, tflint, and test on every PR.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cognitive_account.cognitive_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognitive_account"></a> [cognitive\_account](#input\_cognitive\_account) | Object containing all Cognitive Services Account parameters | `any` | `{}` | no |
| <a name="input_env"></a> [env](#input\_env) | (Required) 4 character string defining the environment name prefix for the Cognitive Services Account | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | (Required) Character string defining the group for the target subscription | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location for the Cognitive Services Account | `string` | `"canadacentral"` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Character string defining the project for the target subscription | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | (Required) Resource group object for the Cognitive Services Account | `any` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet objects for virtual network rules | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be applied to every associated Cognitive Services Account resource | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) User defined portion value for the name of the Cognitive Services Account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_endpoint"></a> [cognitive\_account\_endpoint](#output\_cognitive\_account\_endpoint) | Outputs the endpoint of the Cognitive Services Account |
| <a name="output_cognitive_account_id"></a> [cognitive\_account\_id](#output\_cognitive\_account\_id) | Outputs the ID of the Cognitive Services Account |
| <a name="output_cognitive_account_name"></a> [cognitive\_account\_name](#output\_cognitive\_account\_name) | Outputs the name of the Cognitive Services Account |
| <a name="output_cognitive_account_object"></a> [cognitive\_account\_object](#output\_cognitive\_account\_object) | Outputs the entire Cognitive Services Account object |
| <a name="output_cognitive_account_primary_access_key"></a> [cognitive\_account\_primary\_access\_key](#output\_cognitive\_account\_primary\_access\_key) | Outputs the primary access key of the Cognitive Services Account |
| <a name="output_cognitive_account_secondary_access_key"></a> [cognitive\_account\_secondary\_access\_key](#output\_cognitive\_account\_secondary\_access\_key) | Outputs the secondary access key of the Cognitive Services Account |
<!-- END_TF_DOCS -->
