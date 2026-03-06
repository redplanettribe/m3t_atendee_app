# Create PR

## Overview

Create a well-structured pull request with a clear description, scope, and testing notes. Follow the project's architecture and conventions; link any related issues or specs.

## Steps

1. **Prepare branch**
   - Ensure all changes are committed and the branch is pushed.
   - Rebase or merge from the target branch (e.g. `main`) if needed. Run `flutter test` (and package tests) so the PR is green.

2. **Write PR description**
   - **Summary:** One or two sentences on what this PR does.
   - **Context / motivation:** Why this change is needed (e.g. new feature, bug fix, refactor).
   - **Changes:** Bullet list of main changes (features, files, or areas touched). Mention if new routes, new API endpoints, or new packages were added.
   - **Breaking changes:** Call out any breaking API or behavior changes and how callers should adapt.
   - **Screenshots / UX:** If the change affects the UI, add a screenshot or short clip.

3. **Set up PR**
   - Create the PR with a descriptive title (e.g. "Add events list feature" or "Fix login code validation").
   - Add labels if your repo uses them (e.g. feature, bug, refactor).
   - Assign reviewers. Link related issues (e.g. "Closes #123").
   - If the change touches API or domain contracts, note that and tag relevant reviewers.

## PR Template (copy and fill)

- **Summary:** …
- **Context:** …
- **Changes:**
  - …
- **Breaking changes:** None / …
- **Testing:** Unit tests added/updated; manual testing done for …
- **Checklist:** [ ] Tests pass, [ ] No new analyzer/lint issues, [ ] Routes/API follow project conventions
