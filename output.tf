output "cognitive_account_object" {
  description = "Outputs the entire Cognitive Services Account object"
  sensitive   = true
  value       = azurerm_cognitive_account.cognitive_account
}

output "cognitive_account_id" {
  description = "Outputs the ID of the Cognitive Services Account"
  value       = azurerm_cognitive_account.cognitive_account.id
}

output "cognitive_account_name" {
  description = "Outputs the name of the Cognitive Services Account"
  value       = azurerm_cognitive_account.cognitive_account.name
}

output "cognitive_account_endpoint" {
  description = "Outputs the endpoint of the Cognitive Services Account"
  value       = azurerm_cognitive_account.cognitive_account.endpoint
}

output "cognitive_account_primary_access_key" {
  description = "Outputs the primary access key of the Cognitive Services Account"
  sensitive   = true
  value       = azurerm_cognitive_account.cognitive_account.primary_access_key
}

output "cognitive_account_secondary_access_key" {
  description = "Outputs the secondary access key of the Cognitive Services Account"
  sensitive   = true
  value       = azurerm_cognitive_account.cognitive_account.secondary_access_key
}
