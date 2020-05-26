sudo bash -c "cat etcEnviron.txt >> /etc/environment "
sudo mkdir /etc/systemd/system/docker.service.d
sudo bash -c "cat dockerappend.txt >> /etc/systemd/system/docker.service.d/proxy.conf"
sudo bash -c "cat cluster_kernel.txt >> /opt/couchdb/etc/vm.args"