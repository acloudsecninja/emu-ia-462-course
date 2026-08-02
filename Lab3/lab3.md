# Lab 3 — Security Analysis & Threat Intelligence

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Week:** 5 — Security Analysis & Threat Intelligence
**Points:** 75 points
**Submission:** Upload your screen-recording video (`.wmv`) and required files via Canvas

> **Objectives & Outcomes:** Refer to the course syllabus for course objectives and grading criteria.
>
> This lab aligns to the Week 5 slide deck: *IA462 — Week 5 — Security Analysis & Threat Intelligence*. The Week 5 slides explicitly preview a three-part lab across Docker, Windows, and Linux — this lab is that exercise.

---

## Lab Overview

You will perform threat-analysis and detection work across all three platforms covered so far:

1. **Docker Lab** — Scan a vulnerable container image with Trivy, generate an SBOM with Syft, produce a Grype vulnerability report, rebuild a hardened image, and map findings back to CVEs and MITRE ATT&CK.
2. **Windows Lab** — Enable Sysmon, generate simulated attacker activity, and write a Sigma-style detection rule pinned to real Event IDs (4624, 4625, 4688, 4104, 4720).
3. **Linux Lab** — Configure `auditd` rules to catch SUID execution and SSH key modifications, query the environment with `osquery`, and produce a short threat-hunt report.

Everything you produce (reports, rules, screenshots) is pushed to `Lab3/` in the student upload repo.

---

## Prerequisites

- [ ] Labs 1 & 2 completed
- [ ] Ubuntu Linux (WSL Ubuntu or VM) with Docker installed
- [ ] Elevated PowerShell access on your Windows host
- [ ] `sudo` inside your Linux environment
- [ ] Screen recording software ready with `.wmv` export

---

## Part 1 — Docker: Static Image Analysis & Threat Intelligence

Reference: Week 5 slides — *Docker: Threat Intelligence Techniques* and *Docker: Hardening & CI/CD Integration*.

### 1A — Install Trivy, Syft, Grype

```bash
# Trivy
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
  https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install -y trivy
trivy --version

# Syft + Grype
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh  | sh -s -- -b /usr/local/bin
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
syft version
grype version
```

### 1B — Pull an Intentionally Vulnerable Base Image

```bash
mkdir -p ~/lab3/docker && cd ~/lab3/docker
docker pull ubuntu:18.04
```

Ubuntu 18.04 (EOL) is intentionally chosen — it should generate CRITICAL / HIGH findings.

### 1C — Scan with Trivy

```bash
trivy image --severity CRITICAL,HIGH,MEDIUM ubuntu:18.04 \
  2>&1 | tee lab3-trivy-report.txt
```

**Screenshot 1:** Trivy summary output showing CRITICAL + HIGH counts.

### 1D — Generate an SBOM with Syft

```bash
syft ubuntu:18.04 -o table  | tee lab3-sbom-table.txt
syft ubuntu:18.04 -o spdx-json > lab3-sbom.spdx.json
jq '.packages | length' lab3-sbom.spdx.json
```

**Screenshot 2:** Syft table output + total package count from `jq`.

### 1E — Scan the SBOM with Grype

```bash
grype sbom:lab3-sbom.spdx.json --output table 2>&1 | tee lab3-grype-report.txt
```

**Screenshot 3:** Grype output showing severity breakdown.

### 1F — Pick One CVE and Enrich With Threat Intel

Pick one CRITICAL CVE from your Trivy or Grype output. Look it up in your browser at:

- https://nvd.nist.gov (NVD entry — capture CVSS score + description)
- https://attack.mitre.org (which ATT&CK technique(s) would it enable — e.g., T1068 Exploitation for Privilege Escalation?)

Write your findings into `~/lab3/docker/lab3-cve-writeup.md` with:

- CVE ID + CVSS score + affected package
- Short description (2–3 sentences in your own words)
- The MITRE ATT&CK technique ID and name that best maps to this CVE

**Screenshot 4:** Your NVD browser page for the CVE.
**Screenshot 5:** The MITRE ATT&CK technique page you selected.

### 1G — Rebuild a Hardened Image

Create `Dockerfile.hardened`:

```dockerfile
# IA 462 Lab 3 - hardened rebuild (Week 5 slide guidance)
FROM python:3.11-slim@sha256:REPLACE_WITH_REAL_DIGEST

LABEL maintainer="student@emich.edu"
LABEL version="1.0"
LABEL description="IA 462 Lab 3 hardened container"

RUN groupadd --system appgroup && \
    useradd  --system --gid appgroup --home /app --shell /usr/sbin/nologin appuser

RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --chown=appuser:appgroup index.html /app/index.html
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080 || exit 1
CMD ["python3", "-m", "http.server", "8080"]
```

Fetch the real digest, replace `REPLACE_WITH_REAL_DIGEST`, then build & re-scan:

```bash
docker pull python:3.11-slim
docker inspect --format='{{index .RepoDigests 0}}' python:3.11-slim
# Copy the sha256:... into the Dockerfile above

docker build -t ia462-lab3:hardened -f Dockerfile.hardened .
trivy image --severity CRITICAL,HIGH ia462-lab3:hardened | tee lab3-trivy-hardened.txt
```

**Screenshot 6:** Trivy output for the hardened image — CRITICAL/HIGH counts should be dramatically lower.

---

## Part 2 — Windows: Event Log Analysis & Detection Engineering

Reference: Week 5 slides — *Windows: Event Log Analysis* and *Windows: Threat Hunting & Hardening*.

Run all commands in Part 2 in an **elevated PowerShell** on your Windows host.

### 2A — Install Sysmon

Download **Sysmon** and the **SwiftOnSecurity Sysmon config** (a well-known baseline):

```powershell
$dest = "$env:USERPROFILE\Downloads\lab3-win"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip"           -OutFile "$dest\Sysmon.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "$dest\sysmonconfig.xml"
Expand-Archive "$dest\Sysmon.zip" -DestinationPath $dest -Force

Set-Location $dest
.\Sysmon64.exe -accepteula -i sysmonconfig.xml

# Verify Sysmon is running
Get-Service Sysmon64
```

**Screenshot 7:** Sysmon install output + `Get-Service Sysmon64` showing it running.

### 2B — Enable Command-Line Logging & PowerShell Script Block Logging

```powershell
# Enable command line in 4688 events
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
        /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

# Enable PowerShell script block logging (Event ID 4104)
$sbl = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
if (-not (Test-Path $sbl)) { New-Item -Path $sbl -Force | Out-Null }
Set-ItemProperty -Path $sbl -Name EnableScriptBlockLogging -Value 1
```

### 2C — Generate Attacker-Like Activity (Test Data)

**Only run these commands on your lab host — they simulate common attacker techniques.**

```powershell
# Failed logon attempts (generates 4625)
Start-Process -FilePath "powershell.exe" -Verb runAs -ArgumentList "-Command", "runas /user:BadUser1 cmd" -ErrorAction SilentlyContinue

# Suspicious base64-encoded PowerShell (generates 4104)
$cmd = 'Write-Host "Lab 3 - simulated encoded PowerShell activity"'
$b64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cmd))
powershell.exe -EncodedCommand $b64

# Create a local user (generates 4720)
net user lab3suspect P@ssw0rd! /add
net user lab3suspect /delete
```

### 2D — Query the Windows Security Log

```powershell
# Recent 4624 / 4625 / 4688 / 4720 events
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4625,4688,4720} -MaxEvents 40 |
  Select-Object TimeCreated, Id, @{n='Msg';e={ ($_.Message -split "`n")[0] }} |
  Format-Table -Wrap

# PowerShell script block events (4104)
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" -MaxEvents 20 |
  Where-Object { $_.Id -eq 4104 } |
  Select-Object TimeCreated, Id, @{n='Snippet';e={ ($_.Message -split "`n")[0..2] -join ' | ' }} |
  Format-Table -Wrap
```

**Screenshot 8:** 4624/4625/4688/4720 events output.
**Screenshot 9:** 4104 (script block) events showing your base64 activity.

### 2E — Write a Sigma-Style Detection Rule

Save the following to `lab3-suspicious-encoded-powershell.yml`:

```yaml
title: Suspicious Base64-Encoded PowerShell
id: 5b3a5c7c-1a2b-4c3d-9e8f-lab3-ia462
status: experimental
description: |
  Detects the use of PowerShell with -EncodedCommand, a common living-off-the-land
  technique used to obfuscate malicious payloads. Maps to MITRE ATT&CK T1059.001
  (PowerShell) and T1027 (Obfuscated Files or Information).
author: IA 462 Student
date: 2026/09/01
references:
  - https://attack.mitre.org/techniques/T1059/001/
  - https://attack.mitre.org/techniques/T1027/
logsource:
  product: windows
  service: security
  category: process_creation
detection:
  selection:
    EventID: 4688
    NewProcessName|endswith: '\powershell.exe'
    CommandLine|contains:
      - '-EncodedCommand'
      - '-enc '
      - '-e '
  condition: selection
falsepositives:
  - Legitimate administrator scripts that use -EncodedCommand for line-continuation reasons
level: high
tags:
  - attack.execution
  - attack.t1059.001
  - attack.defense_evasion
  - attack.t1027
```

**Screenshot 10:** Your rendered Sigma YAML file.

Save your PowerShell session as a transcript:

```powershell
Start-Transcript -Path "$env:USERPROFILE\Desktop\lab3-windows-transcript.txt"
# re-run 2B, 2C, 2D so they end up captured
Stop-Transcript
```

---

## Part 3 — Linux: auditd + osquery Threat Hunt

Reference: Week 5 slides — *Linux: Auditd & Logging for Threat Detection*.

### 3A — Install auditd + osquery

```bash
sudo apt update
sudo apt install -y auditd audispd-plugins

# osquery
curl -L https://pkg.osquery.io/deb/osquery.pub.asc | sudo apt-key add -
sudo add-apt-repository -y 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
sudo apt update && sudo apt install -y osquery

systemctl status auditd --no-pager | head -10
osqueryi --version
```

### 3B — Add Detection Rules

Create `/etc/audit/rules.d/lab3-ia462.rules`:

```
# ---- IA 462 Lab 3 - detection rules ----

# Watch for SUID/SGID binary execution (mapped to T1548.001)
-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -k suid_exec

# Watch changes to authorized_keys - SSH key theft / persistence (T1098.004)
-w /root/.ssh/authorized_keys -p wa -k ssh_key_mod
-w /home -p wa -k home_dir_mod

# Watch modifications to critical auth files (T1098)
-w /etc/passwd  -p wa -k identity
-w /etc/shadow  -p wa -k identity
-w /etc/sudoers -p wa -k identity

# Watch new/loaded kernel modules (T1547.006 / T1014 rootkits)
-w /sbin/insmod  -p x -k module_load
-w /sbin/modprobe -p x -k module_load
-a always,exit -F arch=b64 -S init_module,delete_module -k module_load
```

Load & confirm:

```bash
sudo cp /etc/audit/rules.d/lab3-ia462.rules /etc/audit/rules.d/lab3-ia462.rules
sudo augenrules --load
sudo auditctl -l
```

**Screenshot 11:** `auditctl -l` showing your rules loaded.

### 3C — Trigger the Rules & Read the Logs

```bash
# Trigger suid_exec by running a SUID binary as a normal user
/usr/bin/passwd --version || true

# Trigger ssh_key_mod
mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys
echo "# IA462 Lab3 test line" >> ~/.ssh/authorized_keys

# Read events
sudo ausearch -k suid_exec  | tail -40 | tee ~/lab3/lab3-suid-events.txt
sudo ausearch -k ssh_key_mod | tail -40 | tee ~/lab3/lab3-sshkey-events.txt
sudo aureport --summary
```

**Screenshot 12:** ausearch output for `suid_exec` and `ssh_key_mod` keys.

### 3D — Query the Environment with osquery

```bash
sudo osqueryi <<'SQL'
.mode line
SELECT username, uid, gid, shell, directory FROM users WHERE uid = 0;
SELECT name, path, cmdline, uid FROM processes WHERE uid = 0 LIMIT 15;
SELECT path, mode, uid, gid FROM suid_bin LIMIT 20;
SELECT username, key_file, algorithm, comment FROM authorized_keys LIMIT 10;
.exit
SQL
```

Redirect the output to a file:

```bash
sudo osqueryi \
  "SELECT path, mode, uid, gid FROM suid_bin;" \
  > ~/lab3/lab3-osquery-suid.txt
```

**Screenshot 13:** osquery output showing users/processes/suid_bin/authorized_keys.

### 3E — Threat-Hunt Writeup

Create `~/lab3/lab3-threat-hunt.md` with:

- **Hypothesis:** "An attacker has established SSH-key-based persistence and is executing SUID binaries to escalate."
- **Data sources queried:** auditd (`suid_exec`, `ssh_key_mod`), osquery (`users`, `authorized_keys`, `suid_bin`), Windows Security log (4624, 4625, 4688, 4720, 4104).
- **Findings:** which rules fired, which events were captured, and whether they matched attacker behavior or normal admin activity.
- **MITRE ATT&CK Mapping:** at least three techniques covered (e.g., T1548.001, T1098.004, T1059.001, T1027).
- **Recommendations:** three concrete hardening actions that would prevent or detect the attack earlier.

---

## Part 4 — Push Everything to Your Repo

```bash
cd ~/emu-ia-462-fall-2026
git checkout -b lab3-<your-username>
mkdir -p Lab3/{docker,windows,linux,screenshots}

# Docker artifacts
cp ~/lab3/docker/lab3-trivy-report.txt        Lab3/docker/
cp ~/lab3/docker/lab3-sbom-table.txt          Lab3/docker/
cp ~/lab3/docker/lab3-sbom.spdx.json          Lab3/docker/
cp ~/lab3/docker/lab3-grype-report.txt        Lab3/docker/
cp ~/lab3/docker/lab3-trivy-hardened.txt      Lab3/docker/
cp ~/lab3/docker/lab3-cve-writeup.md          Lab3/docker/
cp ~/lab3/docker/Dockerfile.hardened          Lab3/docker/
cp ~/lab3/docker/index.html                   Lab3/docker/

# Windows artifacts
cp /mnt/c/Users/<you>/Desktop/lab3-windows-transcript.txt        Lab3/windows/
cp /mnt/c/Users/<you>/Downloads/lab3-win/sysmonconfig.xml        Lab3/windows/
cp /mnt/c/Users/<you>/Desktop/lab3-suspicious-encoded-powershell.yml Lab3/windows/

# Linux artifacts
cp /etc/audit/rules.d/lab3-ia462.rules Lab3/linux/
cp ~/lab3/lab3-suid-events.txt         Lab3/linux/
cp ~/lab3/lab3-sshkey-events.txt       Lab3/linux/
cp ~/lab3/lab3-osquery-suid.txt        Lab3/linux/
cp ~/lab3/lab3-threat-hunt.md          Lab3/linux/

# Screenshots
cp ~/Desktop/lab3-screenshot-*.png Lab3/screenshots/

git add Lab3/
git commit -m "Lab 3: Security Analysis & Threat Intelligence"
git push origin lab3-<your-username>
```

Open a pull request in the student upload repo and screenshot it (`14-lab3-pull-request.png`).

---

## Part 5 — Video Walkthrough

Record a single `.wmv` video demonstrating:

1. Trivy + Syft + Grype results on `ubuntu:18.04` and the hardened rebuild
2. Your NVD + MITRE ATT&CK browser pages for the CVE you selected
3. Sysmon running on Windows + the 4624/4625/4688/4720/4104 events + a walkthrough of your Sigma rule
4. Your loaded auditd rules + captured suid_exec / ssh_key_mod events
5. osquery output showing SUID binaries and authorized_keys
6. A read-through of your `lab3-threat-hunt.md` file
7. Your open pull request with all artifacts visible

> **Critical:** Export in `.wmv`. Any other format cannot be graded.

---

## Submission Requirements

| Item | Format | Required |
|------|--------|----------|
| Video walkthrough | `.wmv` | Yes |
| Trivy / Syft / Grype reports | `.txt` / `.json` | Yes |
| Hardened `Dockerfile.hardened` + `index.html` | Text | Yes |
| `lab3-cve-writeup.md` | Markdown | Yes |
| Windows transcript + Sysmon config + Sigma YAML | Text | Yes |
| auditd rules + ausearch output + osquery output | Text | Yes |
| `lab3-threat-hunt.md` | Markdown | Yes |
| Screenshots | `.png` / `.jpg` | Yes |
| Pull request link | URL | Yes |

---

## Tips & Resources

- **Trivy Docs:** https://aquasecurity.github.io/trivy/
- **Syft / Grype:** https://github.com/anchore/syft , https://github.com/anchore/grype
- **NVD (CVE lookup):** https://nvd.nist.gov
- **MITRE ATT&CK:** https://attack.mitre.org
- **Sysmon:** https://learn.microsoft.com/sysinternals/downloads/sysmon
- **SwiftOnSecurity Sysmon Config:** https://github.com/SwiftOnSecurity/sysmon-config
- **Sigma:** https://github.com/SigmaHQ/sigma
- **auditd Rules:** https://linux.die.net/man/8/auditctl
- **osquery Docs:** https://osquery.readthedocs.io

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
