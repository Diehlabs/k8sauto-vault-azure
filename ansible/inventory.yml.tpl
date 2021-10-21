---
# Terraform will generate this file on every run
all:
  hosts:
    %{ for host, ipaddr in hosts }
    '${ipaddr}':
  host_ip:
    node_id: ${host}
    %{ endfor ~}
  vars:
    ansible_become: yes
    ansible_connection: ssh
    ansible_python_interpreter: /usr/bin/python
    ansible_ssh_user: ${user_id}
    host_key_checking: False
    user_id: ${user_id}
    azure_storage_account_name: ${azure_storage_account_name}
    azure_storage_account_key: ${azure_storage_account_key}
    azure_storage_container: ${azure_storage_container}
