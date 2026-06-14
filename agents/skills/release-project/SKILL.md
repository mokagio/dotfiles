---
name: release-project
description: Prepare, verify, and publish generic software project releases. Use when asked to release a project, cut a version, prepare release notes, create or push release tags, publish artifacts, inspect whether CI has tag-triggered release jobs, or document a repo's release process.
---

# Release Project

Use the repository's own documentation, scripts, CI, package metadata, and hosting configuration as the source of truth.
Do not assume a language, package registry, release host, tag format, or CI provider.

## Workflow

1. Inspect local instructions first.
   Read root agent instructions, release documentation, changelog guidance, package metadata, CI config, and scripts.
   Prefer `rg` and targeted file reads.

2. Check CI for tag and release behavior before touching versions or tags.
   Search CI config for tag filters, tag environment variables, release jobs, publish jobs, deploy jobs, manual gates, artifact uploads, and registry credentials.
   For common CI systems, look for patterns such as `refs/tags`, `tags:`, `build.tag`, `BUILDKITE_TAG`, `CIRCLE_TAG`, `GITHUB_REF_TYPE=tag`, `CI_COMMIT_TAG`, `APPVEYOR_REPO_TAG`, `TRAVIS_TAG`, and deploy or publish steps.
   Report whether tags trigger a special flow, ordinary CI only, or no CI release path was found.

3. Discover the release contract.
   Identify the current version, intended next version, tag format, changelog format, release branch policy, required checks, and publish mechanism.
   If any release-critical detail is missing and cannot be inferred from repo-local evidence, ask before proceeding.

4. Prepare the release changes.
   Update only the files required by the discovered release contract.
   Keep changelog edits factual and scoped.
   Do not introduce project-specific release conventions that are not already present.

5. Verify locally.
   Run the smallest sufficient tests, builds, linters, or smoke commands described by the repo.
   If verification cannot run locally, surface the exact blocker and use available remote checks only when appropriate.

6. Commit, tag, and publish only after verification.
   Create commits and tags using the repo's documented workflow.
   Before pushing a tag, confirm whether CI will publish artifacts or whether manual publish commands remain.
   After pushing or creating a remote release, monitor the affected CI/checks when tools are available.

7. Close with evidence.
   Summarize the version, commit, tag, release target, publish result, and verification status.
   Include any manual follow-up that remains.

## Guardrails

- Never push a tag or publish artifacts until the release path is confirmed.
- Never invent release notes from unreleased commits without checking existing changelog or PR history.
- Never skip verification when it is available.
- Keep the workflow generic; put repository-specific lessons in that repository's instructions, not this skill.
