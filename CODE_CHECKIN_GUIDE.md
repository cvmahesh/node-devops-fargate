# Code Check-in Guide for Junior Developers

This guide will help you understand how to check in (commit) your code to the repository step by step.

## 📋 Table of Contents

1. [Before You Start](#before-you-start)
2. [Daily Workflow](#daily-workflow)
3. [Step-by-Step Check-in Process](#step-by-step-check-in-process)
4. [Common Scenarios](#common-scenarios)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Before You Start

### Prerequisites

1. **Git is installed** - Check by running:
   ```bash
   git --version
   ```

2. **You have access to the repository** - Make sure you can clone and push to the repo

3. **Your Git is configured** - Set your name and email:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

---

## Daily Workflow

### Typical Day Flow

```
1. Pull latest code from repository
2. Create a branch for your work
3. Make changes to code
4. Test your changes
5. Stage your changes
6. Commit your changes
7. Push to repository
8. Create Pull Request (if working in a team)
```

---

## Step-by-Step Check-in Process

### Step 1: Check Current Status

Before making any changes, always check what files have been modified:

```bash
git status
```

This shows:
- ✅ Files that are modified
- ✅ Files that are staged (ready to commit)
- ✅ Files that are untracked (new files)

**Example output:**
```
On branch main
Changes not staged for commit:
  modified:   server/server.js
  modified:   client/client.js

Untracked files:
  new-file.js
```

---

### Step 2: Pull Latest Changes

**Always pull the latest code before starting work!**

```bash
git pull origin main
```

This ensures you have the latest code from the repository.

**If you get conflicts:**
- Don't panic! Ask a senior developer for help
- Conflicts happen when someone else changed the same file

---

### Step 3: Create a Branch (Recommended)

**Why create a branch?**
- Keeps your work separate from main code
- Allows you to test before merging
- Makes it easier to review changes

```bash
# Create and switch to a new branch
git checkout -b feature/your-feature-name

# Example:
git checkout -b feature/add-login-endpoint
```

**Good branch naming:**
- `feature/add-new-api` - For new features
- `bugfix/fix-cors-error` - For bug fixes
- `hotfix/security-patch` - For urgent fixes

---

### Step 4: Make Your Changes

Edit files, add new code, fix bugs, etc.

**Always test your code before committing!**

```bash
# Test the server
cd server
npm install
npm start

# Test the client
cd ../client
npm install
npm start
```

---

### Step 5: Review Your Changes

Before committing, review what you changed:

```bash
# See what files changed
git status

# See the actual changes (diff)
git diff

# See changes in a specific file
git diff server/server.js
```

**Review checklist:**
- ✅ Did I test the changes?
- ✅ Are there any console.log statements I should remove?
- ✅ Are there any commented-out code blocks?
- ✅ Did I follow the coding standards?

---

### Step 6: Stage Your Changes

**Staging** means telling Git which files you want to commit.

**Option A: Stage specific files (Recommended)**
```bash
# Stage one file
git add server/server.js

# Stage multiple files
git add server/server.js client/client.js

# Stage all files in a directory
git add server/
```

**Option B: Stage all changes (Use carefully!)**
```bash
git add .
```

⚠️ **Warning:** `git add .` adds ALL changes. Make sure you review with `git status` first!

**Check what's staged:**
```bash
git status
```

Files in green are staged and ready to commit.

---

### Step 7: Commit Your Changes

**Commit** saves your changes with a message describing what you did.

```bash
git commit -m "Your commit message here"
```

**Good commit messages:**
- ✅ `"Add health check endpoint"`
- ✅ `"Fix CORS error in server"`
- ✅ `"Update README with Docker instructions"`
- ✅ `"Add error handling for API calls"`

**Bad commit messages:**
- ❌ `"fix"`
- ❌ `"changes"`
- ❌ `"update"`
- ❌ `"asdf"`

**Commit message format:**
```
Short description (50 characters or less)

Longer explanation if needed (wrap at 72 characters)
- What changed
- Why it changed
- Any breaking changes
```

**Example:**
```bash
git commit -m "Add CORS support to server

- Added cors package to dependencies
- Enabled CORS middleware in Express
- Fixes browser client connection errors"
```

---

### Step 8: Push to Repository

**Push** uploads your commits to the remote repository.

**If working on a branch:**
```bash
# First time pushing a branch
git push -u origin feature/your-feature-name

# Subsequent pushes
git push
```

**If working on main (be careful!):**
```bash
git push origin main
```

⚠️ **Note:** Many teams don't allow direct pushes to main. Always check with your team!

---

### Step 9: Create Pull Request (If using branches)

1. Go to your repository on GitHub
2. Click "Pull Requests" tab
3. Click "New Pull Request"
4. Select your branch
5. Add description of changes
6. Request review from team members
7. Wait for approval before merging

---

## Common Scenarios

### Scenario 1: I Made a Mistake in My Last Commit

**If you haven't pushed yet:**
```bash
# Make your corrections
# Then amend the commit
git add .
git commit --amend -m "Corrected commit message"
```

**If you already pushed:**
```bash
# Make corrections
git add .
git commit -m "Fix: correct previous mistake"
git push
```

---

### Scenario 2: I Want to Undo Changes to a File

**Before staging (not committed yet):**
```bash
# Discard changes to a specific file
git checkout -- server/server.js

# Discard ALL changes (be careful!)
git checkout -- .
```

**After staging but before commit:**
```bash
# Unstage a file (keeps the changes)
git reset HEAD server/server.js

# Unstage all files
git reset HEAD .
```

**After commit (but not pushed):**
```bash
# Undo last commit (keeps changes)
git reset --soft HEAD~1

# Undo last commit (discards changes)
git reset --hard HEAD~1
```

---

### Scenario 3: I Need to Update My Branch with Latest Code

```bash
# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Switch back to your branch
git checkout feature/your-feature-name

# Merge main into your branch
git merge main
```

---

### Scenario 4: I Accidentally Committed Wrong Files

**If not pushed yet:**
```bash
# Remove file from last commit (keeps the file)
git reset HEAD~1
git add correct-files
git commit -m "Correct commit"

# Or remove file completely from commit
git reset --soft HEAD~1
git reset HEAD wrong-file.js
git commit -m "Correct commit"
```

---

### Scenario 5: I Want to See My Commit History

```bash
# See recent commits
git log

# See commits in one line
git log --oneline

# See commits with file changes
git log --stat

# See commits for specific file
git log -- server/server.js
```

---

## Best Practices

### ✅ DO:

1. **Commit often** - Small, frequent commits are better than one big commit
2. **Write clear commit messages** - Future you will thank you!
3. **Test before committing** - Make sure your code works
4. **Pull before push** - Always get latest code first
5. **Use branches** - Keep your work organized
6. **Review your changes** - Use `git diff` before committing
7. **Commit related changes together** - Don't mix unrelated changes

### ❌ DON'T:

1. **Don't commit sensitive data** - Passwords, API keys, etc.
2. **Don't commit large files** - Use Git LFS or external storage
3. **Don't commit `node_modules`** - It's in `.gitignore` for a reason
4. **Don't commit commented-out code** - Remove it instead
5. **Don't commit with `--no-verify`** - Unless you know what you're doing
6. **Don't force push to main** - Can break things for everyone
7. **Don't commit without testing** - Test your code first!

---

## What NOT to Commit

These files should **NEVER** be committed (they're in `.gitignore`):

- ❌ `node_modules/` - Dependencies (too large, can be reinstalled)
- ❌ `.env` - Environment variables (contains secrets!)
- ❌ `*.log` - Log files (generated automatically)
- ❌ `.DS_Store` - macOS system files
- ❌ `package-lock.json` - Sometimes, depends on team preference
- ❌ Build artifacts - Generated files
- ❌ IDE settings - `.vscode/`, `.idea/` (sometimes)

**Check what will be committed:**
```bash
git status
```

If you see files that shouldn't be committed, add them to `.gitignore`.

---

## Troubleshooting

### Problem: "Your branch is behind 'origin/main'"

**Solution:**
```bash
git pull origin main
# Resolve any conflicts if they occur
```

---

### Problem: "Merge conflict"

**What it means:** Someone else changed the same file you changed.

**Solution:**
1. Open the conflicted file
2. Look for conflict markers: `<<<<<<<`, `=======`, `>>>>>>>`
3. Choose which version to keep (or combine both)
4. Remove the conflict markers
5. Stage and commit:
   ```bash
   git add conflicted-file.js
   git commit -m "Resolve merge conflict"
   ```

**If you're stuck:** Ask a senior developer for help!

---

### Problem: "Permission denied" when pushing

**Possible causes:**
- You don't have write access to the repository
- Your SSH keys aren't set up
- You're using HTTPS and need to authenticate

**Solution:**
- Ask your team lead for repository access
- Set up SSH keys or use personal access token

---

### Problem: "Changes not staged for commit"

**What it means:** You modified files but didn't stage them.

**Solution:**
```bash
# Stage the files
git add filename.js

# Or stage all changes
git add .
```

---

### Problem: I can't push because someone else pushed first

**Solution:**
```bash
# Pull the latest changes
git pull origin main

# Resolve any conflicts
# Then push again
git push
```

---

## Quick Reference Commands

```bash
# Check status
git status

# See changes
git diff

# Stage files
git add filename.js
git add .

# Commit
git commit -m "Your message"

# Push
git push origin branch-name

# Pull latest
git pull origin main

# Create branch
git checkout -b feature/name

# Switch branch
git checkout branch-name

# See branches
git branch

# See commit history
git log --oneline
```

---

## Getting Help

If you're stuck:

1. **Check Git status:**
   ```bash
   git status
   ```

2. **Read error messages carefully** - They usually tell you what's wrong

3. **Ask for help:**
   - Ask a senior developer
   - Check Git documentation: `git help <command>`
   - Search online for the error message

4. **Don't panic!** - Git is designed to help you, not lose your work

---

## Practice Exercise

Try this workflow:

1. Create a new branch: `git checkout -b practice/my-first-branch`
2. Make a small change to `server/server.js` (add a comment)
3. Check status: `git status`
4. See the diff: `git diff`
5. Stage the file: `git add server/server.js`
6. Commit: `git commit -m "Practice: added comment"`
7. Push: `git push -u origin practice/my-first-branch`
8. Switch back to main: `git checkout main`

---

## Summary

**Remember the golden rule:**
1. ✅ Pull before you start
2. ✅ Test before you commit
3. ✅ Review before you push
4. ✅ Ask if you're unsure

**Happy coding! 🚀**

---

*Last updated: [Current Date]*
*Questions? Ask your team lead or senior developers!*

