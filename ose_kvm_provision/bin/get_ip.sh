#It gets ip of vms in KVM

arp -an | grep "`sudo virsh dumpxml $1 | grep "mac address" | sed "s/.*'\(.*\)'.*/\1/g"`" | awk '{ gsub(/[\(\)]/,"",$2); print $2 }'

