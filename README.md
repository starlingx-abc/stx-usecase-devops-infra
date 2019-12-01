# stx-usecase-devops-infra
DevOps infra as a use case for StarlingX.

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

### install stx app
```
system application-upload stx-devops-1.0.0.tgz

system helm-override-update stx-devops stx-devops stx-devops \
	--set images.tags.registry="<registry>/registry:2.7.1" \
	--set images.tags.nginx="<registry>/nginx:1.16.0" \
	--set images.tags.jenkins="<registry>/jenkins/jenkins:lts" \
	--set images.tags.jenkins_slave="<registry>/jenkins/jnlp-slave:3.35-5-alpine" \
	--set images.tags.docker_build="<registry>/starlingxabc/docker-build" \
    --set ingress.base_url="<ingress url>" \
    --set ceph.user="client.stx-devops" \
    --set ceph.key="" \
	--set proxy.enabled=true \
	--set proxy.http_proxy="http://<hostname>:<port>" \
	--set proxy.https_proxy="https://<hostname>:<port>"

system application-apply stx-devops
```
