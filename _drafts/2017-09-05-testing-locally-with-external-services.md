---
layout: post
title:  "Ngrok: "
date:   2017-05-09 12:00:00
tags: [ngrok, web-development, episerver]
comments: true
---

Now and then I run into problems or inconveniences that hinder productivity way more than they should. If I think about the actual problem I get a feeling that best be described like " &@%#* this should not be so hard". Lately I've been working on an integration between Episerver and a payment provider, Klarna. After reading through the docs and coding away happily for a while I ran into one of the aforementioned problems. 

Somewhere during the payment process; Klarna will try to send data to our server. The provided data can be used for various purposes, such as validating payments or processing any additional payment data. Especially while working on integrations you will encounter processes or data flows like this, where you retrieve data from another system in some way, for example through webhooks or http requests. And I guess you've seen this coming as well: how do you do this on your local dev environment? In the past I've tried various options, from forwarding ports and opening my firewall to remote debugging on a test server or even print statement debugging. I remembered skimming through a post about a tool to help us with this problem somewhere last week and fortunately I remembered the name of the tool: Ngrok.

#### What do I need?
In this specific case I know that Klarna will do a post request to a URI I've set myself. I want to be able to debug my code and receive updates from Klarna while I go through the order/payment process. On the site of ngrok you can read the quote "I want to expose a local server behind a NAT or firewall to the internet." and indeed; that is exactly what I want to do.

#### Setting up Ngrok (is a breeze!)
I was up and running within 2 minutes: 

* Downloaded Ngrok from their [download page](https://ngrok.com/download). 
* Unzip ngrok.zip, execute ngrok.exe (or open a command prompt and navigate to the folder with ngrok.exe)
* As I was running the Klarna test site on my local IIS on ``klarna.localtest.me``: execute ``ngrok http klarna.localtest.me:80`` in the command prompt
    * Take note of the provided "forwarding" url (e.g. https://49ffa8de.ngrok.io), any requests to this url will end up on your local machine, in my case on the sub domain ``klarna.localtest.me``
* Add the "forwarding" url to iis as binding for the Klarna test site
    * I browsed to the "forwarding" url and I reached the site that I was running locally
* Use the "forwarding" url in my communication with Klarna

https://localtunnel.github.io/www/
https://news.ycombinator.com/item?id=14278703

> #### tl;dr?
* 