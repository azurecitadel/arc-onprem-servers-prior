variable "linux_vm_names" {
  type    = list(string)
  default = []
}

variable "linux_prefix" {
  type    = string
  default = "ubuntu"
}

variable "linux_count" {
  type    = number
  default = 0
}

variable "linux_size" {
  type    = string
  default = "Standard_A1_v2"
}

variable "windows_vm_names" {
  type    = list(string)
  default = []
}

variable "windows_prefix" {
  type    = string
  default = "win"
}

variable "windows_count" {
  type    = number
  default = 0
}

variable "windows_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "create_ansible_hosts" {
  type    = bool
  default = false
}

//========================================

variable "resource_group_name" {
  default = "arc-hack"
}

variable "location" {
  default = "UK South"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin_username" {
  type    = string
  default = "arcadmin"
}

variable "admin_ssh_key_file" {
  default = "~/.ssh/id_rsa.pub"
}
