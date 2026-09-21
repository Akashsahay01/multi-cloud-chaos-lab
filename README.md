# Multi-Cloud Chaos Lab

Reusable, safety-first chaos engineering examples for AWS and Azure using Terraform.

## What this project does

Multi-Cloud Chaos Lab provides small, understandable examples for engineers who want to practice resilience testing in isolated cloud environments.

The initial examples cover:

- AWS EC2 CPU stress
- AWS EC2 network disruption
- AWS Auto Scaling instance termination
- Azure VM shutdown
- Azure VM Scale Set instance disruption

The project is designed for **sandbox/test environments**. It intentionally avoids destructive production defaults.

## Project status

Early-stage open-source project. More experiments, validation, documentation and community examples will be added over time.

## Safety

Chaos experiments can interrupt workloads, consume cloud resources and cause data loss if used incorrectly.

**Never run an experiment against production unless you have explicitly reviewed the blast radius and obtained the required approval.**

Before running an experiment:

1. Confirm the target is a test/sandbox resource.
2. Review the Terraform plan.
3. Confirm IAM/RBAC permissions.
4. Understand the expected impact.
5. Define a rollback/recovery procedure.
6. Monitor the target during the experiment.

## Structure

```text
aws/
  ec2/
  network/
  asg/

azure/
  vm/
  vmss/

docs/
examples/
modules/
.github/workflows/
```

## Prerequisites

- Terraform >= 1.6
- AWS CLI for AWS examples
- Azure CLI for Azure examples
- An isolated AWS/Azure test account or subscription
- Appropriate IAM/RBAC permissions

## Roadmap

- Add AWS FIS experiment templates
- Add Azure Chaos Studio examples
- Add network latency and packet-loss scenarios
- Add EKS and AKS experiments
- Add validation tests
- Add GitHub Actions checks
- Add experiment metadata and hypothesis templates
- Add contribution examples from the community

## Contributing

Issues, documentation improvements, new experiments and safety improvements are welcome. See `CONTRIBUTING.md`.

## License

Apache-2.0. See `LICENSE`.
