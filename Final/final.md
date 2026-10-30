# Final Exam & Project — IA 462 Advanced Operating Systems Security & Administration

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Weeks:** 14 — End-to-End Review · 15 — Final Project Work · 16 — Final Exam
**Points:** 300 points
**Format:** Comprehensive hands-on capstone repository + video walkthrough
**Coverage:** Weeks 1–16 (entire course)

> **Objectives & Outcomes:** Refer to the course syllabus for course objectives and grading criteria.
>
> This capstone integrates **every** skill covered in the course — GitHub, Linux hardening, Windows hardening, Docker hardening, security analysis, threat intelligence, enterprise policy management, dependency management, CI/CD pipeline automation, supply-chain security, continuous security operations, and third-party tool integration.

---

## Final at a Glance

You will build **one** capstone GitHub repository — `ia462-final-<your-username>` — that ships a small containerized application together with the full supply-chain, hardening, and continuous-security-operations posture you have learned to design during the semester. The final also incorporates your **GitHub Docker / Open-Source Project** work carried through Weeks 7–15 of the syllabus.

| Section | Points | Coverage | Slide Deck Reference |
|---|---|---|---|
| 1. Linux Hardening + Auditd + osquery | 30 | Weeks 3, 4, 5 | OS Fundamentals · System Admin · Security Analysis |
| 2. Windows Hardening + Sysmon + Sigma Detections | 30 | Weeks 3, 4, 5, 12 | OS Fundamentals · System Admin · Security Analysis · Advanced Security |
| 3. Docker Hardened App (Multi-stage, Non-root, Cosign-signed) | 40 | Weeks 3, 4, 6, 12 | OS Fundamentals · System Admin · Docker Containers · Advanced Security |
| 4. Enterprise Policy — Docker daemon.json, CIS, WDAC/AppLocker, SELinux/AppArmor | 30 | Weeks 4, 7, 12 | System Admin · Enterprise Policy · Advanced Security |
| 5. CI/CD Supply-Chain Pipeline (SBOM, Trivy, pip-audit, Cosign, SLSA) | 40 | Weeks 8, 10, 13 | Dependency Mgmt · Automation & Pipeline · Third-Party Tools |
| 6. Continuous Security Operations (SIEM ingest, IR playbook, MITRE mapping) | 35 | Weeks 5, 11 | Security Analysis · Continuous Sec Ops |
| 7. GitHub Docker / Open-Source Project Integration | 30 | Weeks 7 → 15 | Enterprise Policy · Automation · Continuous Sec Ops |
| 8. `FINAL.md` — Course-Wide Threat Model + ATT&CK Coverage Matrix | 30 | Weeks 1–16 | All weeks |
| 9. `.wmv` Video Walkthrough (20–30 min) | 35 | — | — |
| 10. Reproducibility (someone else can `docker build`/`docker run` cleanly) | 20 | Weeks 6, 8 | Docker Containers · Dependency Mgmt |
| 11. Presentation Slide (single-slide summary) | 10 | — | — |
| **Total** | **300** | | |

---

## Rules

- Individual work only. AI-generated work is **prohibited** per syllabus.
- Everything must live in a single public GitHub repo: `ia462-final-<your-username>`.
- Branch protection with required status checks is mandatory (repeats Lab 4 / Midterm behavior).
- Every third-party GitHub Action, container base image, and application dependency must be pinned.
- Final submission = **Repo URL + `.wmv` walkthrough + single-slide summary PDF** to Canvas by the due date.

> **CRITICAL SECURITY WARNING:** The final repository will be **public**. Never commit personal information, API keys, passwords, credentials, or any sensitive data to this repository. All content in public repos is visible to anyone on the internet. Use environment variables, GitHub Secrets, or secure configuration management for sensitive data. GitHub's Secret scanning and push protection features will help block accidental commits of secrets, but you must remain vigilant. This is a professional portfolio piece that demonstrates your security skills — do not compromise it by leaking sensitive information.

**Git Operations:** You may use either GitHub Desktop (preferred) or command line for all git operations. See [Git Workflow Guide](../git-workflow-guide.md) for detailed instructions on both methods.

**Repository Setup:** Before starting Section 1, create a public GitHub repo named `ia462-final-<your-username>` and enable **Dependabot alerts + security updates**, **Dependency graph**, and **Secret scanning + push protection** under *Settings → Code security and analysis*. Configure branch protection on `main` to require PR + 1 review, required status checks (every CI job below), conversation resolution, and no bypass.

---

## Section 1 — Linux Hardening + Auditd + osquery (30 pts)

Reference: Week 3 OS Fundamentals · Week 4 System Administration & Policy (PAM, sudoers, SELinux/AppArmor, sudo hardening) · Week 5 Security Analysis (auditd rules, osquery, MITRE mapping).

Perform on WSL Ubuntu or an Ubuntu VM. Capture output as text files.

Required:

1. Applied umask, disabled services, hardened `sshd_config`, hardened `common-auth` (pam_faillock).
2. **auditd rules** covering at minimum: SUID execution, authorized_keys modification, `/etc/passwd|shadow|sudoers` writes, kernel module loads.
3. Trigger the rules with benign test activity and capture the resulting audit events.
4. **osquery** queries dumped to file for: `users`, `authorized_keys`, `suid_bin`, `listening_ports`, `logged_in_users`.
5. **Lynis** audit report saved.
6. Configure and enable `ufw` (Uncomplicated Firewall) with a default deny policy and allow only SSH from your specific IP. Verify with `ufw status verbose`.

**Deliverables in `final/section1/`:**

- `sshd_config.hardened`, `common-auth.hardened`, `audit-rules.conf`
- `ausearch-suid.txt`, `ausearch-sshkeys.txt`, `ausearch-identity.txt`, `ausearch-modules.txt`
- `osquery-*.txt` (per query)
- `lynis-report.txt`
- `ufw-rules.txt` — output of `ufw status verbose`
- `screenshots/01-ssh-hardened.png` through `06-lynis-summary.png`

---

## Section 2 — Windows Hardening + Sysmon + Sigma Detections (30 pts)

Reference: Week 3 OS Fundamentals · Week 4 System Administration & Policy (GPO, LAPS, AppLocker/WDAC, audit policy, DISA STIG) · Week 5 Security Analysis (Event IDs, Sigma) · Week 12 Advanced Security Techniques for Windows.

Elevated PowerShell on your Windows host. Required:

1. Verify Defender + firewall + SMBv1 disabled + audit-policy enabled.
2. Sysmon installed with SwiftOnSecurity config running as a service.
3. Command-line auditing (4688) + PowerShell script-block logging (4104) enabled.
4. Generate synthetic attacker activity (Lab 3 style — encoded PS, user creation, failed logons).
5. Export the last 200 Security-log entries + 100 Sysmon events to JSON.
6. Write **two Sigma rules** covering two distinct MITRE ATT&CK techniques (e.g., T1059.001, T1136.001, T1053.005) with ATT&CK tags.
7. Configure Windows Defender exclusions for your application directory and verify with `Get-MpPreference`.

**Deliverables in `final/section2/`:**

- `windows-transcript.txt`, `sysmonconfig.xml`
- `security-events.json`, `sysmon-events.json`
- `<rule-1>.sigma.yml`, `<rule-2>.sigma.yml`
- `defender-exclusions.txt` — output of `Get-MpPreference` showing configured exclusions
- `screenshots/07-defender.png` through `12-sysmon-events.png`

---

## Section 3 — Docker Hardened App (40 pts)

Reference: Week 3 OS Fundamentals (Docker isolation) · Week 4 System Admin & Policy (daemon.json, seccomp/AppArmor/SELinux) · Week 6 Docker Containers & Virtualization (multi-stage, secrets, image scanning, image signing) · Week 12 Advanced Security Techniques (rootless Docker, capability drop).

Under `final/app/` build a small Python + Flask application. Under `final/`:

Required:

1. **Multi-stage** Dockerfile: separate `builder` and runtime stages.
2. Base image **digest-pinned** (`@sha256:...`).
3. Runtime image runs as `USER appuser` (non-root).
4. `run-hardened.sh` demonstrating the full hardened `docker run` invocation:
   - `--read-only`
   - `--cap-drop ALL` (with only explicitly required caps added back — usually none)
   - `--security-opt no-new-privileges:true`
   - `--security-opt seccomp=./seccomp.json` (a custom profile or Docker's default with justification)
   - `--pids-limit 100`, `--memory 256m`, `--cpus 0.5`
5. **Cosign-sign** the image and store the signature material in `final/section3/signatures/`.
6. Image scanned with Trivy — CRITICAL/HIGH count must be **0** (or clearly documented residuals).
7. Implement a rootless Docker configuration document (`rootless-setup.md`) describing how the container would run without root privileges on the host.

**Deliverables in `final/section3/`:**

- `Dockerfile`, `run-hardened.sh`, `seccomp.json`, `cosign.pub`
- `signatures/` folder containing `.sig` output from `cosign sign`
- `rootless-setup.md` — rootless Docker configuration documentation
- `screenshots/13-multistage-build.png`, `14-nonroot-inside-container.png`, `15-cosign-verify.png`

---

## Section 4 — Enterprise Policy Management (30 pts)

Reference: Week 4 System Administration & Policy (CIS Docker Benchmark, DISA STIG) · Week 7 Enterprise Policy Management (Docker daemon.json, GPO, WDAC/AppLocker, OPA/Gatekeeper) · Week 12 Advanced Security Techniques.

Required:

1. `docker/daemon.json.sample` with `icc: false`, `no-new-privileges: true`, `userns-remap: default`, `log-driver: json-file`, `live-restore: true`, `default-ulimits`.
2. `docker-bench-report.txt` from running `docker/docker-bench-security`.
3. **CIS Benchmark evidence** — a `cis-mapping.md` that lists at least 10 CIS Docker Benchmark controls you enforced with references to which file/setting proves each.
4. Windows policy artifact: an **AppLocker XML** (or WDAC XML) that allow-lists your application's binary and denies everything else.
5. Linux policy artifact: an **AppArmor** profile (or SELinux `.te` policy) that constrains your container's binary; loaded and attached to the running container via `--security-opt apparmor=<profile>`.
6. Document a Docker network segmentation strategy (`network-segmentation.md`) describing how your container is isolated from other workloads (bridge network, custom network, or overlay network).

**Deliverables in `final/section4/`:**

- `daemon.json.sample`
- `docker-bench-report.txt`
- `cis-mapping.md`
- `applocker-policy.xml` (or `wdac-policy.xml`)
- `apparmor-ia462-final` (or `.te` SELinux policy)
- `network-segmentation.md` — Docker network isolation strategy
- `screenshots/16-docker-bench.png`, `17-applocker.png`, `18-apparmor-attached.png`

---

## Section 5 — CI/CD Supply-Chain Pipeline (40 pts)

Reference: Week 8 Dependency Management · Week 10 Automation & Pipeline Security & Supply Chain Security (SLSA, artifact signing) · Week 13 Third-Party Tool Integration & CI/CD Pipeline Security.

Required (`.github/workflows/`):

1. **`security-pipeline.yml`** with jobs: `build`, `vulnerability-scan` (Trivy — fail on CRITICAL/HIGH), `sbom` (Syft SPDX + CycloneDX), `dependency-audit` (pip-audit `--strict`), `sign` (Cosign keyless via OIDC), `provenance` (SLSA generator or attest-build-provenance).
2. **`dependency-review.yml`** on `pull_request` — `fail-on-severity: high`, deny GPL-2.0/AGPL-3.0.
3. **`secret-scan.yml`** — GitLeaks pinned by SHA.
4. **`iac-scan.yml`** — Checkov or tfsec (even if your only IaC is the Dockerfile).
5. **Every** third-party action pinned by full commit SHA — no `@v4` or `@main` allowed.
6. `.github/dependabot.yml` covering `pip`, `docker`, and `github-actions` ecosystems.
7. A demonstration PR that introduces a known-vulnerable dependency (`flask==2.0.0`) and shows the pipeline blocks it. PR must be **closed unmerged**.
8. Implement a policy-as-code check using Open Policy Agent (OPA) or Kyverno that validates Dockerfile best practices.

**Deliverables in `final/section5/`:**

- Copies of every workflow file
- `dependabot.yml`
- `opa-policy.rego` (or `kyverno-policy.yaml`) — policy-as-code validation
- `screenshots/19-pipeline-green.png`, `20-blocked-pr.png`, `21-cosign-verify.png`, `22-slsa-attestation.png`, `23-opa-policy-check.png`
- `attestations/*.intoto.jsonl` — SLSA provenance attestations produced by the pipeline

---

## Section 6 — Continuous Security Operations (35 pts)

Reference: Week 5 Security Analysis · Week 11 Continuous Security Operations (SIEM, SOAR, IR lifecycle, threat intel).

Required:

1. **Log-shipping design** (`section6/logging.md`) — a diagram + short narrative describing how logs from your Linux host, Windows host, and Docker container would flow into a SIEM. You do **not** have to run a real SIEM. You **do** have to specify: which logging drivers, which fields, which retention, which severity thresholds trigger alerts.
2. **IR playbook** (`section6/incident-response.md`) — a playbook for **one** scenario (e.g., "encoded PowerShell + LSASS access", "container escape via docker.sock", "vulnerable dep merged to main"). Must include the five NIST IR phases with concrete commands you would run.
3. **MITRE ATT&CK coverage matrix** (`section6/attack-matrix.md`) — a table listing at least 12 techniques your controls cover, showing: technique ID + name, where it fires (Linux/Windows/Docker/pipeline), which of your artifacts detect/prevent it, and the residual risk.
4. **Sample alerts** — at least three Sigma or KQL/SPL-style queries that would trip on activity from Sections 1–2.
5. **Threat hunting queries** — document two proactive threat hunting techniques you would use to detect advanced persistent threats in your environment.

**Deliverables in `final/section6/`:**

- `logging.md`, `incident-response.md`, `attack-matrix.md`
- `queries/*.sigma.yml` (or `.kql`)
- `threat-hunting.md` — documented threat hunting techniques
- `screenshots/24-attack-matrix.png`

---

## Section 7 — GitHub Docker / Open-Source Project Integration (30 pts)

Reference: Syllabus (200-pt GitHub Docker / Open-Source Project) · Weeks 7–15 slide guidance to develop the project across the second half of the term.

Move your semester-long **GitHub Docker / Open-Source Project** into `final/section7/opensource-project/`. Required:

- A working, publicly-forkable subproject that demonstrates at least **one** open-source security tool you integrated (e.g., Falco, Wazuh, OpenSCAP, Suricata, Trivy Operator, OPA/Gatekeeper).
- A `README.md` describing the tool, why you chose it, how to run it, and how it plugs into the pipeline in Section 5.
- Evidence that it runs — logs / screenshots / video segment.
- Document integration challenges and how you overcame them (`integration-challenges.md`).

**Deliverables in `final/section7/`:**

- `README.md`
- Whatever config/manifests are needed to run the tool
- `integration-challenges.md` — documented integration challenges and solutions
- `screenshots/25-opensource-project.png` (or several)

> The syllabus lists the GitHub Docker / Open-Source Project as a separate 200-point deliverable (submitted per Canvas). This section is the *reference/integration copy* included with the Final so the graders can see the whole story end-to-end in one place.

---

## Section 8 — `FINAL.md` (30 pts)

Write `final/FINAL.md` at the repo root with:

1. **Executive summary** (½ page).
2. **Course-wide threat model** — the top 10 threats a mid-size org faces against a repo like this. For each: attacker technique, ATT&CK ID, control(s) in your repo that stop it.
3. **Cross-platform hardening matrix** — Linux vs. Windows vs. Docker across kernel model, DAC/MAC, auditing, hardening standard, privileged-process risk, supply-chain risk.
4. **Learning-objective crosswalk** — every objective listed in the syllabus, mapped to the section(s) of this final that prove it (Sections 1–7).
5. **What you would build next** — 3–5 concrete improvements if this were going into a real production environment.

---

## Section 9 — `.wmv` Video Walkthrough (35 pts)

Record a **single** `.wmv` video (target 20–30 minutes) demonstrating everything above. At minimum, cover:

- Repo layout + branch-protection + Dependabot on
- Linux hardening evidence + auditd + osquery + Lynis summary + UFW firewall
- Windows Defender/firewall/SMB1 + Sysmon + your Sigma rules + sample events + Defender exclusions
- Multi-stage Dockerfile + digest-pinned base + `whoami/id` in the container + `docker run` hardened + cosign verify + rootless setup
- Docker Bench + your CIS mapping + your AppLocker/WDAC + AppArmor/SELinux + network segmentation
- Full green pipeline + blocked vulnerable PR + SLSA attestation artifact + OPA/Kyverno policy check
- Read-through of `logging.md`, `incident-response.md`, `attack-matrix.md`, `threat-hunting.md`
- Your open-source project subfolder running + integration challenges
- A short read-through of `FINAL.md` (skim the crosswalk)

> **Critical:** Export as `.wmv`. Any other format cannot be graded.

---

## Section 10 — Reproducibility (20 pts)

A grader must be able to clone your repo and, from a clean Ubuntu host with Docker installed, run:

**GitHub Desktop:** Clone via File → Clone Repository → URL  
**Command Line (Optional):**
```bash
git clone https://github.com/<your-username>/ia462-final-<your-username>.git
cd ia462-final-<your-username>
./bootstrap.sh    # any setup you require
docker build -t ia462-final:reproduce -f final/section3/Dockerfile final/
./final/section3/run-hardened.sh
```

…and successfully reach the running container. Provide `final/bootstrap.sh` and a `Reproduce` section at the top of `FINAL.md` with the exact steps.

---

## Section 11 — Single-Slide Summary (10 pts)

A single-slide (`final/summary.pdf`) executive summary that could be shown in a meeting. Must include:

- Repo URL (QR or text)
- What the project is (one sentence)
- The 3 supply-chain controls you consider most important
- Your MITRE ATT&CK coverage %
- The residual risk you accept

---

## Submission Requirements

Submit to Canvas by the due date:

| Item | Format | Required |
|------|--------|----------|
| Final repo URL (`ia462-final-<username>`) | URL | Yes |
| Video walkthrough | `.wmv` | Yes |
| `summary.pdf` (single-slide executive summary) | `.pdf` | Yes |

Grading is done against the pushed contents of your repo at the Canvas due-date timestamp.

---

## Grading Rubric (High-Level)

| Section | Points | Excellent |
|---|---|---|
| 1. Linux hardening + auditd + osquery | 30 | Full evidence, all rules trigger, Lynis clean, UFW configured |
| 2. Windows hardening + Sysmon + Sigma | 30 | 2 Sigma rules, events exported, Sysmon service running, Defender exclusions |
| 3. Docker hardened app | 40 | Multi-stage + pinned + non-root + hardened run + cosign + rootless setup |
| 4. Enterprise policy | 30 | daemon.json + docker-bench + CIS mapping + AppLocker + AppArmor + network segmentation |
| 5. CI/CD supply chain | 40 | Full pipeline green + blocked PR + cosign + SLSA + OPA/Kyverno policy |
| 6. Continuous sec ops | 35 | Logging design + IR playbook + ATT&CK matrix + queries + threat hunting |
| 7. Open-source project | 30 | Working tool integrated + README + evidence + integration challenges |
| 8. `FINAL.md` | 30 | Threat model + crosswalk + comparison + next-steps |
| 9. Video | 35 | Comprehensive 20–30 min `.wmv` |
| 10. Reproducibility | 20 | Clean `docker build` + `run` on a fresh host |
| 11. Summary slide | 10 | Well-designed 1-slide PDF |

Partial credit is awarded per rubric criteria — see individual section deliverables.

---

## Tips

- **Git Workflow Guide:** [git-workflow-guide.md](../git-workflow-guide.md) — Comprehensive guide for both GitHub Desktop and command line methods
- Begin the final repo **immediately** in Week 14 (End-to-End Review). The repository setup controls unblock every downstream piece.
- Reuse artifacts from Labs 1–4 and the Midterm — the final is intentionally cumulative.
- Do not commit generated venv / `__pycache__` / `.env` / secrets. Push protection should block anything sensitive.
- Every artifact you list here must actually be present in the repo. Grading looks at the pushed files.

---

## Resources

- **Cosign / Sigstore:** https://docs.sigstore.dev/cosign/overview
- **SLSA Framework:** https://slsa.dev
- **CIS Docker Benchmark:** https://www.cisecurity.org/benchmark/docker
- **DISA STIGs:** https://public.cyber.mil/stigs/
- **MITRE ATT&CK:** https://attack.mitre.org
- **NIST SP 800-190 (Container Security):** https://csrc.nist.gov/publications/detail/sp/800-190/final
- **NIST SP 800-53 Rev. 5 (Security Controls):** https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
