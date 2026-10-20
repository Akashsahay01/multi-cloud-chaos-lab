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
- `scripts/`: health checks and AWS CLI inspection.
- `.github/workflows/`: CI and deployment workflows.

## Safety and prerequisites

- Use a sandbox AWS account and confirm the account/region before deploying.
- Restrict TCP/8080 ingress to your own public IP as `/32`; never open it to `0.0.0.0/0`.
- Build a real AMI and supply its exact ID. Do not use the example placeholder ID.
- Configure GitHub Actions OIDC and a least-privilege IAM role; do not store long-lived AWS keys in the repository.
- EC2, AMI storage and related resources can incur charges. Clean up project resources after assessment.
- This small learning setup does not by itself guarantee zero downtime. An ALB and multiple instances would be needed for a more realistic low-downtime deployment.

## GitHub Actions setup before deployment\n\nThe CI workflow runs without AWS credentials. The image-build and deployment workflows require GitHub Environments and OIDC roles to be configured first.\n\nCreate these GitHub Environments: `image-build`, `staging`, and `production`. Configure environment variables as follows:\n\n- `AWS_IMAGE_BUILD_ROLE_ARN` in `image-build`: IAM role allowed to build the AMI using Packer.\n- `AWS_DEPLOY_ROLE_ARN` in `staging` and `production`: least-privilege role for the deployment workflow.\n- `AWS_REGION` in each environment, e.g. `eu-west-2`.\n- `ALLOWED_CIDR` in staging/production: your public IP as a `/32` CIDR.\n- `TF_STATE_BUCKET` in staging/production: an existing S3 bucket for remote Terraform state, with encryption and versioning enabled. The workflow uses separate state keys per environment.\n\nConfigure an OIDC trust policy scoped to this repository, branch and/or GitHub Environment. The state bucket must already exist and the role must have access to the relevant state object. Configure required reviewers on the `production` GitHub Environment to add an approval gate. Do not run the deployment workflow until these prerequisites are configured and the generated Terraform plan has been reviewed.\n\nThe deployment workflow is manually triggered and accepts a concrete AMI ID and version. Build the AMI with the image-build workflow first. **This scaffold does not yet automatically roll back a deployment after a post-deployment health-check failure**; until that recovery behaviour is implemented and tested, treat Task 4 as incomplete and do not use this for production workloads.\n\n## Local checks

From the repository root:

```bash
python3 projects/doe-m5-project2/app/test_app.py
terraform -chdir=projects/doe-m5-project2/terraform fmt -check
terraform -chdir=projects/doe-m5-project2/terraform init -backend=false
terraform -chdir=projects/doe-m5-project2/terraform validate
packer fmt -check projects/doe-m5-project2/packer/app-image.pkr.hcl
```

Terraform 1.6+ and Packer with the Amazon plugin are required for infrastructure validation/building.
