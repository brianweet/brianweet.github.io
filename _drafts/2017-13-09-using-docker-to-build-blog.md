---
layout: post
title:  "Using docker to build my jekyll blog"
date:   2017-09-13 12:00:00
tags: [docker, jekyll]
comments: true
---

I've been using [jekyll](https://jekyllrb.com/) for my blog site for a while now. It's quite easy to use; but I actually started using it because I am hosting my site on [GitHub pages](https://help.github.com/articles/using-jekyll-as-a-static-site-generator-with-github-pages/). One of the downsides, for me at least, is that you need to install Ruby on your local machine in order to run jekyll and generate the html pages locally. I prefer to proofread my blog in full format before publishing it, therefore I want to be able to run jekyll locally. I've been looking at [docker](https://www.docker.com/) for a while now and thought this might be the ideal opportunity to put it to the test.

### Running jekyll in a linux container
So the first thing you do is search the [docker hub](https://hub.docker.com) to check if there's a container which suits your needs. A quick search on 'jekyll' shows me a couple of docker images, nice!

After some weird errors I decided to write a simple docker compose file, which looks like this:
```yml
version: '3.1'
services:
  site:
    command: jekyll s --drafts --future
    image: jekyll/jekyll:pages
    volumes:
      - .:/srv/jekyll
    ports:
      - 4000:4000
```
After that run ``docker-compose up`` from the console and navigate to http://localhost:4000. The configured command will make sure we can see future posts and draft posts and by default it will watch for changes on the disk. 

### Running jekyll in a windows container

> #### tl;dr?
> 