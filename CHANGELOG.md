# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Addressed PR #1 review feedback (Copilot multi-axis review):
  - Removed the no-op `lifecycle { ignore_changes = [] }` block from `module.tf` (an empty list is a no-op and gave a false impression of drift protection).
  - Added two `validation` blocks to `variable "cognitive_account"` in `variables.tf` requiring `kind` and `resource_group` to be set, so a typo'd or omitted required field fails plan with a clear message instead of silently producing a misconfigured resource. Added matching negative-path tests (`missing_kind_fails_validation`, `missing_resource_group_fails_validation`) to `tests/cognitive_account.tftest.hcl`.
  - Added a comment in `locals.tf` documenting that `storage = {}` (an empty map) normalizes to a broken `storage` block missing `storage_account_id` - callers must pass `null` or omit the key to suppress it.
  - Added a comment in `module.tf` clarifying that `custom_question_answering_search_service_key` is already marked `sensitive` in the azurerm provider's own resource schema (verified via `terraform providers schema -json`), so Terraform already redacts it from plan/apply output without further action.
  - Added a comment in `providers.tf` citing the azurerm v5.0 upgrade guide URL that the "no breaking changes for this resource" claim is based on.
  - Added `permissions: contents: read` to `.github/workflows/terraform-ci.yml` and `permissions: contents: write` to `.github/workflows/documentation.yml` (least privilege; the latter's missing `contents: write` could silently fail the `terraform-docs/gh-actions` push on repos with restricted default workflow permissions).
  - Narrowed `.github/workflows/release.yml`'s version-extraction grep to only match `ESLZ/cognitive_account.tf`'s `source =` line, so a commented-out prior `ref=` reference can no longer be picked up instead of the live one.
  - Fixed the stale `# terraform-azurerm-caf-cognitive_account` H1 in `README.md` to the actual repo name, `terraform-azurerm-caf-foundry`.
  - Added a comment in `ESLZ/cognitive_account.tf` (and the matching README.md example) noting that `local.resource_groups_all`/`local.subnets` are expected to be defined by the caller's own ESLZ root module.
  - Added a comment in `tests/upgrade_compat.tftest.hcl` clarifying that `upgrade_plan_no_replacement` implies, but does not itself prove, that no attribute forced replacement (`terraform test` has no first-class "assert no replacement" primitive).

## [1.1.0] - 2026-08-11


### Changed

- Bumped `azurerm` provider requirement in [providers.tf](providers.tf) from `~> 4.0` to `~> 5.0` to target azurerm v5.0.1.
- Corrected the self-referencing `ESLZ/cognitive_account.tf` module source (and the matching example in README.md) from the stale `terraform-azurerm-caf-cognitive_account.git` repo name to the actual repo, `terraform-azurerm-caf-foundry.git`, and bumped the `ref` to `v1.1.0`.
- Verified and bumped pinned GitHub Actions versions in `.github/workflows/terraform-ci.yml` and `.github/workflows/documentation.yml` (`actions/checkout` -> `v7.0.1`, `hashicorp/setup-terraform` -> `v4.0.1`, `terraform-linters/setup-tflint` -> `v6.3.0` / tflint `v0.64.0`, `terraform-docs/gh-actions` -> `v1.4.1`).
- Expanded `tests/cognitive_account.tftest.hcl` with coverage for the `storage`, `network_injection`, and `network_acls.virtual_network_rules` blocks, and the remaining scalar optional arguments (`fqdns`, `dynamic_throttling_enabled`, `qna_runtime_endpoint`, `custom_question_answering_search_service_id`/`_key`, and the `metrics_advisor_*` arguments under `kind = "MetricsAdvisor"`), so every documented optional argument/block has explicit `mock_provider` coverage, not only the ones touched by this upgrade.

### Added

- `.github/workflows/release.yml`: creates a GitHub release on merge to `main`, tagged with the version pinned in `ESLZ/cognitive_account.tf`'s own `?ref=`. Idempotent — a no-op if that version's release already exists.

### Notes

- `azurerm_cognitive_account`'s argument schema is unchanged between v4.0.0 and v5.0.1 for every argument this module already exposes (confirmed by diffing the provider's raw resource docs at both tags); the v5.0 provider upgrade guide's [Breaking Changes in Resources](https://github.com/hashicorp/terraform-provider-azurerm/blob/v5.0.1/website/docs/guides/5.0-upgrade-guide.html.markdown) section does not list `azurerm_cognitive_account`. No `try()`/compat-pattern changes were required in `module.tf`.
- The module already implemented the `network_injection` block and `kind = "AIServices"`, both introduced ahead of this upgrade — no additive work was needed there either.
- Azure Provider v5.0's provider-level changes (`resource_provider_registrations` defaulting to `none` instead of `legacy`, and the `enhanced_validation` block moving under `features`) apply to the root `provider "azurerm" {}` block, not to this module — callers upgrading their root configuration to azurerm v5.x should review those changes independently; this module declares no `provider` block of its own.

## [1.0.0] - initial release

- Initial scaffold of the `terraform-azurerm-caf-cognitive_account` module (`azurerm_cognitive_account`), targeting azurerm `~> 4.0`.
