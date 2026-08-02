# Lab 2 — Operating Systems Fundamentals: Docker, Windows and Linux

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Week:** 3 — Operating Systems Fundamentals, Docker, Windows and Linux
**Points:** 75 points
**Submission:** Upload your screen-recording video (`.wmv`) and required files via Canvas

> **Objectives & Outcomes:** Refer to the course syllabus for course objectives and grading criteria.
>
> This lab aligns to the Week 3 slide deck: *IA462 — Week 3 — OS Fundamentals, Docker, Windows and Linux*.

---

## Lab Overview

This lab exercises the three foundational platforms covered in Week 3 — **Linux**, **Windows**, and **Docker**. You will:

- Inspect the Linux kernel/user-space boundary, permission model, and hardening surface
- Enumerate the Windows security stack (Active Directory awareness, Defender/Firewall, audit policy, credential-adjacent processes)
- Build a minimally-privileged Docker container that runs as a non-root user
- Contrast each platform's security controls and produce a short cross-platform comparison

You will submit screenshots, artifact files, and a `.wmv` walkthrough video.

---

## Prerequisites

- [ ] Lab 1 completed (GitHub configured, both repos cloned, SSH auth working)
- [ ] Windows 11/10 host with WSL Ubuntu enabled — or Ubuntu VM / macOS + Ubuntu VM
- [ ] Sudo access inside your Linux environment
- [ ] Docker Desktop (Windows/macOS) *or* Docker Engine (Linux/WSL) installed
- [ ] Screen recording software ready with `.wmv` export

Install Docker inside WSL Ubuntu (if not already installed):

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
newgrp docker
docker --version
docker run --rm hello-world
```

---

## Part 1 — Linux Fundamentals & Hardening

Reference: Week 3 slides — *Part 2: Linux, the Security Engineer's OS*.

### 1A — Kernel vs. User Space

Confirm which kernel you are running and how it manages resources:

```bash
uname -a
cat /proc/version
lscpu | head -20
free -h
```

**Screenshot 1:** Output showing kernel version, CPU info, and memory usage.

### 1B — Filesystem Hierarchy & Sensitive Files

Explore the FHS locations covered in the slides:

```bash
ls -ld /etc /var/log /bin /usr/bin /home /proc /tmp
ls -la /etc/passwd /etc/shadow /etc/sudoers 2>/dev/null
stat /etc/shadow
```

Identify all UID-0 accounts (accounts with root-level access):

```bash
awk -F: '$3 == 0 {print $1, $3, $7}' /etc/passwd
```

**Screenshot 2:** Sensitive file permissions plus the UID-0 accounts list.

### 1C — Users, Groups & Permissions

Create a controlled lab user (do **not** grant sudo):

```bash
sudo useradd -m -s /bin/bash labuser
sudo passwd labuser
sudo groupadd labgroup
sudo usermod -aG labgroup labuser
groups labuser
```

Practice the permission model discussed in the slides:

```bash
mkdir -p ~/lab2/perms
cd ~/lab2/perms
echo "sensitive data" > secret.txt
ls -la secret.txt
chmod 600 secret.txt
chmod 700 ~/lab2/perms
ls -la ~/lab2 | grep perms
ls -la secret.txt
```

Find dangerous permission conditions on the system:

```bash
# World-writable files (excluding filesystems that shouldn't be scanned)
sudo find / -xdev -type f -perm -0002 2>/dev/null | head -20

# SUID binaries
sudo find / -xdev -perm -4000 2>/dev/null

# SGID binaries
sudo find / -xdev -perm -2000 2>/dev/null | head -20
```

**Screenshot 3:** User creation + group membership.
**Screenshot 4:** World-writable file list + full SUID binary list.

### 1D — Service Enumeration & Hardening

List running services and disable one non-essential service:

```bash
systemctl list-units --type=service --state=running | head -30

# Pick a service that is not required (examples: cups, avahi-daemon, bluetooth)
sudo systemctl stop <service>
sudo systemctl disable <service>
sudo systemctl status <service>
```

**Screenshot 5:** Running services + `inactive (dead)` status of the service you disabled.

### 1E — SSH Hardening

Review and (safely) harden `/etc/ssh/sshd_config`:

```bash
sudo grep -E "^(PermitRootLogin|Protocol|PasswordAuthentication|MaxAuthTries|LoginGraceTime|PermitEmptyPasswords)" /etc/ssh/sshd_config
```

Apply the recommended settings (edit with `sudo nano /etc/ssh/sshd_config`):

```
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30
PermitEmptyPasswords no
# PasswordAuthentication no  <-- only enable AFTER you have SSH keys configured!
```

Reload:

```bash
sudo systemctl restart sshd
sudo systemctl status sshd
```

**Screenshot 6:** The relevant `sshd_config` lines + `sshd` service status.

### 1F — Basic Security Audit with Lynis

```bash
sudo apt install lynis -y
sudo lynis audit system 2>&1 | tee ~/lab2/lab2-lynis-report.txt
```

**Screenshot 7:** The Lynis summary showing the Hardening Index score plus at least three suggestions.

---

## Part 2 — Windows Security Surface

Reference: Week 3 slides — *Part 3: Windows Enterprise Dominance & Security Architecture*.

Run **all** commands in this Part from an **elevated PowerShell** (Run as Administrator) on your Windows host.

### 2A — Basic Windows Enumeration

```powershell
Get-ComputerInfo | Select-Object OsName, OsVersion, OsBuildNumber, WindowsInstallationType
Get-Host | Select-Object Version
whoami /priv
```

**Screenshot 8:** Output of the above commands.

### 2B — Windows Defender Status

```powershell
Get-MpComputerStatus | Select-Object AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled, IsTamperProtected, AMEngineVersion, AntivirusSignatureLastUpdated
Get-MpPreference | Select-Object DisableRealtimeMonitoring, DisableIOAVProtection, DisableScriptScanning
```

**Screenshot 9:** Defender status output.

### 2C — Windows Firewall Profiles

```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction, LogAllowed, LogBlocked
```

**Screenshot 10:** All three profiles (Domain, Private, Public) showing `Enabled: True`.

### 2D — SMBv1, LSASS & Audit Policy Review

```powershell
# Confirm SMBv1 is disabled (the protocol behind EternalBlue / WannaCry)
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol

# LSASS - the process most frequently targeted for credential theft
Get-Process lsass | Select-Object Id, Name, StartTime, Path

# Audit policy overview
auditpol /get /category:*
```

**Screenshot 11:** SMB1 disabled + LSASS process visible + top of audit policy list.

### 2E — Recent Security Events

```powershell
# Recent logon events (4624 = success, 4625 = failure)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4625} -MaxEvents 20 |
  Select-Object TimeCreated, Id, Message | Format-List
```

**Screenshot 12:** Sample of recent 4624/4625 events.

Save your PowerShell transcript to a file so we can include it in your submission:

```powershell
Start-Transcript -Path "$HOME\Desktop\lab2-windows-transcript.txt"
# (re-run the commands above)
Stop-Transcript
```

---

## Part 3 — Docker Container Fundamentals

Reference: Week 3 slides — *Part 4: Docker Containerization Fundamentals*.

Work inside WSL Ubuntu (or your Linux VM) for this Part.

### 3A — Verify Docker

```bash
docker --version
docker info | head -30
docker run --rm hello-world
```

### 3B — Explore Isolation Primitives

Start a temporary Ubuntu container and inspect the isolation the slides described (namespaces, cgroups, capabilities):

```bash
docker run --rm -it --name lab2-linux ubuntu:22.04 bash

# INSIDE the container:
cat /etc/os-release
whoami
id
ps -ef
cat /proc/1/cgroup
ls -la /proc/self/ns/
exit
```

**Screenshot 13:** The `id`, `ps -ef`, and `/proc/self/ns/` output showing container isolation.

### 3C — Build a Non-Root Hardened Container

Create `~/lab2/docker/` and inside it create `Dockerfile`:

```bash
mkdir -p ~/lab2/docker && cd ~/lab2/docker
```

`Dockerfile`:

```dockerfile
# IA 462 Lab 2 — minimally-privileged container
FROM python:3.11-slim

LABEL maintainer="student@emich.edu"
LABEL description="IA 462 Lab 2 - hardened baseline container"

# Create a dedicated non-root user (Week 3 slide guidance: never run as root)
RUN groupadd --system appgroup && \
    useradd  --system --gid appgroup --home /app --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY --chown=appuser:appgroup index.html /app/index.html

USER appuser

EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080"]
```

`index.html`:

```html
<h1>IA 462 - Lab 2 Container is Running</h1>
```

Build & run:

```bash
docker build -t ia462-lab2:v1 .
docker run -d --name lab2-hardened -p 8080:8080 --read-only --tmpfs /tmp ia462-lab2:v1
docker ps --filter name=lab2-hardened
```

Verify the container is not running as root:

```bash
docker exec lab2-hardened whoami
docker exec lab2-hardened id
```

Fetch the page over HTTP:

```bash
curl -s http://localhost:8080/
```

**Screenshot 14:** `docker build` output.
**Screenshot 15:** `docker exec ... whoami / id` showing `appuser` (non-root) + `curl` output.

### 3D — Attempted-Root Contrast (Optional but Recommended)

Show the difference by running an intentionally *root* container and diffing the behavior:

```bash
docker run --rm -it --name lab2-root ubuntu:22.04 bash -c "whoami; id"
```

**Screenshot 16:** Output showing root inside a plain container (contrast to your hardened container).

### 3E — Cleanup

```bash
docker stop lab2-hardened && docker rm lab2-hardened
docker rmi ia462-lab2:v1
docker system prune -f
```

---

## Part 4 — Cross-Platform Comparison

Create `~/lab2/comparison.md` with a short (½ page) table + narrative that compares Linux, Windows, and Docker across:

| Control Area | Linux | Windows | Docker |
|--------------|-------|---------|--------|
| Kernel Model | | | |
| Access Control | | | |
| Auditing / Logging | | | |
| Hardening Standard | | | |
| Common Attack Surface | | | |

Under the table, write 3–5 sentences summarizing **one hardening step per platform** you would prioritize for a brand-new host, and cite the Week 3 slide topic that informed each choice.

**Screenshot 17:** The rendered comparison file.

---

## Part 5 — Push Everything to Your Repo

All screenshots, the Lynis report, the PowerShell transcript, the Dockerfile, and `comparison.md` must be committed and pushed to your student upload repo.

```bash
cd ~/emu-ia-462-fall-2026
git checkout -b lab2-<your-username>
mkdir -p Lab2/screenshots Lab2/artifacts Lab2/docker

# Copy artifacts in
cp ~/lab2/lab2-lynis-report.txt         Lab2/artifacts/
cp /mnt/c/Users/<you>/Desktop/lab2-windows-transcript.txt Lab2/artifacts/ 2>/dev/null || true
cp ~/lab2/docker/Dockerfile             Lab2/docker/
cp ~/lab2/docker/index.html             Lab2/docker/
cp ~/lab2/comparison.md                 Lab2/
cp ~/Desktop/lab2-screenshot-*.png      Lab2/screenshots/

git add Lab2/
git status
git commit -m "Lab 2: OS fundamentals - Linux, Windows, Docker"
git push origin lab2-<your-username>
```

Open a pull request into `main` on the student upload repo and screenshot the open PR (call it `18-lab2-pull-request.png`).

**Validation Check:** Navigating to your PR, you should see:

- `Lab2/screenshots/` with all screenshots (01–18)
- `Lab2/artifacts/lab2-lynis-report.txt`
- `Lab2/artifacts/lab2-windows-transcript.txt`
- `Lab2/docker/Dockerfile` + `Lab2/docker/index.html`
- `Lab2/comparison.md`

---

## Part 6 — Video Walkthrough

Record a single `.wmv` video demonstrating:

1. Linux — user creation, permission changes, world-writable + SUID findings, disabled service, Lynis summary
2. Windows — Defender status, firewall profiles, SMBv1 disabled, LSASS process, sample 4624/4625 event
3. Docker — building + running your non-root container, `whoami/id` inside it, `curl` output
4. Your rendered `comparison.md`
5. Your open pull request in the student upload repo with the `Lab2/` folder visible
6. A short verbal wrap-up highlighting the single most impactful hardening step per platform

> **Critical:** Export in `.wmv`. Any other format cannot be graded.

---

## Submission Requirements

| Item | Format | Required |
|------|--------|----------|
| Video walkthrough | `.wmv` | Yes |
| `lab2-lynis-report.txt` | Plain text | Yes |
| `lab2-windows-transcript.txt` | Plain text | Yes |
| `Dockerfile` + `index.html` | Text | Yes |
| `comparison.md` | Markdown | Yes |
| Screenshots (`Lab2/screenshots/`) | `.png` / `.jpg` | Yes |
| Pull request link (student upload repo) | URL | Yes |

---

## Tips & Resources

- **Linux Permissions Guide:** https://www.guru99.com/file-permissions.html
- **Lynis Documentation:** https://cisofy.com/lynis/
- **CIS Ubuntu Benchmarks:** https://www.cisecurity.org/benchmark/ubuntu_linux
- **Microsoft Security Baselines (Compliance Toolkit):** https://www.microsoft.com/en-us/download/details.aspx?id=55319
- **Docker Docs — Best Practices:** https://docs.docker.com/develop/dev-best-practices/
- **NIST SP 800-190 (Container Security):** https://csrc.nist.gov/publications/detail/sp/800-190/final

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
