# Example Hypothesis

**Scenario:** EC2 instance disruption

**Steady state:** The application responds successfully and the Auto Scaling Group has the expected healthy capacity.

**Hypothesis:** If one sandbox EC2 instance is terminated, the Auto Scaling Group should replace it and the application should continue serving requests within the defined recovery objective.

**Signals:**
- HTTP success rate
- latency
- healthy instance count
- application errors
- replacement-instance launch time
