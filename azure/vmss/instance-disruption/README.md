# Azure VM Scale Set Instance Disruption

Template for testing the resilience of an Azure VM Scale Set when a sandbox instance becomes unavailable.

## Hypothesis

If one VMSS instance is disrupted, the service should maintain the expected capacity and recover the affected instance according to its configuration.
