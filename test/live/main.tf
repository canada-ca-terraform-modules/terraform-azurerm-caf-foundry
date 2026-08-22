# no-op touch: satisfies live-test.yml's test/live/** path filter for this PR
terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {}
}

module "foundry" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env      = var.env
  group    = var.group
  project  = var.project
  location = var.location
  # The module's generated name is `{env_4}{serverType_3}-{userDefinedString_7}`
  # (see name.tf) - NOT derived from resource_group.id like Key Vault's is, and
  # Cognitive Services Account names are globally unique across Azure. Fixing
  # this to a constant string would collide between two concurrently open
  # PRs even though each has its own resource group, so pr_number is folded
  # into the (7-char-truncated) userDefinedString instead.
  userDefinedString = "lt${var.pr_number}"
  cognitive_account = var.cognitive_account
  resource_groups   = local.resource_groups # from test_dependencies.tf
  subnets           = {}
  tags              = var.tags
}
