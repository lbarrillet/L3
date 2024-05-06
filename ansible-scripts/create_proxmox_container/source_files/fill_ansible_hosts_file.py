#!/usr/bin/python3

import pathlib
import argparse
import sys

parser = argparse.ArgumentParser(
    prog=sys.argv[0],
    add_help=True
)
parser.add_argument('-f',
                    action='store',
                    dest='hostname_csv',
                    required=True,
                    help='CSV file containing all hostnames to add to ansible hosts file.')
args_parsed = parser.parse_args()

Dictionnary = {}

section_name = "containers_europe"

with open("/etc/ansible/hosts", "r") as file:
    for line in file:
        if line.startswith("\n"):
            continue
        if line.startswith("["):
            Table = []
            Section = line[1:line.index("]")]
            Dictionnary[Section] = Table
            continue
        Table.append(line.rstrip('\n'))

# Récupérer le fichier hostname_containers.csv en argument du script python.

srv = open(args_parsed.hostname_csv, 'r')
data = srv.read()
hostnames_list = list(set(data.split("\n")))
srv.close()

for element in hostnames_list:
    new_ansible_host = True
    if element != "":
        for entry in Dictionnary[section_name]:
            if element in entry:
                new_ansible_host = False
                break
        if new_ansible_host:
            Dictionnary[section_name].append(f"{element} ansible_user=4n51bl3")

with open('/etc/ansible/hosts', 'w') as file:
    for key, value in Dictionnary.items():
        file.write('\n' + '[' + key + ']' + '\n')
        for ligne in value:
            if ligne != '':
                file.write(ligne + '\n')

