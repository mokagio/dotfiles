Rules for interpreting and acting on tool output without inventing facts.

---

**Verify what a thing is before acting on it.**

Don't infer what a server, file, or resource is from its name, port, process, or path.
Confirm directly before building anything on top of it.

For URLs: `curl -sI <url>` for headers, `curl -s <url> | head` for the title and a snippet of body.
For unknown files: read the first lines and check the type.
For processes: check what they're actually serving, not just what's running.

This is especially critical when comparing multiple things that you expect to be similar.
Divergence in raw content (HTML, file bytes, headers) is faster and more reliable to detect than divergence in rendered output.

**Wrong:**

- "There's a Python http.server on :8000, so it must be serving the project's static build" → screenshot it → build comparison.
- "The file is named `config.yaml`, so it must be the active config" → edit it.

**Right:**

- `curl -s http://localhost:8000/ | head` → confirm title, charset, body — *then* screenshot.
- Read the file, check whether anything actually loads it, *then* edit.

---

**When a tool result is surprising, investigate before narrating.**

If a screenshot, command output, file content, or API response doesn't match what you'd predict, treat the surprise as a signal to investigate — not as data to interpret.

Do **not** rationalize an anomaly into a plausible-sounding story.
The story is almost always wrong, and narrating it commits you to a fiction that compounds into worse mistakes downstream.

Concrete next moves when surprised:

- Re-fetch with a different method or tool.
- Diff the inputs against what you expected.
- Check whether your assumptions about what the thing *is* are correct (see rule above).
- Ask the human if you're stuck — surfacing the surprise is part of the job.

Only narrate after the surprise is explained, not before.
"This looks wrong, here's what I think is happening" without verification is the failure mode.

---

**Headless rendering ≠ interactive rendering.**

Headless Chrome (`--headless`, `--headless=new`) may degrade JS-heavy or asset-heavy pages:

- External resources can fail silently (no cache, no cookies, network restrictions).
- JS may not run long enough; even `--virtual-time-budget` isn't a guarantee.
- CDN-loaded styling (e.g. `cdn.tailwindcss.com`) may not apply before the screenshot is taken.

A "broken-looking" headless screenshot may reflect headless limitations rather than the page's true state.

When in doubt:

- `curl` the HTML as ground truth before trusting the rendered pixels.
- Ask the human for an interactive screenshot if the page can't be reliably rendered headlessly.
