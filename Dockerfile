# Download base/parent image ubuntu:20.04 from which we build
FROM ubuntu:20.04

# Set the environment variable.
ENV container=docker

# Setting the default timezone
ENV TZ=Africa/Lagos
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Identify the maintainer of this image
LABEL maintainer="philemonnwanne"
LABEL version="1.0"
LABEL description="This is custom Docker Image meant for use with Vagrant."

# Update Ubuntu Software repository
RUN apt-get update -y && \
    apt-get dist-upgrade -y

# Install system dependencies and once all installation is completed, remove all packages cache to reduce the size of the custom image.
RUN apt-get install -y --no-install-recommends tzdata ssh sudo systemd openssh-client && \ 
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# Add vagrant user and key for SSH
RUN useradd --create-home -s /bin/bash vagrant && \ 
    echo -n 'vagrant:vagrant' | chpasswd && \ 
    echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \ 
    chmod 440 /etc/sudoers.d/vagrant && \ 
    mkdir -p /home/vagrant/.ssh && \ 
    chmod 700 /home/vagrant/.ssh && \ 
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys && \ 
    chmod 600 /home/vagrant/.ssh/authorized_keys

# Change ownership of the .ssh directory to vagrant user
RUN chown -R vagrant:vagrant /home/vagrant/.ssh && \ 
    sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers && \ 
    sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config 

# Create the SSH Daemon directory
RUN mkdir /var/run/sshd

# Inform Docker that the container will listen on port 80 for SSH at runtime.
EXPOSE 22

# Start the OpenSSH Daemon
RUN /usr/sbin/sshd

# Command to start up Systemd (systemctl) within our container
CMD [ "/lib/systemd/systemd" ]


# FOR OPTIMIZATION-----------------------------------------------------------------
## (-) I minimized the number of RUN commands, as each RUN command adds a layer to the image, so consolidating the number of RUN can reduce the number of layers in the final image.
### (-) I Used --no-install-recommends when installing packages with apt-get install to disable installation of optional packages and save disk space.
#### (-) Cleaning package lists that are downloaded with apt-get update, by removing /var/lib/apt/lists/* in the same RUN step.