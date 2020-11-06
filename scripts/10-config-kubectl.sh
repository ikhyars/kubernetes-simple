  KUBERNETES_LB_ADDRESS=192.168.100.13

  kubectl config set-cluster kubernetes-simple \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://${KUBERNETES_LB_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key

  kubectl config set-context kubernetes-simple \
    --cluster=kubernetes-simple \
    --user=admin

  kubectl config use-context kubernetes-simple

