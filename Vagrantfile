# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure("2") do |config|
  config.vm.box = "debian/jessie64"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provision "shell", path: "init.sh"
end
