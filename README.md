# stx-usecase-devops-infra
DevOps infra as a use case for StarlingX. Can be used as CI/CD infra for any SW development, not limited to StarlingX. How to setup CI/CD using StarlingX as infra, BKM doc

## cephfs setup
### create pools
```
ceph osd pool create fs_data 2048
ceph osd pool create fs_metadata 256
ceph fs new cephfs fs_metadata fs_data
```
### start mds
On controller-0:
```
/usr/bin/ceph-mds --cluster ceph --id controller-0 --hot-standby 0
```
On controller-1:
```
/usr/bin/ceph-mds --cluster ceph --id controller-1 --hot-standby 0
```
### create auth and folders
```
ceph auth get-or-create client.stx-devops mon 'allow r' mds 'allow r, allow rw path=/stx-devops' osd 'allow rw'
sudo mkdir -p /mnt/mycephfs
sudo mount -t ceph controller-0:6789:/ /mnt/mycephfs
sudo mkdir -p -m 777 /mnt/mycephfs/stx-devops/jenkins-master
sudo mkdir -p -m 777 /mnt/mycephfs/stx-devops/pub
sudo mkdir -p -m 777 /mnt/mycephfs/stx-devops/registry
sudo mkdir -p -m 777 /mnt/mycephfs/stx-devops/docker-io-mirror
```

