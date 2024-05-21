# Read the hosts file from Vagrant
input_file="hosts"

# Initialize an empty array
declare -a hosts_array
declare -a ip_array

# Read the input file line by line
while IFS=$'\t' read -r col1 col2; do
    # Add the data to the array
    ip_array+=("$col1")
    hosts_array+=("$col2")
done < "$input_file"

### Create the Ansible inventory file ###
# Remove any previous config
test -f ./inventory && rm ./inventory

# Define Ansible configs and set up structure
touch inventory
cat >> inventory<< EOF
[all:vars]
ansible_connection=ssh
ansible_user=vagrant
ansible_password=vagrant
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

EOF

# Add controllers to [hpc_control] group
printf "[hpc_control]\n" >> inventory
count=$(wc -l < hosts)
for c in $(seq 0 $((count-1))); do
    if [[ "${hosts_array[$c]}" = hpc-control* ]]; then
        printf ${ip_array[$c]} >> inventory
        printf "\n" >> inventory
    fi
done

# Add nodes to [hpc_node] group
printf "[hpc_node]\n" >> inventory
count=$(wc -l < hosts)
for c in $(seq 0 $((count-1))); do
    if [[ "${hosts_array[$c]}" = hpc-node* ]]; then
        printf ${ip_array[$c]} >> inventory
        printf "\n" >> inventory
    fi
done

### Create Slurm compute_nodes file ###
# Remove any previous config
test -f ./compute_nodes && rm ./compute_nodes
count=$(wc -l < hosts)
for c in $(seq 0 $((count-1))); do
    if [[ "${hosts_array[$c]}" != hpc-control* ]]; then
        printf "NodeName="${hosts_array[$c]}" NodeAddr="${ip_array[$c]}" CPUs=2 State=UNKNOWN \n" >> compute_nodes
    fi
done