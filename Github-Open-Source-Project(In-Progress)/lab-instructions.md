# Lab Instructions: GitHub Open-Source Docker Project

## Course
IA 462 — Advanced Operating Systems Security & Administration

## Objective
Select an open-source project from GitHub, build it using Docker, and document each step in a recorded video. This work should reflect the same professionalism, technical depth, and practical demonstration expected in the other IA 462 labs, midterm, and final assessments.

## Assignment Overview
The goal is to demonstrate your ability to:
- identify a suitable open-source project
- understand how the project works at a high level
- prepare and use Docker to build or run the project
- troubleshoot issues
- clearly explain the process in a video
- connect the work to security and administration concepts

## Required Work
Each student must:
1. choose an open-source project from GitHub
2. verify it can be built and run locally
3. use Docker to build or run the project
4. document the commands and outcomes
5. record the process in a video
6. explain what was learned

## Step 1: Select an Open-Source Project
1. Go to [GitHub](https://github.com).
2. Select a project that is:
   - open source
   - well documented
   - buildable on a local system
   - relevant to security, systems administration, Linux, networking, DevOps, or infrastructure
3. Confirm the repository has a clear README and a valid open-source license.
4. Choose something that is technically manageable for the course timeline.

## Step 2: Review the Project
Before building anything, review:
- the repository structure
- the README
- prerequisites
- operating system requirements
- dependency requirements
- build instructions
- Docker support, if available

Take notes on:
- what the project does
- what technologies it uses
- what environment may be required

## Step 3: Clone the Repository
Use Git to clone the selected project:

```bash
git clone <repository-url>
cd <project-folder>
```

Document the repository name, URL, and purpose in your notes or video.

## Step 4: Build with Docker
Create a Dockerfile if one does not already exist, or use an existing Docker setup.

Typical commands:

```bash
docker build -t <project-name> .
```

If the project includes Docker Compose:

```bash
docker compose up --build
```

You must document:
- the exact commands used
- the result of the build
- any errors or warnings
- how you resolved issues

## Step 5: Troubleshoot and Document Errors
This is a required part of the assignment. Students must show that they can investigate and resolve problems encountered during setup or execution.

Common issues may include:
- missing dependencies
- unsupported versions
- Docker build failures
- environment variables missing
- permission issues
- port conflicts
- package manager errors
- runtime configuration problems

When an issue occurs:
- explain what failed
- identify what was checked
- describe the fix
- explain why the fix worked

This is a major part of the assignment and should appear clearly in your video.

## Step 6: Run the Project
Once the build succeeds, run the project in Docker and confirm it works.

Examples:

```bash
docker run --rm -it <project-name>
```

or

```bash
docker compose up
```

Document:
- container startup
- output or logs
- service availability
- port usage
- whether the application runs successfully

## Step 7: Explain the Project in the Video
Your video must explain:
- what the project does
- why you selected it
- what technologies it uses
- how Docker was used
- what commands were executed
- what issues occurred and how they were resolved
- whether the project was successfully built and run

## Video Requirements
The video should:
- show the terminal or screen activity
- explain key steps as they happen
- include troubleshooting and problem-solving
- be clear, organized, and professional
- show evidence of work being performed

Your video should not simply say “I built it.” It should show and explain the technical process.

## Submission Requirements
Submit:
1. the GitHub repository URL
2. the project name and purpose
3. the Docker build steps
4. notes or screenshots showing key outcomes
5. a recorded video
6. a brief reflection paragraph

## Reflection Requirement
In the final summary, explain:
- what the project does
- what challenges you faced
- how Docker affected the build process
- how the project relates to operating systems security or administration
- what you learned from the assignment

## Grading Expectations
This assignment is expected to meet the same standards as the other IA 462 labs, midterm, and final:
- technical correctness
- strong documentation
- clear presentation
- evidence of effort and troubleshooting
- professionalism
- security and systems administration awareness

## Final Note
This assignment is meant to be practical and hands-on. The focus is not just on choosing an open-source project, but also on showing your ability to build, troubleshoot, explain, and document real technical work in a way that reflects the standards of IA 462.
