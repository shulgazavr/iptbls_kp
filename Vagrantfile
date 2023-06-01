MACHINES = {

# routers
## ir-net 192.168.255.0/24
## cr-net 192.168.0.0/24
  :IR1 => {
        :box_name => "centos/7",
        :net => [
                  {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "ir-net"},
                ]
  },
  :IR2 => {
        :box_name => "centos/7",
        :net => [
                  {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "ir-net"},
                ]
  },
  :CR => {
        :box_name => "centos/7",
        :net => [
                  {ip: '192.168.255.3', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "ir-net"},
                  {ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "cr-net"},
                ]
  },

  # servers
  :CS => {
        :box_name => "centos/7",
        :net => [
                  {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "cr-net"},
                ]
  },    
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
        config.vm.define boxname do |box|
              box.vm.box = boxconfig[:box_name]    
              box.vm.host_name = boxname.to_s
              
              boxconfig[:net].each do |ipconf|
                box.vm.network "private_network", ipconf
              end
              
              if boxconfig.key?(:public)
                box.vm.network "public_network", boxconfig[:public]
              end

              box.vm.provision "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                      cp ~vagrant/.ssh/auth* ~root/.ssh
              SHELL
              
              case boxname.to_s
                  when "IR1"
                    box.vm.provision "shell", path: "playbooks/files/IR1/prepare_os_IR1.sh"
                  when "IR2"
                    box.vm.network "forwarded_port", guest: 8080, host: 1234, host_ip: "127.0.0.1", id: "nginx"
                    box.vm.provision "shell", path: "playbooks/files/IR2/prepare_os_IR2.sh" 
                  when "CR"
                    box.vm.provision :ansible do |ansible|
                      ansible.playbook = "playbooks/playbook-CR.yml"
                    end
                    box.vm.provision "shell", path: "playbooks/files/CR/prepare_os_CR.sh" 
                  when "CS"
                    box.vm.provision :ansible do |ansible|
                      ansible.playbook = "playbooks/playbook-CS.yml"
                    end
                    box.vm.provision "shell", path: "playbooks/files/CS/prepare_os_CS.sh" 
              end
        end
  end
end
