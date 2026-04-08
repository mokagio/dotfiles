---
name: linear-issue
description: Fetch a Linear issue by ID and display its details.
allowed-tools: Bash(curl *), Bash(python3 *)
user-invocable: true
---

# Linear Issue

Fetch a Linear issue and display its title, description, state, and comments.

## Arguments

`<issue-id>` — the issue identifier (e.g., `AINFRA-829`).
If empty, ask the user for the issue ID.

## Workflow

### 1. Validate input

If no issue ID is provided, ask the user.

### 2. Fetch the issue

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{"query": "{ issue(id: \"<ISSUE_ID>\") { identifier title description state { name } priority priorityLabel assignee { name } labels { nodes { name } } comments { nodes { body createdAt user { name } } } } }"}' \
  | python3 -m json.tool
```

Replace `<ISSUE_ID>` with the provided issue identifier.

### 3. Present the result

Format the output clearly:

- **Title** and **identifier**
- **State** and **priority**
- **Assignee** and **labels** (if set)
- **Description** (full text)
- **Comments** (chronological, with author and date)

If the API returns an error or null issue, report that the issue was not found and suggest checking the ID.
