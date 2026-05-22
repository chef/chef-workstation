# Ex11 PR Review Artifacts

## Scope

Target subsystem: `ai-track-docs`

Files under review:
- `ai-track-docs/pr-hygiene.md`
- `ai-track-docs/pr-review-artifact-ex11.md`

## Review Focus

- Risk 1: Process guidance may be incomplete and fail to enforce consistent review behavior.
- Risk 2: Missing checklist categories could leave correctness/security/performance blind spots.
- Verification steps: markdown lint/readability check + structured checklist walk-through.
- Rollback: `git revert <commit-sha>`.

## AI/Simulated Review Checklist

- Correctness: PASS
  - Workflow includes required sections: review focus, checklist, findings log, request flow, resolution loop.
- Test Coverage: PASS
  - For doc-only changes, verification is checklist completeness and command validity.
- Security: PASS
  - No secrets added; guidance emphasizes risk and rollback discipline.
- Performance: PASS
  - No runtime or CI execution-path code changes.
- Documentation: PASS
  - Adds both reusable process guidance and exercise-specific artifact template.

## Findings Response Log

| Source | Finding | Response | Status |
|---|---|---|---|
| Simulated checklist | Human-review request path was not explicit enough | Added concrete `gh pr edit` + `gh pr comment` commands in `pr-hygiene.md` | Resolved |
| Simulated checklist | Comment conflict handling was underspecified | Added tradeoff/decision rule and close-out response template in `pr-hygiene.md` | Resolved |

## Human Review Request Log

- Request posted in PR comment with reviewer guidance and artifact locations.
- Human comments will be appended to the table below and resolved with commit references.

| Comment ID/Link | Summary | Resolution | Status |
|---|---|---|---|
| pending | Awaiting reviewer feedback | Will update after review comments arrive | Open |
