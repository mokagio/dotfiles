---
name: editor
description: |
  Review writing for logical soundness, structural issues, and surface errors.
  Use when asked to edit, review, or critique a piece of writing.
  Works on blog posts, essays, notes, and any argumentative or expository prose.
allowed-tools: Read, Glob
---

# Editor

Review a piece of writing for logical soundness, argument structure, and surface errors.

## Why this skill exists

Writing review benefits from a consistent, repeatable lens.
This skill codifies the editorial approach: logic first, structure second, polish last.

## Arguments

`$ARGUMENTS` — path to the file to review, or a description of which piece to look at.

## Workflow

### 1. Read the piece

Read the file specified in `$ARGUMENTS`.
If the argument is ambiguous, use Glob to find the file.

### 2. Identify the core argument

Before critiquing, state the core argument in one sentence.
This forces understanding before judgment and gives the author a mirror.

### 3. Check logic

This is the most important pass. Look for:

- **Unsupported claims** — assertions presented without evidence or reasoning.
- **False dilemmas** — binary framings that ignore plausible alternatives.
- **Conflations** — distinct concepts lumped together as if interchangeable.
- **Hedging both ways** — disclaiming expertise then making expert claims, or vice versa.
- **Non sequiturs** — conclusions that don't follow from the premises.
- **Missing steelman** — counterarguments acknowledged but dismissed without engagement.

For each issue found, cite the specific line(s) and explain *why* it's a problem.
Don't just name the fallacy — show how it weakens the piece.

### 4. Check structure

Evaluate the piece's arc and pacing:

- **Does the emotional/argumentative arc build or zigzag?**
  Flag detours that dilute tension before the payoff.
- **Does each paragraph earn its place?**
  If removing a paragraph wouldn't hurt the argument, say so.
- **Does the opening hook and the ending land?**
  A piece that builds well but fizzles at the end wastes the reader's investment.

### 5. Surface errors

Typos, grammar, and awkward phrasing.
List them with line numbers, original text, and fix.
Keep this section mechanical — no commentary.

### 6. Present the review

Structure the output as:

```
**Core argument:** [one sentence]

**Logic:**
[numbered list of issues, each with line reference and explanation]

**Structure:**
[paragraph-level feedback on arc and pacing]

**Surface errors:**
[list: line N: "original" → "fix"]
```

## Tone

Be direct and specific.
Praise nothing — the author asked for holes, not validation.
If the logic is sound, say "logic is sound" and move on; don't pad it.
