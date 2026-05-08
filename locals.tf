locals {
  # If resource_group was an ARM ID, parse the name from the ID; otherwise look up in the resource_groups map
  resource_group_name = strcontains(var.cognitive_account.resource_group, "/resourceGroups/") ? regex("[^/]+$", var.cognitive_account.resource_group) : var.resource_groups[var.cognitive_account.resource_group].name

  # Normalize storage blocks: accept a single object or a list
  _storage_raw = try(var.cognitive_account.storage, [])
  storage      = try(tolist(local._storage_raw), [local._storage_raw])

  # Normalize virtual_network_rules: accept single object or list
  # subnet_id can be a subnet name (looked up from var.subnets) or a full ARM resource ID
  _vnet_rules_raw  = try(var.cognitive_account.network_acls.virtual_network_rules, [])
  _vnet_rules_list = try(tolist(local._vnet_rules_raw), [local._vnet_rules_raw])
  vnet_rules = [
    for rule in local._vnet_rules_list : merge(rule, {
      subnet_id = strcontains(rule.subnet_id, "/resourceGroups/") ? rule.subnet_id : var.subnets[rule.subnet_id].id
    })
  ]
}
