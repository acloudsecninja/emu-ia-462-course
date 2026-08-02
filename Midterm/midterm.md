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
| 1. Repository Setup, SSH & Signed Commits | 25 | Week 1–2 | Technology Requirements · GitHub Configuration & Setup |
| 2. Linux Host Hardening + Lynis | 25 | Week 3–4 | OS Fundamentals · System Administration & Policy |
| 3. Windows Baseline + Event Log Analysis | 25 | Week 3–4–5 | OS Fundamentals · System Admin · Security Analysis |
| 4. Docker Hardened Build + Runtime Controls | 30 | Week 3–4–6 | OS Fundamentals · System Admin · Docker Containers |
| 5. Trivy + Syft + Grype Scan Report | 25 | Week 5 | Security Analysis & Threat Intelligence |
| 6. Enterprise Policy Enforcement (Daemon + CIS + Sigma rule) | 20 | Week 4–5–7 | System Admin · Security Analysis · Enterprise Policy (preview) |
| 7. Dependency Pinning + Dependabot + Dependency Review Gate | 25 | Week 8 | Dependency Management & Version Control |
| 8. Written Threat-Model & Cross-Platform Comparison (`MIDTERM.md`) | 15 | Weeks 1–8 | All weeks |
| 9. Video Walkthrough (`.wmv`) | 10 | — | — |
| **Total** | **200** | | |

---

## Rules

- Individual work only. AI-generated work is **prohibited** per syllabus.
- All artifacts must be committed and pushed to a **single midterm repo** on your GitHub account: `ia462-midterm-<your-username>`
- The midterm repo must be **public** and use branch protection with signed commits + required status checks (per Lab 4).
- Every third-party GitHub Action, container base image, and Python dependency must be pinned (Week 8).
- Submit the repo URL + `.wmv` walkthrough to Canvas by the due date shown in Canvas.

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
4. Configure SSH commit signing locally (Lab 4 style) and produce at least one commit on `main` that shows **Verified** on GitHub.

**Deliverables in `midterm/section1/`:**

- `screenshots/01-code-security-settings.png`
- `screenshots/02-branch-protection.png`
- `screenshots/03-verified-commit.png`
- `notes.md` — 3–5 sentences explaining why each control matters (cite slide titles).

---

## Section 2 — Linux Host Hardening + Lynis (25 pts)

Reference: Week 3 OS Fundamentals (Linux hardening essentials), Week 4 System Administration & Policy (Linux PAM, sudoers, SELinux/AppArmor).

Perform on WSL Ubuntu or an Ubuntu VM. Capture output as text files (not just screenshots).

1. Create a non-root lab user + group; verify with `groups` (no sudo membership).
2. Apply a restrictive `umask 027` in `/etc/profile`; verify with a new file.
3. Enumerate + record **all** SUID binaries and any world-writable files under `/`.
4. Disable **two** non-essential services with `systemctl` and capture the pre/post state.
5. Harden `/etc/ssh/sshd_config` (PermitRootLogin no, MaxAuthTries 3, PermitEmptyPasswords no). Restart sshd.
6. Configure `pam_faillock` in `/etc/pam.d/common-auth` to lock accounts after 5 failed attempts.
7. Run `sudo lynis audit system` and save the report.

**Deliverables in `midterm/section2/`:**

- `linux-hardening-transcript.txt` — full terminal output (use `script` or copy/paste)
- `suid-binaries.txt`, `world-writable.txt`
- `sshd_config.hardened` (the modified file)
- `pam-common-auth.hardened` (the modified file)
- `lynis-report.txt`
- `screenshots/04-service-disabled.png`, `05-sshd-status.png`, `06-lynis-summary.png`

---

## Section 3 — Windows Baseline + Event Log Analysis (25 pts)

Reference: Week 3 OS Fundamentals (Windows architecture), Week 4 System Administration & Policy (GPO, audit policy), Week 5 Security Analysis (Windows Event IDs, Sysmon).

Run everything in Section 3 in an **elevated PowerShell** on your Windows host.

1. `Get-MpComputerStatus` — Defender enabled, real-time on, tamper protected.
2. `Get-NetFirewallProfile` — all three profiles enabled.
3. Verify SMBv1 is disabled (`Get-SmbServerConfiguration | select EnableSMB1Protocol`).
4. Enable command-line logging for 4688 events (registry key `ProcessCreationIncludeCmdLine_Enabled = 1`) and PowerShell script-block logging (Event 4104).
5. Install Sysmon with the SwiftOnSecurity config (Lab 3).
6. Generate 4624/4625/4688/4720/4104 events (Lab 3 test data commands).
7. Export the last 100 Security-log entries to JSON.

**Deliverables in `midterm/section3/`:**

- `windows-transcript.txt` (PowerShell `Start-Transcript` output of the full session)
- `sysmonconfig.xml`
- `security-events.json` — output of `Get-WinEvent -FilterHashtable ... | ConvertTo-Json -Depth 5`
- `screenshots/07-defender-status.png`, `08-firewall-profiles.png`, `09-smb1-disabled.png`, `10-sysmon-service.png`, `11-events-sample.png`

---

## Section 4 — Docker Hardened Build + Runtime Controls (30 pts)

Reference: Week 3 OS Fundamentals (Docker isolation, hardening steps), Week 4 System Administration & Policy (daemon.json, seccomp/AppArmor/SELinux), Week 6 Docker Containers & Virtualization (multi-stage, secrets, image scanning).

Under `midterm/app/`, build a Python + Flask app equivalent to Lab 4's application. Under `midterm/`:

1. Write `Dockerfile` as a **multi-stage** build (`FROM ... AS builder` + minimal runtime).
2. Base image must be **digest-pinned** (`@sha256:...`).
3. Container must **not run as root** (`USER appuser`).
4. `docker run` invocation must include `--read-only`, `--cap-drop ALL`, and `--security-opt no-new-privileges:true`.
5. Provide a `/etc/docker/daemon.json` sample with `icc: false`, `no-new-privileges: true`, `userns-remap: default`, and `log-driver: json-file`.

**Deliverables in `midterm/section4/`:**

- `Dockerfile` (multi-stage, pinned, non-root)
- `daemon.json.sample`
- `run-command.sh` — the exact hardened `docker run ...` invocation
- `screenshots/12-docker-build.png`, `13-container-nonroot.png`, `14-hardened-run.png`

---

## Section 5 — Trivy + Syft + Grype Scan Report (25 pts)

Reference: Week 5 Security Analysis & Threat Intelligence.

1. Run **Trivy** against your hardened Docker image (`CRITICAL,HIGH,MEDIUM`).
2. Generate a **Syft SBOM** in SPDX JSON.
3. Run **Grype** against the SBOM.
4. Pick one CRITICAL or HIGH CVE from your output. Enrich it:
   - CVSS score + description from NVD (https://nvd.nist.gov)
   - MITRE ATT&CK technique ID + name (https://attack.mitre.org)
   - Concrete remediation you would apply

**Deliverables in `midterm/section5/`:**

- `trivy-report.txt`, `sbom.spdx.json`, `grype-report.txt`
- `cve-writeup.md` — the enriched write-up above
- `screenshots/15-trivy.png`, `16-syft.png`, `17-grype.png`, `18-nvd-page.png`, `19-attack-page.png`

---

## Section 6 — Policy Enforcement (Docker Bench + Sigma Rule) (20 pts)

Reference: Week 4 System Administration & Policy (CIS Docker Benchmark, STIG categories, SELinux/AppArmor), Week 5 Security Analysis (Sigma rules, ATT&CK mapping).

1. Run `docker-bench-security` against your host and save the report.
2. Write a Sigma rule (YAML) that would fire on **one** attacker technique observed in Section 3's Windows events (e.g., 4104 encoded PowerShell, 4720 user creation, or 4625 brute force). Include ATT&CK tag(s).

**Deliverables in `midterm/section6/`:**

- `docker-bench-report.txt`
- `<name>.sigma.yml`
- `screenshots/20-docker-bench.png`, `21-sigma-rule.png`

---

## Section 7 — Dependency Pinning + Dependabot + Dependency Review Gate (25 pts)

Reference: Week 8 Dependency Management & Version Control for GitHub.

Under `midterm/` (same repo):

1. Provide `requirements.txt` **exact pins** + `requirements.lock` generated with `pip-compile --generate-hashes`.
2. Provide `.github/dependabot.yml` for `pip`, `docker`, and `github-actions` ecosystems.
3. Provide `.github/workflows/security-pipeline.yml` (Trivy + Syft SBOM + pip-audit) — **all third-party actions pinned to full commit SHAs**.
4. Provide `.github/workflows/dependency-review.yml` set to `fail-on-severity: high`.
5. Open a **temporary PR** that downgrades Flask to a known-vulnerable version (e.g., `flask==2.0.0`). The Dependency Review + pip-audit jobs must fail. Close the PR without merging.

**Deliverables in `midterm/section7/`:**

- `requirements.txt`, `requirements.lock`
- `dependabot.yml`, `security-pipeline.yml`, `dependency-review.yml` (copies of the files in `.github/`)
- `screenshots/22-actions-green-main.png`, `23-vulnerable-pr-blocked.png`, `24-vulnerable-pr-closed.png`

---

## Section 8 — `MIDTERM.md`: Threat Model + Cross-Platform Comparison (15 pts)

Write `midterm/MIDTERM.md` at the repo root with:

1. **What this repo is** (one paragraph).
2. **Cross-platform hardening comparison** — Linux vs. Windows vs. Docker across: kernel model, access control, auditing, hardening standard, common attack surface (a table plus 2–3 sentences of narrative).
3. **Supply-chain threat model** — what an attacker would try against this repo/image and which of your controls stops each attempt. Cite slide titles you drew from.
4. **Which section proves which learning objective** — a short bulleted crosswalk from Section 1–7 back to at least five course objectives listed in the syllabus.

---

## Section 9 — Video Walkthrough (10 pts)

Record a **single** `.wmv` video (target 10–15 minutes) demonstrating:

- The repo layout and every enabled security setting on GitHub
- One signed commit + one PR blocked by Dependency Review
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
| Confirmation your repo's most recent commit shows **Verified** | (in video) | Yes |

Grading is done against the **pushed contents of your repo** at the due-date timestamp on Canvas. Local files that are not pushed will not be graded.

---

## Grading Rubric

| Section | Excellent (all pts) | Partial | Zero |
|---|---|---|---|
| Section 1 (25) | Public repo, all security features on, branch protection with signed-commits enforced, at least one Verified commit | Any single control missing | Repo private or missing |
| Section 2 (25) | Full transcript, Lynis run, sshd + pam hardened, evidence of disabled services | Partial evidence | No evidence |
| Section 3 (25) | Sysmon installed, 4688/4104 enabled, sample events exported | Sysmon missing OR events missing | Neither |
| Section 4 (30) | Multi-stage + digest-pinned + non-root + hardened run + daemon.json sample | Any single control missing | Runs as root or unpinned |
| Section 5 (25) | Trivy + Syft + Grype + CVE enrichment complete | Missing one tool or enrichment | Missing scan entirely |
| Section 6 (20) | Docker-bench + Sigma rule with ATT&CK tags | One deliverable missing | Neither |
| Section 7 (25) | Pipeline green, Dependabot on, vulnerable PR proven blocked | Pipeline works but vulnerable-PR demo missing | Pipeline missing |
| Section 8 (15) | Thorough `MIDTERM.md` with crosswalk | Missing crosswalk or comparison | Missing file |
| Section 9 (10) | Clear `.wmv` covering all above | Video too short or missing pieces | No video |

---

## Tips

- Start Section 1 immediately in Week 8; it unblocks all other sections.
- Section 7's pipeline gates Sections 4, 5, and 6. Get the pipeline green early.
- Do not upload compiled Python `__pycache__` or virtualenv folders — add them to `.gitignore`.
- Every artifact you list here must actually be present in the repo. Grading looks at the pushed files.

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
