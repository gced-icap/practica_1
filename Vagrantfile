# -*- mode: ruby -*-
# vi: set ft=ruby :

# require a Vagrant recent version
Vagrant.require_version ">= 2.2.0"

Vagrant.configure('2') do |config|

  # Box de PROXMOX
  config.vm.box = "xoan/proxmox-ve_6.4"
  config.vm.box_version = "1.1"
  config.vm.box_check_update = false

  # evitamos actualizacións automáticas das VBox Guest Additions
  config.vbguest.auto_update = false

  # VirtualBox VM con 2GB RAM e 2 CPUs virtuais
  config.vm.provider :virtualbox do |vb|
    vb.name = "Proxmox VE"
    vb.memory = 2*1024
    vb.cpus = 2
    vb.linked_clone = true
    vb.default_nic_type = "82540EM"

    # 2 discos adicionais de 50GB cada un
    for i in 0..1 do
      filename = "./disks/disk#{i}.vdi"
      unless File.exist?(filename)
        vb.customize ["createmedium", "disk", "--filename", filename, "--size", 50 * 1024]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", i + 1, "--device", 0, "--type", "hdd", "--medium", filename]
    end
  end

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
