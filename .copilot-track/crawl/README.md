# Copilot Track – Crawl Phase

This directory holds prompts, notes, and artifacts for the **Crawl** phase of the AI-assisted development track.

---

## What is the Crawl Phase?

The track is structured as **Crawl → Walk → Run**:

| Phase | Goal |
|-------|------|
| **Crawl** | Understand the codebase; establish conventions and tooling; low-risk changes. |
| **Walk** | Implement features or fixes with AI assistance; write and verify tests. |
| **Run** | Automate review, generation, and refactoring patterns at scale. |

---

## Chain-PRs

Each exercise produces a **small, focused pull request** that builds on the previous one:

1. Keep PRs scoped – one exercise per PR.
2. Later PRs branch from the previous exercise branch so reviewers see incremental diffs.
3. The PR description must include the **exercise number** and link to any relevant prompt file here.

---

## Evidence in PRs

Every PR that uses AI assistance should include an **"AI Evidence" section** in the description:

```
## AI Evidence
- Prompt file: `.copilot-track/crawl/<prompt-file>.md`
- Model: GitHub Copilot / Claude Sonnet 4.6
- What was generated vs. what was edited manually
- Test output (paste or screenshot)
```

This creates an auditable record of what the AI produced and what humans reviewed.

---

## Prompt Usage

Store reusable prompts as `.md` files in this directory.  
Name them descriptively: `explore-cli-entrypoint.md`, `generate-unit-test.md`, etc.

**Tips:**

- Start prompts with a clear **role** and **goal** sentence.
- Provide relevant file paths so Copilot has context.
- Append `// verify before committing` comments to any AI-generated code blocks.
- Iterate: refine the prompt and re-run rather than hand-editing generated output until you understand why it was wrong.
