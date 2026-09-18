# In-Class Lab 2 — Windows Containers

**Course:** IA 462 — Advanced Operating Systems Security & Administration  
**Topic:** Windows containers, Docker Desktop, and Windows administration  

> This lab focuses only on Windows containers. The Linux-container exercise is in [In-Class Lab 3](../InClassLab3/inclasslab3.md). Windows containers require a compatible Windows edition, Docker Desktop configuration, and host build.

## Learning Objectives

You will:

- Identify the difference between a Windows host, Docker Desktop, and a Windows container.
- Build and run a small PowerShell HTTP service in a Windows container.
- Inspect Windows container image and process information.
- Explain host/image compatibility and document a safe fallback when Windows containers are unavailable.
- Apply basic operational controls including explicit ports, logs, cleanup, and least-privilege discussion.

## Prerequisites

- [ ] Windows 10/11 with virtualization enabled
- [ ] Docker Desktop installed and started
- [ ] PowerShell access
- [ ] At least 8 GB RAM and 15 GB free disk space
- [ ] Screen recording software ready with `.wmv` export

Verify the starting environment:

```powershell
docker version
docker info
Get-ComputerInfo | Select-Object OsName, OsVersion, OsBuildNumber, WindowsInstallationType
```

**Screenshot 1:** Docker versions, Docker server information, and Windows build information.

## Part 1 — Switch to Windows Container Mode

Stop any running lab containers. From the Docker Desktop tray menu, choose **Switch to Windows containers**. Verify the engine mode:

```powershell
docker info --format 'OS={{.OperatingSystem}} OSType={{.OSType}}'
```

Expected output should identify a Windows operating-system type. Do not bypass Docker Desktop compatibility checks or change system settings without instructor approval.

Create a working directory:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\ia462-inclasslab2\windows" | Out-Null
Set-Location "$HOME\ia462-inclasslab2\windows"
```

**Screenshot 2:** Docker Desktop in Windows container mode and the `docker info` output.

## Part 2 — Build a Windows Container Service

Create `Dockerfile`:

```dockerfile
# Select a tag compatible with the host Windows build.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR C:\app
COPY server.ps1 C:\app\server.ps1

EXPOSE 8080
ENTRYPOINT ["powershell.exe", "-NoLogo", "-NoProfile", "-File", "C:\\app\\server.ps1"]
```

Create `server.ps1`:

```powershell
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:8080/")
$listener.Start()
Write-Output "IA 462 Windows container listening on port 8080"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $body = [System.Text.Encoding]::UTF8.GetBytes("IA 462 Windows container`n")
    $context.Response.ContentLength64 = $body.Length
    $context.Response.OutputStream.Write($body, 0, $body.Length)
    $context.Response.Close()
}
```

Build and run the service:

```powershell
docker build --tag ia462-inclasslab2:windows .
docker run --detach --name ia462-windows --publish 8081:8080 ia462-inclasslab2:windows
Invoke-WebRequest http://localhost:8081
docker inspect --format='{{.Config.Image}} {{.Os}}/{{.Architecture}}' ia462-windows
docker logs ia462-windows
```

Record the image tag, published port, container process, and service response.

**Screenshot 3:** Successful build and `Invoke-WebRequest` response.  
**Screenshot 4:** Image metadata and container logs.

## Part 3 — Administration and Security Analysis

Run:

```powershell
docker ps
docker top ia462-windows
docker inspect --format='{{json .HostConfig.PortBindings}}' ia462-windows
```

Answer in `windows-container-analysis.md`:

1. Which process is PID 1 inside the container?
2. What Windows API or service does the sample use to listen for HTTP requests?
3. Why does publishing port `8081:8080` expose a host port without changing the service’s internal port?
4. Which controls would you add before production use, such as a non-administrator user, a health check, resource limits, image scanning, or a read-only filesystem?
5. Why must the Windows base image tag be compatible with the host build?

**Artifact 1:** `windows-container-analysis.md` with command output and answers.

## Part 4 — Required Compatibility Fallback

If Windows containers are unavailable, capture the exact Docker error and complete this fallback. Do not disable security controls or bypass compatibility checks.

```powershell
docker info --format 'OS={{.OperatingSystem}} OSType={{.OSType}}'
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
```

In `windows-container-fallback.md`, explain:

- Why this host can run Linux containers but not the Windows base image.
- The relationship between host build, Windows base-image tag, and process isolation.
- How Windows containers differ from virtual machines.
- What evidence would be needed before attempting the lab on another Windows host.

The documented fallback receives full credit for Part 2 when the limitation is genuine and clearly explained.

## Part 5 — Cleanup and Reflection

```powershell
docker rm -f ia462-windows 2>$null
docker image rm ia462-inclasslab2:windows 2>$null
docker system df
```

Write a 200–300 word reflection explaining when Windows containers are preferable to Linux containers and identify two security or operational tradeoffs.

Submit:

- Repository and pull request URL
- `windows-container-analysis.md`, or the fallback artifact
- Screenshots 1–4, or fallback evidence
- `.wmv` walkthrough
- Reflection

## Grading

| Assessment area |
|---|
| Environment verification and Windows mode |
| Container build and service execution |
| Administration and security analysis |
| Fallback, documentation, screenshots, and reflection |
