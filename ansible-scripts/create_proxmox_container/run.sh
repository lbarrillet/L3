usage() {
  echo "script usage: $0 -n proxmox_name -o OS [ -p proxmox_password ]"
  exit 1
}


while getopts 'n:p:o:' OPTION
do
  case "$OPTION" in
    n)
      PROXMOX_NAME=${OPTARG}          
      ;;


    p)
      PROXMOX_PASSWORD=${OPTARG}
      ;;


    o)
      OS_PARAMETER=${OPTARG}
      if [ ${OS_PARAMETER} = "centos6" ]
      then
        OS='local:vztmpl/centos-6-default_20191016_amd64.tar.xz'
      elif [ ${OS_PARAMETER} = "centos7" ]
      then
        OS='local:vztmpl/centos-7-default_20190926_amd64.tar.xz'
      elif [ ${OS_PARAMETER} = "almalinux8" ]
      then
        OS='local:vztmpl/almalinux-8-default_20210928_amd64.tar.xz'
      fi
      ;;


    *)
      usage
      ;;


  esac
done


# If the script was run without argument
# OR
# If the script does not use mandatory argument (-n and -o)
if [ $# -lt 1 ] || [ -z "${PROXMOX_NAME}" ] || [ -z "${OS}" ]
then
  usage
fi


# Check if python3 is installed
if [ -z "$(command -v python3)" ]
then
  echo "Python 3 is not installed, please install it first."
  exit 1
fi




# Check if the proxmox password was given as argument (-p)
if [ -z "${PROXMOX_PASSWORD}" ]
then
  read -r -s -p "${PROXMOX_NAME}'s password: " PROXMOX_PASSWORD
  echo ""
fi


# Create PVE API token
TOKEN=$(curl --silent --insecure --data "username=root" --data "realm=pam" --data-urlencode "password=${PROXMOX_PASSWORD}" https://${PROXMOX_NAME}:8006/api2/json/access/ticket)
echo "$TOKEN" | jq --raw-output '.data.ticket' | sed 's/^/PVEAuthCookie=/' > ${script_path}/source_files/cookie
echo "$TOKEN" | jq --raw-output '.data.CSRFPreventionToken' | sed 's/^/CSRFPreventionToken:/' > ${script_path}/source_files/csrftoken


# Check if the PVE API token is valid
if [ -z "$(curl --silent --insecure --cookie "$(cat ${script_path}/source_files/cookie)" https://${PROXMOX_NAME}:8006/api2/json/nodes)" ]
then
  echo "PVE API token is not valid. Check the proxmox password you have entered."
fi


# Retrieve CT_ID list
NEW_LIST=$(curl --silent --insecure --cookie "$(cat ${script_path}/source_files/cookie)" https://${PROXMOX_NAME}:8006/api2/json/nodes/pve/lxc | jq '.data[].vmid' | sort | tr '\n' ' ' | tr -d '"')

# Determine the first available CT_ID
for CT_ID in $(seq 950 999)
do
  if [[ ! "${NEW_LIST}" =~ "${CT_ID}" ]]
  then
    break
  fi
done


LAST_IP_BYTE=$((${CT_ID}-800))
HOSTNAME="oss-${CT_ID}.internal"


echo "Container ID: ${CT_ID}"
echo "Container IP: 192.168.102.${LAST_IP_BYTE}"
echo "Container hostname: ${HOSTNAME}"


OPERATION_PASSWORD=$(openssl rand -base64 48)
ANSIBLE_PASSWORD=$(openssl rand -base64 48)
ROOT_PASSWORD=$(openssl rand -base64 48)


# Create the container
ansible-playbook --extra-vars "host='${PROXMOX_NAME}' password='${PROXMOX_PASSWORD}' container='${CT_ID}' last_ip_byte='${LAST_IP_BYTE}' hostname='${HOSTNAME}' os='${OS}' root_password='${ROOT_PASSWORD}'" ${script_path}/playbooks/create_lxc_container.yaml


# Create ansible user into the container
ansible-playbook --extra-vars "host='${PROXMOX_NAME}'" ${script_path}/../install_ansible_ssh_keys/playbooks/list_and_register.yaml
ssh-keyscan ${HOSTNAME} >> ~/.ssh/known_hosts
ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 ansible@${HOSTNAME} 'exit 0'


# Add the new container into Ansible hosts file
echo "${HOSTNAME}" >> ${script_path}/retrieved_files/hostname_container.csv
sudo python3 ${script_path}/source_files/fill_ansible_hosts_file.py -f ${script_path}/retrieved_files/hostname_container.csv

# Install
ansible-playbook --extra-vars "host='${HOSTNAME} ansible_user=ansible os='${OS}' ansible_password='${ANSIBLE_PASSWORD}' operation_password='${OPERATION_PASSWORD}'" ${script_path}/playbooks/all_install_template.yaml


ansible-playbook --extra-vars "host='${HOSTNAME}' os='${OS}' ansible_password='${ANSIBLE_PASSWORD}' operation_password='${OPERATION_PASSWORD}' root_password='${ROOT_PASSWORD}' ip='${LAST_IP_BYTE}'" ${script_path}/playbooks/send_email.yaml

