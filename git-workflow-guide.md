# Git Workflow Guide: GitHub Desktop (Preferred) + Command Line (Alternative)

**Course:** IA 462 — Advanced Operating Systems Security & Administration  
**Purpose:** Unified guide for Git operations using both GitHub Desktop (recommended) and command line (alternative)

## Philosophy

This course supports two methods for Git operations:

- **GitHub Desktop (Preferred):** Graphical interface, easier for most students, visual pull request management, built-in conflict resolution
- **Command Line (Alternative):** Traditional terminal-based Git operations, full control via commands, useful for advanced users or when GUI unavailable

Both methods are fully supported and produce identical results. Choose whichever works best for you — you can switch between methods anytime since both work with the same repositories.

---

## Quick Reference: Common Operations

| Operation | GitHub Desktop | Command Line |
|-----------|----------------|--------------|
| Clone repository | File → Clone Repository → Enter URL | `git clone <url>` |
| Create branch | Branch → New Branch → Enter name | `git checkout -b <branch-name>` |
| Stage changes | Check files in "Changes" list | `git add <files>` |
| Commit changes | Enter message → Click "Commit" | `git commit -m "message"` |
| Push changes | Push origin button | `git push origin <branch>` |
| Pull changes | Fetch origin → Pull origin | `git pull origin <branch>` |
| Create Pull Request | Branch → Create Pull Request | Via GitHub web interface |

---

## Part 1 — Installation & Setup

### GitHub Desktop Installation (Preferred)

1. Download GitHub Desktop from https://desktop.github.com/
2. Run the installer (Windows: `.exe`, macOS: `.dmg`)
3. Launch GitHub Desktop and sign in with your GitHub account
4. Configure your Git identity (Tools → Options → Git → Name and Email)
5. Choose your default shell (Git Bash, PowerShell, or WSL for Windows)

### Command Line Installation (Alternative)

#### Windows
```bash
# Download from https://git-scm.com/download/win
# Run installer with recommended settings:
# - Git from the command line and also from 3rd-party software
# - Use bundled OpenSSH
# - Use the OpenSSL library
# - Checkout Windows-style, commit Unix-style
# - Default branch name: main
```

#### WSL Ubuntu
```bash
sudo apt update && sudo apt install git -y
git --version
```

#### macOS
```bash
xcode-select --install
git --version
```

### Verification (Both Methods)

**GitHub Desktop:** Help → About GitHub Desktop (shows version)  
**Command Line:** `git --version` in any terminal

---

## Part 2 — Git Identity Configuration

### GitHub Desktop
1. Open GitHub Desktop
2. Go to **Menu → Preferences (or Options on Windows)**
3. Click **Git** in the sidebar
4. Set:
   - **Name:** Your Full Name
   - **Email:** yourname@emich.edu
5. Click **Save**

### Command Line
```bash
git config --global user.name "Your Full Name"
git config --global user.email "yourname@emich.edu"
git config --global core.editor "nano"
git config --global init.defaultBranch main
```

Verify:
```bash
git config --list
```

---

## Part 3 — SSH Authentication Setup

### GitHub Desktop
1. Open GitHub Desktop
2. Go to **Preferences → Git** or **Options → Git**
3. Click **Create SSH Key** (or import existing key)
4. Follow the prompts to generate a new SSH key
5. Copy the public key shown
6. Go to GitHub.com → **Settings → SSH and GPG keys → New SSH key**
7. Paste the key, give it a descriptive title (e.g., `IA462-laptop`), save
8. Test in GitHub Desktop: **Repository → Clone** and try cloning a test repo

### Command Line
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "yourname@emich.edu"
# Accept default file location. Set a passphrase (recommended).

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub
# 1. Copy the output → GitHub → Settings → SSH and GPG keys → New SSH key
# 2. Paste, give it a descriptive title (e.g., IA462-laptop), save

# Test connectivity
ssh -T git@github.com
```

Expected output:
```
Hi <your-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## Part 4 — Cloning Course Repositories

### GitHub Desktop

#### Clone Public Reference Repo
1. Open GitHub Desktop
2. Click **File → Clone Repository**
3. Click **URL** tab
4. Enter: `https://github.com/acloudsecninja/emu-ia-462-course.git`
5. Choose local path (e.g., `C:\Users\you\github-repos\`)
6. Click **Clone**

#### Clone Private Student Upload Repo
1. Click **File → Clone Repository**
2. Click **URL** tab
3. Enter: `git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git`
4. Choose local path
5. Click **Clone**

### Command Line

#### Clone Public Reference Repo
```bash
git clone https://github.com/acloudsecninja/emu-ia-462-course.git
cd emu-ia-462-course
ls -la
```

#### Clone Private Student Upload Repo
```bash
cd ~
git clone git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git
cd emu-ia-462-fall-2026
git remote -v
```

Verify remote:
```bash
git remote -v
```

Expected output:
```
origin  git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git (fetch)
origin  git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git (push)
```

---

## Part 5 — Branching Workflow

### GitHub Desktop

#### Create New Branch
1. Select the repository in GitHub Desktop
2. Click **Current Branch** dropdown (top-left)
3. Click **New Branch**
4. Enter branch name (e.g., `lab1-your-username`)
5. Click **Create Branch**
6. GitHub Desktop automatically switches to the new branch

#### Switch Between Branches
1. Click **Current Branch** dropdown
2. Select the branch you want to switch to
3. GitHub Desktop updates your working directory

#### View Branch History
1. Click **History** tab (left sidebar)
2. See commits for current branch
3. Click commits to see changes

### Command Line

#### Create New Branch
```bash
git checkout -b lab1-your-username
```

#### Switch Between Branches
```bash
git checkout main
git checkout lab1-your-username
```

#### View Branch History
```bash
git log --oneline
git log --graph --all --decorate
```

---

## Part 6 — Making Changes & Committing

### GitHub Desktop

#### Stage Changes
1. Make changes to files in your repository
2. Open GitHub Desktop
3. Go to **Changes** tab (left sidebar)
4. Check the boxes next to files you want to include
5. Review changes in the diff view (right panel)

#### Commit Changes
1. Enter a commit message in the summary field
2. (Optional) Add extended description
3. Click **Commit** button
4. Changes are now committed to your local branch

#### View Uncommitted Changes
- Changes tab shows all modified files
- Click each file to see detailed diff
- Discard changes if needed (right-click → Discard changes)

### Command Line

#### Stage Changes
```bash
# Stage specific files
git add Lab1/SECURITY.md

# Stage all changes
git add .

# Check status
git status
```

#### Commit Changes
```bash
git commit -m "Lab 1: add SECURITY.md and initial submission"
```

#### View Uncommitted Changes
```bash
git status
git diff
git diff Lab1/SECURITY.md
```

---

## Part 7 — Pushing Changes

### GitHub Desktop

#### Push to Remote
1. Make sure you're on the correct branch (check Current Branch dropdown)
2. Click **Push origin** button (top-right)
3. Wait for push to complete
4. View confirmation in push log

#### Push after Commit
- After committing, GitHub Desktop shows a "Push origin" banner
- Click the banner to push immediately
- Or push later using the Push origin button

### Command Line

#### Push to Remote
```bash
git push origin lab1-your-username
```

#### Push Current Branch
```bash
git push
```

#### Force Push (Use with Caution)
```bash
git push --force origin lab1-your-username
```

---

## Part 8 — Pulling Changes & Syncing

### GitHub Desktop

#### Pull Latest Changes
1. Click **Fetch origin** button (top-right)
2. Click **Pull origin** button
3. GitHub Desktop merges remote changes into your local branch
4. Resolve conflicts if any (see Conflict Resolution section)

#### Sync with Remote
- Click **Sync** button (combination of fetch + pull + push)
- Useful when working on multiple computers

### Command Line

#### Pull Latest Changes
```bash
git pull origin main
```

#### Fetch Without Merging
```bash
git fetch origin
```

#### Rebase Instead of Merge
```bash
git pull --rebase origin main
```

---

## Part 9 — Creating Pull Requests

### GitHub Desktop

#### Create Pull Request
1. Make sure your branch is pushed to remote
2. Click **Branch → Create Pull Request**
3. GitHub Desktop opens your browser to the PR creation page
4. Fill in:
   - Title: descriptive PR title
   - Description: explain your changes
   - Reviewers: add if required
5. Click **Create Pull Request**

#### View Existing PRs
- Click **Branch** menu
- See list of your open PRs
- Click to view in browser

### Command Line

#### Create Pull Request
```bash
# Method 1: Use GitHub CLI (gh)
gh pr create --title "Lab 1: Add SECURITY.md" --body "Adding SECURITY.md for Lab 1 submission"

# Method 2: Manual via browser
# 1. Push your branch: git push origin lab1-your-username
# 2. Go to GitHub.com in browser
# 3. Navigate to your repository
# 4. Click "Compare & pull request" button
# 5. Fill in PR details and create
```

---

## Part 10 — Conflict Resolution

### GitHub Desktop

#### Resolve Conflicts
1. When pulling, GitHub Desktop alerts you to conflicts
2. Go to **Changes** tab
3. Conflicted files show with warning icon
4. Click conflicted file to see conflict markers
5. Choose:
   - **Keep Your Changes** (accept your version)
   - **Keep Incoming Changes** (accept remote version)
   - **Manual Edit** (edit the file directly)
6. After resolving all conflicts, click **Mark as Resolved**
7. Commit the resolution
8. Push the resolved changes

### Command Line

#### Resolve Conflicts
```bash
# 1. Pull to detect conflicts
git pull origin main

# 2. See conflicted files
git status

# 3. Edit conflicted files manually
# Look for <<<<<<<, =======, >>>>>>> markers

# 4. After editing, stage resolved files
git add <resolved-files>

# 5. Complete the merge/rebase
git commit  # for merge
# or
git rebase --continue  # for rebase

# 6. Push resolved changes
git push origin lab1-your-username
```

---

## Part 11 — Signed Commits (SSH)

### Important Note
SSH commit signing is required for this course (Lab 4, Midterm, Final). The setup is primarily command-line based, but once configured, both methods can create signed commits.

### Configuration (Command Line Required)
```bash
# Configure SSH signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Add the same SSH key as a **signing key** on GitHub:
- GitHub → Settings → SSH and GPG keys → New SSH key → Key type: Signing

### GitHub Desktop with Signed Commits
1. After command-line setup, GitHub Desktop automatically uses SSH signing
2. Commit as normal in GitHub Desktop
3. Push and view on GitHub — commits will show "Verified" badge

### Command Line with Signed Commits
```bash
# Standard commit (automatically signed due to config)
git commit -m "chore: verify signed commits"

# Explicitly sign a commit
git commit -S -m "chore: explicitly signed commit"

# Verify signing
git log --show-signature
```

---

## Part 12 — Checking Repository Status

### GitHub Desktop

#### Repository Overview
- **Repository** menu shows current repo info
- **Changes** tab shows uncommitted changes
- **History** tab shows commit history
- **Repository** → **Repository Settings** shows remotes and branches

#### View Remote Info
- Repository → Repository Settings → Remote
- Shows fetch/push URLs

### Command Line

#### Repository Status
```bash
git status
git remote -v
git branch -a
git log --oneline --graph --all
```

---

## Part 13 — Advanced Operations

### GitHub Desktop

#### Ignore Files
1. Go to **Repository → Repository Settings**
2. Click **Ignored Files**
3. Add patterns (e.g., `*.log`, `node_modules/`)

#### Stash Changes
1. Go to **Changes** tab
2. Click **Stash All Changes**
3. Changes are saved temporarily
4. Restore later: Branch → Stashed Changes → Apply

#### Tags
- Repository → Create Tag
- Enter tag name and message
- Push tag: Push origin → Include tags

### Command Line

#### Ignore Files
```bash
# Edit .gitignore
echo "*.log" >> .gitignore
echo "node_modules/" >> .gitignore
git add .gitignore
git commit -m "Add gitignore"
```

#### Stash Changes
```bash
git stash
git stash list
git stash pop
```

#### Tags
```bash
git tag v1.0.0
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
```

---

## Part 14 — Troubleshooting

### Common Issues & Solutions

#### GitHub Desktop Issues

**Issue: Can't connect to GitHub**
- Check internet connection
- Verify GitHub credentials (File → Options → Accounts)
- Try removing and re-adding account

**Issue: Push fails**
- Check if you're on correct branch
- Verify remote URL (Repository → Repository Settings)
- Pull first, then push

**Issue: Changes not showing**
- Refresh repository (F5)
- Check if you're on correct branch
- Verify file location

#### Command Line Issues

**Issue: Permission denied (publickey)**
```bash
# Verify SSH key is loaded
ssh-add -l
# Add key if needed
ssh-add ~/.ssh/id_ed25519
```

**Issue: Merge conflicts**
```bash
# Abort merge and start over
git merge --abort
# Or resolve conflicts manually
```

**Issue: Wrong remote URL**
```bash
# Change remote URL
git remote set-url origin git@github.com:username/repo.git
```

---

## Part 15 — Best Practices

### Course-Specific Workflow

1. **Always work on branches** — Never commit directly to `main`
2. **Branch naming convention:** `lab1-username`, `lab2-username`, etc.
3. **Commit messages:** Be descriptive (e.g., "Lab 1: add SECURITY.md")
4. **Pull before pushing** — Avoid unnecessary conflicts
5. **Use PRs for submissions** — Required for grading workflow
6. **Keep commits atomic** — One logical change per commit
7. **Never commit sensitive data** — API keys, passwords, etc.

### GitHub Desktop Tips

- Use keyboard shortcuts (Ctrl/Cmd + P for quick commands)
- Pin frequently used repositories
- Use the "Compare branches" feature to see differences
- Enable notifications for PR comments

### Command Line Tips

- Use `git alias` for common commands
- Learn `git reflog` to recover lost commits
- Use `git stash` for temporary work preservation
- Configure `.gitignore` early to avoid committing junk

---

## Part 16 — Course-Specific Examples

### Lab 1 Workflow Example

#### GitHub Desktop
1. Clone both repos (see Part 4)
2. Create branch: `lab1-your-username`
3. Add `Lab1/SECURITY.md` file
4. In GitHub Desktop: Check file → Commit → Push
5. Create PR via Branch → Create Pull Request

#### Command Line
```bash
cd ~/emu-ia-462-fall-2026
git checkout -b lab1-your-username
mkdir -p Lab1
# Create SECURITY.md
git add Lab1/SECURITY.md
git commit -m "Lab 1: add SECURITY.md"
git push origin lab1-your-username
# Create PR via browser
```

### Lab 4 Signed Commit Example

#### Setup (Command Line - Required)
```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

#### GitHub Desktop
1. Make changes to files
2. Commit as normal (automatically signed)
3. Push → View on GitHub → Check for "Verified" badge

#### Command Line
```bash
git add .
git commit -m "Lab 4: add supply chain controls"
git push origin lab4-your-username
# Check on GitHub for "Verified" badge
```

---

## Resources

### Official Documentation
- **GitHub Desktop:** https://docs.github.com/en/desktop
- **Git Command Line:** https://git-scm.com/doc
- **GitHub Flow:** https://docs.github.com/en/get-started/quickstart/github-flow

### Course Resources
- **Course reference repo:** https://github.com/acloudsecninja/emu-ia-462-course
- **Student upload repo:** https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026
- **Git cheat sheet:** https://education.github.com/git-cheat-sheet-education.pdf

### Troubleshooting
- Course Slack channel
- Email Professor Weber
- GitHub Community Forums: https://github.community

---

## Quick Decision Guide

**Use GitHub Desktop if:**
- You're new to Git
- You prefer visual interfaces
- You want easier conflict resolution
- You like seeing branch relationships visually
- You're working on multiple platforms

**Use Command Line if:**
- You're comfortable with terminals
- You need to script Git operations
- You're working on remote servers
- You want full control over Git commands
- You're debugging complex Git issues

**Remember:** Both methods work together seamlessly. You can use GitHub Desktop for daily operations and command line for specific tasks as needed.
