# AWS EC2 CPU Stress

This example demonstrates the structure for a controlled EC2 CPU-stress chaos experiment.

It is intentionally a template: connect it to your approved AWS FIS/SSM implementation for the sandbox account before execution.

## Hypothesis

If CPU utilisation is intentionally increased on a non-production EC2 instance, the workload should remain observable and recover when the experiment stops.

## Expected observations

- CPU utilisation increases.
- Application latency may change.
- CloudWatch metrics should show the disturbance.
- The instance should recover after the stress process ends.

## Safety

Use only an isolated test instance and define an explicit duration.
