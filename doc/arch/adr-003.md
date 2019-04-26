# ADR 003: New splits will be prefixed with `[app_name].`

## Status

Accepted

## Context

In order to allow apps to ship independently, we need to ensure that
split names defined in different apps don't collide. The strategy until
now has been for developers to run all the apps that might have
conflicting splits in local dev, but this doesn't scale well as they may
not have the latest version of each app at all times and a
fully-upgraded local testtrack server to detect conflicts that might
arise in production.

We need to make sure that migrations don't get jammed up in production
even if a developer only has their own app downloaded locally.

## Decision

New migration runners will be expected to prefix their split names with
their app names and a dot. Legacy runners will be grandfathered out of
this constraint, but we will begin soft enforcing that any new split
name conform to using at most a single dot, and that the text before
that dot be the app name of the split's owner_app.

## Consequences

As a result, we can be confident that splits shipped in an app will not
get jammed up in production due to naming conflicts.

Clients that may not have previously contemplated dot-prefixed split
names may need to adapt, though it is likely that they will support
these split names natively.

We would like to upgrade clients to auto-prefix split references in vary
and AB calls with their own app names and then fall through to
unprefixed split names if those are not found, to reduce the amount of
typing necessary to refer to your own splits.

At some point, as described in the consequences section of
[ADR-001](adr-001.md), we may move to change the representation of split
references in AppFeatureCompletions and AppRemoteKills from split_ids to
split_names. This increased fuzziness would probably need some
additional thinking to ensure it was safe against typos or
mistaken/missing app-name prefixes while still allowing for temporal
decoupling (e.g. it should be OK to ship a feature completion for a
feature gate that hasn't shipped yet), but for now we'd expect those
migration references to be fully qualified with app-name prefix and
either link up or fail.
