# GitHub Workflows

These workflows are **disabled** and optional. They are kept as reference, so that a repository from this template starts clean. Copy the ones you want to `.github/workflows/` to enable them. Anything left in `workflows/` stays off.

## Enabling

Copy the workflows you want to `.github/workflows/`:

```bash
mkdir -p .github/workflows
cp workflows/*.yml .github/workflows/
```

Then commit and push.

If you copy `push-to-cachix.yml` or `update-docs.yml`, their `on: push` triggers fire on your first push to `main`. Set up the secrets and variables below first, or the runs will fail.

## What each one does

| File | Trigger | Purpose | Needs |
|---|---|---|---|
| `build-package.yml` | manual (`workflow_dispatch`) | Ad-hoc build of packages, optionally from another flake or a PR URL, via nixbuild.net. Can push to Cachix. | `NIXBUILD_TOKEN`, `CACHIX_AUTH_TOKEN` |
| `check-pr.yml` | `pull_request` | Builds the packages and module checks that the PR changed. | `CACHIX_AUTH_TOKEN` |
| `enable-auto-merge.yml` | `Check PR` workflow completed | Merges PRs from the automation bot after the build job passed. Only runs if `AUTO_MERGE_BOT` is set. | `GH_PAT` |
| `label-automated-prs.yml` | `pull_request` opened or reopened | Adds the `3. automated` label to PRs from the automation bot. Only runs if `AUTO_MERGE_BOT` is set. | none |
| `push-to-cachix.yml` | `push` to `main` | Builds changed packages and pushes them to your Cachix cache. | `CACHIX_AUTH_TOKEN` |
| `update-docs.yml` | `push` to `main` | Regenerates the package and module tables in `README.md` and opens a PR with the result. | `GH_PAT` |
| `update-flake-inputs.yml` | schedule (every two weeks, Monday 04:00 UTC) or manual | Runs `nix flake update` and opens a PR with the new `flake.lock`. | `GH_PAT_BOT` |

Notes on behavior:

- `check-pr.yml` maps changed files to checks. A change under `pkgs/<xy>/<name>/` builds that package. A change under `modules/` builds the checks of that module. A change to `flake.lock` builds everything.
- `push-to-cachix.yml` uses a change detection step with the same logic, then builds each package in a matrix job.
- `update-docs.yml` replaces the content between the `<!-- BEGIN ... -->` and `<!-- END ... -->` markers in `README.md`. Do not edit that content by hand.
- `enable-auto-merge.yml` merges only the exact commit that the build tested. It checks the PR head SHA against the tested SHA before it merges.

## Required secrets

Set these under **Settings → Secrets and variables → Actions → Secrets**.

| Secret | Used by | Where to get it |
|---|---|---|
| `CACHIX_AUTH_TOKEN` | build-package, check-pr, push-to-cachix | [app.cachix.org](https://app.cachix.org/) → your cache → Settings → Auth Tokens |
| `NIXBUILD_TOKEN` | build-package | [nixbuild.net](https://nixbuild.net/) account → API token |
| `GH_PAT` | update-docs, enable-auto-merge | A personal access token with `repo`, `contents: write`, and `pull-requests: write` |
| `GH_PAT_BOT` | update-flake-inputs | A token from a separate bot account. The PR author must be that bot, so that `label-automated-prs` and `enable-auto-merge` recognize it. |

## Variables to set

Set these under **Settings → Secrets and variables → Actions → Variables**.

| Variable | Default | Purpose |
|---|---|---|
| `CACHIX_CACHE_NAME` | `tixpkgs` | Your Cachix cache name. Set this to your own cache. The fallback is mine. |
| `CACHIX_SKIP` | *(empty)* | Comma-separated package names to skip in builds and pushes. |
| `AUTO_MERGE_BOT` | *(unset = disabled)* | GitHub username of your automation bot, for example the account behind `GH_PAT_BOT`. `label-automated-prs` and `enable-auto-merge` check PRs against this name. Leave unset to disable auto-merge. |

## Things to change (hardcoded / owner-specific)

- **Cachix cache URL and public key.** The workflows add `https://tixpkgs.cachix.org` and its public key as an extra substituter. A public key is unique to a cache, so it cannot come from a variable. Find `extra-substituters` and `extra-trusted-public-keys` in the workflows and replace both with the values of your own cache.
- **The `3. automated` label.** `label-automated-prs.yml` and `update-docs.yml` apply this label. The label must exist in your repository before those workflows run. Create it under **Issues → Labels**, or change the name in the workflows.
- **The bot account.** `update-flake-inputs.yml` opens its PR with `GH_PAT_BOT`. Set `AUTO_MERGE_BOT` to that account's username. If you do not want a bot, do not copy `update-flake-inputs.yml`, `label-automated-prs.yml`, or `enable-auto-merge.yml`, and remove the auto-merge step from `update-docs.yml`.
- **`CACHIX_SKIP` behavior.** Packages in this list are skipped without an error message in PR checks and pushes. Do not set the variable if you do not want that.

## Notes

- The `on: push` path filters in `push-to-cachix.yml` and `update-docs.yml` point to `.github/workflows/...`. That is the location after you copy the files, so leave them as they are.
- `build-package.yml` takes a `flake` input. You can build from any flake reference or PR URL, for example `github:owner/repo?ref=refs/pull/123/head`. This is useful to test an upstream PR before you merge it.
