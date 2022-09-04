# -*- mode: ruby -*-
# vi: set ft=ruby :
# Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.hostname = "ubuntu"
  # Create a private network
  config.vm.network "private_network", type: "dhcp"
  # Custom configuration for docker
  config.vm.provider :docker do |docker|
    # this is where your Dockerfile lives
    docker.image = "philemonnwanne/ubuntu-mod:20.04"
    # Make sure it sets up ssh with the Dockerfile
    # Vagrant is pretty dependent on ssh
    docker.has_ssh = true
    # Configure Docker to allow access to more resources
    docker.privileged = true
    docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
    docker.create_args = ["--cgroupns=host"]
  end
  # View the documentation for the provider you are using for more
  # information on available options.
end
