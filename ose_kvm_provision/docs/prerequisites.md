### Pre-requites

#### 1. Install KVM and some packages
  	
~~~
yum install virt-manager libvirt virt-viewer qemu-kvm sshpass wget git -y
~~~
  	
#### 2. Add new newtork on KVM

2.1. Create br1.xml 

~~~
<network>
  <name>br1</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <ip address='192.168.200.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.200.2' end='192.168.200.254'/>
    </dhcp>
  </ip>
</network>
~~~

2.2. Execute virsh to create the new network.

~~~
sudo virsh net-create br1.xml
~~~  	
  	
  	
#### 3. Download ISO files

If you don't have your own ISOs, please email me.(**if you are redhatter**)

#### 4. Get full_set_up_kvm.sh 

~~~
wget https://raw.githubusercontent.com/Jooho/rhep-tools/master/ose_kvm_provision/full_set_up_with_kvm.sh
~~~

#### 5. Create BASE Image (above rhel 7.1 'minimal')


