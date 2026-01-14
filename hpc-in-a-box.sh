#!/bin/bash

### Check prequisites ###
# Which Linux distro are we on?
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Can't determine Linux distro. Exiting."
    exit 1
fi

# Determine package manager
if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    PKG_MGR="apt"
elif [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ] || [ "$DISTRO" == "fedora" ]; then
    PKG_MGR="yum"
else
    echo "Unsupported Linux distro: $DISTRO. Exiting."
    exit 1
fi

# Make sure the software is installed
echo "Running prechecks..."
echo "Checking for vagrant..."
vagrant --version 2&> /dev/null && echo -e "\e[32m pass\e[0m" || { echo -e "\e[31m faileds\e[0m Try: $PKG_MGR install vagrant"; exit 1; }
echo "Checking for ansible..."
ansible --version 2&> /dev/null && echo -e "\e[32m pass\e[0m"|| { echo -e "\e[31m faileds\e[0m Try: $PKG_MGR install ansible"; exit 1; }
echo "Checking for VirtualBox..."
vboxmanage --version 2&> /dev/null && echo -e "\e[32m pass\e[0m"|| { echo -e "\e[31m faileds\e[0m Try: $PKG_MGR install ansible?"; exit 1; }
echo "Checking for sshpass..."
sshpass -V 2&> /dev/null && echo -e "\e[32m pass\e[0m"|| { echo -e "\e[31m failed\e[0m \n Try: $PKG_MGR install sshpass"; exit 1; }
echo "Completed prechecks."

### Generate VMs in virtulbox ###
# Run vagrantfile
echo "Bringing up Vagrant VMs. This may take a few minutes..."
vagrant up || { echo "Something went wrong. Is the Vagrantfile in your current working directory?"; exit 1; }

### Process output from VirtualBox ###
echo "Checking for inventory creation script..."
if [ ! -f ./create_inventories.sh ]; then
    echo "Inventory creation script not found! Exiting."
    exit 1
fi
if [ -x ./create_inventories.sh ]; then
    echo "Inventory creation script is executable."
else
    echo "Making inventory creation script executable."
    chmod +x ./create_inventories.sh
fi
# Call another script to create the Ansible inventory and control_node list
echo "Generating inventories..."
/bin/bash ./create_inventories.sh

### Configure Controllers and Nodes with Ansible ###
echo "Configuring the cluster with Ansible. This may take a few minutes..."
# Configure common items on all guests; baseline software, nfs, firewall, etc
ansible-playbook -i inventory ./playbooks/common.yaml
# Configure controller
ansible-playbook -i inventory ./playbooks/control.yaml
# Configure nodes
ansible-playbook -i inventory ./playbooks/node.yaml
# Configure Slurm
ansible-playbook -i inventory ./playbooks/slurm_init.yaml

### Run some tests to confim ###
# Get the control node IP address from hosts file
HPC_CTRL_1_IP=$(grep hpc-control-1 hosts | awk '{print $1}')
# Is the tests file executable?
if [ ! -x ./tests.sh ]; then
    echo "Making tests script executable."
    chmod +x ./tests.sh
fi
# Run a test
echo "Running test jobs..."
/bin/bash ./tests.sh
# Done
echo "HPC cluster setup is complete."