---
layout: post
title:  "Running linux mssql on windows using LCOW"
date:   2018-04-26 01:00:00
tags: [docker, episerver]
comments: true
---

I got a popup from Docker a while ago mentioning LCOW containers. The acronym stands for Linux Containers On Windows, which made me happy for some reason. Why you may ask? One of the first things I tried to do with docker was to run two containers, one based on Linux and one based on Windows (as I'm usually stuck with IIS). Unfortunately I found out that I was asking for the impossible, or at least not-viable-for-me at that moment. But with LCOW this will change, I decided to enable the experimental features and see what all the fuss is about.

#### Running simple example
So I switched docker to use Windows containers and tried to run the example from [lcow](https://github.com/linuxkit/lcow). ``docker run --platform linux --rm -ti busybox sh``

<p class="centered-image">
	<img src="/assets/mssql-linux/first-try.png" alt="First try LCOW, success">	
</p>

Magic. It works on the first try! Expectations are rising, will it actually work without any problems?! (I had quite some problems when I first started with docker, had no experience with the concept neither so that didn't help)

<p class="centered-image">
	<img src="/assets/mssql-linux/im-so-excited.jpg" alt="So excited, I just can't hide it">	
</p>

#### Running mssql-server-linux with LCOW
The [windows image for mssql](https://hub.docker.com/r/microsoft/mssql-server-windows-developer/) is quite big, 15GB when I was using it a while ago. I did update the image to a newer version, reducing the size to 10.8GB [(see edit on this post)]({% post_url 2017-09-10-alloy-in-docker %}), but it's still huge compared to the linux image for mssql. Next to that it seems obvious that the linux image is the way to go, just look at the last updated dates or the pull stats: 

<p class="centered-image">
	<img src="/assets/mssql-linux/different-images.png" alt="Mssql docker image stats">	
</p>

As the initial try went so smooth, I was excited and full of hope:
``docker run --platform linux --rm -ti -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong(!)Password' -p 1433:1433 microsoft/mssql-server-linux``

<p class="centered-image">
	<img src="/assets/mssql-linux/need-memory.png" alt="Need memory">	
</p>

Ah ok so it does start but it needs more memory, I've seen this before, no problem. Just change the memory setting somewhere.. But where?!

After some searching in the app, searching online, trial and error I found out that it's not possible to change the default memory size set for the lcow container. That's a real shame because it means I still can't do what I initially wanted to. Memory and CPU settings task is not [started yet](https://github.com/moby/moby/issues/33850). The bug for this can be found [here](https://github.com/Microsoft/opengcs/issues/145).
One of the posts mentioned that it should be possible to hardcode a value and recompile docker to make it work. I couldn't resist to give it a try.

#### Hardcoding MemoryMaximumInMB and recompiling docker
Everyone knows how much fun it is to compile completely unknown stuff in a completely unknown stack. Slightly hesitating I started searching in the moby repository to figure out how to compile docker. I found [the dockerfile for windows](https://github.com/moby/moby/blob/master/Dockerfile.windows), with some great documentation inside:

<p class="centered-image">
	<img src="/assets/mssql-linux/build-docs.png" alt="Build documentation">
</p>

Basically you check out the source code and they provide some scripts and a docker file which starts a container and builds docker within that container.
Between step 2 and 3 I opened up the `client_local_windows.go` file and added a hardcoded value for `MemoryMaximumInMB`, [see commit](https://github.com/brianweet/moby/commit/cacae69f7adc35800becd7eb044642b1267279d1).

<p class="centered-image">
	<img src="/assets/mssql-linux/hardcoded-memorysize.png" alt="Hardcoded memory size">
</p>

I ended up with a custom compiled dockerd.exe, all that was left was to stop docker, replace the dockerd.exe and restart docker (for me dockerd was located at `C:\Program Files\Docker\Docker\resources`). Let's see what happens if I try to start mssql now:

<p class="centered-image">
	<img src="/assets/mssql-linux/no-more-memory-error.png" alt="No more memory error">
</p>

Yay, the memory error is gone! I probably did something wrong with the env variables though but that's not important, at least now sql is able to start and doesn't complain about memory restrictions anymore.

#### Running Alloy demo with mssql-server-linux
As with the previous Alloy example, I decided to create a db image which includes the database itself. The linux image does not have an `attach_dbs` params, so I decided to copy over the code from the [mssql-node-docker-demo-app](https://github.com/twright-msft/mssql-node-docker-demo-app/) and adapted it to my needs. After addng all of the data to the image, we're left with just 1.73GB, a huge difference from the previous 10.8GB/15GB!

If you want to run Alloy demo using the linux container, use [this docker-compose](https://github.com/brianweet/AlloyDemoKit/blob/docker-linux/Run-using-pre-built-images-linux/docker-compose.yml) file:
```yml
version: '3'

services:
  alloydemokit:
    image: brianweet/alloydemokit:v2
    networks:
      - alloy-network
    depends_on:
      - alloydemokit-db
  alloydemokit-db:
    image: brianweet/alloydemokit-db:linux
    networks:
      - alloy-network
networks:
  alloy-network:
    external:
      name: nat
```
**Note: you might have to pull the image in first using `docker pull --platform linux brianweet/alloydemokit-db:linux`**

<p class="centered-image">
	<img src="/assets/mssql-linux/like-to-live-dangerously.jpg" alt="Like to live dangerously?">
</p>

If you're feeling adventurous or you just don't care about any laws of nature, common sense or just trust me on my blue/green/grey eyes, my compiled dockerd.exe can be found [in this rar](/assets/mssql-linux/dockerd.rar).