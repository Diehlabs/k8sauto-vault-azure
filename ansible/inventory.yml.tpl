---
# Terraform will generate this file on every run
all:
  hosts:
    localhost:
  children:
    vault_nodes:
%{ for host, ipaddr in hosts }
      '${ipaddr}':
%{ endfor ~}
  vars:
    ansible_become: yes
    ansible_connection: ssh
    ansible_python_interpreter: /usr/bin/python
    ansible_ssh_user: ${user_id}
    host_key_checking: False
    user_id: ${user_id}
