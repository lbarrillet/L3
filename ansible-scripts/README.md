# Ansible Scripts

All Ansibles Scripts and Playbooks used by the Exploitation team.

### Structure

This Git repository has to be organized following this template:

    /ansible-scripts
    ├── do_something_1/
    |   ├── playbooks/         ==> Contains all playbooks used in this project.
    |   ├── remote_scripts/    ==> Contains all scripts to run on the remote machine.
    |   ├── retrieved_files/   ==> Contains all files retrieved from the remove machine.
    |   ├── source_files/      ==> Contains additional files used by run.sh to create the expected result
    |   └── run.sh             ==> Script to run
    |
    └── ...

### Rules

1. Do maximum playbooks and scripts that do not require root permission.
2. If you need root permission, speak with SysAdmin/DevOps team to try to find a solution not requiring root permission.
3. Create your playbooks following the official documentation : https://docs.ansible.com/ansible/latest/index.html
4. Verify your YAML syntax using this command : `ansible-playbook do_something_1.yml --syntax-check`
5. If you need to create scripts, avoid code replication.