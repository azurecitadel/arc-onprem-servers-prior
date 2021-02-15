output "linux" {
  value = { for name in var.linux_vm_names:
    name => module.linux_vms[name].ssh_command }
}