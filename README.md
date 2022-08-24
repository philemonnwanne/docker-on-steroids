# Building a Linux VM with Vagrant and Docker on M1 💻
![aleksander-vlad-72XGyzo2keM-unsplash](https://user-images.githubusercontent.com/108567784/186233663-65eca80a-e256-4a80-a134-b1a2b10cb7ab.jpg)

## This image is meant for development use only. I strongly recommend against running it in production!⚙️

## Supported tags
- `ubuntu` `focal-fossa` `docker` `m1` `linux` `vagrant`

I had recently started my DevOps program at [AltSchool](altschoolafrica.com) and I'm fortunate to have a new M1 MacBook. It happened that we were given a task to `to run Linux vm's (Ubuntu) on our laptops, using vagrant and virtual box`, "Wow, this should be easy I thought". But a few hours later I'm still sitting in front of my machine and not one vm running. For compliance purposes, I needed vagrant and docker to work together and free of course😂. I had installed vagrant and Docker earlier and everything worked fine, but when I got to provisioning the vm I hit a dead end. And as some of us know virtualbox doesn't support M1 macs. This led to me scalping the internet looking for a solution, but there wasn't much help on the issue or some were rather too complicated or couldn't do what I needed them to so I decided to build my own solution. 

## Requirements
- Docker installed: you can download the M1 version here [Docker for M1](https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module)
- Vagrant installed: you can also get it here [Vagrant for M1](https://releases.hashicorp.com/vagrant/2.3.0/vagrant_2.3.0_darwin_amd64.dmg) or run `brew install vagrant` on your terminal
- [Dockerfile](Dockerfile)
- [Vagrantfile](Vagrantfile)
- Some Patience😮‍💨

## Links to get you started
> - [Basic Installation](https://github.com/philemonnwanne/docker_systemd-solution/blob/main/docs/basic-installation.md)
> - [Nerdy installation](https://github.com/philemonnwanne/docker_systemd-solution/blob/main/docs/nerdy-installation.md) (still under development)

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
