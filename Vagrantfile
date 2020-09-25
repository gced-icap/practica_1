ENV["VAGRANT_EXPERIMENTAL"]="disks"

Vagrant.configure('2') do |config|

  # PROXMOX box
  config.vm.box = "xoan/proxmox-ve_6.2"
  config.vm.box_version = "1.0"

  # VirtualBox VM con 2GB RAM e 4 CPUs virtuais
  config.vm.provider :virtualbox do |vb|
    vb.name = "Proxmox VE"
    vb.memory = 2048
    vb.cpus = 4
  end

  # 2 discos adicionais de 50GB cada un
  config.vm.disk :disk, size: "50GB", name: "disk02"
  config.vm.disk :disk, size: "50GB", name: "disk03"

  # Rede para conectar co servidor
  ip1 = '10.10.10.2'
  config.vm.network :private_network, ip: ip1, auto_config: false

  # Rede adicional para probas
  # VBox crea 2 adaptadores no mesmo bridge na rede 10.10.20.0/24
  # En Proxmox pode asignarse calqueira IP dentro da rede
  ip2 = '10.10.20.2'
  config.vm.network :private_network, ip: ip2, auto_config: false
  ip3 = '10.10.20.3'
  config.vm.network :private_network, ip: ip3, auto_config: false

  # script de aprovisionamento (so configura a rede de acceso ao servidor)
  config.vm.provision :shell, path: 'provision.sh', args: ip1
end
