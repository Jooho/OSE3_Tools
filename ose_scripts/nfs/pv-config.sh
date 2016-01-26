#Definition
#VOL_SIZE - The size of pv volume
#PV_NAME_PREFIX - This is for pv name (refer following example)
#PV_NAME_PAD - This is pad for volume name (refer following example)
#PV_RANGE_START - The first number of pv volume (refer following example)
#PV_RANGE_END - The last number of pv volume (refer following example)
#PV_SCRIPT_PATH - The folder that will have pv scripts
#NFS_MOUNT_PATH - NFS mount point
#NFS_LOCAL_MOUNT_PATH - If you mount the NFS mount point on the local machin, you don't need to connect nfs server directlly. So just set value.
#NFS_SERVER - NFS Server hostname

# Example
#  Suppose you want to create pv0001 to pv0012
#     PV_NAME_PREFIX should be pv
#     PV_NAME_PAD should be 0000
#     PV_RANGE_START should be 1
#     PV_RANGE_END should be 12


export VOL_SIZE="45Gi"
export PV_NAME_PREFIX=pv
export PV_NAME_PAD=0000 # pv0001
export PV_RANGE_START=10
export PV_RANGE_END=10
export PV_SCRIPT_PATH=./test_pv_script
export NFS_MOUNT_PATH=/vol_openshift_prd/data/persistent-volumes
export NFS_LOCAL_MOUNT_PATH=/openshift/data/persistent-volumes
export NFS_SERVER=lif-core-nfsprd
