# Lab 4 — Dependency Management & Version Control for GitHub

**Course:** IA 462 — Advanced Operating Systems Security & Administration
**Week:** 8 — Dependency Management & Version Control for GitHub
**Points:** 75 points
**Submission:** Upload your screen-recording video (`.wmv`), GitHub repo/PR link, and required files via Canvas

> **Objectives & Outcomes:** Refer to the course syllabus for course objectives and grading criteria.
>
> This lab aligns to the Week 8 slide deck: *IA462 — Week 8 — Dependency Management & Version Control for GitHub*.

---

## Lab Overview

Every prior lab has been about the platform (GitHub, Linux, Windows, Docker). This lab is about the **software supply chain** that flows through them. You will:

1. Stand up a GitHub repo with a Python + Docker application.
2. **Pin** all dependencies (application libraries, base image digest, and GitHub Actions SHAs).
3. Turn on GitHub's supply-chain defenses (Dependency Graph, Dependabot alerts + security updates, secret scanning, branch protection with signed commits).
4. Build a CI/CD pipeline that generates an **SBOM**, runs `pip-audit` + **Trivy**, and enforces **Dependency Review** on every PR.
5. Deliberately introduce a known-vulnerable dependency version and prove the pipeline blocks it.
6. Sign your commits and produce a `README.md` write-up that maps each control back to the slides.

---

## Prerequisites

- [ ] Labs 1, 2, 3 completed
- [ ] Git configured with SSH auth (Lab 1)
- [ ] Docker installed and working (Lab 2 / Lab 3)
- [ ] Ability to enable Dependabot / Advanced Security on a GitHub repo (public repos have most of this free)
- [ ] Screen recording software ready with `.wmv` export

---

## Part 1 — Create a Pinned, Reproducible Repo

### 1A — Create the repo on GitHub

Create a **public** repo named `ia462-lab4-supply-chain` on your GitHub account. Clone it locally:

```bash
git clone git@github.com:<your-username>/ia462-lab4-supply-chain.git
cd ia462-lab4-supply-chain
```

### 1B — Application code

Create `app/app.py`:

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "IA 462 Lab 4 - Supply-Chain-Hardened App"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

### 1C — Pinned dependencies

Create `requirements.txt` with **exact pins** (Week 8 slide: *Pinning vs. Floating Dependencies*):

```
flask==3.0.3
werkzeug==3.0.3
```

Generate a hashed lock file (defense against tampered registries):

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install --upgrade pip pip-tools
pip-compile --generate-hashes --output-file=requirements.lock requirements.txt
deactivate
```

Commit both files. `requirements.lock` is your reproducible-build guarantee.

### 1D — Pinned Dockerfile

Grab the exact digest of the base image:

```bash
docker pull python:3.11-slim
docker inspect --format='{{index .RepoDigests 0}}' python:3.11-slim
```

Create `Dockerfile` with a **digest-pinned** base image:

```dockerfile
# IA 462 Lab 4 - digest-pinned base image (Week 8 slide: pin, don't float)
FROM python:3.11-slim@sha256:REPLACE_WITH_REAL_DIGEST

LABEL maintainer="student@emich.edu"
LABEL description="IA 462 Lab 4 - Supply-Chain-Hardened App"

RUN groupadd --system appgroup && \
    useradd  --system --gid appgroup --home /app --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY --chown=appuser:appgroup requirements.lock ./requirements.txt
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
COPY --chown=appuser:appgroup app/ ./app/

USER appuser
EXPOSE 5000
CMD ["python3", "app/app.py"]
```

### 1E — Directory shape

```
ia462-lab4-supply-chain/
├── .github/workflows/security-pipeline.yml       (Part 3)
├── .github/workflows/dependency-review.yml       (Part 3)
├── .github/dependabot.yml                        (Part 2)
├── app/app.py
├── Dockerfile
├── requirements.txt
├── requirements.lock
└── README.md
```

**Screenshot 1:** Rendered `tree` output of your repo (post-Part-3).

---

## Part 2 — Turn On GitHub's Supply-Chain Defenses

Reference: Week 8 slide *GitHub Dependency Security Tools*.

### 2A — Enable repo-level security features

In your repo → **Settings → Code security and analysis**, enable:

- Dependency graph
- Dependabot alerts
- Dependabot security updates
- Secret scanning (public repos: free) — including **Push protection**

**Screenshot 2:** The Code security and analysis settings page with every option enabled.

### 2B — Configure Dependabot

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  # Python dependencies
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5

  # Docker base image
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"

  # GitHub Actions themselves (pinned SHAs)
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 2C — Branch protection + required signed commits

**Settings → Branches → Add rule** on `main`:

- Require a pull request before merging (`Require approvals: 1`)
- Require status checks to pass — add every job we build in Part 3
- Require signed commits
- Require conversation resolution
- Do not allow bypassing the above

**Screenshot 3:** The branch protection rule for `main` fully configured.

### 2D — Configure SSH commit signing (Week 8 slide: *Commit Signing & Verified History*)

```bash
# Use your existing SSH key from Lab 1 to sign commits
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Add the same SSH key as a **signing key** on GitHub → `Settings → SSH and GPG keys → New SSH key → Key type: Signing`.

Verify:

```bash
git commit --allow-empty -m "chore: verify signed commits"
git push
```

**Screenshot 4:** GitHub PR/commit view showing your commit with a green **Verified** badge.

---

## Part 3 — Automated Supply-Chain CI/CD Pipeline

Reference: Week 8 slide *Integrating Dependency Scanning into CI/CD* + *Securing Dependencies in GitHub Actions* + *GitHub's Dependency Review Action*.

### 3A — Security pipeline

Create `.github/workflows/security-pipeline.yml`:

```yaml
# All third-party actions pinned to a full commit SHA (Week 8 guidance)
name: Security CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0

      - name: Set up Buildx
        uses: docker/setup-buildx-action@d70bba72b1f3fd22344832f00baa16ece964efeb # v3.3.0

      - name: Build
        run: |
          docker build -t ia462-lab4:${{ github.sha }} .
          docker save ia462-lab4:${{ github.sha }} -o image.tar

      - name: Upload image
        uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808 # v4.3.3
        with:
          name: docker-image
          path: image.tar

  vulnerability-scan:
    name: Vulnerability Scan (Trivy)
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0
      - uses: actions/download-artifact@65a9edc5881444af0b9093a5e628f2fe47ea3b2e # v4.1.7
        with: { name: docker-image }
      - run: docker load -i image.tar
      - name: Trivy scan
        uses: aquasecurity/trivy-action@6c175e9c4083a92bbca2f9724c8a5e33bc2d97a5 # v0.28.0
        with:
          image-ref: ia462-lab4:${{ github.sha }}
          exit-code: '1'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'
          output: trivy-results.txt
      - name: Upload results
        if: always()
        uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808 # v4.3.3
        with:
          name: trivy-results
          path: trivy-results.txt

  sbom:
    name: Generate SBOM (Syft, SPDX)
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0
      - uses: actions/download-artifact@65a9edc5881444af0b9093a5e628f2fe47ea3b2e # v4.1.7
        with: { name: docker-image }
      - run: docker load -i image.tar
      - name: Install Syft
        run: curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
      - run: |
          syft ia462-lab4:${{ github.sha }} -o spdx-json > sbom.spdx.json
          syft ia462-lab4:${{ github.sha }} -o table   > sbom.table.txt
      - uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808 # v4.3.3
        with:
          name: sbom
          path: |
            sbom.spdx.json
            sbom.table.txt

  dependency-audit:
    name: Python Dependency Audit (pip-audit)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0
      - uses: actions/setup-python@0a5c61591373683505ea898e09a3ea4f39ef2b9c # v5.0.0
        with: { python-version: '3.11' }
      - run: pip install pip-audit
      - name: Run pip-audit against pinned deps
        run: pip-audit -r requirements.txt --strict --output audit-results.txt
      - if: always()
        uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808 # v4.3.3
        with:
          name: pip-audit-results
          path: audit-results.txt
```

### 3B — Dependency Review action (PR gate)

Create `.github/workflows/dependency-review.yml`:

```yaml
name: Dependency Review

on: [pull_request]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0
      - name: Dependency Review
        uses: actions/dependency-review-action@0c155c5e8556a497adf53f2c18edabf945ed8e70 # v4.3.4
        with:
          fail-on-severity: high
          deny-licenses: GPL-2.0, AGPL-3.0
          comment-summary-in-pr: always
```

Commit + push. Watch the pipeline run under the **Actions** tab.

**Screenshot 5:** Full pipeline (`build`, `vulnerability-scan`, `sbom`, `dependency-audit`) all green on `main`.
**Screenshot 6:** The uploaded SBOM artifact (`sbom.spdx.json`) opened — top of file showing the SPDX header.
**Screenshot 7:** The uploaded Trivy `trivy-results.txt` artifact contents.

---

## Part 4 — Prove the Gate Works: Introduce a Vulnerable Dep

Reference: Week 8 slide *Dependency Confusion & Supply Chain Attacks* + *Dependency Review Action*.

### 4A — Open a PR that downgrades to a vulnerable version

```bash
git checkout -b test/introduce-vulnerable-dep
```

Edit `requirements.txt` to introduce an old, known-vulnerable version:

```
flask==2.0.0
werkzeug==2.0.0
```

Regenerate the lock:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install --upgrade pip pip-tools
pip-compile --generate-hashes --output-file=requirements.lock requirements.txt || true
deactivate

git add requirements.txt requirements.lock
git commit -m "test: introduce vulnerable Flask 2.0.0 to prove gate blocks it"
git push origin test/introduce-vulnerable-dep
```

Open a pull request against `main`. Your `dependency-review` action **must** fail. Your `pip-audit` job **should** fail. Your Trivy scan may also flag additional CVEs.

**Screenshot 8:** The PR page showing `dependency-review` failing with the vulnerable Flask 2.0.0 listed.
**Screenshot 9:** The PR page showing `pip-audit` output flagging the vulnerable version.

### 4B — Close the PR without merging

Under the PR, click **Close pull request** (do **not** merge). Verify `main` stays green.

**Screenshot 10:** The closed PR summary — "This pull request was closed without being merged."

---

## Part 5 — Generate & Publish an SBOM Snapshot

Reference: Week 8 slide *Software Bill of Materials (SBOM)*.

Locally reproduce what the pipeline generates:

```bash
# From your repo root
docker build -t ia462-lab4:local .
syft ia462-lab4:local -o spdx-json  > sbom-local.spdx.json
syft ia462-lab4:local -o cyclonedx-json > sbom-local.cdx.json
syft ia462-lab4:local -o table      > sbom-local.table.txt

# Total packages
jq '.packages | length' sbom-local.spdx.json
```

Commit `sbom-local.*` into a new `sboms/` folder on `main` (via PR):

```bash
git checkout -b sbom-snapshot
mkdir -p sboms
mv sbom-local.* sboms/
git add sboms/
git commit -m "sboms: initial SBOM snapshot (SPDX + CycloneDX + table)"
git push origin sbom-snapshot
```

Open the PR, ensure the whole pipeline stays green, and merge it.

**Screenshot 11:** The merged PR showing the pipeline green.
**Screenshot 12:** GitHub UI → Insights → Dependency graph → *Export SBOM* — the SPDX snapshot from GitHub itself.

---

## Part 6 — Write a Short Supply-Chain Rationale

Create/update `README.md` on `main` (via a signed-commit PR) with:

- What the repo is
- **Every** supply-chain control you enabled, mapped back to Week 8 slide titles:
  - Pinning vs. Floating Dependencies
  - GitHub Dependency Security Tools
  - Dependency Confusion & Supply Chain Attacks
  - Securing Dependencies in GitHub Actions
  - Commit Signing & Verified History
  - Software Bill of Materials (SBOM)
  - Integrating Dependency Scanning into CI/CD
  - GitHub's Dependency Review Action
- A short "How to reproduce the vulnerable-PR demo" section

**Screenshot 13:** The rendered `README.md` on GitHub.

---

## Part 7 — Push Lab 4 Deliverables to the Student Upload Repo

```bash
cd ~/emu-ia-462-fall-2026
git checkout -b lab4-<your-username>
mkdir -p Lab4/{artifacts,screenshots}

# Repo link / evidence
echo "https://github.com/<your-username>/ia462-lab4-supply-chain" > Lab4/repo-link.txt

# Pipeline artifacts (download from Actions run + drop them in)
cp ~/Downloads/sbom.spdx.json      Lab4/artifacts/
cp ~/Downloads/trivy-results.txt   Lab4/artifacts/
cp ~/Downloads/audit-results.txt   Lab4/artifacts/

# Screenshots
cp ~/Desktop/lab4-screenshot-*.png Lab4/screenshots/

git add Lab4/
git commit -m "Lab 4: Dependency Management & Version Control"
git push origin lab4-<your-username>
```

Open a PR in the student upload repo and screenshot it (`14-lab4-pull-request.png`).

---

## Part 8 — Video Walkthrough

Record a single `.wmv` video demonstrating:

1. Your repo layout + pinned `requirements.txt` + `requirements.lock` + digest-pinned `Dockerfile`
2. GitHub `Code security and analysis` page with every setting on
3. Your `dependabot.yml`, branch protection rule, and a signed commit's green **Verified** badge
4. A successful full pipeline run on `main` (build, Trivy, SBOM, pip-audit)
5. The vulnerable-PR demo — `dependency-review` red, `pip-audit` red, PR closed unmerged
6. Your `sboms/` folder + a walkthrough of your `README.md` rationale mapped to the slides
7. Your open pull request in the student upload repo

> **Critical:** Export in `.wmv`. Any other format cannot be graded.

---

## Submission Requirements

| Item | Format | Required |
|------|--------|----------|
| Video walkthrough | `.wmv` | Yes |
| Lab 4 repo link (`repo-link.txt`) | URL | Yes |
| Pipeline artifacts (SBOM + Trivy + pip-audit) | `.json` / `.txt` | Yes |
| Screenshots (`Lab4/screenshots/`) | `.png` / `.jpg` | Yes |
| Pull request link in student upload repo | URL | Yes |

---

## Tips & Resources

- **pip-tools:** https://pip-tools.readthedocs.io
- **Dependabot config reference:** https://docs.github.com/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file
- **Dependency Review Action:** https://github.com/actions/dependency-review-action
- **Trivy Action:** https://github.com/aquasecurity/trivy-action
- **Syft (SBOM generation):** https://github.com/anchore/syft
- **SPDX Spec:** https://spdx.dev
- **SSH Commit Signing:** https://docs.github.com/authentication/managing-commit-signature-verification/about-commit-signature-verification#ssh-commit-signature-verification
- **Pinning GitHub Actions by SHA:** https://docs.github.com/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions

---

> **Reminder:** All work must be your own. AI-generated work is prohibited per syllabus. Refer to the syllabus for full course policies.
