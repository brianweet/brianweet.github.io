---
layout: post
title:  "Using docker to build my jekyll blog"
date:   2017-09-13 12:00:00
tags: [docker, jekyll]
comments: true
---

I've been using [jekyll](https://jekyllrb.com/) for my blog site for a while now. It's quite easy to use; I actually started using it because I am hosting my site on [GitHub pages](https://help.github.com/articles/using-jekyll-as-a-static-site-generator-with-github-pages/). One of the downsides, for me at least, is that you need to install Ruby on your local machine in order to run jekyll and build your site locally. I prefer to proofread my blog in full format before publishing it, therefore I want to be able to run jekyll locally. I've been looking at [docker](https://www.docker.com/) for a while now and thought this might be the ideal opportunity to put it to the test.

### Running jekyll in a linux container
So the first thing you do is search the [docker hub](https://hub.docker.com) to check if there's a container which suits your needs. A quick search on 'jekyll' shows me a couple of docker images, nice!

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
On my previous install I was using jekyll-livereload as a convenient way to let the browser automatically reload the page after re-building. In order to use this feature you have to install the jekyll-livereload Gem, otherwise you'll get an error that the argument ``--livereload`` is unknown. I hardly ever use Ruby but I remembered I could create a Gemfile, which can be seen as a NuGet package.config:
```
source "https://rubygems.org"
group :jekyll_plugins do
   gem 'jekyll-livereload'
end
```
Unfortunately the default jekyll image doesn't seem to be able to install this Gem ``Could not find gem 'jekyll-livereload' in any of the gem sources listed in your Gemfile``. I didn't want to give up and for the sake of trying out docker I decided to write a Dockerfile.

Writing a Dockerfile will allow you to build your own image which appends extra layers on top of the existing jekyll/jekyll image. So my idea was to copy over the Gemfile and run ``bundle install``, which should install the necessary Gem. The Dockerfile itself is pretty self-explanatory:
```
FROM jekyll/jekyll:3.5
COPY Gemfile .
RUN bundle install
```
Same goes for the build output:
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
.....
> docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jekyll-livereload   latest              50102fc1806f        46 seconds ago      384MB
```
Looks like it worked, as I now had a jekyll-livereload image and no errors during the build process. After this I updated the docker-compose.yml to use the newly created image and, hopefully, enable live-reload:
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
We have to expose port 35729 for livereload and I added a hack in order to be able to load the livereload.js file. Without the hack it tried to load the livereload.js file from the ip address 0.0.0.0, which didn't not work. I've added blog.localtest.me in my windows host file so it points to localhost. After that the livereload.js file started to load correctly and my page refreshed automatically after saving a file.

### Summary


> #### tl;dr?
> 