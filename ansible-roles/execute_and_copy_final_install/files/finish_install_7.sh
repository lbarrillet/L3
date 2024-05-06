#!/usr/bin/env bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
LINE="_____________________________________________________________________________________"
FLECHE='\033[0;32m\xe2\x86\x92\033[0m'

declare -r OK=1
declare -r ALREADY_EXIST=2
declare -r ERROR=3
declare -r NOT_EXIST=4

# affichage des log
function display_log() {
    if [ -n "$1" ] && [ -n "$2" ]
    then
        if [ "$1" == OK ]
        then
            echo -e "${LINE} [ ${GREEN}OK${NC} \xE2\x9C\x94 ]\r  $FLECHE $2"
        elif [ "$1" == ALREADY_EXIST ]
        then
            echo -e "${LINE} [ ${YELLOW}ALREADY DONE${NC} \xE2\x9C\x94 ]\r  $FLECHE $2"
        elif [ "$1" == NOT_EXIST ] || [ "$1" == ERROR ]
        then
            echo -e "${LINE} [ ${RED}ERROR${NC} \xe2\x9c\x97 ]\r  $FLECHE $2"
        fi
    fi
}

echo ""
echo "Script lancé seulement à la première connexion d'un nouvel utilisateur :"

if [ ! -d /data/services ]
then
    mkdir --parents /data/services
    chmod --recursive 775 /data
    if chown -R $1:dev /data
    then
        display_log OK "Création et ajout des droits de $1 sur /data : "
    else
        display_log ERROR "Création et ajout des droits de $1 sur /data : "
        exit 3
    fi
fi

until [ ! -z "$passwd" ]
do
    printf "    ${YELLOW}Veuillez entrer le mot de passe LDAP de $1 ${NC}: "
    read -r -s passwd
done
printf "${YELLOW}"
echo -ne "$passwd\n$passwd\n" | smbpasswd -s -a $1
printf "${NC}"

# Ne pas ajouter automatiquement les autres utilisateurs
# Permet de contrôler les accès.
if grep -q xxxxxxxxxxx /etc/samba/smb.conf
then
    sed --in-place "s/xxxxxxxxxxx/$1/g" /etc/samba/smb.conf
else
    sed --in-place "/valid users/ s/$/ $1/g" /etc/samba/smb.conf
fi

if systemctl restart smb
then
    display_log OK "Redémarrage de samba : "
else
    display_log ERROR "Redémarrage de samba : "
    exit 3
fi

if [ $(pdbedit -L | grep $1 | wc -l) -eq 1 ]
then
    display_log OK "Vérification de l'utilisateur samba $1 : "
else
    display_log ERROR "Vérification de l'utilisateur samba $1 : "
    exit 3
fi

# Capabilities are stored in inodes.
if setcap cap_net_raw+p /bin/ping && setcap cap_net_raw+p /usr/bin/ping
then
    display_log OK "Autorisation de la commande ping pour les utilisateur non-root : "
else
    display_log ERROR "Autorisation de la commande ping pour les utilisateur non-root : "
    exit 3
fi

# Correction of incorrectly installed packages
printf "${LINE} [ .... ]\r  $FLECHE Récupération de la liste des paquets mal installés : \r"
REINSTALL_PKG="$(rpm --verify --all --nofiledigest --nosize | grep -v /usr/src/kernels | grep -E '^.{8}P' | awk '{ print $2 }' | while read -r corrupted_binary; do rpm --query --whatprovides "${corrupted_binary}"; done | sort | uniq)"
if [ -n "${REINSTALL_PKG}" ]
then
    printf "${LINE} [ ${GREEN}OK${NC} \xE2\x9C\x94 ]\r  $FLECHE Récupération de la liste des paquets mal installés : \n"
    printf "${LINE} [ .... ]\r  $FLECHE Correction des paquets mal installés par Proxmox : \r"
    if yum reinstall --quiet --assumeyes --nogpgcheck ${REINSTALL_PKG}
    then
        printf "${LINE} [ ${GREEN}OK${NC} \xE2\x9C\x94 ]\r  $FLECHE Correction des paquets mal installés par Proxmox : \n"
    else
        printf "${LINE} [ ${RED}ERROR${NC} \xe2\x9c\x97 ]\r  $FLECHE Correction des paquets mal installés par Proxmox : \n"
        exit 3
    fi
else
    printf "${LINE} [ ${GREEN}VIDE${NC} ]\r  $FLECHE Récupération de la liste des paquets mal installés : \n"
fi

mkdir /home/$1/.ssh/
nomcomplet=$(getent passwd "$1" | cut -d ':' -f 5)

if ssh-keygen -t ed25519 -f /home/$1/.ssh/id_ed25519 -q -N ""
then
    display_log OK "Création d'une clé SSH pour l'utilisateur $1 : "
    if [ $(ls -al /home/$1/.ssh/ | grep "id_ed25519" | wc -l) -eq 2 ]
    then
        echo -e "    ${GREEN}Félicitations $nomcomplet, votre clé SSH a été générée !${NC}"
        echo "    $(cat /home/$1/.ssh/id_ed25519.pub)"
        echo -e "    ${GREEN}Vous pouvez désormais l'ajouter à votre compte gitlab :${NC} http://gitlab.ives.fr/profile/keys"
        echo -e "    ${GREEN}Pour vous connecter à votre serveur, veuillez désormais utiliser l'identifiant $1 (ex: ssh $1@$(hostname))${NC}"
        echo -e "    ${GREEN}Des commandes propres à IVèS existent : elles vous feront gagner du temps ! Vous pouvez les découvrir avec la commande : ${YELLOW}ives-help${NC}"
    fi
else
    display_log ERROR "Création d'une clé SSH pour l'utilisateur $1 : "
    exit 3
fi

touch /home/$1/.ssh/authorized_keys
if chown -R $1:dev /home/$1
then
    display_log OK "Ajout des droits sur /home/$1 à l'utilisateur $1 : "
else
    display_log ERROR "Ajout des droits sur /home/$1 à l'utilisateur $1 : "
    exit 3
fi

ipaddr=$(hostname -i)

echo -e "${GREEN}Vous pouvez aussi utiliser votre montage samba, accessible à l'adresse suivante :${NC} smb://$ipaddr/services"
echo -e "Login    : $1"
echo -e "Password : le mot de passe que vous venez de saisir"
