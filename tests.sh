# !/bin/bash

### Gather facts about the cluster ###
# Get the control node IP address from hosts file
HPC_CTRL_1_IP=$(grep hpc-control-1 hosts | awk '{print $1}')
NUM_NODES=$(wc -l < compute_nodes)

### Tests to confirm the HPC cluster is working ###
### Add tests below ###
printf "%s\n" "If you see a time and date stamp here, Congratulations! The cluster worked! Feel free to add you own tests."
# Get the time and date from the control node and all compute nodes
printf "%s\n" "Getting time and date from all nodes in the cluster:"
sshpass -p vagrant ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$HPC_CTRL_1_IP "srun --nodes=$NUM_NODES date"

# Get the hostname from all compute nodes
printf "%s\n" "Getting hostnames from all nodes in the cluster:"
sshpass -p vagrant ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$HPC_CTRL_1_IP "srun --nodes=$NUM_NODES hostname"