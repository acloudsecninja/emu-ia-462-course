# Lab 1 — GitHub Configuration & Setup

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Week:** 2 — GitHub Configuration & Setup
**Points:** 70 points
**Submission:** Upload your screen-recording video (`.wmv`) and required files via Canvas

> **Objectives & Outcomes:** Refer to the [course syllabus](../README.md) for course objectives and grading criteria.
>
> This lab aligns to the Week 2 slide deck: *IA462 — Week 2 — GitHub Configuration & Setup*.

---

## Lab Overview

Your GitHub environment is the foundation for every lab, midterm, and final in IA 462. Before you can submit any work — or run any of the CI/CD pipelines we build later in the course — you must have:

1. A properly configured GitHub.com account (with 2FA).
2. Access to both the **course reference repo** (public) and the **student upload org repo** (private, invite-only).
3. A local Git installation that is verified across Git Bash, PowerShell, Command Prompt, and WSL Ubuntu.
4. A working push/pull cycle so your commits are correctly attributed and end up in the right repo.

**Key course repositories:**

| Repo | Purpose | Link |
|------|---------|------|
| Course Reference (public) | Lab instructions, midterm, final, syllabus | https://github.com/acloudsecninja/emu-ia-462-course |
| Student Upload (private) | Your assignment submissions via PR | https://github.com/acloudsecninja-emu-org/emu-ia-462-course-student-code-upload |

---

## Prerequisites

Before starting this lab, ensure you have:

- [ ] A working computer running Windows 10/11 (WSL Ubuntu enabled — see the Week 1 Technology Requirements slides)
- [ ] Minimum 8 GB RAM and 30 GB free disk space (16 GB RAM recommended)
- [ ] Screen recording software installed (e.g., https://www.freescreenrecording.com) with `.wmv` export
- [ ] Your EMU email address accessible
- [ ] You have received (and accepted) the GitHub organization invite from Professor Weber

> **IMPORTANT:** Never commit personal information, API keys, passwords, or any sensitive data to any GitHub repository. All work submitted to public repositories is visible to anyone on the internet. Use environment variables or GitHub Secrets for sensitive configuration.

> Linux (Ubuntu) and macOS are supported but instructor support may be limited. See Week 1 slides.

---

## Git Operations: Two Methods Available

**Method 1: GitHub Desktop (Recommended for most students)**
- Visual interface for all Git operations
- Easier pull request management
- Built-in conflict resolution
- See [Git Workflow Guide](../git-workflow-guide.md) for detailed steps

**Method 2: Command Line (Alternative)**
- Traditional terminal-based Git operations
- Full control via commands
- Useful for advanced users or when GUI unavailable
- Command examples provided throughout this lab

You can switch between methods anytime — both work with the same repositories.

---

## Part 1 — Install & Verify Git

### 1A — Install Git for Windows

#### GitHub Desktop (Preferred)
1. Download GitHub Desktop from https://desktop.github.com/
2. Run the installer and follow the prompts
3. Launch GitHub Desktop and sign in with your GitHub account
4. Configure your Git identity in **Preferences/Options → Git**
5. Git for Windows is installed automatically with GitHub Desktop

#### Command Line (Alternative)
1. Navigate to https://git-scm.com/download/win — the 64-bit installer downloads automatically.
2. Run the installer. Recommended settings:
   - **Adjusting PATH:** *Git from the command line and also from 3rd-party software*
   - **HTTPS transport:** *Use the OpenSSL library*
   - **Line endings:** *Checkout Windows-style, commit Unix-style*
   - **Default branch name:** *Override the default* → `main`
   - Leave the remaining defaults (file system caching + Git Credential Manager enabled)

### 1B — Validate Git in Three Windows Shells

#### GitHub Desktop
1. Open GitHub Desktop
2. Go to **Help → About GitHub Desktop**
3. Verify the version number is displayed
4. Git for Windows is automatically installed and configured

#### Command Line
Open each of the following and run `git --version`:

```bash
# Git Bash
git --version
```

```powershell
# PowerShell (Win + X → Windows PowerShell)
git --version
```

```cmd
:: Command Prompt (Win + R → cmd)
git --version
```

**Validation Check:** All three shells should return a version number (e.g., `git version 2.45.0.windows.1`). If PowerShell or CMD does not recognize `git`, re-run the installer and select the correct PATH option.

**Screenshot 1:** All three shells side-by-side showing `git --version` output (or GitHub Desktop About screen).

### 1C — Install & Validate Git in WSL Ubuntu

The Windows Git install does **not** carry over into WSL — you must install Git separately inside WSL.

```bash
# From PowerShell/CMD:
wsl

# Inside your WSL Ubuntu terminal:
sudo apt update && sudo apt install git -y
git --version
```

**Screenshot 2:** WSL Ubuntu terminal showing `git --version` output.

### 1D — (Optional) Share Windows Credentials with WSL

```bash
git config --global credential.helper \
  "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

> Path assumes Git for Windows default install location. Adjust if different.

### 1E — Alternative: Linux (standalone) or macOS

```bash
# Ubuntu (standalone, not WSL)
sudo apt update && sudo apt install git -y
git --version

# macOS
xcode-select --install
git --version
```

---

## Part 2 — Create & Harden Your GitHub.com Account

Follow the Week 2 slide guidance carefully — your GitHub account is part of your professional portfolio.

1. Sign up at https://github.com with your **EMU email** (`@emich.edu`).
2. Choose a **professional username** — avoid random numbers or nicknames (this may appear on your resume).
3. Verify your email address.
4. **Enable Two-Factor Authentication (2FA)** immediately — required for organization membership.
   - `Settings → Password and Authentication → Enable 2FA` (use an authenticator app such as Authy, 1Password, or Google Authenticator).
5. Accept the org invite you received from Professor Weber (check both your EMU email and the email tied to your GitHub account).

**Screenshot 3:** Your GitHub profile page showing your professional username and verified email.
**Screenshot 4:** `Settings → Password and Authentication` showing 2FA is **enabled**.

---

## Part 3 — Configure Your Local Git Identity

### GitHub Desktop
1. Open GitHub Desktop
2. Go to **Menu → Preferences (Mac) or Options (Windows)**
3. Click **Git** in the sidebar
4. Set:
   - **Name:** Your Full Name
   - **Email:** yourname@emich.edu
5. Click **Save**

### Command Line
Open a terminal (Git Bash / WSL / Terminal) and configure your commit identity so pushes are correctly attributed:

```bash
git config --global user.name "Your Full Name"
git config --global user.email "yourname@emich.edu"
git config --global core.editor "nano"
git config --global init.defaultBranch main
```

Verify your configuration:

**GitHub Desktop:** Preferences/Options → Git (shows your configured name and email)  
**Command Line:**
```bash
git config --list
```

**Screenshot 5:** Full `git config --list` output (or GitHub Desktop Git settings screen) showing `user.name`, `user.email`, and `init.defaultBranch`.

---

## Part 4 — Clone Both Course Repositories

### 4A — Clone the public reference repo

#### GitHub Desktop
1. Open GitHub Desktop
2. Click **File → Clone Repository**
3. Click **URL** tab
4. Enter: `https://github.com/acloudsecninja/emu-ia-462-course.git`
5. Choose local path (e.g., `C:\Users\you\github-repos\`)
6. Click **Clone**

#### Command Line (Optional)
```bash
git clone https://github.com/acloudsecninja/emu-ia-462-course.git
cd emu-ia-462-course
ls -la
```

### 4B — Clone the private student upload repo

#### GitHub Desktop
1. Click **File → Clone Repository**
2. Click **URL** tab
3. Enter: `https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026.git`
4. Choose local path
5. Click **Clone**

#### Command Line (Optional)
```bash
cd ~
git clone https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026.git
cd emu-ia-462-fall-2026
git remote -v
```

Verify the remote is correct:

**GitHub Desktop:** Repository → Repository Settings → Remote (shows fetch/push URLs)  
**Command Line:**
```bash
git remote -v
```

Expected output:

```
origin  https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026.git (fetch)
origin  https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026.git (push)
```

**Screenshot 6:** Both cloned directories listed on disk plus the remote information (GitHub Desktop Repository Settings or `git remote -v` output).

---

## Part 5 — Explore & Validate GitHub Security Features

Perform each step on the **student upload repo** you cloned:

1. Navigate to the student upload repo on GitHub.com → **Security and quality** tab. **Screenshot 7**.
2. Click **Dependabot alerts** (if available). **Screenshot 8**.
3. Create a `SECURITY.md` inside your Lab1 folder:

   ```bash
   mkdir -p Lab1
   cat <<'EOF' > Lab1/SECURITY.md
   # Security Policy

   ## Reporting a Vulnerability
   Report security issues to the course instructor via the Slack channel or EMU email.
   EOF
   ```

   - This section is more of a organization level or repo level process and not avaliable for students without paying for these services. At this point I wanted to make you all aware of it as this is a very common in most organziations.

5. Practice the full add/commit/push cycle:

   **GitHub Desktop:**
   - Click **Current Branch** dropdown → **New Branch**
   - Enter branch name: `lab1-<your-username>`
   - Click **Create Branch**
   - Go to **Changes** tab, check `Lab1/SECURITY.md`
   - Enter commit message: "Lab 1: add SECURITY.md and initial submission"
   - Click **Commit**
   - Click **Push origin** button

   **Command Line (Optional):**
   ```bash
   git checkout -b lab1-<your-username>
   git add Lab1/SECURITY.md
   git status
   git commit -m "Lab 1: add SECURITY.md and initial submission"
   git push origin lab1-<your-username>
   ```
   *(Note: With HTTPS authentication, GitHub will prompt for your credentials when pushing)*

6. Open a **pull request** from your branch back to `main` in the student upload repo.

   **GitHub Desktop:** Click **Branch → Create Pull Request** (opens browser to PR creation page)  
   **Command Line:** Go to GitHub.com in browser, navigate to repo, click "Compare & pull request"

   **Screenshot 10:** The open pull request page in GitHub.

> Never push directly to `main`. Always work on a branch and open a PR — this is a course-graded workflow.

---

## Part 6 — Push Your Lab 1 Screenshots

All screenshots must be committed and pushed to your `Lab1/` folder in the student upload repo. This validates that your Git workflow is fully functional.

```bash
mkdir -p Lab1/screenshots
# Copy your captured screenshots into Lab1/screenshots/
cp ~/Desktop/screenshot-*.png Lab1/screenshots/
```

Name your files descriptively:

- `01-git-versions-three-shells.png`
- `02-wsl-git-version.png`
- `03-github-profile.png`
- `04-2fa-enabled.png`
- `05-git-config-list.png`
- `06-both-repos-cloned.png`
- `07-security-tab.png`
- `08-dependabot-alerts.png`
- `09-code-security-settings.png`
- `10-pull-request-opened.png`

Stage, commit, and push:

**GitHub Desktop:**
- Go to **Changes** tab
- Check all files in `Lab1/screenshots/`
- Enter commit message: "Lab 1: add screenshots"
- Click **Commit**
- Click **Push origin** button

**Command Line (Optional):**
```bash
git add Lab1/screenshots/
git status
git commit -m "Lab 1: add screenshots"
git push origin lab1-<your-username>
```
*(Note: With HTTPS authentication, GitHub will prompt for your credentials when pushing)*

**Validation Check:** Navigate to your PR on GitHub — every screenshot should be visible in the `Lab1/screenshots/` folder.

---

## Part 7 — Record Your Video Walkthrough

Using your screen recording software, record a single video demonstrating:

1. `git --version` succeeding in Git Bash, PowerShell, CMD, and WSL Ubuntu.
2. Your GitHub profile with 2FA enabled.
3. `git config --list` showing your correct name and EMU email.
4. Both course repos cloned locally with `git remote -v` verified.
5. The Security tab, `SECURITY.md`, and Dependabot alerts on GitHub.
6. Your open pull request in the student upload repo with the `Lab1/screenshots/` folder visible.
7. A short verbal walkthrough of what each step accomplished.

> **Critical:** Export your video in `.wmv` or `mp3,mp4` formats. Files in any other format cannot be graded.

---

## Submission Requirements

Submit the following to Canvas by the due date:

| Item | Format | Required |
|------|--------|----------|
| Video walkthrough | `.wmv` | Yes |
| Screenshots (in `Lab1/screenshots/`) | `.png` / `.jpg` | Yes |
| Pull request link (student upload repo) | URL | Yes |

---

## Tips & Resources

- **Git Workflow Guide:** [git-workflow-guide.md](../git-workflow-guide.md) — Comprehensive guide for both GitHub Desktop and command line methods
- **Course syllabus (source of truth for policies):** distributed via Canvas and Google Drive
- **Course reference repo:** https://github.com/acloudsecninja/emu-ia-462-course
- **Student upload repo:** https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026
- **Git cheat sheet:** https://education.github.com/git-cheat-sheet-education.pdf
- **GitHub Desktop Docs:** https://docs.github.com/en/desktop
- **GitHub Docs:** https://docs.github.com
- Stuck? Post in the EMU IA Slack or email Professor Weber. Do not wait until class.

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
