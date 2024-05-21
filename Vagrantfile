# Tested on current (as of creation) version of Vagrant
Vagrant.require_version ">= 2.3.4"

# Configure variables; change these based on how large of a stack you want.
CONTROL = 3
NODES = 5
IP = :"192.168.56.1" # This will create machines with IPs of 10.0.0.1+i e.g. hpc-control-1 = 10.0.0.11, hpc-control-2 = 10.0.0.12, etc...

if File.exist?('hosts')
    File.delete('hosts')
end

Vagrant.configure("2") do |config|
    config.vm.box = "generic/rocky9"
    config.vm.provision "shell", inline: <<-SHELL
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
        systemctl restart sshd.service
        SHELL

    (1..CONTROL).each do |i| 
        config.vm.define "hpc-control-#{i}" do |control|
            control.vm.provider "virtualbox" do |vb|
                vb.name = "hpc-control-#{i}"
                vb.memory = 2048
                vb.cpus = 2
            end
            control.vm.hostname = "hpc-control-#{i}"
            control.vm.network "private_network", ip: "#{IP}" + "#{i}"
            # echo hostname + IP to a Hosts file to copy to machines; the next line is ruby
            File.write('./hosts', "#{IP}" + "#{i}" + "\t" + "hpc-control-#{i}" + "\n", mode: 'a')
        end
    end

    i = 0

    (1..NODES).each do |i|
        config.vm.define "hpc-node-#{i}" do |node|
            node.vm.provider "virtualbox" do |vb|
                vb.name = "hpc-node-#{i}"
                vb.memory = 2048
                vb.cpus = 2
            end
            node.vm.hostname = "hpc-node-#{i}"
            node.vm.network "private_network", ip: "#{IP}" + "#{CONTROL + i}" # Add the number of control nodes to IP assignment so that we do not overlap
            # echo hostname + IP to a Hosts file
            File.write('./hosts', "#{IP}" + "#{CONTROL + i}" + "\t" + "hpc-node-#{i}" + "\n", mode: 'a')
        end
    end
end