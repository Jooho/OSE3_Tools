. $OSEKVM_HOME_PATH/config/ose_kvm_config.sh 

cd $OSEKVM_HOME_PATH

function create_ose_kvm_br(){

  exist_ose_kvm_ose=$(sudo virsh net-list|grep ose_br)
  if [[ z$exist_ose_kvm_ose == z ]];then
    sudo virsh net-define $OSEKVM_HOME_PATH/config/ose_kvm_br.xml
    sudo virsh net-start ose_br
    sudo virsh net-autostart ose_br
    echo "ose bridge is created in KVM"
  else
    echo "ose bridge already exist"
  fi
}

for iii in $1 $2 $3
do
        if ( echo $iii | grep "\-arch" &> /dev/null )
        then
                c_arch=`echo $iii | awk -F "=" '{print $2}'`
                if [[ z$c_arch == z ]]; then
                        echo "usage : -arch=max  (mid,min)"
                        exit 1
                else
                        case ${c_arch} in
                            max)
                               vms=$MAX_ARCH
                                ;;
                            mid)
                                vms=$MID_ARCH
                                ;;
                            min)
                                vms=$MIN_ARCH
                                ;;
                            *)
                                echo "Unknown architecture - please select one of max,mid and min"
                         esac
                fi
        fi

        if (echo $iii | grep "\-mode"   &> /dev/null )
        then
            c_mode=`echo $iii | awk -F "=" '{print $2}'`
            if [[ z$c_mode == z ]]; then
              echo "usage : -mode=clone " 
              echo ""
              echo "Parameters:"
              echo "*mode - clone,info,template,clean,force"
              exit 1
            fi
        fi

        if (echo $iii | grep "\-template"   &> /dev/null )
        then
            c_template=`echo $iii | awk -F "=" '{print $2}'`
        fi

done
if [[ "$c_mode" == "clone" ]]; then
  create_ose_kvm_br

  for vm in $vms; do
        # Clone qcow2 file
        sudo virt-clone -o "$BASE_VM" --name $BASE_VM"_ose31_"$c_arch"_"$vm --auto-clone 
        sudo virsh start $BASE_VM"_ose31_"$c_arch"_"$vm

        # Attach a new network interface for public ip
        echo sudo virsh attach-interface --domain $BASE_VM"_ose31_"$c_arch"_"$vm --type network --source ose_br --target eth${ETH_NUM} --model virtio --config --live
        #sudo virsh attach-interface --domain $BASE_VM"_ose31_"$c_arch"_"$vm --type network --source ose_br --target eth${ETH_NUM} --model virtio --config --live
        sudo virsh attach-interface --domain $BASE_VM"_ose31_"$c_arch"_"$vm --type network --source ose_br --config --live

        # Attach a new disk for docker-pool to node vm
        if [[ $vm =~ "node" ]]; then
          #qemu-img create -f qcow2 myRHELVM1-disk2.qcow2 7G
          sudo dd if=/dev/zero of=$VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2" bs=1M count=${NODE_NEW_DEV_SIZE} 
          sudo virsh attach-disk  $BASE_VM"_ose31_"$c_arch"_"$vm  $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2" vdb --live --persistent
          #sudo virsh attach-disk  $BASE_VM"_ose31_"$c_arch"_"$vm  $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2" vdb 
        fi
        
        if [[ $vm =~ "infra" ]]; then
          #qemu-img create -f qcow2 myRHELVM1-disk2.qcow2 7G
          sudo dd if=/dev/zero of=$VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2" bs=1M count=${INFRA_NEW_DEV_SIZE} 
          sudo virsh attach-disk  $BASE_VM"_ose31_"$c_arch"_"$vm  $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2" vdb --live --persistent 
          #sudo virsh attach-disk  $BASE_VM"_ose31_"$c_arch"_"$vm  $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2" vdb 
        fi
        sleep 3
  done
  sudo virsh list
# Usage :
#        ose_kvm_provison.sh -mode=info -arch=min 
elif [[ "$c_mode" == "info" ]]; then
  if [[ -e $INFO_FILE ]]; then
    rm $INFO_FILE
  else
    touch $INFO_FILE
  fi

  for vm in $vms; do 
    ip_list=$($OSEKVM_HOME_PATH/bin/get_ip.sh $BASE_VM"_ose31_"$c_arch"_"$vm )
    for ip in $ip_list; do
      if [[ $ip =~ "192.168.200" ]]; then
        external_ip=$ip
      else 
        internal_ip=$ip
      fi
    done

    echo ${vm^^}_PRIVATE_IP=${internal_ip} >>$INFO_FILE
    echo ${vm^^}_PUBLIC_IP=${PUBLIC_IP_C_LEVEL}.${PUBLIC_START_IP} >>$INFO_FILE
    echo ${vm^^}_PUBLIC_GW_IP=${PUBLIC_IP_C_LEVEL}.1 >> $INFO_FILE

    PUBLIC_START_IP=$((PUBLIC_START_IP+1))
   done
#To-do
#Usage : 
#        ose_kvm_provison.sh -mode=template -arch=min 
# 

elif [[ "$c_mode" == "template" ]]; then
  export INVENTORY_FILE
  if [[ "$c_arch" == "max" ]]; then
    INVENTORY_FILE=production-master-ha-etcd-ha-lb-max.yaml
  elif [[ "$c_arch" == "mid" ]]; then
    INVENTORY_FILE=production-master-ha-etcd-ha-lb-mid.yaml
  else
    INVENTORY_FILE=production-master-2node.yaml
  fi
  
  # if you specify tempate, it will be overwrote.
  if [[ z"$c_template" != z ]]; then
    INVENTORY_FILE=$c_template
  fi

  cp $OSEKVM_HOME_PATH/template/${INVENTORY_FILE}.template $OSEKVM_HOME_PATH/${INVENTORY_FILE}

  for vm in $vms; do
    sed -e "s/%${vm^^}_PRIVATE_IP%/$(cat $INFO_FILE|grep ${vm^^}_PRIVATE_IP|cut -d'=' -f2)/g" -i $OSEKVM_HOME_PATH/${INVENTORY_FILE}
    sed -e "s/%${vm^^}_PUBLIC_IP%/$(cat $INFO_FILE|grep ${vm^^}_PUBLIC_IP|cut -d'=' -f2)/g" -i $OSEKVM_HOME_PATH/${INVENTORY_FILE}
    sed -e "s/%${vm^^}_PUBLIC_GW_IP%/$(cat $INFO_FILE|grep ${vm^^}_PUBLIC_GW_IP|cut -d'=' -f2)/g" -i $OSEKVM_HOME_PATH/${INVENTORY_FILE}
  done
  
  # Check if there are iso files for rhel, ose
  export OSE_ISO_FILE=$(ls $ISO_PATH |grep ose)
  export RHEL_ISO_FILE=$(ls $ISO_PATH |grep rhel)

  if [[ z$OSE_ISO_FILE != z ]] || [ z$RHEL_ISO_FILE != z ]]; then
    sed -e "s/%OSE_ISO_FILE%/${OSE_ISO_FILE}/g" -i $OSEKVM_HOME_PATH/${INVENTORY_FILE}
    sed -e "s/%RHEL_ISO_FILE%/${RHEL_ISO_FILE}/g" -i $OSEKVM_HOME_PATH/${INVENTORY_FILE}
  else
    echo " You need to set ISO_PATH variable in full_set_up_with_kvm.sh"
    exit 1
  fi

elif [[ "$c_mode" == "clean" ]]; then
    for vm in $vms; do
      sudo virsh shutdown $BASE_VM"_ose31_"$c_arch"_"$vm
      if [[ $vm =~ "node" ]]; then
       sudo virsh vol-delete --pool default $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2"
      # sudo  rm -rf $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2"
      fi

      if [[ $vm =~ "infra" ]]; then
        echo "Do you want to delete infra vm?(y/n)"
        read delete_vm
        if [[ $delete_vm == "y" ]]; then
          sudo virsh vol-delete --pool default $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm".qcow2"
          sudo virsh undefine $BASE_VM"_ose31_"$c_arch"_"$vm 
        else
          echo "infra remain"
        fi
      else
        sudo virsh vol-delete --pool default $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm".qcow2"
        sudo virsh undefine $BASE_VM"_ose31_"$c_arch"_"$vm 
      fi
    done

elif [[ "$c_mode" == "force" ]]; then
  sudo rm -rf $VM_PATH/*${c_arch}*
else
  echo "Unknown mode - please select one of clone,info,clean,template,force"
fi


