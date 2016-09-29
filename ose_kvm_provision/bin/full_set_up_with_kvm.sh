. $RHEP_HOME_PATH/ose_kvm_provision/config/ose_kvm_config.sh

#Check architecture
c_arch=$1
valid=false
for arch in min mid max;
do
  if [[ $c_arch == $arch ]]; then
     valid=true 
  fi
done

if [[ z$c_arch ==  "z" ]]  || [[ $valid != "true" ]]  ; then
  echo "usage : ./full_set_up_with_kvm.sh max (mid,min)"
  echo "or"
  echo "usage : ./full_set_up_with_kvm.sh max (mid,min) ose-smart-start.yaml"
  echo " \$1 : architecture "
  echo " \$2 : template  (must be under rhep-tools/ose_kvm_provision/template and looks like
  ose-smart-start,yaml.template) "
  exit 1
fi

# Check if specific template exist
if [[ z$2 != z ]]
then
  c_template=$2
  file_exist=$(ls $RHEP_HOME_PATH/ose_kvm_provision/template/${c_template}.template)
  if [[ $? == 1 ]] ;then
    exit 1
  fi
fi


# Check if generating public key is needed
echo -e "Do you want to go through from the creating VMs?(y/n) (or start from copying files)"
read need_populating_kvm_vm

if [ $need_populating_kvm_vm  == "y" ];
then
#    if [[ -e ./ansible-ose3-install ]]; then
#      echo "* ansible-ose3-install is already cloned so I will pull it"
#      cd ./ansible-ose3-install; git pull; cd ..
#    else
#      echo "* ansible-ose3-install is not here so I will clone it"
#      git clone https://github.com/Jooho/ansible-ose3-install
#    fi  
    echo "Download setup.sh from github.com/Jooho/shell/setup.sh"
    curl https://raw.githubusercontent.com/Jooho/ansible-ose3-install/master/shell/setup.sh > ./setup.sh
    chmod 777 ./setup.sh

    if [[ -e ./rhep-tools ]]; then
      echo "* rhep-tools is already cloned so I will pull it"
      cd ./rhep-tools; git pull origin master; cd .. 
    else
      echo "* rhep-tools is not there so I will clone it"
      git clone https://github.com/Jooho/rhep-tools
    fi
   
   
    #Create KVM VMs according to architecture
    if [[ z$c_template == z ]]; then
       $OSEKVM_HOME_PATH/bin/ose_kvm_provision.sh -mode=clone -arch=$c_arch
    else
       $OSEKVM_HOME_PATH/bin/ose_kvm_provision.sh -mode=clone -arch=$c_arch -template=$c_template
    fi 

    echo Please wait to be stable...
    for i in {40..1}; 
    do
      echo -n "${i}.. "
      sleep 1
    done
    echo "OK MOVE ON"

    #sleep 40
    rm -rf ./*.txt
    rm -rf ./*yaml
     if [[ z$c_template == z ]]; then
      $OSEKVM_HOME_PATH/bin/ose_kvm_provision.sh -mode=info -arch=$c_arch
      $OSEKVM_HOME_PATH/bin/ose_kvm_provision.sh -mode=template -arch=$c_arch
    else
      $OSEKVM_HOME_PATH/bin/ose_kvm_provision.sh -mode=info -arch=$c_arch -template=$c_template
      $OSEKVM_HOME_PATH/bin/ose_kvm_provision.sh -mode=template -arch=$c_arch -template=$c_template
    fi 
   
    # Copy inventory file & ip information txt file.
    echo "Copy information files to $PWD"
    mv $OSEKVM_HOME_PATH/*.yaml .
    mv $OSEKVM_HOME_PATH/*.txt .
   
    echo ""
    #Copy ISO files to master1 server 
    echo "Copy iso files to $PWD"
    cp -R $ISO_PATH/* .
   
    #Clean up known_host(delete IPs start with 192.168.124.200)
    mv ~/.ssh/known_hosts  ~/.ssh/known_hosts_$(date +%Y%m%d%H%M%S)    #backup
    sed '/^192\.168\.124\|200/d' ~/.ssh/known_hosts > ~/.ssh/known_hosts

  fi

   # master_ip=$(grep MASTER1_PRIVATE_IP ./ose31_kvm_info.txt|cut -d"=" -f2)
    master_ip=$(grep MASTER2_PRIVATE_IP ./ose31_kvm_info.txt|cut -d"=" -f2)
    echo -e "Type password for root of vm(redhat): \c"
    read password
    echo "sshpass -p $password ssh -q root@$master_ip 'mkdir -p /root/ose'"
    sshpass -p $password ssh -o StrictHostKeyChecking=no -q root@$master_ip 'mkdir -p /root/ose'
   
    for file in ./*; do
    #if ([ -f $file ] && [ ${file##*.} != "sh" ]); then
     if [[ -f $file ]] && [[ ! $file =~ "full" ]] && [[ ! $file =~ "command" ]]; then
        echo sshpass -p $password scp $(basename $file) root@$master_ip:/root/ose/.
        sshpass -p $password scp -o StrictHostKeyChecking=no $(basename $file) root@$master_ip:/root/ose/.
      fi
    done
    echo ""
    echo ""
    echo "NEXT STEP:"
    echo "After you connect to master server, go to ose folder then execute setup.sh"
    echo "cd ose;./setup.sh $(ls ./ |grep *.yaml)"
    echo ""
    echo "Now it is connecting to master1 server"
    ssh root@$master_ip
