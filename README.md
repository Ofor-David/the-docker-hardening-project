# THE DOCKER HARDENING PROJECT

This project demonstrates how to containerize a FastAPI application using Docker, then progressively **harden** the container image and **secure the CI/CD pipeline** using real-world DevSecOps practices.

By combining **multi-stage Docker builds**, **non-root execution**, **runtime hardening**, and **automated vulnerability scanning**, this project simulates a production-grade container workflow with security built in by default.

---

## Project Objectives

- Build a minimal and secure Docker image for a Python FastAPI web app
- Apply container runtime hardening techniques
- Enforce DevSecOps practices through automated CI pipeline scanning
- Catch vulnerabilities early using [Trivy](https://github.com/aquasecurity/trivy)
- Run containers using **least privilege** principles

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| [FastAPI](https://fastapi.tiangolo.com/) | Python-based API framework |
| [Docker](https://www.docker.com/) | Containerization |
| [Trivy](https://github.com/aquasecurity/trivy) | Vulnerability scanner |
| [GitHub Actions](https://github.com/features/actions) | CI/CD pipeline |
| [Uvicorn](https://www.uvicorn.org/) | ASGI web server for FastAPI |

---

## Key Security Features

- Multi-stage Docker builds  
- Non-root container user (`appuser`)  
-  Hardened container runtime:
- Read-only filesystem
- All Linux capabilities dropped (`--cap-drop=ALL`)
- No privilege escalation (`--security-opt no-new-privileges:true`)
- Automated Trivy scan via GitHub Actions  
- Fails pipeline if CRITICAL or HIGH CVEs are found  
- `.trivyignore` to manage accepted or non-exploitable CVEs

---

## Docker Hardening Summary
|  Area	 |  Status  |
|--------|----------|
Multi-stage build |	✅
 Non-root user	|✅ (USER appuser)
 Read-only filesystem	|✅ (--read-only)
 Dropped Linux capabilities|	✅ (--cap-drop=ALL)
 No privilege escalation	|✅ (--security-opt no-new-privileges:true)
 CI vulnerability scan	|✅ (Trivy via GitHub Actions)
 Clean dependency install	|✅ (--no-cache-dir)

---
## Project Structure

```bash
.
├── .github/
│   └── workflows/
│       └── trivy-scan.yml # GitHub Actions CI pipeline
├── .gitignore             # Ignored by git
├── .trivyignore           # Ignored vulnerability list
├── Dockerfile             # Multi-stage hardened image
├── main.py                # FastAPI app
├── requirements.txt       # Python dependencies
├── README.md              # Project overview & instructions
```

## Local Development & Testing
1.  Build the Docker image
```bash
docker build -t hardening-project .
```
2. Run the container with hardened flags
```bash

docker run \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges:true \
  -p 8000:80 \
  hardening-project
```  
3. Test the app
Open `http://localhost:8000/health` or run:

```bash
curl http://localhost:8000/health
```
Expected response:

```json
{"status": "ok"}
```
## Trivy Scanning Locally
Scan the image for vulnerabilities:
```bash
trivy image --exit-code 1 --severity CRITICAL,HIGH hardening-project
Add --ignore-unfixed
```
- Use `--ignore-unfixed` to skip CVEs with no patch available.

## Continuous Integration with GitHub Actions
The `trivy-scan.yml` workflow performs the following on every push or pull_request:

- Builds the Docker image
- Installs the latest Trivy
- Scans the image
- Fails the pipeline if CRITICAL or HIGH vulnerabilities are found

``` yaml

uses: aquasecurity/trivy-action@0.28.0
with:
  image-ref: 'hardening-project'
  format: 'table'
  exit-code: '1'
  ignore-unfixed: true
  severity: 'CRITICAL,HIGH'
```  
## .trivyignore Explained
Some vulnerabilities (e.g., in uvicorn) may:
- Only affect development mode (which is disabled)
- Be unexploitable in your container due to runtime restrictions
- Have no available fix from maintainers yet

In these cases, they're documented and ignored via `.trivyignore` but are not exploitable due to read-only FS and dropped capabilities


## Contributing
Pull requests are welcome! If you find improvements, feel free to open an issue or fork and submit a PR.