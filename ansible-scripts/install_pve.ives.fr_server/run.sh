#!/bin/bash

echo "Checking proxmox and uploading .patch file..."

ansible-playbook --extra-vars "host=all_proxmox_europe" playbooks/check_and_upload_aplinfo_patch_2022_09_27.yaml

read -r -p "Do you want to apply patch? (o/n)" answer

if [[ "${answer}" =~ ^(Y|y|O|o)$ ]]
then
	ansible-playbook --extra-vars "host=all_proxmox_europe" playbooks/check_and_apply_aplinfo_patch_2022_09_27.yaml
fi
