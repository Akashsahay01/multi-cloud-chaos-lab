# Multi-Cloud Chaos Lab

[![Terraform Validate](https://github.com/Akashsahay01/multi-cloud-chaos-lab/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/Akashsahay01/multi-cloud-chaos-lab/actions/workflows/terraform-validate.yml)

Reusable, safety-first chaos engineering examples for AWS and Azure using Terraform.

## Why this project exists

Cloud resilience is easier to learn and standardise when failure scenarios are reproducible, infrastructure-as-code driven, explicit about blast radius, observable, and easy for another engineer to understand.

## Current experiments

| Cloud | Experiment | Fault mechanism | Status |
|---|---|---|---|
| AWS | EC2 CPU stress | AWS FIS + SSM | Ready for sandbox configuration |
| Azure | VM shutdown | Azure Chaos Studio | Ready for sandbox configuration |
| AWS | Network latency | AWS FIS + SSM | Planned |
| AWS | ASG instance termination | AWS FIS | Planned |
| Azure | VMSS instance disruption | Azure Chaos Studio | Planned |

## Safety model

**This repository is for controlled test/sandbox environments.**

Before running an experiment:

1. Confirm the target is non-production.
2. Review `terraform plan`.
3. Confirm IAM/RBAC scope.
4. Confirm the expected blast radius.
5. Confirm monitoring and abort conditions.
6. Keep a recovery procedure available.
7. Start with the smallest practical target and shortest duration.

Do not put credentials, secrets, internal company configuration or proprietary code into this repository.

## Prerequisites

- Terraform >= 1.6
- AWS CLI for AWS experiments
- Azure CLI for Azure experiments
- An isolated AWS account / Azure subscription
- Appropriate IAM / Azure RBAC permissions

## AWS: EC2 CPU stress

The AWS example uses AWS Fault Injection Simulator (FIS) with the AWS-managed Systems Manager document `AWSFIS-Run-CPU-Stress`.

The Terraform example creates the FIS experiment role and template. It does not create an EC2 instance, so you deliberately provide the target through a tag.

Example target tag:

```text
ChaosLab = cpu-stress
```

Then:

```bash
cd aws/ec2/cpu-stress
terraform init
terraform plan
terraform apply
```

Starting an FIS experiment is an explicit operational action and is documented separately.

## Azure: VM shutdown

The Azure example uses the AzureRM Terraform provider to configure the classic Azure Chaos Studio target/capability/experiment model.

Azure now recommends Chaos Studio Workspaces for new resilience testing; this repository keeps the classic model as a transparent Terraform reference.

## Experiment documentation

Every experiment should document steady state, hypothesis, target, blast radius, fault, duration, observability, abort conditions, recovery, and result.

See `docs/experiment-template.md`.

## Roadmap

### v0.1

- AWS FIS EC2 CPU stress reference
- Azure Chaos Studio VM shutdown reference
- Terraform validation in GitHub Actions
- experiment/hypothesis documentation
- contribution and issue templates
- safety guidance

### Next

- AWS network latency
- AWS packet loss
- AWS ASG termination
- Azure VMSS disruption
- EKS / AKS examples
- experiment result templates
- policy-as-code safety checks
- community-contributed scenarios

## Contributing

See `CONTRIBUTING.md`.

## License

Apache-2.0.
