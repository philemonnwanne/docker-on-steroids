
<p align="center">
  <img width="320" height="280" src="https://github.com/philemonnwanne/docker-on-steroids/blob/main/images/docker.jpg">
  <img width="320" height="280" src="https://github.com/philemonnwanne/docker-on-steroids/blob/main/images/hasicorp.png">
</p>


> If you are here that means you don't like doing things the easy way🌚 so brace yourself🧘🏾‍♂️

## Requirements
- Docker installed: you can download the M1 version here [Docker](https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module)
- Vagrant installed: you can also get it here [Vagrant](https://releases.hashicorp.com/vagrant/2.3.0/vagrant_2.3.0_darwin_amd64.dmg) or run `brew install vagrant` on your terminal
- [Dockerfile](Dockerfile)
- [Vagrantfile](Vagrantfile)
- Some [patience]()😮‍💨

## Docker

There are two ways you can use Docker as provider. Using an image from the Docker registry:
```
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.image = ""
  end
end
```
Or a Dockerfile:
```
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.build_dir = "."
  end
end
```
Using a Dockerfile

First you have to create a directory to store the configuration files for your environment and change to this directory.
```
$ mkdir docker-test
$ cd docker-test
```
Create a Dockerfile:
```
$ touch Dockerfile
```

Add the content of the following Dockerfile that I created:

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

- <samp>All of this sets up a Docker container which doesn't work like a regular Docker container. It runs more like a virtual machine. This means it will be difficult to manage using the normal Docker commands. Once you take it down it will also be difficult to get up again. Best to control it with Vagrant.</samp><br><br>

The official Docker image of Ubuntu 20.04 will be used as specified in FROM ubuntu:focal.

When running `apt-get update -y` or `apt update -y`, it will ask you to configure the timezone, the prompt will wait for you to enter the selected option.

To avoid this, you have to add the configuration options in the `Dockerfile`, by adding the following lines:
```
ENV TZ=Africa/Lagos
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
````
Replacing the value of `TZ` according to your timezone.

# Change TimeZone in Docker containers
<samp>Below are multiple ways in which you can change the timezone of your dockers containers</samp>

## With Docker Engine
The timezone of a container can be set using an environment variable in the docker container when it is created. For example:
```
$ docker run ubuntu:latest date
Sat Feb 27 15:58:32 UTC 2021
$ docker run -e TZ=America/Bogota ubuntu:latest date
Sat Feb 27 15:58:40 Asia 2021
```

## With Dockerfile
We can also control container timezone using the Dockerfile. For this, we first need to install tzdata package and then specify timezone setting using the environmental variable:
```
FROM ubuntu:16.04
 
# tzdata for timzone
RUN apt-get update -y
RUN apt-get install -y tzdata
 
# timezone env with default
ENV TZ=America/Bogota
```
Lets build docker image and run it:
```
# build docker image
$ docker build -t ubuntu_modified_tz:20210221 .

# run docker container
$ docker run ubuntu_modified_tz:20210221 date
Sat Feb 27 16:58:17 America 2021
```

## With Docker Compose
We can control timezone in the container, by setting TZ environment variable as part of docker-compose:
```
version: "3.9"
services:
  ubuntu:
    image: ubuntu:latest
    container_name: ubuntu_container
    environment:
        - TZ=America/Bogota
```

## With Storage Data Volumes
The directory /usr/share/zoneinfo in Docker contains the container time zones available.  The desired time zone from this folder can be copied to /etc/localtime file, to set as default time.

This time zone files of the host machine can be set in Docker volume and shared among the containers by configuring it in the Dockerfile as below:
```
volumes: 
- "/etc/timezone:/etc/timezone:ro" 
- "/etc/localtime:/etc/localtime:ro"
```

The containers created out of this Dockerfile will have the same timezone as the host OS (as set in /etc/localtime file).

This method can also be used to set timezone when using docker compose. However as we have noted above, this might not work for all cases.

## With Kubernetes Pods
Again, we have to rely here on setting up of the TZ variable:
```
spec:
      containers:
      - name: demo
        image: docker.io/ubuntu:latest
        imagePullPolicy: Always
        env:
        - name: TZ
          value: America/Bogota
```
If we are using deployments, we can mention environment variable as part of container spec:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 3
  selector:
    matchLabels:
        app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: demo
        image: docker.io/ubuntu:latest
        imagePullPolicy: Always
        env:
        - name: TZ
          value: America/Bogota
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      terminationGracePeriodSeconds: 0
```
> If the methods listed above do not work for you, you may also choose to use host volumes to map /etc/localtime file with the pods/deployments.


Vagrant requires an SSH connection to access the container and Docker images come only with the root user. You have to configure another user with `root` permissions. That's why the `ssh` and `sudo` packages are required.

In the following lines the `vagrant` user is created and a password assigned. The user wouldn't be required to use a password when running any command that requires `root` permissions. The user is also added to the `sudo` group.
```
RUN useradd --create-home -s /bin/bash vagrant
RUN echo -n 'vagrant:vagrant' | chpasswd
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
```
.ssh directory must be created. This is the directory when configuration files related with SSH connection are stored.
```
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
```
An insecure key is added for the initial configuration. This key will be replaced later when you initialize your virtual environment the first time. Also, the ownership of the `.ssh` directory is changed to `vagrant` user.

```
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
```
You can log in with the `root` user but the password wasn't assigned. You can change the password adding a similar line but changing `vagrant:vagrant` to `root:THEPASSWORDYOUCHOOSE` or after log in.

> Want to buid your own dockerfile, here's a simple guide to get you started: [Stackify](https://stackify.com/)

# Creating your Development Environment
## Vagrant
Vagrant is quite easy to configure if you go through the docs

If you are confused on how to go about the setup, take a look at the [vagrant docker provider ](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjnpYu6r975AhVTnVwKHTKfBFwQFnoECBAQAQ&url=https%3A%2F%2Fwww.vagrantup.com%2Fdocs%2Fproviders%2Fdocker&usg=AOvVaw2OqVQ-HB6hvL96Coi7OP8e) and [vagrant docker provisioning](https://www.vagrantup.com/docs/provisioning/docker) documentation.

- Create the directory where you want to initialize the vagrant configuration file

## Initializing the Vagrant configuration file
- Naviagate into the directory created in step 2 by running `cd directory-name` 
- While in that directory run `touch Vagrantfile` which creates a Vagrantfile
- Copy the contents of my [vagrantfile](Vagrantfile) into yours, it should look just like the image below👇🏾

![vagrant-config-image](https://github.com/philemonnwanne/docker-on-steroids/blob/main/images/vagrant-config.png)

Here you tell Vagrant to build the Docker image from the `dockerhub` and the container can be accessed through SSH and must be always running.

## Creating your container

> `Note:` Docker desktop needs to be running before you run the `vagrant up` command.

Run the `vagrant up --provider=docker` command which should give you an output similar to the one below👇🏾:

![vagrant-up-image](https://github.com/philemonnwanne/docker-on-steroids/blob/main/images/vagrant-up.png)

Wait for the process to complete successfully as it can take a while depending on network. Once you see `Machine booted and ready!` the process is complete and you can now login to your linux virtual machine via SSH.

## Accessing your Linux virtual machine

This final command  `vagrant ssh` allows you access to the newly created virtual machine, and you can confirm this by checking the left part of terminal where you will notice that the curent logged in user is now @```vagrant.```

## NetTools
> If you try runing `ifconfig` and you get the popular error: `-bash: ifconfig: command not found`
> 
> Run the following set of commands to install `net-tools` package and clear the error
- `sudo apt-get update`
- `sudo apt-get install -y net-tools` 

<details><summary>Trouble installing nano🦠</summary>
<p>

#### Run the following code!

```bash
   sudo apt-get update
   sudo apt-get install nano
```

</p>
</details>

## Conclusion

`Disclaimer:` While I have learned a lot about linux, docker and vagrant just trying to make this work, I know I still have a lot to learn. I'm just someone who's trying to make things work, plus there's not much help out there for this issue. So if I've written anything horribly wrong or extremely misguided here please feel free to leave a comment. Also if this has helped you in any way, or if you've encountered this issue before and was able to solve it, I would love to hear how you went about it.
Also I'll be creating a multi architecture image to support multi platform deployments in the furure so be on the look out.

## Contribute

Want to contribute?
 1. Fork this repo
 2. Create a new branch with your changes
 3. Submit a pull request


## License

Copyright © 2022 [philemonnwanne](http://github.com/philemonnwanne). Licensed under [the MIT license](https://github.com/philemonnwanne/docker-on-steroids/blob/master/LICENSE).
