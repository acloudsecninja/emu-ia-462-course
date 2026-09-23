# In-Class Lab 1 — Dependabot Alerts in a Dockerized Application

**Course:** IA 462 — Advanced Operating Systems Security & Administration  
**Topic:** Software supply-chain security, Docker, and Dependabot  

> This in-class lab gives you a controlled way to create, observe, triage, and remediate dependency alerts. The vulnerable versions are used only for demonstration; do not deploy the intentionally vulnerable image to a public service.

---

## Learning Objectives

By the end of this lab, you will be able to:

- Explain the difference between a dependency graph, an alert, and a Dependabot security update.
- Configure Dependabot for Python, Docker, and GitHub Actions ecosystems.
- Connect a vulnerable application dependency and Docker base image to a GitHub alert.
- Review a remediation pull request and verify the result locally with Docker and a scanner.
- Document residual risk when an update is unavailable or introduces a breaking change.

## Prerequisites

- [ ] A public GitHub repository, or a repository where your instructor has enabled the required security features
- [ ] Git and Docker Desktop installed and working
- [ ] A GitHub account with permission to create branches and pull requests
- [ ] Screen recording software ready with `.wmv` export

> Dependabot availability varies by repository visibility and organization plan. If the alert does not appear in a private repository, use a public repository or record the equivalent configuration and local scan evidence.

---

## Part 1 — Create the Deliberately Vulnerable Baseline

Create a new repository named `ia462-inclasslab1-dependabot`, clone it, and create this structure:

```text
ia462-inclasslab1-dependabot/
├── .github/dependabot.yml
├── .github/workflows/ci.yml
├── app/app.py
├── requirements.txt
├── Dockerfile
└── README.md
```

Create `app/app.py`:

```python
from flask import Flask

app = Flask(__name__)


@app.get("/")
def home():
    return "IA 462 Dependabot lab"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Create `requirements.txt` with an intentionally old Flask release:

```text
Flask==2.2.2
```

Create `Dockerfile`:

```dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ app/

EXPOSE 5000
CMD ["python", "app/app.py"]
```

Build and run the baseline locally:

```bash
docker build -t ia462-inclasslab1:baseline .
docker run --rm -d --name ia462-inclasslab1 -p 5000:5000 ia462-inclasslab1:baseline
curl http://localhost:5000
docker logs ia462-inclasslab1
docker stop ia462-inclasslab1
```

**Screenshot 1:** Successful Docker build and `curl` response.  
**Artifact 1:** Save the exact build and run commands in `baseline-commands.txt`.

---

## Part 2 — Configure Dependabot

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: pip
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  - package-ecosystem: docker
    directory: "/"
    schedule:
      interval: weekly

  - package-ecosystem: github-actions
    directory: "/"
    schedule:
      interval: weekly
```

Create `.github/workflows/ci.yml`:

```yaml
name: Container build

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build --tag ia462-inclasslab1:${{ github.sha }} .
```

Commit and push on a branch:

```bash
git checkout -b inclasslab1-dependabot
 git add .
git commit -m "In-Class Lab 1: add Dependabot Docker baseline"
git push -u origin inclasslab1-dependabot
```

In GitHub, open **Settings → Code security and analysis** and enable, where available:

- Dependency graph
- Dependabot alerts
- Dependabot security updates
- Dependabot version updates

Open the **Insights → Dependency graph** view and confirm that the Python dependency and Docker base image are detected.

**Screenshot 2:** Dependabot settings and the dependency graph.  
**Artifact 2:** Save a copy of `.github/dependabot.yml` in your submission.

---

## Part 3 — Triage the Alert

Open **Security → Dependabot alerts**. For each alert that appears, record:

- Package or base image name
- Vulnerable version and patched version, if available
- Severity and CVSS information
- Affected file and dependency path
- Recommended remediation
- Whether the application is actually exposed to the vulnerable behavior

Create `dependabot-triage.md` using this table:

```markdown
| Alert | Severity | Affected file | Patched version | Exploitability in this lab | Action |
|---|---|---|---|---|---|
| Example | High | requirements.txt | <version> | Explain the exposure | Update/test |
```

**Screenshot 3:** One alert expanded so the severity, affected dependency, and remediation are visible.

> Do not download or execute exploit code. Alert triage requires understanding the affected component and exposure, not exploitation.

---

## Part 4 — Apply and Verify Remediation

Create a remediation branch and update the dependency to the patched version shown by GitHub. Also replace floating references with a current supported Python slim tag, then record the exact resulting image digest:

```bash
git checkout -b inclasslab1-remediate
# Edit requirements.txt and Dockerfile using the versions recommended by Dependabot.
docker pull python:3.12-slim
docker inspect --format='{{index .RepoDigests 0}}' python:3.12-slim
docker build --tag ia462-inclasslab1:remediated .
docker run --rm -d --name ia462-inclasslab1 -p 5000:5000 ia462-inclasslab1:remediated
curl http://localhost:5000
docker stop ia462-inclasslab1
```

Run one local vulnerability check if available:

```bash
trivy image --severity HIGH,CRITICAL ia462-inclasslab1:remediated
```

Commit the fix and open a pull request. Review the Dependabot-generated diff or your manual remediation diff. Do not merge until the build passes.

**Screenshot 4:** Passing build check and the remediation pull request.  
**Screenshot 5:** The remediated image scan and working application response.  
**Artifact 3:** `remediation-notes.md` with before/after versions, test results, and any remaining alerts.

---

## Part 5 — Reflection and Submission

Write 200–300 words answering:

1. Why can a Docker base image create a security alert even when application code is unchanged?
2. What information did the alert provide that a raw scanner did not?
3. Why should an alert be triaged for reachability and impact rather than blindly upgraded?
4. What additional controls would you add to CI, such as SBOM generation, image signing, or severity gates?

Submit:

- GitHub repository and pull request URL
- `dependabot-triage.md`
- `remediation-notes.md`
- `baseline-commands.txt`
- Screenshots 1–5
- `.wmv` walkthrough
- Reflection

## Grading

| Assessment area |
|---|
| Working Docker baseline |
| Dependabot configuration and dependency graph |
| Alert triage accuracy |
| Remediation and verification |
| Documentation, screenshots, and reflection |
