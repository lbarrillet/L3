#!/bin/bash

#ADD SSH KEY AND REGISTER MODIFICATION
ansible-playbook --extra-vars "host=all_proxmox_europe" playbooks/list_and_register.yaml

for file in retrieved_files/*list_*.csv
do
  echo -e "$(cat $file)\n" >> retrieved_files/all_hostnames.csv
done

#Delete lines breaks
sed -i '/^$/d' retrieved_files/all_hostnames.csv

cat retrieved_files/all_hostnames.csv | while read LINE
do
  ssh-keyscan ${LINE} >> /home/4n51bl3/.ssh/known_hosts
done

#SENDING MAIL
ansible-playbook --extra-vars "host=all_proxmox_europe" playbooks/send_email.yaml

# Cleaning temporary files
rm -f retrieved_files/*list_*.csv retrieved_files/all_hostnames.csv retrieved_files/modifications.csv

