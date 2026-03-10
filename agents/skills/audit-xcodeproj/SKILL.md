---
name: audit-xcodeproj
description: |
  Audit an Xcode project file (pbxproj) for common post-merge issues.
  Use when asked to "audit project file", "check pbxproj", "fix project file",
  or after a merge/rebase that touched the project file.
allowed-tools: Bash(ruby *), Bash(/tmp/*), Read, Glob, Grep, Edit
---

# Audit Xcode Project File

Detect and optionally fix common `.pbxproj` issues caused by merge conflicts or bad rebases.

## Input

`$ARGUMENTS` — optional path to a `.xcodeproj` directory or `.pbxproj` file.
If empty, find the project file automatically:

```
Glob for *.xcodeproj in the working directory (not recursive — skip vendor/, DerivedData/, etc.).
If multiple matches, list them and ask which one to audit.
```

## Check dependency chain

Checks are ordered by severity.
Later checks depend on earlier ones passing — stop at the first failure tier.

```
Tier 0: Balanced delimiters ({}, (), ;)     ← pure text, no gem needed
  │     If this fails, STOP. Fix before proceeding.
  │
Tier 1: Gem parsing + unknown UUID warnings  ← xcodeproj gem
  │     If parsing fails, STOP. Fix before proceeding.
  │     Unknown UUID warnings (stderr) are collected here.
  │
Tier 2: All semantic checks (independent, run in parallel)
  ├─ Duplicate group children (same UUID twice)
  ├─ Duplicate file names in groups (different UUIDs, same name)
  ├─ Duplicate files in build phases
  ├─ Orphaned build files (nil file_ref)
  └─ "Recovered References" group
```

## Tier 0: Balanced delimiters

This is the most common post-merge issue.
Run a simple Ruby script **before** attempting gem parsing.

The script reads the raw `.pbxproj` file and checks:

- Every `{` has a matching `}`
- Every `(` has a matching `)`
- Report the line number where the mismatch occurs

**Important**: `.pbxproj` files use old-style plist format with `//` comments.
`plutil -lint` does NOT work on them. Use a custom script.

```ruby
#!/usr/bin/env ruby

# Tier 0: Check balanced delimiters in pbxproj
file = ARGV[0]
lines = File.readlines(file)
issues = []

braces = 0   # { }
parens = 0   # ( )

lines.each_with_index do |line, i|
  # Skip comment lines
  stripped = line.strip
  next if stripped.start_with?('//')
  next if stripped.start_with?('/*') && stripped.end_with?('*/')

  line.each_char do |c|
    case c
    when '{' then braces += 1
    when '}'
      braces -= 1
      issues << "Line #{i + 1}: unexpected '}' (braces went negative)" if braces < 0
    when '(' then parens += 1
    when ')'
      parens -= 1
      issues << "Line #{i + 1}: unexpected ')' (parens went negative)" if parens < 0
    end
  end
end

issues << "Unmatched '{' — #{braces} still open at end of file" if braces > 0
issues << "Unmatched '(' — #{parens} still open at end of file" if parens > 0

if issues.empty?
  puts "Tier 0 OK — delimiters balanced"
else
  puts "Tier 0 FAIL — #{issues.size} issue(s):"
  issues.each { |i| puts "  #{i}" }
  exit 1
end
```

If Tier 0 fails, report the issues and STOP.
Use the line numbers to find and fix the truncated entries (usually a missing `);`, `sourceTree`, `};` sequence).
After fixing, re-run Tier 0.

## Tier 1: Gem parsing

Use the `xcodeproj` Ruby gem to parse the project.
Capture both stdout and stderr — the gem prints "unknown UUID" warnings to stderr that are valuable diagnostics.

```ruby
#!/usr/bin/env ruby

require 'xcodeproj'

project_path = ARGV[0]

begin
  project = Xcodeproj::Project.open(project_path)
  puts "Tier 1 OK — project parsed successfully"
rescue => e
  $stderr.puts "Tier 1 FAIL — #{e.message}"
  exit 1
end
```

Run with `2>&1` to capture unknown UUID warnings.
These warnings indicate dangling references (build phase entries or target attributes pointing to non-existent objects) — a direct sign of merge damage.

If parsing fails, report the error and STOP.
If unknown UUID warnings appear, report them as issues to fix.

## Tier 2: Semantic checks

All of these are independent and run in a single script after Tier 1 passes.

**Important**: Skip `PBXAggregateTarget` when checking build phases — it doesn't have `source_build_phase` etc.
Filter with `target.is_a?(Xcodeproj::Project::Object::PBXNativeTarget)`.

### Combined script template

```ruby
#!/usr/bin/env ruby

require 'xcodeproj'

project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)
issues = []

# Duplicate children in groups
def check_groups(group, issues)
  uuids = group.children.map(&:uuid)
  dupes = uuids.select { |u| uuids.count(u) > 1 }.uniq
  dupes.each do |uuid|
    obj = group.children.find { |c| c.uuid == uuid }
    issues << "[DUP_CHILD] Group '#{group.display_name}': #{obj.display_name} (#{uuid})"
  end

  names = group.children.map(&:display_name)
  name_dupes = names.select { |n| names.count(n) > 1 }.uniq
  name_dupes.each do |name|
    refs = group.children.select { |c| c.display_name == name }
    next if refs.map(&:uuid).uniq.size == 1
    issues << "[DUP_NAME] Group '#{group.display_name}': '#{name}' (#{refs.map(&:uuid).join(', ')})"
  end

  group.groups.each { |g| check_groups(g, issues) }
end

check_groups(project.main_group, issues)

# Duplicate files in build phases
project.targets
  .select { |t| t.is_a?(Xcodeproj::Project::Object::PBXNativeTarget) }
  .each do |target|
    [target.source_build_phase, target.resources_build_phase, target.frameworks_build_phase].compact.each do |phase|
      refs = phase.files.map { |f| f.file_ref&.uuid }.compact
      dupes = refs.select { |r| refs.count(r) > 1 }.uniq
      dupes.each do |uuid|
        bf = phase.files.find { |f| f.file_ref&.uuid == uuid }
        issues << "[DUP_BUILD] #{target.name}/#{phase.display_name}: #{bf.file_ref.display_name} (#{uuid})"
      end
    end
  end

# Orphaned build files
project.targets.each do |target|
  target.build_phases.each do |phase|
    phase.files.each do |bf|
      if bf.file_ref.nil?
        issues << "[ORPHAN] #{target.name}/#{phase.display_name}: build file #{bf.uuid}"
      end
    end
  end
end

# Recovered References
recovered = project.main_group.children.find { |c| c.display_name == 'Recovered References' }
if recovered
  issues << "[RECOVERED] Found 'Recovered References' group with #{recovered.children.count} children"
end

# Summary
counts = {
  'DUP_CHILD' => 0, 'DUP_NAME' => 0, 'DUP_BUILD' => 0,
  'ORPHAN' => 0, 'RECOVERED' => 0
}
issues.each { |i| tag = i[/\[(\w+)\]/, 1]; counts[tag] += 1 if counts.key?(tag) }

puts ""
puts "=== Tier 2 Summary ==="
counts.each { |k, v| puts "  #{k}: #{v > 0 ? "#{v} found" : 'OK'}" }

if issues.empty?
  puts "\nNo issues found."
else
  puts "\nDetails:"
  issues.each { |i| puts "  #{i}" }
  exit 1
end
```

## Reporting

Present results as a summary table:

| Tier | Check | Status | Details |
|------|-------|--------|---------|
| 0 | Balanced delimiters | OK/FAIL | line numbers |
| 1 | Gem parsing | OK/FAIL | error message |
| 1 | Unknown UUID refs | OK/N found | list |
| 2 | Duplicate group children | OK/N found | — |
| 2 | Duplicate file names | OK/N found | — |
| 2 | Duplicate build phase files | OK/N found | — |
| 2 | Orphaned build files | OK/N found | — |
| 2 | Recovered References | OK/Found | — |

## Fixing issues

If issues were found, ask the user if they want to apply fixes.

- **Tier 0** (truncated entries): Use `Edit` on the raw `.pbxproj` file.
  Look at the line number, read context, and restore missing `);`, `sourceTree = "<group>";`, `};` sequences.
  Cross-reference with the default branch or the introducing commit (`git log -S <UUID>`) to find correct content.
- **Tier 1** (unknown UUIDs): Remove the dangling UUID lines from the raw file with `Edit`.
  These are lines in `files = (` or `fileSystemSynchronizedGroups = (` arrays referencing non-existent objects.
- **Tier 2**: Write a second Ruby script using `xcodeproj` to programmatically remove duplicates/orphans, then `project.save`.

After fixing, re-run the full audit to confirm all issues are resolved.
