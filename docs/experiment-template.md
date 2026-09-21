# Chaos Experiment Template

## Hypothesis

> If [fault] is introduced against [target], then [expected behaviour] should occur because [reason].

## Steady state

Describe the healthy state before the experiment.

## Target

Resource:

Target selection:

Why this target is safe:

## Blast radius

Expected impact:

Known exclusions:

Maximum number of resources:

## Fault parameters

Duration:

Intensity:

## Observability

Metrics:

Logs:

Traces:

Alerts:

## Abort conditions

Stop the experiment if:

- user-facing availability crosses the agreed threshold;
- an unrelated incident begins;
- the experiment exceeds the expected blast radius;
- recovery does not behave as expected.

## Recovery

Expected recovery mechanism:

Manual recovery procedure:

Recovery objective:

## Result

Observed behaviour:

Hypothesis confirmed / rejected:

Evidence:

Follow-up actions:
