# Agent guidance

Read [CONTRIBUTING.md](CONTRIBUTING.md) before changing formulae or bottles. It is the source of truth for the update workflow, validation, and publication checks; do not duplicate it here.

- Work on a branch, not `main`. Keep formula updates to one formula per PR; coordinate dependent builds as described in the guide.
- Check the current [test](.github/workflows/tests.yml) and [publish](.github/workflows/publish.yml) workflows rather than assuming runner targets or bottle behavior have stayed the same.
- Report what local checks and CI actually proved, including missing bottles or incomplete source builds. Do not treat a closed PR as proof of publication.
- Ask the contributor or maintainer before pushing, opening a PR, applying `pr-pull`, or otherwise publishing changes. Never merge, force-push, or rewrite history without explicit approval.
