variable "name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Resource ID for a subnet."
}

variable "asg_id" {
  type        = string
  description = "Optional resource ID for an application security group"
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

//=============================================================

variable "size" {
  default = "Standard_D2s_v3"
}

variable "location" {
  default = "UK South"
}

//=============================================================

variable "admin_username" {
  default = "arcdemo"
}

variable "admin_ssh_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_label_prefix" {
  type        = string
  default     = ""
  description = "Prefix to make the FQDN unique. Will default to arclinuxvm-<uniq> where uniq is a short hash based on the resource group ID."
}

//=============================================================

variable "arc" {
  description = "Object desribing the service principal and resource group for the Azure Arc connected machines."
  type = object({
    tenant_id                = string
    subscription_id          = string
    service_principal_appid  = string
    service_principal_secret = string
    resource_group_name      = string
    location                 = string
  })

  default = {
    tenant_id                = null
    subscription_id          = null
    service_principal_appid  = null
    service_principal_secret = null
    resource_group_name      = null
    location                 = null
  }
}