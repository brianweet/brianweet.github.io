---
layout: post
title:  "Trying out Docker: Alloy demo kit"
date:   2017-09-19 12:00:00
tags: [docker, jekyll]
comments: true
---

In this blog I'll be taking another look at [Docker](https://www.docker.com/). The aim is to get the [AlloyDemoKit](https://github.com/episerver/AlloyDemoKit) reference site up and running in Docker containers. I will be running it in two separate containers, one for the site and one for the SQL server.

<p class="centered-image">
	<img src="/assets/docker-blog-1/docker-logo.png" alt="Cute Docker logo">	
</p>

### Running the alloy in a container
I've installed [VS tools for Docker](https://marketplace.visualstudio.com/items?itemName=MicrosoftCloudExplorer.VisualStudioToolsforDocker-Preview) as this gives me an easy way of adding Docker support to an existing project. Adding Docker support will do a couple of things for you, for example create a Docker .dcproj, create a docker compose file and add a Dockerfile for our project. So what are the other files what do we need it for?
The .dcproj is the Docker project file. It contains the docker-compose file(s) which hook everything up together. It also will allow us to press F5 in order to build and start debugging. This will build the image(s), start the container(s) set up debug tools and open op the browser with the correct url. All of this can also be done from the command line, and you see what is happening in your output window, so no magic here. As we have to use Windows containers, it will take quite a while to build the project for the first time, as the windows images are very big. This has to happen only once (or when you explicitely want to update the windows image) so be patient.

After adding Docker support it seems that we can build an image called ``alloydemokit`` for our web project:
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

As said before I want to run the database in a container as well and fortunately Microsoft provides images for that. Below you can see the docker-compose file I ended up with, with comments to describe what every line is doing.

```yml
version: '3'
services:
  alloydemokit: # Service for our web project
    image: alloydemokit # Image name
    build: # Info needed to build the image
      context: .\AlloyDemoKit
      dockerfile: Dockerfile
    networks: # We'll be using a network I've defined below called alloy-network
      - alloy-network # This allows communication between containers based on the service name
    depends_on: # the db is required
      - alloydemokit-db
  alloydemokit-db:
    image: microsoft/mssql-server-windows-developer # Empty sql server instance
    ports:
      - "1433:1433"
    environment: 
      - ACCEPT_EULA=Y
      - sa_password=All0yDemokit! # This sets the sa account password
      - attach_dbs="[{'dbName':'alloydemokit','dbFiles':['C:\\data\\alloydemokit.mdf','C:\\data\\alloydemokit_log.ldf']}]"
      # Attach dbs will attach the database files once the server has started
    volumes: # This will map the App_Data folder on my PC to c:/data in the container (R/W)
      - ./AlloyDemoKit/App_Data:C:/data/
    networks:
      - alloy-network
networks: # Used to redirect traffic and make communication between containers possible
  alloy-network:
    external:
      name: nat
```
Now all I had to do was [change the connection string](https://github.com/brianweet/AlloyDemoKit/commit/265dd3d18cf958abdf27c2760ca3b3e72ff6bb05#diff-0d9151933f32e2929ddc7906ed378fbdR553) to reflect the docker db instance and add the .net compilers/compilerplatform nuget packages and alloy was up and running in two Docker containers, using the latest SQL server which is not installed on my local machine!

#### Adding websocket support
After logging in I noticed an error about real-time updates, which you can see below. I've seen this error before and I know it has something to do with websockets, so probably the default image does not have websocket support. What to do?!

<p class="centered-image">
	<img src="/assets/docker-blog-2/websocket-error.png" alt="Websocket error">
</p>

It's actually quite easy to add extra layers to existing images, which I figured out in my [previous blog post]({% post_url 2017-17-09-trying-out-docker-build-jekyll-blog %}) about Docker. After a quick search on Google I found out that you can add windows features in powershell using this cmdlet ``Add-WindowsFeature Web-WebSockets`` and indeed, after adding a ``RUN`` command to the [Dockerfile](https://github.com/brianweet/AlloyDemoKit/commit/dd71127447c78caad5edc1ed1addc945c66c3a37) the project rebuilt successfully and the error was fixed!

#### Pre-built images for demo environments and testing
The next thing I wanted to try was creating 'self-sufficient' images which will allow me to spin up a complete environment for demo or testing purposes. This way you will always have a known state to start with, sounds great right!


### Summary


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