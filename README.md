> How I was able to get systemd to work in a ubuntu:20.04 Docker container on a MacOS (M1) host.
## This image is meant for development use only. I strongly recommend against running it in production!

## Supported tags
- `ubuntu` `focal-fossa` 
- `docker` `M1` `linux` 
- `vagrant` `2.30`

While I don't have the best idea on how to write an article as I have never written one until now, I'm just going to put this out here and who knows maybe someone could pick a thing or two from it. So here goes:

So moving on to my main reason for putting this up here, I had recently started my DevOps program and I'm fortunate to have a new M1 MacBook. And it happened that we were given this particular task to `to run Linux vm's (Ubuntu) on our laptops, using vagrant and virtual box`, "Wow, this should be easy I thought". But a few hours later I'm still sitting in front of my machine and not one vm running...`Note` this wasn't my first time using a virtual machine, as I had used VMware, virtual box, hyper-v and kvm sometime during the course of my job. 

There were other alternatives like parallels, Multipass, UTM and fusion or maybe dual-booting my MAC to run some nice Linux flavour like (Asahi Linux, which I'm on currently and it does run at near native speed on M1). Sure, I could have used any of these, but for compliance purposes, and just to be on the same page as the instructor and my fellow students I needed vagrant and docker to work together and free of course😂. I had installed vagrant and Docker earlier and everything worked fine, but when I get to provisioning the vm I hit a dead end. And as some of us know virtualbox doesn't support M1 macs.

This led me to scalping the internet looking for a solution, but there wasn't much help on the issue or some were rather too complicated or couldn't do what I needed them to so I decided to build my own solution. I can't put all the details here as that would be too long a read, but if you're just interested in knowing how I got them both to work seamlessly, or you own an M1 and have a project that requires you to use docker and vagrant, or perhaps you want to (make docker behave like a virtual machine) even though it wasn't really designed to, you can read on.


So you just learned about docker and it's coola nd you're excited to start creating your first container. You import a base image in your dockerfile and create your app then run and Cool, it seems to work. Pretty easy, right?

<samp>Not so fast.</samp>

You just built a container which contains a minimal operating system, and which only runs your app. But the operating system inside the container is not configured correctly. A proper Unix system should run all kinds of important system services. You're not running them, you're only running your app.

> _But then you ask "What do you mean? I'm just using Ubuntu in Docker. Doesn't the OS inside the container take care of everything automatically?"_

Not quite. You have Ubuntu installed in Docker. The files are there. But that doesn't mean Ubuntu's running as it should.
When your Docker container starts, only the CMD command is run. 

The only processes that will be running inside the container is the CMD command, and all processes that it spawns. That's why all kinds of important system services are not run automatically – you have to run them yourself.

Furthermore, Ubuntu is not designed to be run inside Docker. Its init system, Upstart, assumes that it's running on either real hardware or virtualized hardware, but not inside a Docker container, which is a locked down environment with e.g. no direct access to many kernel resources. Normally, that's okay: inside a container you don't want to run Upstart anyway. You don't want a full system, you want a minimal system. But configuring that minimal system for use within a container has many strange corner cases that are hard to get right if you are not intimately familiar with the Unix system model. This can cause a lot of strange problems.

If you want to know how to build the dockerfile you can check out the readme here [dockerfile](create-dockerfile.md)

Even though vagraant docs stats that it supports dockr as one of it's providers, they are not exactly friends or should I say configuring them to work together isn't quite friendly:

to get docker up and running, youll need a dockerfile, this contains all the instructions that docker needs to build your conatiner. And for your docker conatiner to work together with vagrant you'll need to configure it to behave as a traditional linux machine, which means you ll need at least sshd (which lets you ssh into the machine) and systemd even though it's advised against containers as it makes them mutable thereby less secure.


## Requirements
- Docker installed: you can download the M1 version here [Docker for M1](https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module)
- Vagrant installed: you can also get it here [Vagrant for M1](https://releases.hashicorp.com/vagrant/2.3.0/vagrant_2.3.0_darwin_amd64.dmg) or run `brew install vagrant` on your terminal


## Installing Docker and Vagrant

- After installing Docker and Vagrant you need to confirm your installations by running `docker --version` which should give you an output similar to:

```
Last login: Fri Aug 19 11:24:34 on ttys000
[14:55:35] philemonnwanneⓐPhilemonsMac ~ %  docker --version
Docker version 20.10.17, build 100c701
[14:55:41] philemonnwanneⓐPhilemonsMac ~ %
```

`vagrant --version` should also give an ouput similar to:

```
[14:55:41] philemonnwanneⓐPhilemonsMac ~ %  vagrant --version
Vagrant 2.3.0
[14:57:23] philemonnwanneⓐPhilemonsMac ~ % 
```

> If you want a guide on how to buid your own dockerfile here's a simple example to get you strated: [Stackify](https://stackify.com/)


# Docker
 Here's the Dockerfile that I used

```
# Download base/parent image ubuntu:20.04 from which we build our custome image
FROM ubuntu:focal

# Identify the maintainer of this image
LABEL maintainer="Philemon Nwanne <philemonnwanne@gmail.com>"
LABEL version="1.0"
LABEL description="This is a custom Docker image meant for use with Vagrant."

# Set the environment variable.
ENV container=docker

# Setting the default timezone (in my case [Africa/Lagos])
ENV TZ=Africa/Lagos
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update Ubuntu Software repository
RUN apt-get update && \
    yes | unminimize

# Install system dependencies and once all installation is completed, remove all packages cache to reduce the size of the custom image.
RUN apt-get -y install \
    tzdata \
    openssh-server \
    sudo \
    man-db \
    curl \
    wget \
    vim-tiny && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable systemd (from Matthew Warman's mcwarman/vagrant-provider)
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Enable ssh for vagrant
RUN systemctl enable ssh.service; 

# Inform Docker that the container will listen on port 22 for SSH at runtime.
EXPOSE 22

# Add vagrant user and key for SSH
RUN useradd -m -G sudo -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \
    chmod 440 /etc/sudoers.d/vagrant

# Establish ssh keys for vagrant
RUN mkdir -p /home/vagrant/.ssh; \
    chmod 700 /home/vagrant/.ssh

RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys;

# Change ownership of the .ssh directory to vagrant user
RUN chown -R vagrant:vagrant /home/vagrant/.ssh 

# Start the init daemon
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]


# FOR OPTIMIZATION-----------------------------------------------------------------
## (-) I minimized the number of RUN commands, as each RUN command adds a layer to the image, so consolidating the number of RUN can reduce the number of layers in the final image.
### (-) I used --no-install-recommends when installing packages with apt-get install to disable installation of optional packages and save disk space.
#### (-) Cleaned package lists that are downloaded with apt-get update, by removing /var/lib/apt/lists/* in the same RUN step.

```

- <samp>All of this sets up a Docker container which doesn't work like a regular Docker container. It runs more like a virtual machine. This means it will be difficult to manage using the normal Docker commands. Once you take it down it will also be difficult to get up again. Best to control it with Vagrant. I've had to delete the container and re-create it with Vagrant many times.</samp><br><br>


# Vagrant
Vagrant is quite easy to configure if you go through the docs

Here's my vagrant file:
```

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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  #config.vm.box = "generic/centos7"
  config.vm.hostname = "ubuntu"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "private_network", type: "dhcp"

  # Provider-specific configuration so you can fine-tune various backing providers for Vagrant. These expose provider-specific options.
  
  # Custom configuration for docker
  config.vm.provider :docker do |docker, override|
    override.vm.box = nil

    # this is where your Dockerfile lives
    docker.image = "philemonnwanne/vagrant-provider:20.04"
    docker.remains_running = true

    # Make sure it sets up ssh with the Dockerfile
    # Vagrant is pretty dependent on ssh
    docker.has_ssh = true

    # Configure Docker to allow access to more resources
    docker.privileged = true
    docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
    docker.create_args = ["--cgroupns=host"]
    # Uncomment to force arm64 for testing images on Intel
    # docker.create_args = ["--platform=linux/arm64"]     
  end
  
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", path: "script.sh"
end

```

If you are confused on how to go about the setup, take a look at the [vagrant docker provider ](vagrant.com) and [vagrant docker provisioning](vagrant.com.com) documentation.


## Step 2: Creating your Development Environment

- Create the directory where you want to initialize the vagrant configuration file


## Step 3: Initializing the Vagrant configuration file

- `cd into that directory` which you made in step 3 above and run `vagrant init philemonnwanne/baseimage-ubuntu-20.04 --minimal` to create the Vagrantfile below:

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "philemonnwanne/baseimage-ubuntu-20.04"
end
```


- You should also get a message in your terminal saying:
```
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
[vagrantup.com](vagrantup.com) for more information on using Vagrant.
```
- This confirms that you now have a `Vagrantfile` present in your current working directory and are ready to proceed to the next step.


`Note:` Docker desktop needs to be running before you run the `vagrant up` command.


## Step 4: Creating your container

Run the `vagrant up --provider=docker` command which should give you an output similar to the one below👇🏾:

```

I'll embedd an image here

```

Wait for the process to complete successfully as it can take a while depending on network. Once you see `Machine booted and ready!` the process is complete and you can now login to your linux virtual machine via SSH.


## Step 5: Accessing your Linux virtual machine

This final command  `vagrant ssh` allows you access to the newly created virtual machine, and you can confirm this by checking the left part of terminal where you will notice that the curent logged in user is now @```vagrant.```


## NetTools
> If you try runing `ifconfig` and you get the popular `-bash: ifconfig: command not found` error
Just run the following commands to install net-tolls and fix the error
- `sudo apt-get update`
- `sudo apt-get install -y net-tools` 


## Conclusion

`Disclaimer:` While I have learned a lot about linux, docker and vagrant just trying to make this work, I know I still have a lot to learn. I'm just someone who's trying to make things work, plus there's not much help out there for this issue. So if I've written anything horribly wrong or extremely misguided here please feel free to leave a comment. Also if this has helped you in any way, or if you've encountered this issue before and was able to solve it, I would love to hear how you went about it.
Also I'll be creating a multiplatform image to support multiple architecture in my free time so be on the look out.

## Contribute

How to contribute?

 1. Fork this repo
 2. Create a new branch with your changes
 3. Submit a pull request

## License

MIT - see the accompanying [LICENSE](https://github.com/tknerr/vagrant-docker-baseimages/blob/master/LICENSE) file

## <samp>Credits and References:</samp>

- https://dev.to/mattdark/using-docker-as-provider-for-vagrant-10me
- https://dev.to/taybenlor/running-vagrant-on-an-m1-apple-silicon-using-docker-3fh4
- https://www.howtoforge.com/tutorial/how-to-create-docker-images-with-dockerfile/
- https://phusion.github.io/baseimage-docker/#intro
- https://docs.docker.com/engine/reference/builder/#usage
- https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container
- https://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/#hack_to_run_container_in_the_background
- https://github.com/hashicorp/vagrant/issues/8769
- https://www.vagrantup.com/docs
- https://stackoverflow.com/questions/34677042/vagrant-and-docker-provider
- https://medium.com/theleanprogrammer/shipping-docker-learn-to-build-docker-image-for-ubuntu-20-04-fe9b082fd3f4
- https://docs.docker.com/engine/reference/builder/#buildkit
