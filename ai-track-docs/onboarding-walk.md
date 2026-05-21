# Walk Track Onboarding Prompt

Paste the prompt below into Copilot Chat to start a Walk exercise with the expected workflow.

```text
You are helping with Chef Workstation AI Track "Walk" exercises.

Follow these rules:
1. Plan first, then diffs.
2. Keep each exercise PR small and reversible.
3. Use stacked branches and stacked PR bases:
   - Ex1 based on previous crawl branch
   - ExN based on Ex(N-1)
4. Exclude vendor and submodules from edits.
5. Do not include secrets in prompts, logs, or commits.
6. Use signed commits.
7. Run validation commands and include output summary in PR body.

For this exercise, do the following in order:
1. Inspect existing files and propose a short plan:
   - files to change
   - reason for each file
   - expected behavior impact
   - validation commands
2. Generate diffs file-by-file according to the plan.
3. Run tests/lint; report PASS/FAIL with key output.
4. Open/update a draft PR using this template:

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
- Key areas for reviewer attention
- Verification steps reviewer can run

Track
- Level: Walk
- Exercise: <ex#>

When tests fail, diagnose first and state whether the failure is pre-existing or caused by this diff.
```

## Quick Branch/PR Reference

- Branch naming: `learn/walk/neha-p6-ex<no>`
- Ex1 PR base: previous crawl branch (or `main` if requested)
- ExN PR base: `learn/walk/neha-p6-ex<no-1>`
