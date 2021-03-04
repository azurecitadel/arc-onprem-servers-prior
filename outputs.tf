output "linux" {
  value = { for name in local.linux_vm_names :
  name => module.linux_vms[name].ssh_command }
}

output "windows" {
  value = { for name in local.windows_vm_names :
  name => module.windows_vms[name].fqdn }
}

output "windows_admin_password" {
  value = local.windows_admin_password
}
