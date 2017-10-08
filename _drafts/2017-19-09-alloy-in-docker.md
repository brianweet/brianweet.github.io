---
layout: post
title:  "Trying out Docker: Alloy demo kit"
date:   2017-09-19 12:00:00
tags: [docker, episerver]
comments: true
---

In this blog I'll be taking another look at [Docker](https://www.docker.com/). The aim is to get the [AlloyDemoKit](https://github.com/episerver/AlloyDemoKit) reference site up and running in Docker containers. I will be running it in two separate containers, one for the site and one for the SQL server. The first goal is to show how we can configure the environments we need in configuration files and provide a consistent experience for every developer checking out the project. The second goal is to have a (fast) way of spinning up a demo or test environment with a known state.

<p class="centered-image">
	<img src="/assets/docker-blog-1/docker-logo.png" alt="Cute Docker logo">	
</p>

### Running alloy in a container
I want to run alloy in Docker containers, all changes can be found in the [docker branch on GitHub](https://github.com/brianweet/AlloyDemoKit/tree/docker). To start off, I've installed [VS tools for Docker](https://marketplace.visualstudio.com/items?itemName=MicrosoftCloudExplorer.VisualStudioToolsforDocker-Preview) as this provides the option to add Docker support from Visual Studio. When you run "Add - Docker Support", a couple of files will be created for you. Let's take a look to see what these files are for: 

* There's a Dockerfile for our web project (in the alloydemo folder)
  * This is a description of how to build an image for our web project. After building we will have an image called alloydemokit. The Dockerfile has a reference to a Microsoft image which includes IIS and adds remote debugging support to that image
* There are multiple docker-compose*.yml file(s) 
  * Configuration for setting up complete environments, with one or multiple 'services'. It is used to configure things like port mappings, volume shares etc
* There's a Docker project (.dcproj)
  * It contains the docker-compose file(s) and is used as startup project to run our project in Docker

 If you run the project it will not run in IIS or IIS express anymore, you'll notice that the run button now says "Docker". A couple of things will happen once you run your project: first it builds the Docker image(s), start the container(s), hook up debug tools and open op the browser with the correct url. All of this can also be done from the command line and you see what is happening in your output window, so no magic here. As we have to use Windows containers, it will take quite a while to build the project for the first time, as the windows images are very big. Fortunately this will only happen the first time (or when you explicitely want to update to a different windows image version) so be patient and make sure that you have plenty of disk space.

After adding Docker support it seems that it now builds an image called ``alloydemokit`` for our web project, using the default Dockerfile. Here's some info from the output window:
```
1>Building alloydemokit
1>Step 1/4 : FROM microsoft/aspnet:4.6.2
1> ---> 8352eb08cfc4
1>Step 2/4 : ARG source
1> ---> Running in 18a750e96125
1> ---> 1a574005157b
1>Removing intermediate container 18a750e96125
1>Step 3/4 : WORKDIR /inetpub/wwwroot
1> ---> f55e03a33d15
1>Removing intermediate container bf30af72d81a
1>Step 4/4 : COPY ${source:-obj/Docker/publish} .
1> ---> 7fe4fbdaf958
1>Removing intermediate container 1fc3a286aa08
1>Successfully built 7fe4fbdaf958
1>Successfully tagged alloydemokit:dev
```
Every command creates a layer and can be cached, therefore only have to be executed if changes have been made. As seen in the output log, our ``alloydemokit`` has a base layer using an image built by microsoft, and three extra layers needed to run our project from VS. 

#### Running SQL in docker
[Microsoft provides images](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=microsoft%2Fmssql&starCount=0) that can be used in order to run SQL in a container. The documentation is quite clear and it's quite easy to get an instance up and running. The image requires you to accept the EULA, set a ``sa`` password an has a parameter to set up databases immediately. Below you can see the docker-compose file I ended up with, with comments to describe what every line is doing.

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
Our ``alloydemokit`` service has to be able to access to the container running the database. With the set up as shown above this is quite easy, as we're using compose, other services can be reached by using the service name as hostname ``Data Source=alloydemokit-db;Initial Catalog=alloydemokit;Integrated Security=False;User ID=sa;Password=All0yDemokit!`` ([see full diff on github](https://github.com/brianweet/AlloyDemoKit/commit/265dd3d18cf958abdf27c2760ca3b3e72ff6bb05#diff-0d9151933f32e2929ddc7906ed378fbdR553)). 

If you want you can use an explicit SQL version by adding a tag behind the image name, for example ``:2016-sp1`` or ``2017``. By default it will use the ``:latest`` tag. 

#### Fixing a runtime error
As you can see in the diff I had to add the .net compilers/compilerplatform nuget packages to fix a weird 'runtime' bug but after that Alloy was up and running in two Docker containers, using the most SQL server version which is not installed on my local machine! (couldn't compile )

#### Fixing another error: lack of websocket support
After logging in I noticed an error about real-time updates, which you can see below. I've seen this error before and I know it has something to do with websockets, so probably the image I'm using (microsoft/aspnet:4.6.2) does not have websocket support. What to do?!

<p class="centered-image">
	<img src="/assets/docker-blog-2/websocket-error.png" alt="Websocket error">
</p>

It's actually quite easy to add extra layers (of changes/data) to existing images, which I figured out in my [previous blog post]({% post_url 2017-17-09-trying-out-docker-build-jekyll-blog %}) about Docker. After a quick search on Google I found out that you can add windows features in powershell using this cmdlet ``Add-WindowsFeature Web-WebSockets`` and indeed, after adding a ``RUN`` command to the [Dockerfile](https://github.com/brianweet/AlloyDemoKit/commit/dd71127447c78caad5edc1ed1addc945c66c3a37) the project rebuilt successfully and the error was gone!

We now have a Dockerfile for our alloydemokit project which has all the features we need in order to run our project. Next to that we have an up to date SQL instance for this project, which we can spin up and down whenever we want and we can update to a new version simply by changing the [tag for the mssql image](https://hub.docker.com/r/microsoft/mssql-server-windows-developer/tags/) in the docker-compose file.

### Pre-built images for demo environments and automated testing
Let's focus on something different, let's to try to create 'self-sufficient' images which will allow us to spin up complete environments for demo or automated testing purposes. These images will contain both the complete environment and all data required to run the alloy demo. This means that your complete environment, including the db, will be in a known state when you start the containers. When you stop the containers, all data will be gone unless you take explicit actions to keep the data. In general you should not store data inside your images if it's not necessary, however including data inside an image can be very useful for demo/test purposes. You will always have a known state to start with, sounds great right!

First start with the web project, change the build configuration to release and try to run the project. After building and running I got a couple of issues regarding file permissions, as this is just a demo [I granted everyone full access](https://github.com/brianweet/AlloyDemoKit/commit/4cf6ac81e209a612cafdc641a57aebe0717d360f#diff-c36ee58e01fc5f7d07dd824b226b433bR6). After that I noticed I was missing the appdata so I also included that in my [csproj](https://github.com/brianweet/AlloyDemoKit/commit/4cf6ac81e209a612cafdc641a57aebe0717d360f#diff-fd43246249295c88b78100e38e8efb25R671). 
That was actually all I had to do, after running the project and checking everything is ok I had a ``alloydemokit`` image which contained all data that's needed to run the project.

We'll also need the database inside an image. Therefore I created a [Dockerfile](https://github.com/brianweet/AlloyDemoKit/blob/docker/Build-sql/Dockerfile) to create an image for the database. To build the image I ran ``docker build . -t alloydemokit-db:test`` which creates an image based on the ``microsoft/mssql-server-windows-developer`` image and copies in the two db files.

The images can be pushed to the [Docker Hub](https://hub.docker.com/) which is a free Docker registry. Pushing an image is also [really easy](https://docs.docker.com/docker-cloud/builds/push-images/), just tag the image with your username and push the image to the repository:
```
docker tag alloydemokit-db brianweet/alloydemokit-db:test
docker push brianweet/alloydemokit-db:test
```

#### Running the pre-built images
If you have Docker installed locally you can try to run the demo/test images I built on alloy. Create a [docker-compose.yml](https://github.com/brianweet/AlloyDemoKit/blob/docker/Run-using-pre-built-images/docker-compose.yml) file with the following content (as mentioned before, it can take quite a while to run this for the first time):
```yml
version: '3'

services:
  alloydemokit:
    image: brianweet/alloydemokit:test # Use pre built image, uploaded to Docker Hub
    ports:
      - "80:80"
    networks:
      - alloy-network
    depends_on:
      - alloydemokit-db
  alloydemokit-db:
    image: brianweet/alloydemokit-db:test
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
```

Now run ``docker-compose up -d`` to start the two containers to run alloy in Docker. If everything succeeds you should be able to browse to the [container instance ip](https://docs.docker.com/engine/reference/commandline/inspect/#get-an-instances-ip-address) and see exactly the same content as you see in this image:

<p class="centered-image">
	<img src="/assets/docker-blog-2/from-docker-hub.png" alt="Using pre-built alloy images with data">
</p>


### Summary
I had two ideas I wanted to try out using Docker.
First I wanted to convert an existing Episerver demo project to use Docker, as it should result in a consistent behaviour of our project across environments. Next to being consistent it will also give us flexibility regarding the software that is being used (SQL server version, enabled windows features). As dev using Docker can eliminate start-up problems when checking out a project for the first time, as we can make configuration explicit and we can move dependencies and requirements on the runtime environment to the container. 
The second idea was to created 'self-sufficient' images, which are available on the Docker hub, in order to start and stop complete environments without any hassle. The images I've built therefore contain all data that is necessary to run the site and they are perfect for demo or automated testing environments. With one docker-compose file and by running one command you can now start up the alloy demo kit in a predefined state. 

Clearly, there's still a lot to be explored if it comes to Docker. But from what I've seen and read I think it is definitely worth the effort as it has potential on so many levels.


> #### tl;dr
* Docker provides a way to have consistent environments with consistent behaviour
* Docker can help 