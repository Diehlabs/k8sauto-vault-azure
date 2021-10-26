---
# Terraform will generate this file on every run
all:
  hosts:
%{ for public_ip, host_data in hosts }
    '${public_ip}':
      node_ip: '${host_data.private_ip}'
%{ endfor ~}
  vars:
    ansible_become: yes
    ansible_connection: ssh
    ansible_python_interpreter: /usr/bin/python
    ansible_ssh_user: ${user_id}
    host_key_checking: False
    user_id: ${user_id}
    ca: ${ca_pem}
    cert: '${tls_cert}'
    key: '${tls_key}'
