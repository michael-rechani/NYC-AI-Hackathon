variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for the Azure Bastion subnet"
  type        = string
}

variable "jumpbox_subnet_prefix" {
  description = "Address prefix for the jumpbox subnet"
  type        = string
}

variable "privateendpoint_subnet_prefix" {
  description = "Address prefix for the private endpoint subnet"
  type        = string
}

# Bastion Variables
variable "bastion_name" {
  description = "Name of the Azure Bastion"
  type        = string
}

variable "bastion_sku" {
  description = "SKU for Azure Bastion (Basic, Standard, or Premium)"
  type        = string
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.bastion_sku)
    error_message = "bastion_sku must be 'Basic', 'Standard', or 'Premium'"
  }
}

# Jumpbox Variables
variable "jumpbox_name" {
  description = "Name of the jumpbox VM"
  type        = string
}

variable "jumpbox_vm_size" {
  description = "VM size for the jumpbox"
  type        = string
}

variable "jumpbox_image" {
  description = "Source image reference for the jumpbox VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "jumpbox_zone" {
  description = "Availability zone for the jumpbox VM (1, 2, 3, or null)"
  type        = string
}

# Key Vault Variables
variable "key_vault_name" {
  description = "Name of the Key Vault (3-24 chars, alphanumeric + hyphens)"
  type        = string
}

variable "key_vault_sku" {
  description = "SKU for Key Vault (standard or premium)"
  type        = string
}

variable "key_vault_purge_protection" {
  description = "Enable purge protection for Key Vault (cannot be reversed)"
  type        = bool
}

variable "key_vault_soft_delete_days" {
  description = "Number of days to retain soft-deleted secrets (7-90)"
  type        = number
}

variable "key_vault_allowed_ips" {
  description = "Additional public IPs to allow access to Key Vault (CIDR notation, e.g. ['203.0.113.5/32']). The Terraform executor's IP is automatically added."
  type        = list(string)
  default     = []
}



# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
