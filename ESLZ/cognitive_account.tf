terraform {
  required_version = ">= 1.9"
}

variable "cognitive_accounts" {
  description = "Map of Cognitive Services Account configuration objects"
  type        = any
  default     = {}
}

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
