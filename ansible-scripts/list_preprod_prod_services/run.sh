#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f "$0"))
LIST_SERVICES_FILE="${SCRIPT_DIR}/source_files/list_services.php"
cd ${SCRIPT_DIR}

sudo rm -rf retrieved_files/*.csv
sudo ansible-playbook playbooks/list_preprod_prod_services.yaml --extra-vars "host=list_services"

cat source_files/start_tag_html.txt > ${LIST_SERVICES_FILE}

for LINES in $(cat retrieved_files/*.csv | sort --ignore-case)
do
    SERVICE=$(echo "${LINES}" | cut -d ',' -f1)
    TYPE=$(echo "${LINES}" | cut -d ',' -f2)
    VERSION=$(echo "${LINES}" | cut -d ',' -f3)
    SERVER=$(echo "${LINES}" | cut -d ',' -f4)

    echo "                            <tr>" >> ${LIST_SERVICES_FILE}
    echo "                                <td class='text-center'>${SERVICE}</td>" >> ${LIST_SERVICES_FILE}
    echo "                                <td class='text-center'>${TYPE}</td>" >> ${LIST_SERVICES_FILE}
    echo "                                <td class='text-center'>${VERSION}</td>" >> ${LIST_SERVICES_FILE}
    echo "                                <td class='text-center'>${SERVER}</td>" >> ${LIST_SERVICES_FILE}
    echo "                            </tr>" >> ${LIST_SERVICES_FILE}
done

cat source_files/end_tag_html.txt >> ${LIST_SERVICES_FILE}
rm -rf ${LIST_SERVICES_FILE} retrieved_files/*.csv
