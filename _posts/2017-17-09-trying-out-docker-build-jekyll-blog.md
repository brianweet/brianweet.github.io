---
layout: post
title:  "Trying out Docker: building my jekyll blog"
date:   2017-09-17 12:00:00
tags: [docker, jekyll]
comments: true
---

> #### tl;dr
> * I want to build and run my Jekyll blog using Docker
> * Docker provides a way to have consistent environments with consistent behaviour
> * Docker hub has a lot of docker images with all sorts of OSses/languages/tools

In this blog I'll be taking a look at [Docker](https://www.docker.com/) which I will use to build my blog site. The aim is to play around with Docker a bit and understand what it is able to offer. The reason to use Docker for this example is that I don't want to install all required tooling on my local machine in order to build my blog.

<p class="centered-image">
	<img src="/assets/docker-blog-1/docker-logo.png" alt="Cute Docker logo">	
</p>

### Jekyll
I've been using [jekyll](https://jekyllrb.com/) for my blog site for a while now. It's quite easy to use; I actually started using it because I am hosting my site on [GitHub pages](https://help.github.com/articles/using-jekyll-as-a-static-site-generator-with-github-pages/). One of the downsides, for me at least, is that you need to install Ruby on your local machine in order to run jekyll. I prefer to proofread my blog in full format before publishing it, therefore I want to be able to run jekyll locally. I've been looking at Docker for a while now and thought this might be the ideal opportunity to put it to the test.

### Running jekyll in a linux container
So the first thing I did was to search the [docker hub](https://hub.docker.com) to check if there's a Docker image available which suits my needs. A quick search on 'jekyll' shows me a couple of Docker images, nice!

After some weird errors I ended up with a simple docker-compose.yml file, quite similar to the ones they have in the docs, and it looks like this:
```yml
version: '3.1'
services:
  site:
    command: jekyll s --drafts --future --force_polling 
    image: jekyll/jekyll:3.5
    volumes:
      - .:/srv/jekyll
    ports:
      - 4000:4000
```
With this docker-compose file I could run ``docker-compose up`` from the console and navigate to http://localhost:4000. The command ``jekyll s --drafts --future --force_polling`` command will make sure we can see draft posts, future posts and it will force polling which will rebuild the site once a file on disk changes.

### Adding live reload
On my previous install I was using jekyll-livereload as a convenient way to let the browser automatically reload the page after re-building. In order to use this feature you have to install the jekyll-livereload Gem, otherwise you'll get an error that the argument ``--livereload`` is unknown. I hardly ever use Ruby but I remembered I could use the Gemfile for this, which can be seen as a NuGet packages.config:
```ruby
source "https://rubygems.org"
gem 'github-pages', group: :jekyll_plugins
group :jekyll_plugins do
   gem "jekyll-feed", "~> 0.6"
   gem 'jekyll-livereload'
end
```
Unfortunately the default jekyll image doesn't seem to be able to install this Gem ``Could not find gem 'jekyll-livereload' in any of the gem sources listed in your Gemfile``. I didn't want to give up and for the sake of trying out Docker I decided to write a Dockerfile.

Writing a Dockerfile will allow you to build your own image; which appends extra layers on top of the existing jekyll/jekyll image. In order to do so I tried to copy over the Gemfile and run ``bundle install``, which should install the necessary Gem. The Dockerfile itself is pretty self-explanatory:
```
FROM jekyll/jekyll:3.5
COPY Gemfile .
RUN bundle install
```
And here is the build output:
```
> docker build . -t jekyll-livereload
Sending build context to Docker daemon  50.34MB
Step 1/3 : FROM jekyll/jekyll:3.5
 ---> 35a9c0f8537b
Step 2/3 : COPY Gemfile .
 ---> f64eb50ce792
Removing intermediate container 0d84de918a16
Step 3/3 : RUN bundle install
 ---> Running in e0066d6ce88b
 ... a lot of output from bundle unstall ...
```
What happened? What you see there is that my Dockerfile results in three different build steps, corresponding to the commands defined in the Dockerfile. Each command creates a new layer, which contains the changes compared to the previous layer. So in my case I would have a base layer, the ``jekyll/jekyll`` image, a second layer with the Gemfile and a third layer with all files affected by running ``bundle install``. All of these layers are read-only and if you start a new container your changes will end up in a new read/write layer, not affect the image itself. The read/write layer will be removed once the container is deleted.  

```
> docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jekyll-livereload   latest              50102fc1806f        46 seconds ago      384MB
```

After building, you can see I now have a ``jekyll-livereload`` image. This image can be pushed to a Docker registry in order to share it easily. In order to use this new image I've updated the docker-compose.yml like so:
```yml
version: '3.1'
services:
  site:
    command: jekyll s --drafts --future --force_polling --livereload --host blog.localtest.me
    image: jekyll-livereload:latest
    volumes:
      - .:/srv/jekyll
    ports:
      - 4000:4000
      - 35729:35729
    extra_hosts:
      - "blog.localtest.me:0.0.0.0"
```
The first thing was to change the image to ``jekyll-livereload``, port 35729 has to be exposed for livereload and I had to hack in a host name in order to be able to load the livereload.js file. Without the hack it tried to load the livereload.js file from the ip address 0.0.0.0, which didn't work. But livereload now works and I don't have to install anything on my local environment. If I would push the image to a Docker registry and switch to a new machine I wouldn't even have to build the image again, just set up the registry as a source and pull the image from there! 

### Summary
This my first experiment with Docker and I tried to focus on the concepts of Docker while fixing a real problem I had. A real benifit of Docker is that it provides a consistent environment no matter where you run it. Setting up the environment can be done by creating simple files you can easily share and make sure you can re-execute the same steps. On development environments it's quite awesome as well, if you need certain tooling just make sure it's available in a docker image and share that image, instead of having to install all sort of tools locally. Use Docker on a build server and you're sure it builds if it builds locally. Everything you do can be simply saved and shared across machines.

<p class="centered-image">
	<img src="/assets/docker-blog-1/works-on-my-machine.png" alt="For real!">	
</p>