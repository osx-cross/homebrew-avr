# Updating formulae and bottles

Contributions to this tap are welcome. You do not have to prepare a multi-formula update by hand: ask an agent to investigate upstream releases, prepare one formula change per PR, and collect CI and bottle evidence. Review its work yourself, especially build failures and publishing decisions. The [Homebrew documentation](https://docs.brew.sh/) covers general formula conventions; this guide covers this tap's release workflow.

## Plan the update

1. Check the relevant `Formula/*.rb`, upstream release notes, dependencies, patches, and existing bottle block. Decide whether you are changing the source version, changing a formula without changing its version (which may require a `revision` bump to replace bottles), or only changing documentation. A new version already produces a new bottle identity; do not bump `revision` reflexively. A revision bump changes the package identity and rebuilds bottles on **all** configured runners, not only the new platform.
2. List affected formulae and dependencies. If several formulae need work, open a tracking issue with one checklist item per formula and links to its PR. Make **one formula change per PR**, based on current `main`; do not bundle several long GCC builds into a single PR. Publish prerequisites (for example, `avr-binutils`) before attempting dependent GCC bottles on a new OS. Formulae that need no change need no PR.
3. In a revision-bump PR, leave the existing `bottle do` block alone. It represents already published bottles; the publish workflow will replace/update it. State the reason for the bump, reference the tracking issue, and say what verification is still pending. When prerequisites land on `main`, update dependent PRs against it and rerun their checks; rebasing a shared branch requires coordination with its owner.

## Check the change, not just the green badge

For a changed formula, start with Ruby syntax (`ruby -c Formula/<name>.rb`), `brew style Formula/<name>.rb`, and `brew audit <name>` where applicable. `git diff --check` catches whitespace errors. Use the [CI workflow](.github/workflows/tests.yml) as the authoritative list of checks and runner targets: it runs `brew test-bot --only-tap-syntax` and, on PRs, `brew test-bot --only-formulae` on its configured macOS matrix. It uploads per-runner bottle artifacts even on failed jobs; an artifact's presence alone does not prove a successful build. Read the relevant job logs and inspect the artifacts.

Choose additional checks according to what changed:

- Installing a **bottle** and running `brew test <name>` check installation and the formula's test block. They do not exercise source-build arguments.
- `brew install --build-from-source <name>` checks the actual build. Reaching `configure` validates configure arguments but **not** compilation, installation, or a working bottle; report where you stopped. Source builds of GCC may take a long time.
- A passing build on one runner does not prove other runners produced bottles. Check each intended platform, including platforms whose existing bottles must be retained, before publication. Distinguish a failure, a skipped build, and a cancelled/timed-out run by reading logs rather than guessing.

If tap-wide checks fail because of another formula, identify the actual offense. Do not silently remove tap-wide checks to get a PR green: an earlier style issue was fixed in the formula instead of keeping a proposed CI workaround ([#388](https://github.com/osx-cross/homebrew-avr/pull/388), [#390](https://github.com/osx-cross/homebrew-avr/pull/390)).

## Publish and verify

The [publish workflow](.github/workflows/publish.yml) triggers when a maintainer applies the `pr-pull` label to a PR. It runs `brew pr-pull`, pushes bottle commits to `main`, and deletes same-repository PR branches. **Do not apply that label until the PR checks, bottle artifacts, and platform coverage have been reviewed.** This workflow can leave a successfully published PR marked **closed, not merged**. PR state alone is not evidence of publication: verify the formula's final revision and bottle block on `main`, and the release assets/checksums for the intended OSes. If a dependency bottle was missing on one runner, publish the dependency first, then arrange a new revision/build of the dependent formula; do not claim the earlier PR covered that OS.

The configured runner matrix, platform tags, and publication mechanism can change. Check the linked workflows and current `main` before using this recipe again. A macOS-new-platform-only `--keep-old` approach was discussed during the 2026 campaign but was **not** implemented or validated in this tap; do not assume that a no-op/comment change creates safe new bottles without rebuilding old ones.

## Ask an agent to help

Copy this brief into your agent, replacing the placeholders. Confirm permissions with the agent before it publishes anything:

> In `osx-cross/homebrew-avr`, investigate updating `<formula or upstream release>` for `<reason/target platforms>`. Read the current formula, CI/publish workflows, upstream release notes, and any related issues/PRs. Propose dependency order and one PR **per formula** (tracking issue if multiple); distinguish version updates from revision bumps and preserve existing bottle blocks until publication. Prepare the smallest changes and run scoped syntax, style, audit, install/test or source-build checks appropriate to the change. Report exactly what each check proves and does not prove. For each PR, examine runner logs and bottle artifacts; after publication verify final `main` bottle blocks and release assets for every intended platform. Ask me before pushing branches, creating PRs, applying `pr-pull`, or changing publication state. Never merge or rewrite shared history without my explicit approval. Summarize blockers and link evidence instead of assuming a green job means all bottles exist.

You can delegate investigation and repetitive branch/PR preparation, but a contributor or maintainer remains responsible for reviewing changes, authorizing actions, and validating published results.

## Worked examples from October 2026

- [#387](https://github.com/osx-cross/homebrew-avr/pull/387) combined changes to eight GCC formulae. The remaining affected versions were tracked in [#391](https://github.com/osx-cross/homebrew-avr/issues/391) and rebuilt separately in [#392–#397](https://github.com/osx-cross/homebrew-avr/issues/391). Combined CI was prolonged/failed; do not assume every failed run was *caused* by a timeout. The path-style fix had already landed in [#390](https://github.com/osx-cross/homebrew-avr/pull/390), so it did not need repeating in each PR. The publish workflow closed the split PRs rather than marking them merged.
- [#389](https://github.com/osx-cross/homebrew-avr/pull/389) added a macOS 27 runner, but did not rebuild unchanged formulae. [#398](https://github.com/osx-cross/homebrew-avr/issues/398) tracked one revision-bump PR per formula. [#400](https://github.com/osx-cross/homebrew-avr/pull/400) published the Binutils bottle; [#401](https://github.com/osx-cross/homebrew-avr/pull/401) had already published GCC 10 without a macOS 27 bottle because Binutils was unavailable on that runner. [#412](https://github.com/osx-cross/homebrew-avr/pull/412) opened a further GCC 10 revision to rebuild after Binutils became available. This is an ordering and per-platform verification lesson, not proof that #398 is complete; consult its current state.
- [#399](https://github.com/osx-cross/homebrew-avr/pull/399) exposed Avarice source compilation errors with newer clang and needed a source patch as well as the bottle campaign. In the separate [#390](https://github.com/osx-cross/homebrew-avr/pull/390) style fix, bottle installation plus `brew test` exercised the changed helper at test time; only a partial GCC source build reached `configure` with the changed linker/assembler arguments. Neither check established a complete GCC source build.
