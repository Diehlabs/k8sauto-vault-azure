# variable "hosts_data" {
#     type = map(any)
# #   type = object({
# #     <name> = object({
# #       dns_names    = list(string),
# #       ip_addresses = list(string),
# #     })
# #   })
# }

variable "organization_name" {
  default = "Diehlabs, Inc"
}

variable "ca_common_name" {
  default = "diehlabs.com"
}

variable "dns_names" {
  type = list(string)
}

variable "ip_addresses" {
  type = list(string)
}
