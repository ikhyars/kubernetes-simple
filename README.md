# Introduction
It is derived from [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way) with some modification.

# Requirement
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed  (eg: `sudo apt-get install virtualbox`)  
- [git](https://git-scm.com/downloads/) installed (eg: `sudo apt-get install git`)  
- [vagrant](https://www.vagrantup.com/downloads.html) installed (eg: `sudo apt-get install vagrant`)  

# Resources

|Hostname|vCPU|Memory|
|---|---|---|
|master-1|1|1024 MB|
|master-1|1|1024 MB|
|loadbalancer|1|512 MB|
|worker-1|1|512 MB|
|worker-2|1|512 MB|

Operating system: Centos 7

# Preparation
Add below lines in your laptop's /etc/hosts  
> 192.168.100.11  master-1  
> 192.168.100.12  master-2  
> 192.168.100.13  lb loadbalancer  
> 192.168.100.14  worker-1  
> 192.168.100.15  worker-2  

Download the git sources using below command  
> $ `cd ~`   
> $ `git clone https://github.com/ikhyars/kubernetes-simple.git`  
  
Navigate to the directory  
> $ `cd ~/kubernetes-simple/`  

# Provision and bring-up the VMs

> $ `vagrant up`  

Once all VMs have been UP and running, please do ssh to nodes using username/password: vagrant/vagrant123  
example:  
- `ssh vagrant@master-1`  
- `ssh vagrant@loadbalancer`  
- `ssh vagrant@worker-2`  

etc.

# Configuration

#### Login to master-1 & master-2 and run below command (parallel execution is possible)
> $ `./01-kubclient.sh`  
  
#### Login to master-1 and run below command   
> $ `./02-cert.sh`  

#### Login to master-1 and run below command  
> $ `./03-kubeconfig.sh`  

#### Login to master-1 and run below command  
> $ `./04-dataencrypt.sh`  

#### Login to master-1 & master-2 and run below command (parallel execution is possible)  
> $ `./05-etcd.sh`  
>> Expected output:  
>> 1a82afa2247e7562, started, master-2, https://192.168.100.12:2380, https://192.168.100.12:2379  
>> b9a27230d536d1e8, started, master-1, https://192.168.100.11:2380, https://192.168.100.11:2379  

#### Login to master-1 & master-2 and run below command (parallel execution is possible)  
> $ `./06-bootstrap-controlplane.sh`  
>> Expected output:  
>> NAME                 STATUS    MESSAGE             ERROR  
>> controller-manager   Healthy   ok                    
>> scheduler            Healthy   ok                    
>> etcd-1               Healthy   {"health":"true"}     
>> etcd-0               Healthy   {"health":"true"}     

#### Login to loadbalancer and run below command
> $ `./07-network-lb.sh`  
>> Expected output:  
>   

#### Login to master-1 and run below command 
> $ `./08-bootstrap-worker.sh`

#### Login to worker-1 & worker-2 and run below command (parallel execution is possible)
> $ `./09-bootstrap-worker-client.sh`

#### Login to master-1 and run below command 
> $ `kubectl get nodes --kubeconfig admin.kubeconfig`
>> Expected output:  
>  

#### Login to master-1 and run below command 
> $ `./10-config-kubectl.sh`  
> $ `kubectl get componentstatuses`  
>> Expected output:  
>    
> `$ kubectl get nodes --kubeconfig admin.kubeconfig`  
>> Expected output:  
>    

#### Login to worker-1 & worker-2 and run below command (parallel execution is possible)
> $ `./11-config-podnetwork.sh`

#### Login to master-1 and run below command 
> $ `kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`  
> $ `kubectl get pods -n kube-system`  
>> Expected output:    
>  
> $ `kubectl get componentstatuses`  
>> Expected output:  
>  
> $ `kubectl get nodes --kubeconfig admin.kubeconfig`  
>> Expected output:  
>    

#### Login to master-1 and run below command 
> $ `./12-apiserver-to-kubelet.sh`

#### Login to master-1 and run below command   
> $ `kubectl apply -f coredns.yaml`  
> $ `kubectl apply -f nginx-deployment.yaml`  
> $ `kubectl apply -f nginx-service.yaml`  
> $ `kubectl get pods -n kube-system`  
>> Expected output:  
>    
> $ `kubectl get pods -l k8s-app=kube-dns -n kube-system`  
>> Expected output:    
>  
> $ `kubectl get componentstatuses`  
>> Expected output:  
>  
> $ `kubectl get nodes --kubeconfig admin.kubeconfig`  
>> Expected output:  
>  
> $ `kubectl get services`  
>> Expected output:  
>    
