---
# Terraform will generate this file on every run
all:
  hosts:
%{ for public_ip, private_ip in hosts }
    '${public_ip}':
      node_ip: '${private_ip}'
%{ endfor ~}
  vars:
    ansible_become: yes
    ansible_connection: ssh
    ansible_python_interpreter: /usr/bin/python
    ansible_ssh_user: ${user_id}
    host_key_checking: False
    user_id: ${user_id}
