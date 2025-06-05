# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrant file creates a local virtual machine for testing purposes

Vagrant.configure("2") do |config|
  config.vm.define "test_server"
  
  config.vm.box = "almalinux/10"

  # Open our nginx ports
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 443, host: 4040, host_ip: "127.0.0.1"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provision :ansible do |ansible|
   ansible.playbook = "playbooks/security-setup-playbook.yml"
  end

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbooks/vagrant-setup-playbook.yml"
  end

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbooks/webserver-setup-playbook.yml"
    ansible.groups = {
      "webservers" => ["test_server"]
    }
    ansible.host_vars = {
      "test_server" => {
        "ansible_python_interpreter" => "{{ ansible_playbook_python }}"
      }
    }
  end
end
