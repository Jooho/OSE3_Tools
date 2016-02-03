### Installation

#### Step 1: Change essencial parameters accorinding to your environment.

ose_kvm_provision.sh

~~~

 # The name of base name which will be cloned.
export BASE_VM="RHEL_7U1"

 #The location where cloned images are stored.
export VM_PATH="/home/jooho/dev/REDHAT_VM"

 # The size for docker-storage on Node 1024/5120/10240 ==> 1G/5G/11G
export NODE_NEW_DEV_SIZE=5120 

 # The size for NFS server on infra(it will be used for docker registry and pv)
export INFRA_NEW_DEV_SIZE=10240  #1024/5120/10240 ==> 1G/5G/11G, this will be used for NFS¬

~~~

full_set_up_provision.sh

~~~
 # The folder where ISO files are.
export ISO_PATH=/home/jooho/dev/OSE_REPO_ISO/rhel7u1_ose3u1_151125
~~~


#### Step 2 : Check files

~~~
# ls -al
-rwxrwxr-x  1 jooho jooho 2.5K Jan 31 21:18 full_set_up_with_kvm.sh*
-rw-r--r--  1 jooho jooho 217M Feb  1 17:47 ose-3.1-x86_64-151125.iso
-rw-r--r--  1 jooho jooho 3.7G Feb  1 17:47 rhel-server-7.1-x86_64-151125.iso
~~~

#### Step 3 : Execute full_set_up_with_kvm.sh   (refer [README.md](https://github.com/Jooho/rhep-tools))

~~~
./full_set_with_kvm.sh max
..
..
 Id    Name                           State
----------------------------------------------------
 12    RHEL_7U2-Internal-repository   running
 13    RHEL_7U1-docker-repository     running
 14    RHEL_7U1_ose31_max_infra       running
 15    RHEL_7U1_ose31_max_lb          running
 16    RHEL_7U1_ose31_max_master1     running
 17    RHEL_7U1_ose31_max_master2     running
 18    RHEL_7U1_ose31_max_master3     running
 19    RHEL_7U1_ose31_max_etcd1       running
 20    RHEL_7U1_ose31_max_etcd2       running
 21    RHEL_7U1_ose31_max_etcd3       running
 22    RHEL_7U1_ose31_max_node1       running
 23    RHEL_7U1_ose31_max_node2       running
 24    RHEL_7U1_ose31_max_node3       running

Please wait to be stable...
40.. 39.. 38.. 37.. 36.. 35.. 34.. 33.. 32.. 31.. 30.. 29.. 28.. 27.. 26.. 25.. 24.. 23.. 22.. 21.. 20.. 19.. 18.. 17.. 16.. 15.. 14.. 13.. 12.. 11.. 10.. 9.. 8.. 7.. 6.. 5.. 4.. 3.. 2.. 1.. OK MOVE ON
**Type password for root of vm(redhat):redhat    <----Type here then enter!**
sshpass -p redhat ssh -q root@192.168.124.137 'mkdir -p /root/ose'
sshpass -p redhat scp full_clean_up_with_kvm.sh root@192.168.124.137:/root/ose/.
sshpass -p redhat scp full_set_up_with_kvm.sh root@192.168.124.137:/root/ose/.
sshpass -p redhat scp ose31_kvm_info.txt root@192.168.124.137:/root/ose/.
sshpass -p redhat scp ose-3.1-x86_64-151125.iso root@192.168.124.137:/root/ose/.
sshpass -p redhat scp production-master-ha-etcd-ha-lb.yaml root@192.168.124.137:/root/ose/.
sshpass -p redhat scp rhel-server-7.1-x86_64-151125.iso root@192.168.124.137:/root/ose/.
sshpass -p redhat scp test.sh root@192.168.124.137:/root/ose/.


NEXT STEP:
After you connect to master server, go to ose folder then execute setup.sh
cd ose;./setup.sh production-master-ha-etcd-ha-lb.yaml

Now it is connecting to master1 server
root@192.168.124.137's password:    <==Type this then enter 
Last login: Sat Jan  9 16:03:41 2016
[root@localhost ~]#     
~~~

#### Step 4 : Execute ansible-ose3-script on master 1 server.

~~~
[root@localhost ~]# cd ose;./setup.sh production-master-ha-etcd-ha-lb.yaml
Do you want to go through from the beginning?(y/n) (or just start to install)
y  <--- Type y at first time

..
..
Complete!
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): <-- Enter
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase):    <-- Enter 
Enter same passphrase again:     <-- Enter
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
24:9d:04:03:33:a2:05:50:e4:d5:10:bf:a4:dd:9a:88 root@localhost.localdomain
The key's randomart image is:
+--[ RSA 2048]----+
|++= B=o..        |
| + o +.+ .       |
|. .   + +        |
|     + =         |
|    . o S        |
|   . . o         |
|  E . o          |
|                 |
|                 |
+-----------------+
Do you want to copy id_rsa.pub file to all machines with 1 password?(y/n)y  <--- Type y at first time
Type password : redhat    <-- Type root password for vm
...
...
Cloning into 'ansible-ose3-install'...
remote: Counting objects: 654, done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 654 (delta 4), reused 0 (delta 0), pack-reused 636
Receiving objects: 100% (654/654), 87.54 KiB | 0 bytes/s, done.
Resolving deltas: 100% (295/295), done.
 [WARNING]: It is unnecessary to use '{{' in conditionals, leave variables in
loop expressions bare.
..
~~~


