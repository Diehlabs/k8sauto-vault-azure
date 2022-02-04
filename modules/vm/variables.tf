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

variable "msi" {}

variable "availability_set_id" {}
