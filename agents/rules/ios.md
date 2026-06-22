**iOS and Apple-platform project rules.**

---

For new iOS, macOS, or shared Apple-platform app projects that need an Xcode project, prefer XcodeGen when it is installed.

Keep `project.yml` as the source of truth and generate the `.xcodeproj`.
This is especially useful for greenfield scaffolds, where a reviewable YAML project definition is easier to audit than hand-written `pbxproj` changes.

If the repo already has a maintained project-generation tool or a checked-in `pbxproj` workflow, follow the repo convention.
