wget "https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz"
tar -xvf etcd-v3.3.9-linux-amd64.tar.gz
sudo mv etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin/

sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/

INTERNAL_IP=$(ip addr show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
ETCD_NAME=$(hostname -s)
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/etcd-server.crt \\
  --key-file=/etc/etcd/etcd-server.key \\
  --peer-cert-file=/etc/etcd/etcd-server.crt \\
  --peer-key-file=/etc/etcd/etcd-server.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster master-1=https://192.168.100.11:2380,master-2=https://192.168.100.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

if [ $HOSTNAME == "master-1" ]; then
  touch ~/05-etcd.complete
  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ~/05-etcd.complete master-2:~/
  rm ~/05-etcd.complete
fi

if [ $HOSTNAME == "master-2" ]; then
 while [ ! -f ~/05-etcd.complete ]
 do
  sleep 1
 done
 rm ~/05-etcd.complete
fi

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

sleep 30

ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key


