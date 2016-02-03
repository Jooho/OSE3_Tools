
# ose_kvm_provision
This project help you to set up complete Openshift test environment with KVM. Basically, this is written for Red Hat Consultant but anybody can use it if you have openshift subscription. (This is using iso files for RHEL, OSE because it is much faster than official repository)

## Descriptions: 


**ose_kvm_provision.sh**

	* clone mode
		* Clone kvm vms from base rhel images
		* Attach a new network on "br1" bridge to each vm for public ip
		* Attach a new storage disk for infra/nodes  	
	
	* info mode
		* Gather IP information from created VMs.
	
	* template mode
		* Create a inventory file based on IP information.

	* clean mode
		* Remove removed VMs (related with a architecture)


**get_ip.sh**

	* Get IP from VM
	

**full_set_up_with_kvm.sh**

	* Flow
		* Clone ansible-ose3-install
		* Clone rhep-tools
		* Copy setup.sh from ansible-ose3-install/shell to $pwd
		* Create VMs using ose_kvm_provision.sh
		* Get VM IPs and Create a inventory
		* Copy ISO files/setup.sh and all file under $pwd to master1 server.

	
**full_clean_up_with_kvm.sh**

	* Flow
		* Delete VMs which related with a architecture
		* Delete DISK vms for infra/nodes
		* Stop all VMs



##Getting Started

###[Pre-requites](https://github.com/Jooho/rhep-tools/blob/master/ose_kvm_provision/docs/prerequisites.md)

- Install KVM and some packages
- Add new newtork on KVM
- Download ISO files
- Get full_set_up_kvm.sh 
- Create BASE Image (above rhel7.1 'minial')

###[Installation doc](https://github.com/Jooho/rhep-tools/blob/master/ose_kvm_provision/docs/installation.md)

###[Troubleshooting doc](https://github.com/Jooho/rhep-tools/blob/master/ose_kvm_provision/docs/troubleshooting.md)

 
 
License
---

Licensed under the Apache License, Version 2.0

*Free Software*
