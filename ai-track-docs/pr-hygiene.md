# PR Hygiene Notes

## Copilot-Drafted PR Summary

Use the following structure for small crawl-track PRs so reviewers can understand intent, evidence, risk, and rollback quickly.

### Summary

- State what changed in 1-2 lines.
- Name the exact files or surfaces touched.
- Say whether the change is code, docs, validation, or workflow only.

Example:

- Added a repeatable local validation fallback for the crawl-track Go slice in `chef-automate-collect`.
- Added `scripts/run-crawl-checks.sh` and documented usage in `ai-track-docs/ci-baseline.md`.
- Scope is validation tooling only; no runtime behavior changes.

### Review Focus

Ask reviewers to spend time on the parts that actually matter.

Example:

- Confirm the local script covers the intended `chef-automate-collect` checks and nothing broader.
- Confirm the documented commands in `ai-track-docs/ci-baseline.md` match the script behavior.
- Confirm rollback is straightforward and the scope is isolated to validation tooling.

### Verification

List the exact commands used, plus the success signal.

Example:

```sh
./scripts/run-crawl-checks.sh
```

Expected success signal:

- unit tests pass
- `go build ./...` succeeds
- script ends with `==> Crawl checks passed`

### Evidence

Include concrete pointers reviewers can inspect.

Example:

- Script: `scripts/run-crawl-checks.sh`
- Notes: `ai-track-docs/ci-baseline.md`
- Command output captured in PR description

### Risk

Keep this short and explicit.

Example:

- Low risk: additive script and documentation only.
- No runtime code paths changed.

### Rollback

Always give the one-command rollback.

Example:

```sh
git revert <commit-sha>
```

## Commit Message Improvements

Prefer short, action-oriented messages that say what changed, not just the exercise number.

Examples:

- `Crawl: add local CI fallback script`
- `Crawl: add structured config-load logging`
- `Crawl: improve secrets hygiene`
- `Crawl: validate git remote env override`

Avoid vague messages like:

- `Exercise 11 updates`
- `misc fixes`
- `address review comments`

## Practical Rules

- Put reviewer guidance in a `Review Focus` section.
- Put exact commands in a `Verification` section.
- Include rollback even for low-risk docs or tooling changes.
- Mention when Copilot was used to draft the PR content.
