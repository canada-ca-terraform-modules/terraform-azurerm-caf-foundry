locals {
  # Regex: Azure Cognitive Services Account name allows letters, digits, and hyphens only
  cognitive_account_regex = "/[^a-zA-Z0-9-]/"

  env_4               = substr(var.env, 0, 4)
  serverType_3        = substr(try(var.cognitive_account.serverType, "CNA"), 0, 3)
  userDefinedString_7 = substr(var.userDefinedString, 0, 7)

  # Generated name: {env}{serverType}-{userDefinedString}
  # Override via cognitive_account.name to pin existing resources
  cognitive_account_name = try(
    var.cognitive_account.name,
    replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_7}", local.cognitive_account_regex, "")
  )
}
