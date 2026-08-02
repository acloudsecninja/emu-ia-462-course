# Lab 1 — GitHub Configuration & Setup

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Week:** 2 — GitHub Configuration & Setup
**Points:** 75 points
**Submission:** Upload your screen-recording video (`.wmv`) and required files via Canvas

> **Objectives & Outcomes:** Refer to the [course syllabus](../README.md) for course objectives and grading criteria.
>
> This lab aligns to the Week 2 slide deck: *IA462 — Week 2 — GitHub Configuration & Setup*.

---

## Lab Overview

Your GitHub environment is the foundation for every lab, midterm, and final in IA 462. Before you can submit any work — or run any of the CI/CD pipelines we build later in the course — you must have:

1. A properly configured GitHub.com account (with 2FA and SSH keys).
2. Access to both the **course reference repo** (public) and the **student upload org repo** (private, invite-only).
3. A local Git installation that is verified across Git Bash, PowerShell, Command Prompt, and WSL Ubuntu.
4. A working push/pull cycle so your commits are correctly attributed and end up in the right repo.

**Key course repositories:**

| Repo | Purpose | Link |
|------|---------|------|
| Course Reference (public) | Lab instructions, midterm, final, syllabus | https://github.com/acloudsecninja/emu-ia-462-course |
| Student Upload (private) | Your assignment submissions via PR | https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026 |

---

## Prerequisites

Before starting this lab, ensure you have:

- [ ] A working computer running Windows 10/11 (WSL Ubuntu enabled — see the Week 1 Technology Requirements slides)
- [ ] Minimum 8 GB RAM and 30 GB free disk space (16 GB RAM recommended)
- [ ] Screen recording software installed (e.g., https://www.freescreenrecording.com) with `.wmv` export
- [ ] Your EMU email address accessible
- [ ] You have received (and accepted) the GitHub organization invite from Professor Weber

> Linux (Ubuntu) and macOS are supported but instructor support may be limited. See Week 1 slides.

---

## Part 1 — Install & Verify Git

### 1A — Install Git for Windows

1. Navigate to https://git-scm.com/download/win — the 64-bit installer downloads automatically.
2. Run the installer. Recommended settings:
   - **Adjusting PATH:** *Git from the command line and also from 3rd-party software*
   - **SSH executable:** *Use bundled OpenSSH*
   - **HTTPS transport:** *Use the OpenSSL library*
   - **Line endings:** *Checkout Windows-style, commit Unix-style*
   - **Default branch name:** *Override the default* → `main`
   - Leave the remaining defaults (file system caching + Git Credential Manager enabled)

### 1B — Validate Git in Three Windows Shells

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

**Screenshot 1:** All three shells side-by-side showing `git --version` output.

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

Open a terminal (Git Bash / WSL / Terminal) and configure your commit identity so pushes are correctly attributed:

```bash
git config --global user.name "Your Full Name"
git config --global user.email "yourname@emich.edu"
git config --global core.editor "nano"
git config --global init.defaultBranch main
```

Verify your configuration:

```bash
git config --list
```

**Screenshot 5:** Full `git config --list` output showing `user.name`, `user.email`, and `init.defaultBranch`.

---

## Part 4 — Set Up SSH Authentication

Password authentication is deprecated on GitHub. Configure an SSH key.

### 4A — Generate an SSH key

```bash
ssh-keygen -t ed25519 -C "yourname@emich.edu"
# Accept default file location. Set a passphrase (recommended).
```

### 4B — Add the public key to GitHub

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the output → GitHub → `Settings → SSH and GPG keys → New SSH key` → paste, give it a descriptive title (e.g., `IA462-laptop`), save.

### 4C — Test SSH connectivity

```bash
ssh -T git@github.com
```

Expected output:

```
Hi <your-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

**Screenshot 6:** Terminal output of `ssh -T git@github.com` showing a successful authentication.

---

## Part 5 — Clone Both Course Repositories

### 5A — Clone the public reference repo

```bash
git clone https://github.com/acloudsecninja/emu-ia-462-course.git
cd emu-ia-462-course
ls -la
```

### 5B — Clone the private student upload repo

```bash
cd ~
git clone git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git
cd emu-ia-462-fall-2026
git remote -v
```

Verify the remote is correct:

```bash
git remote -v
```

Expected output:

```
origin  git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git (fetch)
origin  git@github.com:acloudsecninja-emu-org/emu-ia-462-fall-2026.git (push)
```

**Screenshot 7:** Both cloned directories listed on disk plus the `git remote -v` output of the student upload repo.

---

## Part 6 — Explore & Validate GitHub Security Features

Perform each step on the **student upload repo** you cloned:

1. Navigate to the repo on GitHub.com → **Security** tab. **Screenshot 8**.
2. Click **Dependabot alerts** (if available). **Screenshot 9**.
3. Go to **Settings → Code security and analysis** — enable **Dependency graph**, **Dependabot alerts**, and **Secret scanning** if not already on. **Screenshot 10**.
4. Create a `SECURITY.md` inside your Lab1 folder:

   ```bash
   mkdir -p Lab1
   cat <<'EOF' > Lab1/SECURITY.md
   # Security Policy

   ## Reporting a Vulnerability
   Report security issues to the course instructor via the Slack channel or EMU email.
   EOF
   ```

5. Practice the full add/commit/push cycle:

   ```bash
   git checkout -b lab1-<your-username>
   git add Lab1/SECURITY.md
   git status
   git commit -m "Lab 1: add SECURITY.md and initial submission"
   git push origin lab1-<your-username>
   ```

6. Open a **pull request** from your branch back to `main` in the student upload repo. **Screenshot 11**.

> Never push directly to `main`. Always work on a branch and open a PR — this is a course-graded workflow.

---

## Part 7 — Push Your Lab 1 Screenshots

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
- `06-ssh-auth-success.png`
- `07-both-repos-cloned.png`
- `08-security-tab.png`
- `09-dependabot-alerts.png`
- `10-code-security-settings.png`
- `11-pull-request-opened.png`

Stage, commit, and push:

```bash
git add Lab1/screenshots/
git status
git commit -m "Lab 1: add screenshots"
git push origin lab1-<your-username>
```

**Validation Check:** Navigate to your PR on GitHub — every screenshot should be visible in the `Lab1/screenshots/` folder.

---

## Part 8 — Record Your Video Walkthrough

Using your screen recording software, record a single video demonstrating:

1. `git --version` succeeding in Git Bash, PowerShell, CMD, and WSL Ubuntu.
2. Your GitHub profile with 2FA enabled.
3. `git config --list` showing your correct name and EMU email.
4. `ssh -T git@github.com` returning a successful authentication.
5. Both course repos cloned locally with `git remote -v` verified.
6. The Security tab, `SECURITY.md`, and Dependabot alerts on GitHub.
7. Your open pull request in the student upload repo with the `Lab1/screenshots/` folder visible.
8. A short verbal walkthrough of what each step accomplished.

> **Critical:** Export your video in `.wmv` format. Files in any other format cannot be graded.

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

- **Course syllabus (source of truth for policies):** distributed via Canvas and Google Drive
- **Course reference repo:** https://github.com/acloudsecninja/emu-ia-462-course
- **Student upload repo:** https://github.com/acloudsecninja-emu-org/emu-ia-462-fall-2026
- **Git cheat sheet:** https://education.github.com/git-cheat-sheet-education.pdf
- **GitHub Docs:** https://docs.github.com
- Stuck? Post in the EMU IA Slack or email Professor Weber. Do not wait until class.

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
