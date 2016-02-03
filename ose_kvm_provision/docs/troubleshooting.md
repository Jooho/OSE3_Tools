### Troubleshooting

**Case 1. During installation by ose3-ansible, it fails with following error**

*Error logs*
~~~
TASK: [openshift_master | Start and enable master api] ************************
<192.168.124.137> ESTABLISH CONNECTION FOR USER: root
<192.168.124.137> REMOTE_MODULE service name=atomic-openshift-master-api enabled=yes state=started
<192.168.124.137> EXEC ssh -C -tt -vvv -o ControlMaster=auto -o ControlPersist=60s -o
ControlPath="/root/.ansible/cp/ansible-ssh-%h-%p-%r" -o KbdInteractiveAuthentication=no -o Pr
eferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o
ConnectTimeout=10 192.168.124.137 /bin/sh -c 'mkdir -p $HOME/.ansible/tmp/a
nsible-tmp-1454449284.84-76394267207367 && echo $HOME/.ansible/tmp/ansible-tmp-1454449284.84-76394267207367'
<192.168.124.137> PUT /tmp/tmpWiecFu TO /root/.ansible/tmp/ansible-tmp-1454449284.84-76394267207367/service
<192.168.124.137> EXEC ssh -C -tt -vvv -o ControlMaster=auto -o ControlPersist=60s -o
ControlPath="/root/.ansible/cp/ansible-ssh-%h-%p-%r" -o KbdInteractiveAuthentication=no -o Pr
eferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o
ConnectTimeout=10 192.168.124.137 /bin/sh -c 'LANG=C LC_CTYPE=C /usr/bin/py
thon /root/.ansible/tmp/ansible-tmp-1454449284.84-76394267207367/service; rm -rf
/root/.ansible/tmp/ansible-tmp-1454449284.84-76394267207367/ >/dev/null 2>&1'
failed: [master1.example.com] => {"failed": true}
msg: Job for atomic-openshift-master-api.service failed. See 'systemctl status atomic-openshift-master-api.service' and
'journalctl -xn' for details.


FATAL: all hosts have already failed -- aborting

PLAY RECAP ********************************************************************
           to retry, use: --limit @/root/config.yaml.retry

           etcd1.example.com          : ok=130  changed=60   unreachable=0    failed=0
           etcd2.example.com          : ok=70   changed=40   unreachable=0    failed=0
           etcd3.example.com          : ok=70   changed=40   unreachable=0    failed=0
           infra.example.com          : ok=44   changed=43   unreachable=0    failed=0
           lb.example.com             : ok=53   changed=34   unreachable=0    failed=0
           localhost                  : ok=27   changed=5    unreachable=0    failed=0
           master1.example.com        : ok=115  changed=65   unreachable=0    failed=1
           master2.example.com        : ok=49   changed=34   unreachable=0    failed=0
           master3.example.com        : ok=49   changed=33   unreachable=0    failed=0
           node1.example.com          : ok=26   changed=25   unreachable=0    failed=0
           node2.example.com          : ok=26   changed=25   unreachable=0    failed=0
           node3.example.com          : ok=26   changed=25   unreachable=0    failed=0
~~~

*Resolution*

Check etcd service on each etcd server and if you see error message to look up etcd member, delete member data.
Then re-execute setup.sh 

Example:

1.fix etcd data
~~~
  # ssh master1.example.com
  # journalctl -f -u etcd.service
----
  .......   rafthttp: failed to find member xxxxxxxx in cluster ......
-----

  # systemctl stop etcd
  # rm -rf /var/lib/etcd/member
  # systemctl start etcd
~~~  

2.On Master1 server, execute setup.sh again.
~~~
[root@master1 ose]# ./setup.sh ./production-master-ha-etcd-ha-lb.yaml
Do you want to go through from the beginning?(y/n) (or just start to install)
n   <== Type n then enter
~~~
