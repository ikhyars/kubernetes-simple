cat > openssl-worker-1.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-1
IP.1 = 192.168.100.14
EOF

openssl genrsa -out worker-1.key 2048
openssl req -new -key worker-1.key -subj "/CN=system:node:worker-1/O=system:nodes" -out worker-1.csr -config openssl-worker-1.cnf
openssl x509 -req -in worker-1.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-1.crt -extensions v3_req -extfile openssl-worker-1.cnf -days 1000

LOADBALANCER_ADDRESS=192.168.100.13
{
  kubectl config set-cluster kubernetes-simple \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://${LOADBALANCER_ADDRESS}:6443 \
    --kubeconfig=worker-1.kubeconfig

  kubectl config set-credentials system:node:worker-1 \
    --client-certificate=worker-1.crt \
    --client-key=worker-1.key \
    --embed-certs=true \
    --kubeconfig=worker-1.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-simple \
    --user=system:node:worker-1 \
    --kubeconfig=worker-1.kubeconfig

  kubectl config use-context default --kubeconfig=worker-1.kubeconfig
}

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ca.crt worker-1.crt worker-1.key worker-1.kubeconfig worker-1:~/

cat > openssl-worker-2.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-2
IP.1 = 192.168.100.15
EOF

openssl genrsa -out worker-2.key 2048
openssl req -new -key worker-2.key -subj "/CN=system:node:worker-2/O=system:nodes" -out worker-2.csr -config openssl-worker-2.cnf
openssl x509 -req -in worker-2.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-2.crt -extensions v3_req -extfile openssl-worker-2.cnf -days 1000

LOADBALANCER_ADDRESS=192.168.100.13
{
  kubectl config set-cluster kubernetes-simple \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://${LOADBALANCER_ADDRESS}:6443 \
    --kubeconfig=worker-2.kubeconfig

  kubectl config set-credentials system:node:worker-2 \
    --client-certificate=worker-2.crt \
    --client-key=worker-2.key \
    --embed-certs=true \
    --kubeconfig=worker-2.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-simple \
    --user=system:node:worker-2 \
    --kubeconfig=worker-2.kubeconfig

  kubectl config use-context default --kubeconfig=worker-2.kubeconfig
}

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ca.crt worker-2.crt worker-2.key worker-2.kubeconfig worker-2:~/

