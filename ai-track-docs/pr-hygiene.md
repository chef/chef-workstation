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

## Walk PR Review Focus (Ex11)

Use the following when drafting Walk PRs so reviewers can quickly validate the riskiest areas.

### Review Focus Bullets (3-5)

- Confirm the change is scoped to the intended files only and does not expand beyond the exercise goal.
- Verify behavior-impact claims match the diff (for refactors/docs/tooling, check that runtime logic is unchanged unless explicitly stated).
- Check that evidence commands in the PR body are reproducible and align with the touched component.
- Validate that observability/security/CI changes are additive and have clear rollback.
- Confirm no secrets or sensitive values are introduced in code, logs, or examples.

### Reviewer Verification Steps

Pick the commands relevant to the PR surface and include them verbatim in the PR body.

```sh
# main-chef-wrapper unit slice
cd components/main-chef-wrapper
go test -tags=unit ./cmd -count=1

# chef-automate-collect command slice
cd components/chef-automate-collect
go test ./commands -count=1

# repo-level soft evidence command used in CI advisory summary
cd components/main-chef-wrapper
go test -tags=unit -cover -count=1 ./cmd
```

### Rollback Pattern

Always include a one-line rollback in PRs:

```sh
git revert <commit-sha>
```

### Final PR Text Template (Walk)

```text
Title: GHCP -- Walk: <ex#> <name>

Summary
- What changed and why
- Plan: <inline summary>
- Files/paths touched

Evidence
- Tests/logs/metrics: <commands + output summary>
- Coverage: <percentage or contract evidence>

Risk & Rollback
- Risk: low/medium
- Rollback: revert <commit SHA>

Review Focus
- Confirm <risk area 1>
- Confirm <risk area 2>
- Confirm <scope / safety claim>

Verification Steps
- <command 1>
- <command 2>
- <expected success signal>

Track
- Level: Walk
- Exercise: <ex#>
```

## Run PR Hygiene Workflow (Ex11)

Use this workflow for Run-track PRs to keep review quality high while reducing back-and-forth.

Concrete example artifact for this exercise:

- `ai-track-docs/pr-review-artifact-ex11.md`

### 1) Review Focus Section (Required in PR Body)

Include these fields explicitly:

- Scope risk: what could break if this PR is wrong
- Verification scope: exact commands/checks used
- Rollback confidence: one-line revert plan

Suggested block:

```text
Review Focus
- Key risk 1: <risk + why it matters>
- Key risk 2: <risk + why it matters>
- Verification steps: <commands>
- Rollback: git revert <commit-sha>
```

### 2) AI Review (or Simulated Checklist)

If an AI review tool is unavailable, run this checklist manually and include it in the PR body.

Checklist categories (required):

- Correctness
- Test Coverage
- Security
- Performance
- Documentation

Example template:

```text
AI/Simulated Review Checklist
- Correctness: pass/fail + notes
- Test Coverage: pass/fail + notes
- Security: pass/fail + notes
- Performance: pass/fail + notes
- Documentation: pass/fail + notes
```

### 3) Findings Response Log (Systematic Resolution)

Track every finding in a table and resolve each item explicitly.

| Source | Finding | Response | Status |
|---|---|---|---|
| AI/Checklist | <finding> | <what changed or why no change> | Resolved/Accepted risk |
| Human Review | <comment> | <what changed or rationale> | Resolved/Accepted risk |

Rules:

- Do not leave findings undocumented.
- If two comments conflict, record the tradeoff and chosen path.
- Link the commit or file section used to resolve the comment.

### 4) Human Review Request (Required)

Request a human reviewer after checklist pass and before marking final ready.

Suggested commands:

```sh
gh pr edit <pr-number> --add-reviewer <github-handle>
gh pr comment <pr-number> --body "Requesting human review. Review focus and findings log are in the PR body."
```

### 5) Human Feedback Resolution (Required)

After human comments arrive:

1. Add each comment to the findings response log.
2. Apply fixes in a focused follow-up commit.
3. Reply on the thread with the exact resolution.

Suggested close-out comment format:

```text
Addressed in <commit-sha>:
- <comment summary>
- <change made>
- <verification rerun>
```
