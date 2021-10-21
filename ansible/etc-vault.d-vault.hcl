cluster_addr  = "https://<LOCAL_IPV4_ADDRESS>:8201"
api_addr      = "https://<LOCAL_IPV4_ADDRESS>:8200"
disable_mlock = true

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/opt/vault/tls/vault-cert.pem"
  tls_key_file       = "/opt/vault/tls/vault-key.pem"
  tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "<UNIQUE_ID_FOR_THIS_HOST>"

  retry_join {
    auto_join               = "provider=azure subscription_id=<SUBSCRIPTION_ID> resource_group=<RESOURCE_GROUP_NAME> vm_scale_set=<VM_SCALE_SET_NAME>"
    auto_join_scheme        = "https"
    # leader_tls_servername   = "<VALID_TLS_SERVER_NAME>"
    leader_ca_cert_file     = "/opt/vault/tls/vault-ca.pem"
    leader_client_cert_file = "/opt/vault/tls/vault-cert.pem"
    leader_client_key_file  = "/opt/vault/tls/vault-key.pem"
  }
}

storage "azure" {
  accountName = "my-storage-account"
  accountKey  = "abcd1234"
  container   = "container-efgh5678"
  environment = "AzurePublicCloud"
}

# seal "azurekeyvault" {
#   tenant_id  = "<AZURE_TENANT_ID>"
#   vault_name = "<AZURE_VAULT_NAME>"
#   key_name   = "<AZURE_KEY_NAME>"
# }

ui = true
