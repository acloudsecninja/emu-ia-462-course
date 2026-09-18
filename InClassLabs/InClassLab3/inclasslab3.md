# In-Class Lab 3 — Linux Containers

**Course:** IA 462 — Advanced Operating Systems Security & Administration  
**Topic:** Linux containers, WSL2, isolation, and hardening  
**Submission:** Pull request containing the lab artifacts, screenshots, and a short `.wmv` walkthrough

> This lab focuses only on Linux containers running through Docker Desktop and WSL2 on Windows. The Windows-container exercise is in [In-Class Lab 2](../InClassLab2/inclasslab2.md).

## Learning Objectives

You will:

- Distinguish the Windows host, WSL2, Docker Desktop, and a Linux container process.
- Build and run a small Linux service as a non-root user.
- Observe Linux namespaces, cgroups, process identity, and container capabilities.
- Apply practical hardening controls including a read-only filesystem, dropped capabilities, health checks, and memory limits.
- Explain why a Linux container shares a kernel boundary instead of acting as a full virtual machine.

## Prerequisites

- [ ] Windows 10/11 with virtualization enabled
- [ ] Docker Desktop installed and started in Linux containers mode
- [ ] WSL2 with Ubuntu installed
- [ ] PowerShell and `sudo` access in WSL Ubuntu
- [ ] At least 8 GB RAM and 15 GB free disk space
- [ ] Screen recording software ready with `.wmv` export

Verify the environment from PowerShell:

```powershell
docker version
docker info
wsl --status
wsl --list --verbose
```

Verify the Linux shell from WSL Ubuntu:

```bash
uname -a
cat /etc/os-release
docker context show
docker info --format 'Server={{.ServerVersion}} OS={{.OperatingSystem}} Kernel={{.KernelVersion}}'
```

**Screenshot 1:** Docker client/server versions, WSL2 status, distribution version, and Docker context.

## Part 1 — Build a Non-Root Linux Service

From PowerShell, create the working directory:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\ia462-inclasslab3\linux" | Out-Null
Set-Location "$HOME\ia462-inclasslab3\linux"
```

Create `app.py`:

```python
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"IA 462 Linux container\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format_string, *args):
        print(format_string % args)


HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

Create `Dockerfile`:

```dockerfile
FROM python:3.12-slim

RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --home-dir /app --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY --chown=appuser:appgroup app.py .
USER appuser

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080')"
CMD ["python", "app.py"]
```

Build and run with hardening controls:

```powershell
docker build --tag ia462-inclasslab3:linux .
docker run --detach --name ia462-linux --publish 8080:8080 --read-only --tmpfs /tmp:rw,noexec,nosuid,size=16m --cap-drop ALL --memory 256m ia462-inclasslab3:linux
Invoke-WebRequest http://localhost:8080
docker inspect --format='{{.State.Health.Status}}' ia462-linux
docker exec ia462-linux id
docker exec ia462-linux cat /etc/os-release
docker top ia462-linux
docker logs ia462-linux
```

Record:

- The host operating system and Docker server operating system
- The container user and UID
- The published port and process ID 1
- Which capabilities, filesystem writes, and memory use were restricted

**Screenshot 2:** Successful Linux container response and health status.  
**Screenshot 3:** `id`, `/etc/os-release`, `docker top`, logs, and hardened run options.

## Part 2 — Observe Linux Isolation

Run these commands from WSL Ubuntu. Docker Desktop versions may report different kernel details; record the values you observe.

```bash
docker context show
docker info --format 'Server={{.ServerVersion}} OS={{.OperatingSystem}} Kernel={{.KernelVersion}}'
docker run --rm alpine:3.20 sh -c 'id; ps; cat /proc/1/cgroup; readlink /proc/1/ns/pid'
```

Answer in `linux-container-analysis.md`:

1. Which kernel executes the Linux container process?
2. What does the PID namespace output show about process visibility?
3. What does `/proc/1/cgroup` reveal about resource-control membership?
4. What is the difference between running this process in a container and directly in WSL?
5. Why does `--cap-drop ALL` reduce attack surface but not replace patching?

**Artifact 1:** `linux-container-analysis.md` with command output and answers.

## Part 3 — Inspect and Explain Hardening

Inspect the running container:

```powershell
docker inspect ia462-linux
docker inspect --format='{{json .HostConfig.CapDrop}}' ia462-linux
docker inspect --format='{{json .HostConfig.ReadonlyRootfs}}' ia462-linux
docker inspect --format='{{.HostConfig.Memory}}' ia462-linux
docker stats --no-stream ia462-linux
```

In the analysis artifact, explain the security purpose and limitation of each control:

- Non-root `USER appuser`
- `--read-only`
- `--tmpfs /tmp`
- `--cap-drop ALL`
- `--memory 256m`
- `HEALTHCHECK`

Do not add `--privileged` to make commands work. If a command fails because of the hardening controls, document the failure and explain which permission boundary caused it.

## Part 4 — Cleanup and Reflection

```powershell
docker stop ia462-linux
docker rm ia462-linux
docker image rm ia462-inclasslab3:linux
docker system df
```

Write a 200–300 word reflection explaining why containers are useful for administration and deployment, which Linux isolation boundary is most important in this lab, and one risk that remains even after hardening.

Submit:

- Repository and pull request URL
- `linux-container-analysis.md`
- Screenshots 1–3
- `.wmv` walkthrough
- Reflection

## Grading

| Assessment area |
|---|
| Environment verification |
| Linux build and service execution |
| Isolation analysis |
| Hardening analysis |
| Documentation, screenshots, and reflection |
