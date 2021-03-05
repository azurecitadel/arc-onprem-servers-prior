# arc-onprem-servers

Repository to create "on prem" VMs for the [Azure Arc &amp; Management hack](https://www.azurecitadel.com/arc/servers-hack/).

## Overview

The repo will deploy two resource groups:

| Resource Group | Description |
|---|---|
| arc-demo | Empty, ready for your connected machines |
| arc-demo-resources | Resources for the "on prem" servers |

These default names may be overriden.

Operating systems available:

| OS | Admin User | Admin Credentials |
|---|---|---|
| Ubuntu Server 18.04 LTS | arcuser | Uses the default [SSH key pair](https://docs.microsoft.com/azure/virtual-machines/linux/mac-create-ssh-keys) unless specified |
| Windows Server 2019 | arcuser | Terraform output displays the admin password |

It will also create a vNet and a custom NSG (using ASGs) to control the ports opened up to the Windows and Linux VMs' public IPs. Note that these VMs are intended for training and demo purpose only and expose ports that should not be exposed for production workloads.

The provisioned servers are customised to remove the Azure Agent and to block the internal http endpoint for the Instance Metedata Service (IMDS). They can then be onboarded to Azure by downloading azcmagent and connecting as per the [Azure docs](https://aka.ms/AzureArcDocs).

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

## Output

Use `terraform output` to show FQDNs, SSH commands and the Windows admin password.

## Removal

To remove the resources:

```bash
terraform destroy
```

> **Note that this will remove the arc-demo resource group and therefore any resources within that resource group (such as connected machine resources) will also be deleted.**
