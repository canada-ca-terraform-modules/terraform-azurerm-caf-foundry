terraform {
  required_version = ">= 1.9"
  required_providers {
    # azurerm_cognitive_account's argument schema is unchanged between v4.0.0 and
    # v5.0.1 for every argument this module exposes - confirmed by diffing the
    # provider's raw resource docs at both tags, and azurerm_cognitive_account is
    # absent from the "Breaking Changes in Resources" section of the v5.0 upgrade
    # guide: https://github.com/hashicorp/terraform-provider-azurerm/blob/v5.0.1/website/docs/guides/5.0-upgrade-guide.html.markdown
    # See CHANGELOG.md for the full upgrade summary.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}
