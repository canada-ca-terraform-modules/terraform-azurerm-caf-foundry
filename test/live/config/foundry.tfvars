# config/foundry.tfvars
# Tracked, ready-to-run fixture for the test/live harness - one representative
# real-usage instance, not a two-code-path engineered fixture and not a
# dormant "_" template.
#
# Mirrors the module's common path: a single OpenAI-kind Cognitive Services
# Account in the harness's own throwaway resource group, no network_acls /
# customer_managed_key / storage blocks exercised.
#
# Maintained by whoever adds a new optional input to the module: update this
# file in the same PR if you want live coverage of it, same discipline as
# updating tests/*.tftest.hcl.

env = "livetest"

cognitive_account = {
  resource_group = "live_test"
  kind           = "OpenAI"
  sku_name       = "S0"
}
