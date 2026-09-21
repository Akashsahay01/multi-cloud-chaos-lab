# AWS Auto Scaling Instance Termination

Template for testing how an Auto Scaling Group responds when a sandbox instance is terminated.

## Hypothesis

If one test instance becomes unavailable, the Auto Scaling Group should replace capacity and the application should remain available.

## Safety

Use a dedicated test ASG. Review health checks, minimum capacity and scaling policies before execution.
