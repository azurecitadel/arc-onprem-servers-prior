variable "linux_vm_names" {
  type    = list(string)
  default = []
}

variable "windows_vm_names" {
  type    = list(string)
  default = []
}

//========================================

variable "resource_group_name" {
  default = "arc-demo"
}

variable "location" {
  default = "UK South"
}

variable "tags" {
  type    = map(string)
  default = {}
}
