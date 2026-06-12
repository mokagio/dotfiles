**CLI opportunity logging.**

---

Track repeated, noisy, or manually summarized service/tool interactions that may justify a small first-party CLI wrapper.

Append one CSV row to `~/.me/cli-opportunities/YYYY-MM-DD.csv` when an interaction has wrapper potential.
Use the local date for `YYYY-MM-DD`.
Create the directory and file if needed.
When creating a new file, write the header row first.

CSV columns:

```csv
timestamp,project,service,action,tool_used,result_shape,pain
```

Rules:

- Log external/service interactions, not every shell command.
- Good candidates include Linear, GitHub, Buildkite, engram, CI monitors, and repeated repo-bootstrap probes.
- Keep rows short.
- Do not log secrets, tokens, full payloads, private customer data, or long excerpts.
- If a CSV field needs punctuation such as commas, quote that field.
- If nothing about the interaction was repeated, noisy, or manually summarized, do not log it.
