path "secret/data/docker" {
  capabilities = ["read"]
}
path "secret/data/sonar" {
  capabilities = ["read"]
}
path "secret/metadata/*" {
  capabilities = ["list"]
}
