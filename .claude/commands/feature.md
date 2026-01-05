---
description: Full feature development workflow - plan, confirm, build, test
---

# Feature Development

This is for building complete features, not quick fixes.

## Phase 1: Understand

1. First, ask me to describe exactly what I want this feature to do
2. Ask clarifying questions:
   - What triggers this feature?
   - What should happen step by step?
   - What are the edge cases?
   - How does it fit with existing screens?

## Phase 2: Plan

3. Create a detailed plan:
   - List all files that need to be created/modified
   - Describe the data model changes (if any)
   - Outline the UI components needed
   - Note any new dependencies

4. Check the plan against:
   - CLAUDE.md design system
   - roadmap.md to ensure this is in scope
   - Existing code patterns

5. Present the plan and WAIT for my approval before coding

## Phase 3: Build

6. Only after I confirm the plan:
   - Create/modify files one at a time
   - Start with data models
   - Then services/utilities
   - Then views (bottom-up: components → screens)
   - Add previews to every view

7. After each file, briefly explain what it does

## Phase 4: Verify

8. Build the project:
   ```bash
   xcodebuild -project Learnt.xcodeproj -scheme Learnt -sdk iphonesimulator build
   ```

9. If build fails, fix errors immediately

10. Run on simulator and test the feature

11. Take a screenshot for review if UI was changed

## Phase 5: Complete

12. Summarize what was built
13. Update roadmap.md to check off completed items
14. Suggest next logical feature to build

---

$ARGUMENTS should be a brief description of the feature (e.g., "voice input recording")
