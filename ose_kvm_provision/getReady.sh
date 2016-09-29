# Soft Link
export RHEP_HOME_PATH=$(cd ..; echo $PWD)
export OSEKVM_HOME_PATH=$PWD


if [[ ! -e  ../../full_set_up_with_kvm.sh ]];
then
  ln -s $PWD/bin/full_set_up_with_kvm.sh ../../full_set_up_with_kvm.sh  
  ln -s $PWD/bin/full_clean_up_with_kvm.sh ../../full_clean_up_with_kvm.sh
  ln -s $PWD/bin/kvm_command.sh ../../kvm_command.sh
fi
cd ../../
