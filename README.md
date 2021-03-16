# arc-onprem-servers

Repository to create "on prem" VMs for the [Azure Arc &amp; Management hack](https://www.azurecitadel.com/arc/servers-hack/).

## Overview

The repo will deploy two resource groups:

| Resource Group | Description |
|---|---|
| arc-hack | Empty, ready for your connected machines |
| arc-hack-resources | Resources for the "on prem" servers |

These default names may be overridden.

Operating systems available:

| OS | Admin User | Admin Credentials |
|---|---|---|
| Ubuntu Server 18.04 LTS | arcadmin | Uses the default [SSH key pair](https://docs.microsoft.com/azure/virtual-machines/linux/mac-create-ssh-keys) unless specified |
| Windows Server 2019 | arcadmin | Terraform output displays the admin password |

> You will need an SSH key pair: <https://docs.microsoft.com/azure/virtual-machines/linux/mac-create-ssh-keys>

It will also create a vNet and a custom NSG (using ASGs) to control the ports opened up to the Windows and Linux VMs' public IPs. Note that these VMs are intended for training and demo purpose only and expose ports that should not be exposed for production workloads.

## Azure Agent and IMDS Endpoint

The provisioned servers are customised to remove the Azure Agent and to block the internal http endpoint for the Instance Metedata Service (IMDS).

They can then be onboarded to Azure by downloading azcmagent and connecting as per the [Azure docs](https://aka.ms/AzureArcDocs). If the agent and endpoint were visible to the azcmagent installation then it would abort.

You should not need to touch the resources that Terraform creates in the `arc-hack-resources` session. (You wouldn't be able to reset password etc. from the portal or run Custom Script Extensions as these all run on top of the Azure Agent.)

## Deployment

1. Login

    Login to Azure and check you are in the correct subscription context.

    ```bash
    az login
    ```

1. Clone

   ```bash
   git clone https://github.com/azurecitadel/arc-onprem-servers/
   ```

1. Directory

    Change directory to the root module.

    ```bash
    cd arc-onprem-servers
    ```

1. Edit terraform.tfvars

    Modify the terraform.tfvars as required. The default will create one VM of each type.

    Additional variables are defined in variables.tf with sensible defaults.

1. Deploy

    Run through the standard Terraform workflow.

    ```bash
    terraform init
    terraform validate
    terraform plan
    terraform apply
    ```

    If there are any errors then rerun the `terraform apply` and Terraform should create remaining resources.

    Once everything has been created then `terraform plan` should display

    ```text
    No changes. Infrastructure is up-to-date.
    ```

## Output

Use `terraform output` to show FQDNs, SSH commands.

The Windows admin password is a "sensitive value". Use `terraform output windows_admin_password` and the value will be displayed.

## Removal

To remove the resources:

```bash
terraform destroy
```

> **Note that this will remove the arc-hack resource group and therefore any resources within that resource group (such as connected machine resources) will also be deleted.**

## Notable variables

The variables are shown with their default value.

* linux_count = 0
* linux_prefix = "ubuntu"

    Use in combination to generate an array of linux VM names. If linux_count = 2 then the array = ["ubuntu-01","ubuntu-02"].

* windows_count = 0
* windows_prefix = "win"

    Does the same for windows VM names. Note that "windows" is not a permitted prefix as it is a trademarked word.

* linux_vm_names = []
* windows_vm_name = []

    Use these to explicitly set the individual names. Overrides the count and prefix values.

* create_ansible_hosts = false

    Set to true to create a hosts file usable by Ansible. Recommended environment variables:

    ```text
    export ANSIBLE_HOST_KEY_CHECKING=false
    export ANSIBLE_INVENTORY=$(pwd)/hosts
    ```

* resource_group_name = arc-hack
* location = "UK South"
* tags = {}
* admin_username = arcadmin
