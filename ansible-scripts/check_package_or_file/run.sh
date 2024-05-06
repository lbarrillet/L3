#!/bin/bash

usage() {
    echo "script usage: $0 [-f file [-m md5sum]] [-p package]"
}

if [ $# -lt 1 ]
then
    usage
fi

while getopts 'f:p:m:' OPTION; do
  case "$OPTION" in
    f)
      FILE_PATH="$OPTARG"
      cd /data/ansible-scripts/check_package_or_file/playbooks

      ansible-playbook --extra-vars "host=all_proxmox_europe file_name='$FILE_PATH' " check_md5sum_file.yaml

      SERVICE_BASENAME=$(basename $FILE_PATH)
      cd ..
      echo "proxmox;ct_id;ct_type;hostname;md5sum;file;date" > retrieved_files/${SERVICE_BASENAME}_results.csv
      cat retrieved_files/result.csv/*/home/* >> retrieved_files/${SERVICE_BASENAME}_results.csv

      rm -rf /data/ansible-scripts/check_package_or_file/retrieved_files//result.csv


      ;;
    p)
      PACKAGE_NAME="$OPTARG"
      cd /data/ansible-scripts/check_package_or_file/playbooks

      ansible-playbook --extra-vars "host=all_proxmox_europe package_name='$PACKAGE_NAME' " check_package.yaml

      cd ..
      echo "proxmox;ct_id;ct_type;hostname;package" > retrieved_files/${PACKAGE_NAME}_results.csv
      cat retrieved_files/package_version.csv/*/home/* >> retrieved_files/${PACKAGE_NAME}_results.csv

      rm -rf /data/ansible-scripts/check_package_or_file/retrieved_files/package_version.csv
      ;;

    m)
      MD5SUM="$OPTARG"

      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -n "$MD5SUM" ]
then
    cd /data/ansible-scripts/check_package_or_file/retrieved_files
    sed -i "/${MD5SUM}/d" sendmail.mc_results.csv
fi
