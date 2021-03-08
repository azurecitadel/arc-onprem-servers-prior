[linux]
%{ for fqdn in linux_fqdns ~}
${fqdn}
%{ endfor ~}

[linux:vars]
ansible_user=${username}

[windows]
%{ for fqdn in windows_fqdns ~}
${fqdn}
%{ endfor ~}

[windows:vars]
ansible_user=${username}
ansible_password="${password}"
ansible_connection=winrm
ansible_winrm_transport=basic
ansible_port=5985
ansible_winrm_server_cert_validation=ignore
