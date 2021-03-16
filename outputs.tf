output "linux_ssh_commands" {
  value = { for name in local.linux_vm_names :
  name => module.linux_vms[name].ssh_command }
}

output "linux_fqdns" {
  value = { for name in local.linux_vm_names :
  name => module.linux_vms[name].fqdn }
}

output "windows_fqdns" {
  value = { for name in local.windows_vm_names :
  name => module.windows_vms[name].fqdn }
}

output "admin_username" {
  value     = var.admin_username
}


output "windows_admin_password" {
  value     = local.windows_admin_password
  sensitive = true
}

output "uniq" {
  value = local.uniq
}

resource "local_file" "ansible" {
  for_each = toset(var.create_ansible_hosts ? ["hosts"] : [])

  content = templatefile("${path.root}/hosts.tpl", {
    linux_fqdns = [
      for name in local.linux_vm_names :
      module.linux_vms[name].fqdn
    ],
    windows_fqdns = [
      for name in local.windows_vm_names :
      module.windows_vms[name].fqdn
    ],
    username = var.admin_username,
    password = local.windows_admin_password
  })

  filename        = "${path.root}/hosts"
  file_permission = 644
}
