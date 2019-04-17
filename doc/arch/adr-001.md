# ADR 001: AppRemoteKill Will Loosely Couple to Override Variant

## Status

Accepted

## Context

Splits are accessible to any app in the same ecosystem, but not always
defined by within that app.

Increasingly, migrations may not be validated centrally in local
development ecosystems as we build out a standalone migration runner,
and there's no guarantee that all apps in an ecosystem will be up to
date, so forcing central validation could introduce significant
developer friction.

Therefor it is unlikely that we could strongly valiate the variants
of split that was defined by another app at the time that an
app_remote_kill is created.

Also, such validations, if they're only possible in production, could
lead to broken migrations in production that are already applied in
other ecosystems.

## Decision

We will not validate the override_to value of an AppRemoteKill against
the split. The registry knock-out will simply no-op at runtime if the
chosen variant is not available, allowing the team to quickly ship another
migration to disable the feature.

At this time, we will still strongly couple app_remote_kills to split
existence, however. This may change in the future if it proves to cause
operational issues

## Consequences

The only remaining way to ship an AppRemoteKill that doesn't apply
correctly in production would be to misspell the split name itself.

We'll see whether that is acceptable or whether we should walk further
down the decoupling path and make AppRemoteKills and
AppFeatureCompletions entirely soft-coupled to splits by name.
