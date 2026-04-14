#!/bin/bash
VM_NAME="finaldefinalversiondebian3"
VM_IP=$(VBoxManage guestproperty get "$VM_NAME" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk "{print \$2}" | tr -d "\r")
echo "IP_DETECTEE : $VM_IP"
echo "[k3s_nodes]
debian_vm ansible_host=$VM_IP ansible_user=vagrant ansible_password=vagrant ansible_become_password=vagrant ansible_ssh_common_args='-o StrictHostKeyChecking=no'" > hosts.ini