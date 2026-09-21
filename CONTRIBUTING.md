# Contributing

Thanks for contributing to Multi-Cloud Chaos Lab.

## Good contributions

Examples include:

- New AWS or Azure chaos experiments
- Terraform improvements
- Safety checks
- Documentation
- Test coverage
- Example architectures
- Bug fixes

## Safety requirements

Contributions must:

- clearly identify the target resource;
- document expected impact;
- include recovery/rollback guidance;
- avoid production-oriented defaults;
- never contain credentials, secrets or company-private information.

## Pull requests

Please explain:

1. What changed?
2. What failure mode does it model?
3. How was it tested?
4. What is the expected blast radius?
5. How is the experiment stopped or recovered?
