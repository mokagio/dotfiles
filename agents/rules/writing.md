**Writing and Markdown formatting rules.**

---

I want an empty line before the start of my lists.

Bad:

```
Here are the items:
- One
- Two
- Three
```

Good:

```
Here are the items:

- One
- Two
- Three
```

---

When writing for me, including in commit messages, fence inline code and file names, unless doing so goes over the standard line length for the commit title.
Example:

```
Update `AGENTS.md` with rule for code fencing
```

---

When writing Markdown, use [**semantic line breaks**](https://sembr.org/):

- One sentence per line.
- No blank line between closely related sentences.
- Blank line between distinct thoughts/paragraphs.

This keeps diffs clean and source readable.
