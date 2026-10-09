# Midterm Exam — IA 462 Advanced Operating Systems Security & Administration

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Week:** 9 — Midterm Review & Midterm Exam
**Points:** 200 points
**Format:** Hands-on practical exam + video walkthrough (no in-class written portion)
**Coverage:** Weeks 1–8

> **Objectives & Outcomes:** Refer to the course syllabus for course objectives and grading criteria.
>
> This exam is a comprehensive, hands-on assessment of everything covered from Weeks 1–8 of the course. It combines the four core disciplines the syllabus enumerates — GitHub, Linux, Windows, Docker — into a single supply-chain-secure deliverable in one repository.

---

## Exam at a Glance

You will build, harden, scan, and defend a single Python + Docker application in a **midterm** GitHub repository. Each section below maps directly to material from a specific week's slide deck.

| Section | Points | Coverage Week | Slide Deck Reference |
|---|---|---|---|
| 1. Linux Host Hardening + Lynis | 30 | Week 3–4 | OS Fundamentals · System Administration & Policy |
| 2. Windows Baseline + Event Log Analysis | 30 | Week 3–4–5 | OS Fundamentals · System Admin · Security Analysis |
| 3. Docker Hardened Build + Runtime Controls | 35 | Week 3–4–6 | OS Fundamentals · System Admin · Docker Containers |
| 4. Trivy + Syft + Grype Scan Report | 30 | Week 5 | Security Analysis & Threat Intelligence |
| 5. Enterprise Policy Enforcement (Daemon + CIS + Sigma rule) | 25 | Week 4–5–7 | System Admin · Security Analysis · Enterprise Policy (preview) |
| 6. Dependency Pinning + Dependabot + Dependency Review Gate | 25 | Week 8 | Dependency Management & Version Control |
| 7. Written Threat-Model & Cross-Platform Comparison (`MIDTERM.md`) | 15 | Weeks 1–8 | All weeks |
| 8. Video Walkthrough (`.wmv`) | 10 | — | — |
| **Total** | **200** | | |

---

## Rules

- Individual work only. AI-generated work is **prohibited** per syllabus.
- All artifacts must be committed and pushed to a **single midterm repo** on your GitHub account: `ia462-midterm-<your-username>`
- The midterm repo must be **public** and use branch protection with required status checks (per Lab 4).
- Every third-party GitHub Action, container base image, and Python dependency must be pinned (Week 8).
- Submit the repo URL + `.wmv` walkthrough to Canvas by the due date shown in Canvas.

<<<<<<< HEAD
> **CRITICAL SECURITY WARNING:** The midterm repository will be **public**. Never commit personal information, API keys, passwords, credentials, or any sensitive data to this repository. All content in public repos is visible to anyone on the internet. Use environment variables, GitHub Secrets, or secure configuration management for sensitive data. GitHub's Secret scanning and push protection features will help block accidental commits of secrets, but you must remain vigilant.

**Git Operations:** You may use either GitHub Desktop (preferred) or command line for all git operations. See [Git Workflow Guide](../git-workflow-guide.md) for detailed instructions on both methods.

**Repository Setup:** Before starting Section 1, create a public GitHub repo named `ia462-midterm-<your-username>` and enable **Dependabot alerts + security updates**, **Dependency graph**, and **Secret scanning + push protection** under *Settings → Code security and analysis*.

---

## Section 1 — Linux Host Hardening + Lynis (30 pts)
=======
**Git Operations:** GitHub Desktop is recommended for this course — it provides a visual interface for all Git operations, easier pull request management, and built-in conflict resolution. Download from https://desktop.github.com/. Command line operations are available as an optional alternative. See [Git Workflow Guide](../git-workflow-guide.md) for detailed instructions on both methods. SSH commit signing requires command-line configuration, but once configured, both GitHub Desktop and command line can create signed commits.

### GitHub Desktop Basics

If you're new to GitHub Desktop, here are the essential operations:

- **Clone Repository:** File → Clone Repository → Enter URL
- **Create Branch:** Current Branch dropdown → New Branch → Enter name
- **Stage Changes:** Go to Changes tab → Check files you want to include
- **Commit:** Enter commit message → Click Commit button
- **Push:** Click Push origin button
- **Create Pull Request:** Branch → Create Pull Request (opens browser)
- **Resolve Conflicts:** Changes tab shows conflicted files → Click to resolve → Mark as resolved

---

## Section 1 — Repository Setup, SSH & Signed Commits (25 pts)

Reference: Week 1 Technology Requirements, Week 2 GitHub Configuration & Setup slides.

1. Create a public GitHub repo named `ia462-midterm-<your-username>`.
2. Enable **Dependabot alerts + security updates**, **Dependency graph**, and **Secret scanning + push protection** under *Settings → Code security and analysis*.
3. Configure a branch-protection rule on `main`:
   - Require PR + 1 review
   - Require passing status checks (the CI/CD jobs from Section 5/7)
   - Require signed commits
   - Require conversation resolution
   - No bypass
4. Configure SSH commit signing locally (Lab 4 style) and produce at least one commit on `main` that shows **Verified** on GitHub. (SSH signing configuration requires command line; this is optional if you prefer unsigned commits.)

**Deliverables in `midterm/section1/`:**

- `screenshots/01-code-security-settings.png`
- `screenshots/02-branch-protection.png`
- `screenshots/03-verified-commit.png`
- `notes.md` — 3–5 sentences explaining why each control matters (cite slide titles).

---

## Section 2 — Linux Host Hardening + Lynis (25 pts)
>>>>>>> 709d31817deacecd610c75c1d420339daf1a765c

Reference: Week 3 OS Fundamentals (Linux hardening essentials), Week 4 System Administration & Policy (Linux PAM, sudoers, SELinux/AppArmor).

Perform on WSL Ubuntu or an Ubuntu VM. Capture output as text files (not just screenshots).

1. Create a non-root lab user + group; verify with `groups` (no sudo membership).
2. Apply a restrictive `umask 027` in `/etc/profile`; verify with a new file.
3. Enumerate + record **all** SUID binaries and any world-writable files under `/`.
4. Disable **two** non-essential services with `systemctl` and capture the pre/post state.
5. Harden `/etc/ssh/sshd_config` (PermitRootLogin no, MaxAuthTries 3, PermitEmptyPasswords no). Restart sshd.
6. Configure `pam_faillock` in `/etc/pam.d/common-auth` to lock accounts after 5 failed attempts.
7. Run `sudo lynis audit system` and save the report.
8. Configure and enable `ufw` (Uncomplicated Firewall) with a default deny policy and allow only SSH from your specific IP. Verify with `ufw status verbose`.

**Deliverables in `midterm/section1/`:**

- `linux-hardening-transcript.txt` — full terminal output (use `script` or copy/paste)
- `suid-binaries.txt`, `world-writable.txt`
- `sshd_config.hardened` (the modified file)
- `pam-common-auth.hardened` (the modified file)
- `lynis-report.txt`
- `ufw-rules.txt` — output of `ufw status verbose`
- `screenshots/01-service-disabled.png`, `02-sshd-status.png`, `03-lynis-summary.png`, `04-ufw-status.png`

---

## Section 2 — Windows Baseline + Event Log Analysis (30 pts)

Reference: Week 3 OS Fundamentals (Windows architecture), Week 4 System Administration & Policy (GPO, audit policy), Week 5 Security Analysis (Windows Event IDs, Sysmon).

Run everything in Section 2 in an **elevated PowerShell** on your Windows host.

1. `Get-MpComputerStatus` — Defender enabled, real-time on, tamper protected.
2. `Get-NetFirewallProfile` — all three profiles enabled.
3. Verify SMBv1 is disabled (`Get-SmbServerConfiguration | select EnableSMB1Protocol`).
4. Enable command-line logging for 4688 events (registry key `ProcessCreationIncludeCmdLine_Enabled = 1`) and PowerShell script-block logging (Event 4104).
5. Install Sysmon with the SwiftOnSecurity config (Lab 3).
6. Generate 4624/4625/4688/4720/4104 events (Lab 3 test data commands).
7. Export the last 100 Security-log entries to JSON.
8. Configure Windows Defender exclusions for your Python application directory and verify with `Get-MpPreference`.

**Deliverables in `midterm/section2/`:**

- `windows-transcript.txt` (PowerShell `Start-Transcript` output of the full session)
- `sysmonconfig.xml`
- `security-events.json` — output of `Get-WinEvent -FilterHashtable ... | ConvertTo-Json -Depth 5`
- `defender-exclusions.txt` — output of `Get-MpPreference` showing configured exclusions
- `screenshots/05-defender-status.png`, `06-firewall-profiles.png`, `07-smb1-disabled.png`, `08-sysmon-service.png`, `09-events-sample.png`, `10-defender-exclusions.png`

---

## Section 3 — Docker Hardened Build + Runtime Controls (35 pts)

Reference: Week 3 OS Fundamentals (Docker isolation, hardening steps), Week 4 System Administration & Policy (daemon.json, seccomp/AppArmor/SELinux), Week 6 Docker Containers & Virtualization (multi-stage, secrets, image scanning).

Under `midterm/app/`, build a Python + Flask app equivalent to Lab 4's application. Under `midterm/`:

1. Write `Dockerfile` as a **multi-stage** build (`FROM ... AS builder` + minimal runtime).
2. Base image must be **digest-pinned** (`@sha256:...`).
3. Container must **not run as root** (`USER appuser`).
4. `docker run` invocation must include `--read-only`, `--cap-drop ALL`, and `--security-opt no-new-privileges:true`.
5. Provide a `/etc/docker/daemon.json` sample with `icc: false`, `no-new-privileges: true`, `userns-remap: default`, and `log-driver: json-file`.
6. Implement a custom seccomp profile that only allows the syscalls your application actually needs. Document the profile in `seccomp-profile.json`.

**Deliverables in `midterm/section3/`:**

- `Dockerfile` (multi-stage, pinned, non-root)
- `daemon.json.sample`
- `seccomp-profile.json` — custom seccomp profile for your application
- `run-command.sh` — the exact hardened `docker run ...` invocation (including `--security-opt seccomp=seccomp-profile.json`)
- `screenshots/10-docker-build.png`, `11-container-nonroot.png`, `12-hardened-run.png`

---

## Section 4 — Trivy + Syft + Grype Scan Report (30 pts)

Reference: Week 5 Security Analysis & Threat Intelligence.

1. Run **Trivy** against your hardened Docker image (`CRITICAL,HIGH,MEDIUM`).
2. Generate a **Syft SBOM** in SPDX JSON.
3. Run **Grype** against the SBOM.
4. Pick one CRITICAL or HIGH CVE from your output. Enrich it:
   - CVSS score + description from NVD (https://nvd.nist.gov)
   - MITRE ATT&CK technique ID + name (https://attack.mitre.org)
   - Concrete remediation you would apply

**Deliverables in `midterm/section4/`:**

- `trivy-report.txt`, `sbom.spdx.json`, `grype-report.txt`
- `cve-writeup.md` — the enriched write-up above
- `screenshots/14-trivy.png`, `15-syft.png`, `16-grype.png`, `17-nvd-page.png`, `18-attack-page.png`

---

## Section 5 — Policy Enforcement (Docker Bench + Sigma Rule) (25 pts)

Reference: Week 4 System Administration & Policy (CIS Docker Benchmark, STIG categories, SELinux/AppArmor), Week 5 Security Analysis (Sigma rules, ATT&CK mapping).

1. Run `docker-bench-security` against your host and save the report.
2. Write a Sigma rule (YAML) that would fire on **one** attacker technique observed in Section 2's Windows events (e.g., 4104 encoded PowerShell, 4720 user creation, or 4625 brute force). Include ATT&CK tag(s).

**Deliverables in `midterm/section5/`:**

- `docker-bench-report.txt`
- `<name>.sigma.yml`
- `screenshots/19-docker-bench.png`, `20-sigma-rule.png`

---

## Section 6 — Dependency Pinning + Dependabot + Dependency Review Gate (25 pts)

Reference: Week 8 Dependency Management & Version Control for GitHub.

Under `midterm/` (same repo):

1. Provide `requirements.txt` **exact pins** + `requirements.lock` generated with `pip-compile --generate-hashes`.
2. Provide `.github/dependabot.yml` for `pip`, `docker`, and `github-actions` ecosystems.
3. Provide `.github/workflows/security-pipeline.yml` (Trivy + Syft SBOM + pip-audit) — **all third-party actions pinned to full commit SHAs** (the CI/CD jobs from Section 4/6).
4. Provide `.github/workflows/dependency-review.yml` set to `fail-on-severity: high`.
5. Open a **temporary PR** that downgrades Flask to a known-vulnerable version (e.g., `flask==2.0.0`). The Dependency Review + pip-audit jobs must fail. Close the PR without merging.

**Deliverables in `midterm/section6/`:**

- `requirements.txt`, `requirements.lock`
- `dependabot.yml`, `security-pipeline.yml`, `dependency-review.yml` (copies of the files in `.github/`)
- `screenshots/21-actions-green-main.png`, `22-vulnerable-pr-blocked.png`, `23-vulnerable-pr-closed.png`

---

## Section 7 — `MIDTERM.md`: Threat Model + Cross-Platform Comparison (15 pts)

Write `midterm/MIDTERM.md` at the repo root with:

1. **What this repo is** (one paragraph).
2. **Cross-platform hardening comparison** — Linux vs. Windows vs. Docker across: kernel model, access control, auditing, hardening standard, common attack surface (a table plus 2–3 sentences of narrative).
3. **Supply-chain threat model** — what an attacker would try against this repo/image and which of your controls stops each attempt. Cite slide titles you drew from.
4. **Which section proves which learning objective** — a short bulleted crosswalk from Section 1–6 back to at least five course objectives listed in the syllabus.

---

## Section 8 — Video Walkthrough (10 pts)

Record a **single** `.wmv` video (target 10–15 minutes) demonstrating:

- The repo layout and every enabled security setting on GitHub
- One PR blocked by Dependency Review
- Your `docker run` hardened invocation with `whoami/id` inside the container
- Trivy + Syft + Grype output + your enriched CVE write-up
- Your Linux hardening evidence + Lynis summary
- Your Windows Defender/firewall/SMB1 status + a sample of your Security events
- Your `docker-bench-security` result + your Sigma rule
- A read-through of `MIDTERM.md`

> **Critical:** Export as `.wmv`. Any other format cannot be graded.

---

## Submission Requirements

Submit to Canvas by the due date:

| Item | Format | Required |
|------|--------|----------|
| Midterm GitHub repo URL (`ia462-midterm-<username>`) | URL | Yes |
| Video walkthrough | `.wmv` | Yes |

Grading is done against the **pushed contents of your repo** at the due-date timestamp on Canvas. Local files that are not pushed will not be graded.

---

## Grading Rubric

| Section | Excellent (all pts) | Partial | Zero |
|---|---|---|---|
| Section 1 (30) | Full transcript, Lynis run, sshd + pam hardened, evidence of disabled services | Partial evidence | No evidence |
| Section 2 (30) | Sysmon installed, 4688/4104 enabled, sample events exported | Sysmon missing OR events missing | Neither |
| Section 3 (35) | Multi-stage + digest-pinned + non-root + hardened run + daemon.json sample | Any single control missing | Runs as root or unpinned |
| Section 4 (30) | Trivy + Syft + Grype + CVE enrichment complete | Missing one tool or enrichment | Missing scan entirely |
| Section 5 (25) | Docker-bench + Sigma rule with ATT&CK tags | One deliverable missing | Neither |
| Section 6 (25) | Pipeline green, Dependabot on, vulnerable PR proven blocked | Pipeline works but vulnerable-PR demo missing | Pipeline missing |
| Section 7 (15) | Thorough `MIDTERM.md` with crosswalk | Missing crosswalk or comparison | Missing file |
| Section 8 (10) | Clear `.wmv` covering all above | Video too short or missing pieces | No video |

---

## Tips

- **Git Workflow Guide:** [git-workflow-guide.md](../git-workflow-guide.md) — Comprehensive guide for both GitHub Desktop and command line methods
- Section 6's pipeline gates Sections 3, 4, and 5. Get the pipeline green early.
- Do not upload compiled Python `__pycache__` or virtualenv folders — add them to `.gitignore`.
- Every artifact you list here must actually be present in the repo. Grading looks at the pushed files.

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
