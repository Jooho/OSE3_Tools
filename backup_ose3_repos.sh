#!/bin/bash

# This script is created by Jooho Lee(jlee@redhat.com)
# If you have any questions or requests about this script, please email me.

# This shell script is for backup openshift v3 packages. In order to test openshift v3, you should sync the environment of client but you can only install latest packages. 
#Therefore, you have to archieve those essential packages as iso file.
#
#  Usage : backup_repos.sh (with root user)
# 
#  Necessary parameters that you should notice:
#  RHEL_VERSION - Installed RHEL OS version  ex) 7.1 or 7.2
#  OSE_VERSION - Installed Openshift version ex) 3.0 or 3.1
#  ISO_DIRECTORY - Directory contained archieved ISO files.
#  CLEAR - If you want to archieve different v  ersion of Openshift(3.0 -> 3.1), you should remove previous repositories. Hence, you should set it to true.  
#  IS_FIRST - If it is first time to run this script, you should set it to true. This will register your system to rhn-manager, enable repositories and create some folders.
#             Once you run it, you should set it to false.            
#  USER - rhn login user id.(it should be changed when IS_FIRST set to true)
#  PASSWORD - rhn login user password.(it should be changed when IS_FIRST set to true)

RHEL_VERSION="7.2"
RHEL_MAJOR_VERSION=$(echo $RHEL_VERSION |cut -d"." -f1)
OSE_VERSION="3.1"
BACKUP_REPOS="rhel-$RHEL_MAJOR_VERSION-server-rpms rhel-$RHEL_MAJOR_VERSION-server-extras-rpms rhel-ha-for-rhel-$RHEL_MAJOR_VERSION-server-rpms rhel-$RHEL_MAJOR_VERSION-server-ose-$OSE_VERSION-rpms"
TEMP_DIRECTORY=/tmp/temp_repo_root
ISO_DIRECTORY=~/ISO_FILES
CLEAR=false
IS_FIRST=true
USER=test     # If IS_FIRST set true, you have to set this parameter which is rhn user id.
PASSWORD=test    # If IS_FIRST set true, you have to set this parameter which is rhn password.



echo "$BACKUP_REPOS will be archived into .iso file"

if [[ $CLEAR == true ]]
then 
  # Delete TEMP directory
  echo "Delete TEMP directory($TEMP_DIRECTORY)"
  rm -rf $TEMP_DIRECTORY

  # Create temp_repo_root directory
  echo "Create TEMP directory($TEMP_DIRECTORY)"
  mkdir -p $TEMP_DIRECTORY

else 
  if [ -e $TEMP_DIRECTORY ]; then
     echo "TEMP directory won't be deleted"
  else
     # Create temp_repo_root directory
     echo "Create TEMP directory($TEMP_DIRECTORY)"
     mkdir -p $TEMP_DIRECTORY
   fi
fi
# Move to temp_repo_root
cd $TEMP_DIRECTORY

#if it is first time to run, it will try to configure subscription and repositories.
if [[ $IS_FIRST == true ]]
then
  # Register employee subscription (Should be commented after registered.)
  echo "subscription-manager register --username=$USER --password='$PASSWORD'"
  subscription-manager register --username=$USER --password='$PASSWORD'
  subscription-manager list --available
  subscription-manager attach --pool=8a85f9833e1404a9013e3cddf99305e6


  # Disable all repos
  echo "Disable all repos"
  subscription-manager repos --disable="*" 

  # Enable repos which related with OSE
  echo "Enable repos which related with OSE"

  REPO_REGISTER="subscription-manager repos"
  for REPO in $BACKUP_REPOS
    do 
	REPO_REGISTER="$REPO_REGISTER --enable=\"$REPO\""
    done

  echo "$REPO_REGISTER are being enabled"

  #Execute REPO_REGISTER
  echo "$REPO_REGISTER"|sh

  # For checking enabled repositories.
  #subscription-manager repos --list-enabled

  # Install essential tools
  echo "Install essential tools : yum install yum-utils createrepo genisoimage -y"
  yum install yum-utils createrepo genisoimage -y
 
  mkdir ~/ISO_FILES
else
  echo "It is not first time to run so registering subscription will be skipped"
fi

# Download channels (latest packages only)
echo " Download channels (latest packages only). It will take around 30m~60m."
for REPO in $BACKUP_REPOS
do 
	reposync -l -n -r $REPO
done

# Create repositories (for all channels)
echo "Create repositories \(for all channels\)"
for REPO in $BACKUP_REPOS
do 
   	cd $REPO ; createrepo . ; cd ..
done


#Check if repos are created or not
echo "Check if repos are created or not"

DIRS=$(for dir in *;do if [[ -d $dir  ]]; then echo $dir;fi; done;)
EXIST=0
for folder in $DIRS
do 
    for REPO in $BACKUP_REPOS
    do 
       if [[  $REPO == $folder  ]] 
         then EXIST=$(( $EXIST+1 )) 
       fi 
    done
done  
 
if [[  $EXIST == 3  ]]
then
      echo "==> some repositories are not downloaded"
else
      echo "==> all repositories are downloaded."
fi

# Prepare to achieve repositories.
echo "Prepare to achieve repositories."

rm -rf  $TEMP_DIRECTORY/ose3
mkdir $TEMP_DIRECTORY/ose3
for REPO in $(echo $BACKUP_REPOS |cut -d" " -f2-4 ) 
do
	cp -Rf ./$REPO ./ose3/ 
done

# 1) RHEL iso
cd $(echo $BACKUP_REPOS |cut -d" " -f1 )
mkisofs -r -J -joliet-long -o ../rhel-server-$RHEL_VERSION-x86_64-$(date '+%y%m%d').iso .
cd ..

# 2) OSE iso
cd ose3
mkisofs -r -J -joliet-long -o ../ose-$OSE_VERSION-x86_64-$(date '+%y%m%d').iso .
cd ..

echo Copy iso files to $ISO_DIRECTORY
cp -fv rhel-server-$RHEL_VERSION-x86_64-$(date '+%y%m%d').iso ose-$OSE_VERSION-x86_64-$(date '+%y%m%d').iso $ISO_DIRECTORY/

echo done!


#How to deploy iso files
# mkdir -p /var/iso_images/rhel
# mkdir -p /var/iso_images/ose
# mount -o loop,ro rhel-server-7.1-x86_64_151119.iso /var/iso_images/rhel
# mount -o loop,ro ose-3.0-x86_64_151119.iso /var/iso_images/ose

#/etc/fstab
#/root/ose/rhel-server-7.1-x86_64-151125.iso /var/iso_images/rhel iso9660 loop 0 0
#/root/ose/ose-3.1-x86_64-151125.iso /var/iso_images/ose iso9660 loop 0 0

#cat  /etc/yum.repos.d/ose.repo
#[ose]
#name=Openshift v3
#baseurl=file:///var/iso_images/ose
#enabled=1
#[rhel]
#name=RHEL 7.1
#baseurl=file:///var/iso_images/rhel
#enabled=1
