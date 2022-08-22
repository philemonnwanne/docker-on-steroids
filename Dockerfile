# Download base/parent image ubuntu:20.04 from which we build
FROM ubuntu:focal-fossa

# Identify the maintainer of this image
LABEL maintainer="Philemon Nwanne <philemonnwanne@gmail.com>"
LABEL version="1.0"
LABEL description="This is custom Docker Image meant for use with Vagrant."

# Set the environment variable.
ENV container=docker

# Setting the default timezone
ENV TZ=Africa/Lagos
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update Ubuntu Software repository
RUN apt-get update && \
    yes | unminimize

# Install system dependencies and once all installation is completed, remove all packages cache to reduce the size of the custom image.
RUN apt-get -y install \
    --no-install-recommends \
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
### (-) I Used --no-install-recommends when installing packages with apt-get install to disable installation of optional packages and save disk space.
#### (-) Cleaning package lists that are downloaded with apt-get update, by removing /var/lib/apt/lists/* in the same RUN step.