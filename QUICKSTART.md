# Quick Start Guide

Get from zero to building in 30 minutes.

---

## Step 1: Apple Developer Account (If Not Done)

1. Go to https://developer.apple.com/programs/
2. Click "Enroll" → Sign in with Apple ID → Choose "Individual"
3. Pay $99
4. Wait for approval (usually instant to 48 hours)

**Don't wait** - continue with Steps 2-4 while this processes. You only need the account for TestFlight and device testing.

---

## Step 2: Create GitHub Repo

```bash
# On GitHub: Create new repo named "Learnt" (private)
# Don't initialize with README

# Then locally:
cd ~/Developer  # or wherever you keep projects
mkdir Learnt
cd Learnt

# Copy all these files into this directory
# (From the zip/folder I provided)

# Initialize git
git init
git add .
git commit -m "Initial commit: Project setup with Claude Code configuration"
git remote add origin git@github.com:YOUR_USERNAME/Learnt.git
git push -u origin main
```

---

## Step 3: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "App" under iOS
4. Configure:
   - **Product Name:** Learnt
   - **Team:** Your Apple ID (or Developer account when approved)
   - **Organization Identifier:** com.itamih
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** SwiftData ✅
   - **Include Tests:** ✅

5. Save it **inside** your Learnt folder (replace/merge if asked)

6. In Xcode:
   - Select the Learnt target
   - Go to Signing & Capabilities
   - Set Team to your Apple ID

7. Build (Cmd+B) to verify everything works

---

## Step 4: Verify Claude Code Setup

```bash
cd ~/Developer/Learnt

# Start Claude Code
claude

# Once in Claude Code, verify setup
/init  # Let Claude scan the project

# Ask Claude to verify it sees everything
"Can you see the CLAUDE.md and the design skill? List what you have access to."
```

Claude should confirm:
- ✅ CLAUDE.md with project context
- ✅ roadmap.md with version planning  
- ✅ .claude/commands/ with 5 slash commands
- ✅ .claude/skills/learnt-design/ with design system

---

## Step 5: Build First Screen

Now you're ready. In Claude Code:

```
/feature today screen

# Claude will ask clarifying questions
# Answer them based on the design in CLAUDE.md
# Review the plan
# Say "yes" to start building
```

Or if you want to go step by step:

```
"Let's build the Today screen. Start with just the date display and empty state. Follow the design system in the learnt-design skill."
```

---

## Workflow Going Forward

### Starting a session:
```bash
cd ~/Developer/Learnt
claude
```

### Adding a feature:
```
/feature [description]
```

### Quick commits:
```
/commit
```

### Checking your work:
```
/build-run
/screenshot
```

### Viewing roadmap:
```
"Show me what's left in v1 from the roadmap"
```

---

## Common Issues

### "Xcode can't find signing certificate"
- Go to Xcode → Settings → Accounts
- Add your Apple ID
- Let Xcode manage signing automatically

### "Build fails with module not found"
- Clean build: Cmd+Shift+K
- Rebuild: Cmd+B

### "Simulator won't boot"
- Reset simulator: Device → Erase All Content and Settings
- Or use a different simulator model

### "Claude doesn't see my files"
- Make sure you're in the right directory
- Run `ls` to verify CLAUDE.md exists
- Try `/init` to rescan

---

## First Day Goals

By end of today:
- [ ] Apple Developer enrollment submitted
- [ ] GitHub repo created
- [ ] Xcode project building
- [ ] Claude Code verified working
- [ ] TodayView with date display created

By end of tomorrow:
- [ ] Entry model created (SwiftData)
- [ ] Text input working
- [ ] Can save and display an entry

By end of week 1:
- [ ] Voice input working
- [ ] Activity dots showing
- [ ] Swipe navigation between days
- [ ] All 3 tabs present (even if Insights/Profile are stubs)

---

## Getting Help

If stuck:
1. Check CLAUDE.md for design/architecture decisions
2. Check roadmap.md for what's in/out of scope
3. Ask Claude: "I'm stuck on [X], what should I try?"
4. Take a screenshot and ask Claude to review

Remember: Ship ugly, then polish. Don't optimize early.
