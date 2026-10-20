# DOE Module 5 Project 2 — Multi-Environment Deployment Pipeline

This project area is an initial implementation scaffold for immutable EC2 image builds, Terraform-managed staging/production instances, scripted health checks, and GitHub Actions workflows.

**Status:** Files are being added on branch `doe-m5-project2`. They are not yet proven against your AWS account. Validate locally and review plans before applying.

## Assessment mapping

| Task | Planned implementation | Evidence |
|---|---|---|
| 1 — Immutable infrastructure (S5) | Packer builds a versioned AMI; Terraform creates instances from an explicit AMI ID; validate before replacement | Packer build, Terraform plan and deployment logs |
| 2 — Automation scripts (K13) | Bash health-check script and AWS CLI-based operational checks | Script source and console output |
| 3 — CI/CD promotion (S15) | GitHub Actions CI and environment-specific deployment stages; same AMI ID promoted | Workflow YAML, successful run and test output |
| 4 — Validation | Smoke tests, environment configuration checks and controlled failure/recovery test | Logs/screenshots proving checks and recovery |

## Layout

- `app/`: Python HTTP app and test.
- `packer/`: Amazon Linux 2023 AMI template.
- `terraform/`: EC2 and security group resources for staging/production.
- `scripts/`: health checks.
- `.github/workflows/`: CI and deployment workflows.

## Safety and prerequisites

- Use a sandbox AWS account and confirm the account/region before deploying.
- Restrict TCP/8080 ingress to your own public IP as `/32`; never open it to `0.0.0.0/0`.
- Build a real AMI and supply its exact ID. Do not use the example placeholder ID.
- Configure GitHub Actions OIDC and a least-privilege IAM role; do not store long-lived AWS keys in the repository.
- EC2, AMI storage and related resources can incur charges. Clean up project resources after assessment.
- This small learning setup does not by itself guarantee zero downtime. An ALB and multiple instances would be needed for a more realistic low-downtime deployment.

## Local checks

From the repository root:

```bash
python3 projects/doe-m5-project2/app/test_app.py
terraform -chdir=projects/doe-m5-project2/terraform fmt -check
terraform -chdir=projects/doe-m5-project2/terraform init -backend=false
terraform -chdir=projects/doe-m5-project2/terraform validate
packer fmt -check projects/doe-m5-project2/packer/app-image.pkr.hcl
```

Terraform 1.6+ and Packer with the Amazon plugin are required for infrastructure validation/building.
