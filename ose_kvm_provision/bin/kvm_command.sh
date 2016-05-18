 
VMS=$(sudo virsh list --all|grep  $1 |awk '{print $2}');
VMS_WC=$(sudo virsh list --all| grep $1|awk '{print $2}'|wc -l);
TEMP_FILE=temp_running_vms.txt

#if [[ $VMS_WC == 1 ]] && [[ -e $TEMP_FILE ]];
#then
#    VMS=$(cat ./$TEMP_FILE)
#elif [[ $VMS_WC == 1 ]] && [[ ! -e $TEMP_FILE ]];
#then
#    echo "no information so please start every vms manually"
#fi

#if [[ ! -e $TEMP_FILE ]];
#then
#    touch ./$TEMP_FILE
#    echo "#EMPTY" >> ./$TEMP_FILE
#fi

for i in $VMS;                                                                                                                                                                 
do
    if [[ $2 == "start" ]];
    then
        echo $i >> $TEMP_FILE
        $OSEKVM_HOME_PATH/bin/get_ip.sh $i >> $TEMP_FILE    
    elif [[ $2 == "shutdown" ]];
    then
        rm -rf $TEMP_FILE
    fi
    if [[ ! $i =~ "#" ]];
    then
          sudo virsh $2 $i 
    fi
done
#sed -e "s/EMPTY/RUNNING VMS LIST/g" -i ./$TEMP_FILE 
