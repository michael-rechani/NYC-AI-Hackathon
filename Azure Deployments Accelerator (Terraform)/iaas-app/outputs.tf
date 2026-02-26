output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.iaas.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.virtual_network.name
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = module.virtual_network.subnets["web"].resource_id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = module.virtual_network.subnets["data"].resource_id
}

output "web_vm_id" {
  description = "ID of the web VM"
  value       = module.web_vm.resource_id
}

output "web_vm_name" {
  description = "Name of the web VM"
  value       = module.web_vm.name
}

output "sql_vm_id" {
  description = "ID of the SQL VM"
  value       = module.sql_vm.resource_id
}

output "sql_vm_name" {
  description = "Name of the SQL VM"
  value       = module.sql_vm.name
}
