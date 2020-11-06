Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_check_update = false

  # Provision Master Node 1
  config.vm.define "master-1" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubernetes-ha-master-1"
      vb.memory = 1024
      vb.cpus = 1
    end
    node.vm.hostname = "master-1"
    node.vm.network :private_network, ip: "192.168.100.11"
    node.vm.network "forwarded_port", guest: 22, host: 2711  
    node.vm.provision "file", source: "./files/id_rsa", destination: "$HOME/.ssh/"
    node.vm.provision "file", source: "./scripts/01-kubclient.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/02-cert.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/03-kubeconfig.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/04-dataencrypt.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/05-etcd.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/06-bootstrap-controlplane.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/08-bootstrap-worker.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/10-config-kubectl.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/12-apiserver-to-kubelet.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./yaml/coredns.yaml", destination: "$HOME/"
    node.vm.provision "file", source: "./yaml/nginx-deployment.yaml", destination: "$HOME/"
    node.vm.provision "file", source: "./yaml/nginx-service.yaml", destination: "$HOME/"  
    node.vm.provision "setup-nodes", :type => "shell", :path => "scripts/setup-nodes.sh"
    node.vm.provision "setup-nodes2", :type => "shell", :path => "scripts/setup-nodes2.sh"
  end

  # Provision Master Node 2
  config.vm.define "master-2" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubernetes-ha-master-2"
      vb.memory = 1024
      vb.cpus = 1
    end
    node.vm.hostname = "master-2"
    node.vm.network :private_network, ip: "192.168.100.12"
    node.vm.network "forwarded_port", guest: 22, host: 2712  
    node.vm.provision "file", source: "./files/id_rsa", destination: "$HOME/.ssh/"
    node.vm.provision "file", source: "./scripts/01-kubclient.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/05-etcd.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/06-bootstrap-controlplane.sh", destination: "$HOME/"
    node.vm.provision "setup-nodes", :type => "shell", :path => "scripts/setup-nodes.sh"
    node.vm.provision "setup-nodes2", :type => "shell", :path => "scripts/setup-nodes2.sh"
  end
   
  # Provision Load Balancer Node
  config.vm.define "loadbalancer" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubernetes-ha-lb"
      vb.memory = 512
      vb.cpus = 1
    end
    node.vm.hostname = "loadbalancer"
    node.vm.network :private_network, ip: "192.168.100.13"
    node.vm.network "forwarded_port", guest: 22, host: 2713
    node.vm.provision "file", source: "./files/id_rsa", destination: "$HOME/.ssh/"
    node.vm.provision "file", source: "./scripts/07-network-lb.sh", destination: "$HOME/"
    node.vm.provision "setup-nodes", :type => "shell", :path => "scripts/setup-nodes.sh"
    node.vm.provision "setup-nodes2", :type => "shell", :path => "scripts/setup-nodes2.sh"
  end

  # Provision Worker Node 1
  config.vm.define "worker-1" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubernetes-ha-worker-1"
      vb.memory = 512
      vb.cpus = 1
    end
    node.vm.hostname = "worker-1"
    node.vm.network :private_network, ip: "192.168.100.14"
    node.vm.network "forwarded_port", guest: 22, host: 2714
    node.vm.provision "file", source: "./files/id_rsa", destination: "$HOME/.ssh/"
    node.vm.provision "file", source: "./scripts/09-bootstrap-worker-client.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/11-config-podnetwork.sh", destination: "$HOME/"
    node.vm.provision "setup-nodes", :type => "shell", :path => "scripts/setup-nodes.sh"
    node.vm.provision "install-docker", type: "shell", :path => "scripts/install-docker.sh"
    node.vm.provision "setup-nodes2", :type => "shell", :path => "scripts/setup-nodes2.sh"
    end

  # Provision Worker Node 2
  config.vm.define "worker-2" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubernetes-ha-worker-2"
      vb.memory = 512
      vb.cpus = 1
    end
    node.vm.hostname = "worker-2"
    node.vm.network :private_network, ip: "192.168.100.15"
    node.vm.network "forwarded_port", guest: 22, host: 2715
    node.vm.provision "file", source: "./files/id_rsa", destination: "$HOME/.ssh/"
    node.vm.provision "file", source: "./scripts/09-bootstrap-worker-client.sh", destination: "$HOME/"
    node.vm.provision "file", source: "./scripts/11-config-podnetwork.sh", destination: "$HOME/"
    node.vm.provision "setup-nodes", :type => "shell", :path => "scripts/setup-nodes.sh"
    node.vm.provision "install-docker", type: "shell", :path => "scripts/install-docker.sh"
    node.vm.provision "setup-nodes2", :type => "shell", :path => "scripts/setup-nodes2.sh"
  end
  
end

