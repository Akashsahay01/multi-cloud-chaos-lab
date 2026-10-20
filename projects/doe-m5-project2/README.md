# DOE Module 5 Project 2 — Multi-Environment Deployment Pipeline

This project demonstrates an application deployment pipeline using an immutable EC2 image, Terraform, Bash validation scripts, and GitHub Actions. The local checks and CI workflow have been exercised; a real AWS AMI build and deployment have **not** yet been verified.

**Branch:** `doe-m5-project2`

## Assessment mapping

| Task | Implementation | Evidence and current limitations |
|---|---|---|
| 1 — Immutable infrastructure (S5) | Packer installs the Python application and configures its systemd service in an Amazon Linux 2023 AMI. Terraform provisions EC2 from an explicit AMI ID. | Packer and Terraform configuration are in the repository. Terraform validation and local Floci infrastructure tests have passed. A real AWS AMI build and deployment have not yet been verified. |
| 2 — Automation scripts (K13) | The Bash health-check script retries requests to the application endpoint and exits unsuccessfully if the endpoint does not return the expected healthy response. The AWS CLI inspection script displays the authenticated identity and tagged project instances. | Local health-check success and failure paths were exercised. See `evidence/DOE-M5-Project2/04-health-check-success.png` and `05-health-check-failure.png`. |
| 3 — CI/CD promotion (S15) | GitHub Actions runs application tests and infrastructure formatting/validation. Separate manually triggered image-build and deployment workflows support staging and production. The deployment workflow accepts an explicit AMI ID and application version. | A successful CI run is captured in `evidence/DOE-M5-Project2/06-github-actions-ci-success.png`. Real AWS image builds and staging-to-production promotion have not yet been verified. |
| 4 — Validation and recovery | Application health checks validate the endpoint. After a successful Terraform apply, the deployment workflow runs a health check and includes conditional rollback logic that attempts to restore the previously deployed AMI if a later step fails and a previous AMI was captured. | Local application and health-check tests are captured in `evidence/DOE-M5-Project2/04-health-check-success.png`, `05-health-check-failure.png`, and `07-local-app-health-check.png`. The rollback workflow has not been verified through a real AWS deployment failure and recovery test. A first deployment has no previous AMI to restore. |

## Layout

- `app/`: Python HTTP application and application test.
- `packer/`: Amazon Linux 2023 AMI template.
- `terraform/`: EC2 and security-group resources for staging/production.
- `scripts/`: health-check and AWS CLI inspection scripts.
- `.github/workflows/`: CI, AMI build, Terraform validation, and deployment workflows.
- `evidence/DOE-M5-Project2/`: screenshots of local validation and CI/test results.

## Safety and prerequisites

- Use an approved sandbox AWS account and confirm the AWS account and region before deploying.
- Restrict TCP/8080 ingress to your own public IP as a `/32`; never open it to `0.0.0.0/0`.
- Build a real AMI and supply its exact ID. Do not use a placeholder AMI ID.
- Configure GitHub Actions OIDC and least-privilege IAM roles. Do not store long-lived AWS access keys in the repository.
- EC2, AMI storage, and related resources can incur charges. Review resources and clean up assessment resources when finished.
- The learning setup does not guarantee zero downtime. An ALB and multiple instances would be needed for a more realistic low-downtime deployment.

## GitHub Actions setup before deployment

The CI workflow runs without AWS credentials. The image-build and deployment workflows require GitHub Environments and OIDC roles to be configured first.

Create these GitHub Environments: `image-build`, `staging`, and `production`. Configure environment variables as follows:

- `AWS_IMAGE_BUILD_ROLE_ARN` in `image-build`: IAM role allowed to build the AMI using Packer.
- `AWS_DEPLOY_ROLE_ARN` in `staging` and `production`: least-privilege role for the deployment workflow.
- `AWS_REGION` in each environment, for example `eu-west-2`.
- `ALLOWED_CIDR` in staging/production: your public IP as a `/32` CIDR.
- `TF_STATE_BUCKET` in staging/production: an existing S3 bucket for remote Terraform state, with encryption and versioning enabled. The workflow uses separate state keys per environment.

Configure an OIDC trust policy scoped to this repository and the appropriate branch and/or GitHub Environment. The state bucket must already exist, and the deployment role must have access to the relevant state objects. Configure required reviewers on the `production` GitHub Environment to add an approval gate. Do not run deployment until these prerequisites are configured and the generated Terraform plan has been reviewed.

The deployment workflow is manually triggered and accepts a concrete AMI ID, application version, and target environment. Build the AMI with the image-build workflow first. The deployment workflow contains conditional rollback logic, but **rollback has not been tested against a real AWS deployment failure**. Do not use this learning pipeline for production workloads.

## Local checks

Run these commands from the repository root:

```bash
python3 projects/doe-m5-project2/app/test_app.py
terraform -chdir=projects/doe-m5-project2/terraform fmt -check -recursive
terraform -chdir=projects/doe-m5-project2/terraform init -backend=false
terraform -chdir=projects/doe-m5-project2/terraform validate
packer fmt -check projects/doe-m5-project2/packer/app-image.pkr.hcl
```

The local Floci test uses an AWS emulator; it does not prove that the same resources or workflows work in a real AWS account. Terraform 1.6+ and Packer with the Amazon plugin are required for infrastructure validation and image builds.
