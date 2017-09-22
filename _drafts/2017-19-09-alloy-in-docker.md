---
layout: post
title:  "Trying out Docker: Alloy with Docker"
date:   2017-09-17 12:00:00
tags: [docker, jekyll]
comments: true
---

In this blog I'll be taking another look at [Docker](https://www.docker.com/). The aim is to get the [AlloyDemoKit](https://github.com/episerver/AlloyDemoKit) reference site up and running in Docker containers. I will be running it in two separate containers, one for the site and one for the SQL server.

<p class="centered-image">
	<img src="/assets/docker-blog-1/docker-logo.png" alt="Cute Docker logo">	
</p>

### Running the Alloy site in a container
The first step is to make sure you have [VS tools for Docker](https://marketplace.visualstudio.com/items?itemName=MicrosoftCloudExplorer.VisualStudioToolsforDocker-Preview), this will give you the optino to add Docker support to your project. So I opened up the AlloyDemoKit solution and clicked on the menu item to add docker to my project. This will do a couple of things for you, for example create a Docker .dcproj, create a docker compose file and a Dockerfile for your project. So what is it and what do you need it for?
The .dcproj will allow you to just press F5 in order to build and start debugging. This will build the image(s), start the container(s) set up debug tools and open op the browser with the correct url. 

Unfortunately the site didn't seem to work


```
1>Building alloydemokit
1>Step 1/5 : FROM microsoft/aspnet:4.6.2
1> ---> 8352eb08cfc4
1>Step 2/5 : RUN Add-WindowsFeature Web-WebSockets
1> ---> Running in 0f70f79551be
1>Success Restart Needed Exit Code      Feature Result
1>------- -------------- ---------      --------------
1>True    No             Success        {WebSocket Protocol}
1> ---> a1326308d4dd
1>Removing intermediate container 0f70f79551be
1>Step 3/5 : ARG source
1> ---> Running in 18a750e96125
1> ---> 1a574005157b
1>Removing intermediate container 18a750e96125
1>Step 4/5 : WORKDIR /inetpub/wwwroot
1> ---> f55e03a33d15
1>Removing intermediate container bf30af72d81a
1>Step 5/5 : COPY ${source:-obj/Docker/publish} .
1> ---> 7fe4fbdaf958
1>Removing intermediate container 1fc3a286aa08
1>Successfully built 7fe4fbdaf958
1>Successfully tagged alloydemokit:dev
```


### Summary
This my first experiment with Docker and I tried to focus on the concepts of Docker while fixing a real problem I had. A real benifit of Docker is that it provides a consistent environment no matter where you run it. Setting up the environment can be done by creating simple files you can easily share and make sure you can re-execute the same steps. On development environments it's quite awesome as well, if you need certain tooling just make sure it's available in a docker image and share that image, instead of having to install all sort of tools locally. Use Docker on a build server and you're sure it builds if it builds locally. Everything you do can be simply saved and shared across machines.

<p class="centered-image">
	<img src="/assets/docker-blog-1/works-on-my-machine.png" alt="For real!">	
</p>

> #### tl;dr
* Docker provides a way to have consistent environments with consistent behaviour
* Docker hub has a lot of docker images with all sorts of OSses/languages/tools



version: '3'

services:
  alloydemokit:
    image: alloydemokit:test
    networks:
      - alloy-network
    ports:
      - "80"
    depends_on:
      - alloydemokit-db
  alloydemokit-db:
    image: alloydemokit-db:test
    ports:
      - "1433:1433"
    environment: 
      - ACCEPT_EULA=Y
      - sa_password=All0yDemokit!
      - attach_dbs="[{'dbName':'alloydemokit','dbFiles':['C:\\alloydemokit.mdf','C:\\alloydemokit_log.ldf']}]"
    networks:
      - alloy-network
networks:
  alloy-network:
    external:
      name: nat 
  default:
    external:
      name: nat

	  version: '3'

services:
  alloydemokit:
    image: alloydemokit:test
    networks:
      - alloy-network
    depends_on:
      - alloydemokit-db
  alloydemokit-db:
    image: alloydemokit-db:test
    ports:
      - "1433:1433"
    environment: 
      - ACCEPT_EULA=Y
      - sa_password=All0yDemokit!
      - attach_dbs="[{'dbName':'alloydemokit','dbFiles':['C:\\alloydemokit.mdf','C:\\alloydemokit_log.ldf']}]"
    networks:
      - alloy-network
networks:
  alloy-network:
    external:
      name: nat