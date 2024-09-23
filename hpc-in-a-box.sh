#!/bin/bash

### Check prequisites ###
# Make sure the software is installed
echo "Running prechecks..."
vagrant --version || (echo "Whoops! Can't find Vagrant. Is it installed?"; exit)
ansible --version || (echo "Whoops! Can't find Ansible. Is it installed?"; exit)
vboxmanage --version || (echo "Whoops! Can't find VirtualBox. Is it installed?"; exit)
echo "Completed prechecks."

### Generate VMs in virtulbox ###
# Run vagrantfile
vagrant up || echo "Whoops! Something went wrong. Is the Vagrantfile in your current working directory?"

### Process output from VirtualBox ###
# Make executable the inventory creation script
chmod +x ./create_inventories.sh
# Call another script to create the Ansible inventory and control_node list
/bin/bash ./create_inventories.sh

### Configure Controllers and Nodes with Ansible ###
# Configure common items on all guests; baseline software, nfs, firewall, etc
ansible-playbook -i inventory ./playbooks/common.yaml
# Configure controller
ansible-playbook -i inventory ./playbooks/control.yaml
# Configure nodes
ansible-playbook -i inventory ./playbooks/node.yaml
# Configure Slurm
ansible-playbook -i inventory ./playbooks/slurm_init.yaml

### Run some tests to confim ###
# Run a test
printf "%s\n" "If you see a time and date stamp here, Congratulations! The cluster worked! Feel free to add you own tests."
NUM_NODES=$(wc -l < compute_nodes)
sshpass -p vagrant ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@hpc-control-1 "srun --nodes=$NUM_NODES date"; exit
# More tests under here