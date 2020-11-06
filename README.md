# kubernetes-simple
Derived from https://github.com/kelseyhightower/kubernetes-the-hard-way with some modification

# Preparation
sudo apt-get install git
sudo apt-get install vagrant

git clone https://github.com/ikhyars/kubernetes-simple.git

cd /home/smiertx/kubernetes-simple/vagrant

vagrant up

add below lines in your laptop's /etc/hosts

192.168.100.11  master-1
192.168.100.12  master-2
192.168.100.13  lb loadbalancer
192.168.100.14  worker-1
192.168.100.15  worker-2

ssh to nodes using username/password: vagrant/vagrant123

master-1 & master-2: parallel execution
01-kubclient.sh

master-1 only:
02-cert.sh

master-1 only:
03-kubeconfig.sh

master-1 only:
04-dataencrypt.sh

master-1 & master-2: parallel execution
05-etcd.sh

Expected output:
45bf9ccad8d8900a, started, master-2, https://192.168.100.12:2380, https://192.168.100.12:2379
54a5796a6803f252, started, master-1, https://192.168.100.11:2380, https://192.168.100.11:2379

master-1 & master-2: parallel execution
06-bootstrap-controlplane.sh

Expected output:
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}   

loadbalancer:
07-network-lb.sh

Expected output:
{
  "major": "1",
  "minor": "13",
  "gitVersion": "v1.13.0",
  "gitCommit": "ddf47ac13c1a9483ea035a79cd7c10005ff21a6d",
  "gitTreeState": "clean",
  "buildDate": "2018-12-03T20:56:12Z",
  "goVersion": "go1.11.2",
  "compiler": "gc",
  "platform": "linux/amd64"
}

master-1:
08-bootstrap-worker.sh

worker-1 & worker-2: parallel execution
09-bootstrap-worker-client.sh

master-1:
kubectl get nodes --kubeconfig admin.kubeconfig

Expected output:
NAME       STATUS     ROLES    AGE   VERSION
worker-1   NotReady   <none>   66s   v1.13.0
worker-2   NotReady   <none>   51s   v1.13.0

master-1:
10-config-kubectl.sh

kubectl get componentstatuses
Expected output:
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-1               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   

kubectl get nodes --kubeconfig admin.kubeconfig
Expected output:
NAME       STATUS     ROLES    AGE    VERSION
worker-1   NotReady   <none>   2m4s   v1.13.0
worker-2   NotReady   <none>   109s   v1.13.0

worker-1 & worker-2: parallel execution
11-config-podnetwork.sh

master-1:
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl get pods -n kube-system
Expected output:
NAME              READY   STATUS    RESTARTS   AGE
weave-net-g69kv   2/2     Running   0          80s
weave-net-vgk5p   2/2     Running   0          80s

kubectl get componentstatuses
Expected output:
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"} 

kubectl get nodes --kubeconfig admin.kubeconfig
Expected output:
NAME       STATUS   ROLES    AGE     VERSION
worker-1   Ready    <none>   5m10s   v1.13.0
worker-2   Ready    <none>   4m55s   v1.13.0

master-1:
12-apiserver-to-kubelet.sh

master-1:
kubectl apply -f coredns.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml

kubectl get pods -n kube-system
Expected output:
NAME                       READY   STATUS    RESTARTS   AGE
coredns-69cbb76ff8-plk44   1/1     Running   0          31s
coredns-69cbb76ff8-q88xt   1/1     Running   0          31s
weave-net-g69kv            2/2     Running   0          4m2s
weave-net-vgk5p            2/2     Running   0          4m2s

kubectl get pods -l k8s-app=kube-dns -n kube-system
Expected output:
NAME                       READY   STATUS    RESTARTS   AGE
coredns-69cbb76ff8-plk44   1/1     Running   0          62s
coredns-69cbb76ff8-q88xt   1/1     Running   0          62s

kubectl get componentstatuses
Expected output:
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}  

kubectl get nodes --kubeconfig admin.kubeconfig
Expected output:
NAME       STATUS   ROLES    AGE     VERSION
worker-1   Ready    <none>   8m32s   v1.13.0
worker-2   Ready    <none>   8m17s   v1.13.0

kubectl get services
Expected output:
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1     <none>        443/TCP        15m
nginx        LoadBalancer   10.96.0.192   <pending>     80:32688/TCP   106s
