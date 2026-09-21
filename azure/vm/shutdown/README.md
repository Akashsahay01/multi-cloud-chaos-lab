# Azure VM Shutdown

This reference configures the classic Azure Chaos Studio target/capability/experiment model for a controlled VM shutdown.

> Azure recommends Chaos Studio Workspaces for new resilience testing. This example keeps the classic Terraform model as a transparent reference for the underlying target, capability and experiment concepts.

## What Terraform creates

- Chaos Studio target for an existing VM.
- `Shutdown-1.0` capability.
- System-assigned managed identity.
- One shutdown action targeting the selected VM.

The module does **not** create a VM and does not execute the experiment automatically.

## Inputs

Create a `terraform.tfvars` file:

```hcl
resource_group_name = "my-sandbox-rg"
target_vm_id        = "/subscriptions/<subscription-id>/resourceGroups/my-sandbox-rg/providers/Microsoft.Compute/virtualMachines/my-sandbox-vm"
location            = "uksouth"
experiment_name     = "mcl-vm-shutdown"
```

## Deploy

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After apply, retrieve the experiment identity:

```bash
terraform output -raw experiment_principal_id
```

Grant the experiment identity only the permissions required by your approved Chaos Studio design. Review the current Microsoft RBAC guidance before applying permissions.

The experiment itself is started separately through the approved Azure Chaos Studio workflow.

The example uses:

```text
abruptShutdown = false
```

to request a graceful shutdown.

## Observe and recover

Before execution, record steady-state availability and VM/application health. During the experiment, monitor Azure Monitor and application telemetry. After completion, confirm the VM and workload return to the expected state and that alerts/recovery automation behaved as designed.

## Safety

Use only a non-production VM in an isolated subscription/resource group. Review `terraform plan`, RBAC scope, target resource ID and recovery steps before execution.

Clean up the experiment resources with:

```bash
terraform destroy
```
