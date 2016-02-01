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
    echo "usage : ./full_clean_up_with_kvm.sh max (mid,min)"
    exit 1
fi

#Create KVM VMs according to architecture
cd ./rhep-tools/ose_kvm_provision/
./ose_kvm_provision.sh -mode=clean -arch=$c_arch
./ose_kvm_provision.sh -mode=force -arch=$c_arch

exist=1
while [[ exist -gt 0 ]]
do
exist=$(sudo virsh list |grep $c_arch|wc -l)
echo "It is being deleted.....vms: $exist"
sleep 2
done

echo "Done... All $c_arch vms are deleted.!"

sudo virsh list
