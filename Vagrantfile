
Vagrant.configure('2') do |config|

  # PROXMOX box
  config.vm.box = "xoan/proxmox-ve_6.4"
  config.vm.box_version = "1.0"

  # VirtualBox VM con 2GB RAM e 2 CPUs virtuais
  config.vm.provider :virtualbox do |vb|
    vb.name = "Proxmox VE"
    vb.memory = 2*1024
    vb.cpus = 2
    vb.linked_clone = true

    # 2 discos adicionais de 50GB cada un
    for i in 0..1 do
      filename = "./disks/disk#{i}.vmdk"
      unless File.exist?(filename)
        vb.customize ["createmedium", "disk", "--filename", filename, "--size", 50 * 1024]
        vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", i + 1, "--device", 0, "--type", "hdd", "--medium", filename]
      end
    end
  end

  # Rede para conectar co servidor
  ip1 = '10.10.10.2'
  config.vm.network :private_network, ip: ip1, auto_config: false, nic_type: "virtio"

  # Rede adicional para probas
  # VBox crea 2 adaptadores no mesmo bridge na rede 10.10.20.0/24
  # En Proxmox pode asignarse calqueira IP dentro da rede
  ip2 = '10.10.20.2'
  config.vm.network :private_network, ip: ip2, auto_config: false, nic_type: "virtio"
  ip3 = '10.10.20.3'
  config.vm.network :private_network, ip: ip3, auto_config: false, nic_type: "virtio"

  # script de aprovisionamento (so configura a rede de acceso ao servidor)
  config.vm.provision :shell, path: 'provision.sh', args: ip1
end
