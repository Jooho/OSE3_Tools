export BASE_VM="RHEL_7U1"
export VM_PATH="/home/jooho/dev/REDHAT_VM"
export MAX_ARCH="infra lb master1 master2 master3 etcd1 etcd2 etcd3 node1 node2 node3"
export MID_ARCH="infra lb master1 master2 master3 node1 node2 node3 node4 node5 "
export MIN_ARCH="infra master1 node1 node2 "
export ISO_PATH=/home/jooho/dev/OSE_REPO_ISO/rhel7u1_ose3u1_151125
export NODE_NEW_DEV_SIZE=5120  #1024/5120/10240 ==> 1G/5G/11G
export INFRA_NEW_DEV_SIZE=10240  #1024/5120/10240 ==> 1G/5G/11G, this will be used for NFS
export PUBLIC_IP_C_LEVEL="192.168.200"   #Depend on bridge ip range
export PUBLIC_START_IP=100
export vms
export INFO_FILE="ose31_kvm_info.txt"
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
              echo "*mode - clone,info,template,clean.force"
              exit 1
            fi
        fi
done
if [[ "$c_mode" == "clone" ]]; then
  for vm in $vms; do
        # Clone qcow2 file
        sudo virt-clone -o "$BASE_VM" --name $BASE_VM"_ose31_"$c_arch"_"$vm --auto-clone 
        sudo virsh start $BASE_VM"_ose31_"$c_arch"_"$vm

        # Attach a new network interface for public ip
        echo sudo virsh attach-interface --domain $BASE_VM"_ose31_"$c_arch"_"$vm --type network --source br1 --target eth${ETH_NUM} --model virtio --config --live
        #sudo virsh attach-interface --domain $BASE_VM"_ose31_"$c_arch"_"$vm --type network --source br1 --target eth${ETH_NUM} --model virtio --config --live
        sudo virsh attach-interface --domain $BASE_VM"_ose31_"$c_arch"_"$vm --type network --source br1 --config --live

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
    ip_list=$(./get_ip.sh $BASE_VM"_ose31_"$c_arch"_"$vm )
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
    INVENTORY_FILE=production-master-ha-etcd-ha-lb.yaml
  elif [[ "$c_arch" == "mid" ]]; then
    INVENTORY_FILE=production-master-ha-lb.yaml
  else
    INVENTORY_FILE=production-master-ha-etcd-ha-lb.yaml
  fi

  cp ./template/${INVENTORY_FILE}.template ./${INVENTORY_FILE}

  for vm in $vms; do
    sed -e "s/%${vm^^}_PRIVATE_IP%/$(cat $INFO_FILE|grep ${vm^^}_PRIVATE_IP|cut -d'=' -f2)/g" -i ./${INVENTORY_FILE}
    sed -e "s/%${vm^^}_PUBLIC_IP%/$(cat $INFO_FILE|grep ${vm^^}_PUBLIC_IP|cut -d'=' -f2)/g" -i ./${INVENTORY_FILE}
    sed -e "s/%${vm^^}_PUBLIC_GW_IP%/$(cat $INFO_FILE|grep ${vm^^}_PUBLIC_GW_IP|cut -d'=' -f2)/g" -i ./${INVENTORY_FILE}
  done
  
  # Check if there are iso files for rhel, ose
  export OSE_ISO_FILE=$(ls $ISO_PATH |grep ose)
  export RHEL_ISO_FILE=$(ls $ISO_PATH |grep rhel)

  if [[ z$OSE_ISO_FILE != z ]] || [ z$RHEL_ISO_FILE != z ]]; then
    sed -e "s/%OSE_ISO_FILE%/${OSE_ISO_FILE}/g" -i ./${INVENTORY_FILE}
    sed -e "s/%RHEL_ISO_FILE%/${RHEL_ISO_FILE}/g" -i ./${INVENTORY_FILE}
  else
    echo " You need to set ISO_PATH variable in full_set_up_with_kvm.sh"
    exit 1
  fi

elif [[ "$c_mode" == "clean" ]]; then
    for vm in $vms; do
      sudo virsh shutdown $BASE_VM"_ose31_"$c_arch"_"$vm
      if [[ $vm =~ "node" ]]; then
        #sudo virsh vol-delete --pool default $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2"
       sudo  rm -rf $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm"_disk.qcow2"
      fi

      sudo virsh vol-delete --pool default $VM_PATH/$BASE_VM"_ose31_"$c_arch"_"$vm".qcow2"
      sudo virsh undefine $BASE_VM"_ose31_"$c_arch"_"$vm 
    done

elif [[ "$c_mode" == "force" ]]; then
  sudo rm -rf $VM_PATH/*ose*
else
  echo "Unknown mode - please select one of clone,info,clean,force"
fi




