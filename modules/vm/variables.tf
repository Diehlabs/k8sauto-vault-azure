variable "tags" {}

variable "rg_name" {}

variable "subnet_id" {}

variable "vm_name" {}

variable "ssh_key" {
  type = object({
    public_key_openssh = string
    private_key_pem    = string
  })
}

# variable "common_name" {}

# variable "organization_name" {}

# variable "ca_cert" {
#   type = object({
#     cert_pem = string
#   })
# }

# variable "ca_key" {
#   type = object({
#     algorithm       = string,
#     private_key_pem = string,
#   })
# }

# variable "lb_addresses" {
#   type    = list(any)
#   default = null
# }

variable "msi" {}

variable "availability_set_id" {}
