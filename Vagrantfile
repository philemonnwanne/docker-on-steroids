# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.
    config.vm.hostname = "ubuntu"
    # Create a private network
    config.vm.network "private_network", type: "dhcp"
    # Provider-specific configuration so you can fine-tune 
    # Custom configuration for docker
    config.vm.provider :docker do |docker|
      # this is where your Dockerfile lives
      docker.image = "philemonnwanne/ubuntu-mod:20.04"
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