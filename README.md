# Timesheet DevSecOps Pipeline 

A Spring Boot timesheet app secured with a full DevSecOps pipeline
on a local Kubernetes environment (Minikube).

## Results

| Layer | Before | After | Critical |
|---|---|---|---|
| Dependency CVEs | 84 | 7 | 5 → 0 |
| Container CVEs | 26 | 7 | 2 → 0 |
| DAST (ZAP) | — | 64 checks passed | 0 failures |
| Quality Gate | — | Passed | — |

## Pipeline
GIT → COMPILE → SONARQUBE → OWASP DC → BUILD → TRIVY → PUSH → DEPLOY → ZAP DAST

## Stack

| Layer | Tools |
|---|---|
| CI/CD | Jenkins |
| SAST | SonarQube |
| SCA | OWASP Dependency Check |
| Container | Docker + Trivy |
| Secrets | HashiCorp Vault + Agent Injector |
| Kubernetes | Minikube + Kyverno + Network Policies |
| Runtime | Falco |
| DAST | OWASP ZAP |
| Monitoring | Prometheus + Grafana |

## Secrets Management

Vault Agent Injector injects secrets at runtime into `/vault/secrets/`.
Zero secrets in code, images, or manifests.

| Secret | Path |
|---|---|
| Docker Hub token | `secret/data/docker` |
| SonarQube token | `secret/data/sonar` |

## Policy as Code

| Policy | Mode | Result |
|---|---|---|
| disallow-privileged | Enforce | 103 pass |
| disallow-root-user | Audit | 103 fail — MySQL runs as root by design |
| require-resource-limits | Audit | 102 pass / 1 fail |

## Network Policies

| Policy | Effect |
|---|---|
| allow-timesheet-to-mysql | Only timesheet → MySQL on port 3306 |
| default-deny-ingress | Block all ingress unless explicitly allowed |
| deny-mysql-egress | MySQL cannot initiate outbound connections |

## Runtime Security

| Rule | MITRE | Trigger |
|---|---|---|
| Shell in container | T1059 | bash/sh spawned in pod |
| Sensitive file read | T1003 | /etc/shadow access |
| Drop and execute new binary | T1059 | Binary executed in container |
| Redirect STDOUT/STDIN | TA0003 | Network connection in container |
| Contact K8S API Server | TA0003 | Direct K8S API access from container |

## Monitoring

Grafana security dashboard - real cluster data:

- **Runtime Threats** — Falco alert rate, security events table
- **Policy & Compliance** — Kyverno admission results
- **DAST — OWASP ZAP** — 64 checks passed, 0 failures, 3 warnings