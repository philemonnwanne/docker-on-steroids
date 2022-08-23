![aleksander-vlad-72XGyzo2keM-unsplash](https://user-images.githubusercontent.com/108567784/186233663-65eca80a-e256-4a80-a134-b1a2b10cb7ab.jpg)

## This image is meant for development use only. I strongly recommend against running it in production!

## Supported tags
- `ubuntu` `focal-fossa` `docker` `m1` `linux` `vagrant`

While I don't have the best idea on how to write an article as I have never written one until now, I'm just going to put this out here and who knows maybe someone could pick a thing or two from it. So here goes:

So moving on to my main reason for putting this up here, I had recently started my DevOps program and I'm fortunate to have a new M1 MacBook. And it happened that we were given this particular task to `to run Linux vm's (Ubuntu) on our laptops, using vagrant and virtual box`, "Wow, this should be easy I thought". But a few hours later I'm still sitting in front of my machine and not one vm running.

> `Note` this wasn't my first time using a virtual machine, as I had used VMware, virtual box, hyper-v and kvm sometime during the course of my job. 

There were other alternatives like parallels, Multipass, UTM and fusion or maybe dual-booting my MAC to run some nice Linux flavour like (Asahi Linux, which I'm on currently and it does run at near native speed on M1). Sure, I could have used any of these, but for compliance purposes, and just to be on the same page as the instructor and my fellow students I needed vagrant and docker to work together and free of course😂. I had installed vagrant and Docker earlier and everything worked fine, but when I get to provisioning the vm I hit a dead end. And as some of us know virtualbox doesn't support M1 macs.

This led me to scalping the internet looking for a solution, but there wasn't much help on the issue or some were rather too complicated or couldn't do what I needed them to so I decided to build my own solution. I can't put all the details here as that would be too long a read, but if you're just interested in knowing how I got them both to work seamlessly, or you own an M1 and have a project that requires you to use docker and vagrant, or perhaps you want to (make docker behave like a virtual machine) even though it wasn't really designed to, you can read on.

So you just learned about docker and it's coola nd you're excited to start creating your first container. You import a base image in your dockerfile and create your app then run and Cool, it seems to work. Pretty easy, right?

<samp>Not so fast</samp>🌚

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
- [Dockerfile](Dockerfile)
- [Vagrantfile](Vagrantfile)
- Some Patience😮‍💨

> If you want a guide on how to buid your own dockerfile here's a simple example to get you strated: [Stackify](https://stackify.com/)

## Conclusion

`Disclaimer:` While I have learned a lot about linux, docker and vagrant just trying to make this work, I know I still have a lot to learn. I'm just someone who's trying to make things work, plus there's not much help out there for this issue. So if I've written anything horribly wrong or extremely misguided here please feel free to leave a comment. Also if this has helped you in any way, or if you've encountered this issue before and was able to solve it, I would love to hear how you went about it.
Also I'll be creating a multiplatform image to support multiple architecture in my free time so be on the look out.

## Contribute

How to contribute?

 1. Fork this repo
 2. Create a new branch with your changes
 3. Submit a pull request

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

## License

Copyright © 2022 [philemonnwanne](http://github.com/philemonnwanne). Licensed under [the MIT license](https://github.com/philemonnwanne/docker_systemd-solution/blob/main/LICENSE).
