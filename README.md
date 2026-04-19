# Timesheet DevSecOps Pipeline 

A Spring Boot timesheet app with a full DevSecOps pipeline built
on a local Kubernetes environment (Minikube).
## Results

| Layer | Before | After | Critical |
|---|---|---|---|
| Dependency CVEs | 84 | 7 | 5 → 0 |
| Container CVEs | 26 | 7 | 2 → 0 |
| DAST (ZAP) | — | 64 checks passed | 0 failures |
| Quality Gate | — | Passed | — |

## Stack

| Layer | Tools |
|---|---|
| CI/CD | Jenkins |
| SAST | SonarQube |
| SCA | OWASP Dependency Check |
| Container | Docker + Trivy |
| Secrets | HashiCorp Vault |
| Kubernetes | Minikube + Kyverno + Network Policies |
| Runtime | Falco |
| DAST | OWASP ZAP |
| Monitoring | Prometheus + Grafana |

## Structure

app/           → Spring Boot source + Dockerfile
pipeline/      → Jenkinsfile
kubernetes/    → K8s manifests
security/      → Kyverno, Falco, Vault, ZAP configs
monitoring/    → Prometheus + Grafana
reports/       → Scan results before/after
docs/          → CVE remediation journey
## Secrets Management

HashiCorp Vault manages all secrets — no credentials in code, images, or manifests.

**How it works:**
- Vault Agent Injector runs as a sidecar in every pod
- Secrets are mounted at `/vault/secrets/` at runtime
- Kubernetes authenticates to Vault via service account tokens
- TTL: 24h token expiry

**Secrets stored:**
- `secret/data/docker` — Docker Hub credentials
- `secret/data/sonar` — SonarQube token

**Policies:**
- `timesheet-policy` — read access for app pods
- `k8s-policy` — read access for Kubernetes workloads
 ## Pipeline Stages

GIT → COMPILE → SONARQUBE → OWASP DC → BUILD → TRIVY → PUSH → DEPLOY → ZAP DAST

## Runtime Security

Falco monitors all containers using default + custom rules:

| Rule | MITRE | Trigger |
|---|---|---|
| Shell in container | T1059 | bash/sh spawned in pod |
| Sensitive file read | T1003 | /etc/shadow access |
| Unexpected outbound | TA0003 | connection outside port 3306/8200 |

## Policy as Code

Kyverno enforces security at admission time:

| Policy | Mode |
|---|---|
| disallow-privileged | Enforce |
| disallow-root-user | Audit |
| require-resource-limits | Audit |


 ## Monitoring & Observability

Grafana security dashboard with real data from the cluster:

**Runtime Threats (Falco)**
- Live threat detection rate over time
- Security alerts table with timestamps, priority, and rule name
- Rules triggered: Drop and execute new binary, Contact K8S API Server, Terminal shell in container

**Policy & Compliance (Kyverno)**
- disallow-privileged → 107 pass
- disallow-root-user → 107 fail (audit mode — MySQL runs as root)
- require-resource-limits → 101 pass / 6 fail
 
 ## Network Policies

Zero-trust networking enforced in namespace `chap4`:

| Policy | Effect |
|---|---|
| `allow-timesheet-to-mysql` | Only timesheet → MySQL on port 3306 |
| `default-deny-ingress` | Block all ingress unless explicitly allowed |
| `deny-mysql-egress` | MySQL cannot initiate outbound connections |