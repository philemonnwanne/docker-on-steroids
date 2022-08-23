# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.
    config.vm.hostname = "ubuntu"
    # Create a private network
    config.vm.network "private_network", type: "dhcp"
    # Provider-specific configuration so you can fine-tune various backing 
    # providers for Vagrant.
    # Custom configuration for docker
    config.vm.provider :docker do |docker, override|
      override.vm.box = nil
      # this is where your Dockerfile lives
      docker.image = "philemonnwanne/ubuntu-mod:latest"
      docker.remains_running = true
      # Make sure it sets up ssh with the Dockerfile Vagrant is pretty dependent on ssh
      docker.has_ssh = true
      # Configure Docker to allow access to more resources
      docker.privileged = true
      docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
      docker.create_args = ["--cgroupns=host"]    
    end
    # View the documentation for the provider you are using for more
    # information on available options.
  end