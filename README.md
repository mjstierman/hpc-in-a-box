## Introduction
The purpose of this project is to create a self-contained HPC (High Performance Compute) system by executing a single script. The project will use Vagrant to deploy the virtual servers into VirtualBox and Ansible to configure the servers. </br>
This was built on an x86_64 Fedora 40 workstation; it is untested against Windows, MacOS, other Linux, or alternate architectures. To run on Windows, you will need to [instal WSL](https://learn.microsoft.com/en-us/windows/wsl/install) to run the shell script.

## Prerequisites
To run this script, you will need the following installed on your computer:
<ul>
  <li>Ansible</li>
  <li>Vagrant</li>
  <li>VirtualBox</li>
  <li>Internet Connection</li>
</ul>

## How to use
<ol>
  <li>Ensure the prerequisites are met</li>
  <li>`dnf install -y ansible vagrant virtualbox`</li>
  <li>Clone this repository</li>
  <li>`git clone https://github.com/itsramen/hpc-in-a-box.git`
  <li>Change to repo directory</li>
  <li>`cd hpc-in-a-box`</li>
  <li>Ensure the script is executable</li>
  <li>`chmod u+x hpc-in-a-box.sh`</li>
  <li>Run the script</li>
  <li>`./hpc-in-a-box.sh`</li>
</ol>

## Notes
Some general notes. Kind of an FAQ.
#### Design decisions
- To change the number of controllers and nodes, change the variables located at the top of Vagrantfile
- While you can have as many controllers and nodes as you like, changing physical deployment, especially CPU count, will break the script. If you change the number of controllers, destroy and recreate the environment.
- Only the first controller will have NFS sharing enabled and be an actual controller. The rest will simply mount the share just as the nodes do.
- This assumes all machines are identical as configured. 
- The Ansible config defaults to 7 forks. CPUs with 8 threads is very common, so n-1 would be 7. You can set this to n-1 threads you have avaiable in the `ansible.cfg` file.
#### Security Considerations
- Security was not a consideration for this project. This is meant to be a portable POC. There are baked-in usernames and passwords, and the firewall is disabled. This would never be done in an enterprise environment.</br>
- NOTE: In a future release, I may extract the keys from Vagrant and import those into Ansible for orchestration.</br>
- NOTE2: The exception to the above is that the munge key is generated on cluster created and treated sanely.
#### Software versioning
- Ideally the various software installs would be pegged to a specific version; more ideally in a local repo or build pipeline. Again, as a standalone cluster, it's designed to be built all at once, ergo pulling from the same :latest package available.
#### Other operating systems
- This is not tested in Windows, but should work as long as the Ansible, Vagrant, and VirtualBox binaries are accessible by the script.


## Contributing
Contributions are not accepted at this time. This repo is for demonstrative purposes only and is not monitored.
