output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.hub.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.virtual_network.name
}

output "bastion_subnet_id" {
  description = "ID of the Azure Bastion subnet"
  value       = module.virtual_network.subnets["bastion"].resource_id
}

output "jumpbox_subnet_id" {
  description = "ID of the jumpbox subnet"
  value       = module.virtual_network.subnets["jumpbox"].resource_id
}

output "bastion_id" {
  description = "ID of the Azure Bastion"
  value       = module.bastion.resource_id
}

output "jumpbox_id" {
  description = "ID of the jumpbox VM"
  value       = module.jumpbox.resource_id
}

output "jumpbox_name" {
  description = "Name of the jumpbox VM"
  value       = module.jumpbox.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.key_vault.resource_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.uri
}

output "privateendpoint_subnet_id" {
  description = "ID of the private endpoint subnet"
  value       = module.virtual_network.subnets["privateendpoint"].resource_id
}

output "key_vault_private_dns_zone_id" {
  description = "ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.key_vault.id
}

output "key_vault_private_dns_zone_name" {
  description = "Name of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.key_vault.name
}

