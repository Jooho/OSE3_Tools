. ./pv-config.sh

export exist_folders
export created_folders

#Flow
#1. Check if NFS_LOCAL_MOUNT_PATH have value. (In case, you mount the nfs server on the local machine)
#2. If there is, it will overwrite NFS_MOUNT_PATH
#3. Create PV volume folders
#4. Change owner of those folders to nfsnobody:nfsnobody
#5. Change permission of those folders to 777

for c in $(seq -f "%0${#PV_NAME_PAD}g" ${PV_RANGE_START} ${PV_RANGE_END})
do

  VOL_NAME=${PV_NAME_PREFIX}${c}

  if [[ x${NFS_LOCAL_MOUNT_PATH} != x ]]; then
     NFS_MOUNT_PATH=${NFS_LOCAL_MOUNT_PATH}
  fi

  if [[ -e ${NFS_MOUNT_PATH}/${VOL_NAME} ]]; then
      echo "${VOL_NAME} is already exist so skip to create the folder!!"
      exist_folders=("${exist_folders[@]}" "${VOL_NAME}")
  else
      echo "Creating ${NFS_MOUNT_PATH}/${VOL_NAME}"

      mkdir -p ${NFS_MOUNT_PATH}/${VOL_NAME}
      created_folders=("${created_folders[@]}" "${VOL_NAME}")

      echo "Changing owenr for ${NFS_MOUNT_PATH}"
      chown -R nfsnobody:nfsnobody ${NFS_MOUNT_PATH}

      echo "Changing permission for ${NFS_MOUNT_PATH}"
      chmod -R 777 ${NFS_MOUNT_PATH}
  fi

done

echo ""
echo ""
echo "Summary :"
echo "=============================================================="
echo Exist folders  :
echo ${exist_folders[@]}
echo ""
echo Created folders  :
echo ${created_folders[@]}
