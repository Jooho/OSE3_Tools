export ISO_PATH=/home/jooho/dev/OSE_REPO_ISO/rhel7u1_ose3u1_151125

git clone https://github.com/Jooho/ansible-ose3-install
git clone https://github.com/Jooho/rhep-tools

cp ansible-ose3-install/shell/setup.sh .

cd ./rhep_tools/ose_kvm_provision/
./ose_kvm_provision.sh -mode=info -arch=max
./ose_kvm_provision.sh -mode=template -arch=max

cd ../../
cp ./rhep_tools/ose_kvm_provision/*.yaml .
cp ./rhep_tools/ose_kvm_provision/*.txt .

cp -R $ISO_PATH/* .
master_ip=$(grep MASTER1_PRIVATE_IP ./ose31_kvm_info.txt|cut -d"=" -f2)
echo -e "Type password : \c"
read password
sshpass -p $password ssh -q root@$master_ip 'mkdir -p /root/ose'

for file in ./*; do
#if ([ -f $file ] && [ ${file##*.} != "sh" ]); then
 if [[ -f $file ]]; then
    echo sshpass -p $password scp $(basename $file) root@$master_ip:/root/ose/.
    sshpass -p $password scp $(basename $file) root@$master_ip:/root/ose/.
  fi
done

echo "After you connect to master server, go to ose folder then execute setup.sh"
echo "cd ose;./setup.sh"

ssh root@$master_ip

