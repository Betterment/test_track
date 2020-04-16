# ADR 002: Remote kills are absolute

## Status

Accepted

## Context

When rapidly iterating on API for prerelease features, we will commonly
want to make breaking API changes without revving the API endpoints and
maintaining the previous versions of the endpoints indefinitely for
versions of the app that will never be seen by customers.

In that context, remote kills stand to be an incredibly useful tool.
When you decide to make a breaking API change, you simply create/update
a remote kill for the app from version `0` through the first client
version conforming to the new contract. Then, instead of getting crash
bugs on dev builds, the feature simply turns itself off, and testers
will have to upgrade in order to see the feature again.

This stands to eliminate false bug reports of crash bugs from
internal/alpha testers who simply need to upgrade.

But if we want to rely on this as a safety mechanism, we need to make
sure that chrome extension assignment overrides don't have the
opportunity to win-out over a remote kill, because they are too blunt of
a tool. As an alpha tester, you might see that the feature went away and
perform another override in the Chrome extension. If that happens,
you'd be back in crash bug land.

## Decision

On TestTrack server, remote kills will be absolute and won't be
overridden by force assignments regardless of the relative recency of
the override and the remote kill.

## Consequences

As a result, it may be somewhat more difficult for app developers to
"see around" an open-ended remote kill that was dropped because of a bug
as they work on the bugfix _in production_.

~~A hypothetical solution is to bump the app version on their branch and
then mark the remote_kill's fixed_version as that version, so that as
they develop the fix, their local builds will allow them to see their
work. Then merging and releasing the branch will cause the fix to be
available to consumers of that build.~~

~~This might introduce version number linearization problems unless we
hold all other merges until the bugfix is released, which may or may not
be an issue the dev team can stomach.~~

~~As an alternative, we could make the forthcoming fake TestTrack server
being developed into the Rails client less draconian, and allow
assignment overrides to take precedence over remote kills in that
context only. Then the remote_kill fixed_version could be stamped once
the release version of the bugfix is known, after the developer has
already locally tested the fix.~~

_TestTrack fake servers used in non-production environments (e.g. the
testtrack CLI for local dev) therefore do not have a remote kill feature
at all, enabling simple debugging._
