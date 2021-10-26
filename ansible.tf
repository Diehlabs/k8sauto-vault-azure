resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.yml"
  content = templatefile("${path.module}/ansible/inventory.yml.tpl", {
    user_id = "adminuser"
    hosts = { for host in module.vault_vms :
      host.public_ip => {
        private_ip = host.ip_addresses #[0]
      }
    }
    tls_cert = base64encode(module.tls.cert)
    tls_key  = sensitive(base64encode(module.tls.key))
    ca_pem   = base64encode(module.tls.ca_pem)
  })
}

resource "local_file" "rsa_key" {
  filename          = "${path.module}/ansible/rsa.key"
  sensitive_content = data.terraform_remote_state.core.outputs.ssh_key.private_key_pem
  file_permission   = "0600"
}

resource "null_resource" "ansible" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.rsa_key,
  ]
  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ansible/setup.yml -i ${path.module}/ansible/inventory.yml --private-key ${path.module}/ansible/rsa.key"
  }
}

output "ansible_inventory" {
  sensitive = true
  value     = local_file.ansible_inventory.content
}
