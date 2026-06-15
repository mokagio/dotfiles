**Swift Package Manager dependency rules.**

---

When updating a SwiftPM dependency to a published release, pin it by **exact version**, not by a raw git revision — provided the release is tagged.

```swift
// Good — when the upstream release is tagged 4.3.0
.package(url: "https://github.com/Automattic/Automattic-Tracks-iOS", exact: "4.3.0"),

// Avoid — a raw revision hides the version and reads as a moving target
.package(url: "https://github.com/Automattic/Automattic-Tracks-iOS", revision: "5b648ab..."),
```

Why:

- The manifest states the intent — consuming a shipped release — instead of an opaque SHA.
- `swift package resolve` records the semantic `version` alongside the `revision` in `Package.resolved`, so the pin is auditable at a glance.

`exact:` over `from:`/`upToNextMajor:` for these deliberate, reviewed bumps: the update is the change under review, so the version should not drift implicitly on a later resolve.

Fall back to a `revision` pin only when there is no tag to point at (e.g. consuming an unreleased fix off a branch). State that reason in the commit message.

After changing the pin, always run `swift package resolve` so `Package.resolved` is regenerated and committed together with the manifest.
