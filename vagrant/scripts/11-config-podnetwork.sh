wget https://github.com/containernetworking/plugins/releases/download/v0.7.5/cni-plugins-amd64-v0.7.5.tgz
sudo tar -xzvf cni-plugins-amd64-v0.7.5.tgz  --directory /opt/cni/bin/

sudo mkdir -p /run/systemd/resolve/
sudo ln -sf /etc/resolv.conf /run/systemd/resolve/resolv.conf

