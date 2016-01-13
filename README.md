# Red Hat Emerging Product Tools

##Openshift v3 tools
![Openshift icon](https://upload.wikimedia.org/wikipedia/en/3/3a/OpenShift-LogoType.svg)

### Overview

**Openshift v3 tools**, these tools are useful for who use Openshift v3.

#### * backup_ose3_repos.sh  (RHN Repository Backup Script)
 This shell script is for backup openshift v3 repositories. In order to test openshift v3, you should sync the environment of client but you can always install latest packages via yum. Therefore, you have to archieve essential packages for each version formatted by ISO file. With those ISO file, you are able to configure specific version of openshift v3. 
 
 
 
 ```
  Usage : backup_repos.sh (with root user)
  
  Necessary parameters that you should notice:
  RHEL_VERSION - Installed RHEL OS version  (ex) 7.1 or 7.2
  OSE_VERSION - Installed Openshift version (ex) 3.0 or 3.1
  ISO_DIRECTORY - Directory contained archieved ISO files.
  CLEAR - If you want to archieve different version of Openshift(3.0 -> 3.1), you should remove previous repositories. 
          Hence, you should set it to true.  
  IS_FIRST - If it is first time to run this script, you should set it to true.
             This will register your system to rhn-manager, enable repositories and create some folders. 
             Once you run it, you should set it to false.            
  USER - rhn login user id.(it should be changed when IS_FIRST set to true)
  PASSWORD - rhn login user password.(it should be changed when IS_FIRST set to true)
```

#### * ose_kvm_provision.sh  (Create KVM VMs for Openshift v3)
 This shell script is for creation of openshift v3 nodes. In order to install openshift v3, there should be several VMs. Using this script, you can easily set up VMs which have prerequite conditions. After you create those VMs, I strongly recommend to use [ansible-ose3-install](https://github.com/Jooho/ansible-ose3-install) which will help you change public ip and set up docker-pool and so on. Note: you should have basic pure os vm such as RHEL or CentOS. 
 
  ```
  Usage : ose_kvm_provision.sh -mode=clone -arch=max (with root user)
  
  Parameters:
  mode - clone : it start to clone basic vm to several VMs (master/node/etcd/infra/lb)
         clean : it remove all ose VMs from KVM
         force : it delete all vm images from $VM_PATH
         info  : it gather IP information from all created VMs, so normally it is used after clone.
         template : it changes IPs in inventory file which will be used for installation ose using  [ansible-ose3-install](https://github.com/Jooho/ansible-ose3-install)
  
  arch - max : 3xMaster, 3xNode, 3xETCD, 1xInfra, 1xLB
         mid : 3xMaster, 3xNode, 1xETCD, 1xInfra, 1xLB  (TBD)
         min : 1xMaster, 2xNode, 1xInfra     (TBD)
```

 
License
---
---
Licensed under the Apache License, Version 2.0

*Free Software*
