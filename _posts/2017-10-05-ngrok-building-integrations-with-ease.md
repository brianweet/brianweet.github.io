---
layout: post
title:  "Ngrok: building integrations with ease. A public endpoint for local development"
date:   2017-05-10 12:05:00
tags: [web-development, episerver]
comments: true
---

Occasionaly I run into problems that hinder productivity way more than they should. If I think about what the actual problem is, I get a feeling that best be described as " &@%#* this should not be so hard". Lately I've been working on an integration between Episerver and a payment provider, Klarna. After reading through the docs and coding away happily for a while, I ran into one of the aforementioned problems. 

<p class="centered-image">
	<img src="/assets/ngrok/simple-or-hard.gif" alt="Easy peasy bag squeezy">
</p>
<a href="https://www.bloomberg.com/news/features/2017-04-19/silicon-valley-s-400-juicer-may-be-feeling-the-squeeze" target="_blank">
    <strong>Easy peasy bag squeezy: "Two investors in Juicero were surprised to learn the startup’s juice packs could be squeezed by hand without using its high-tech machine."</strong>
</a>

#### What am I doing?
Somewhere during the payment process Klarna will try to send some data to our server. The provided data can be used for various purposes, such as validating payments or processing any additional payment data. Especially while working on integrations you will encounter processes or data flows like this, where you retrieve data from another system in some way, f.e. through webhooks or http requests. If you're a dev you probably guessed the 'problem' I am trying to address: how do you do test/debug flows like this on your local dev environment? 

In the past I've tried various options, from forwarding ports and opening my firewall to remote debugging on a test server or even print statement debugging. But today is different, I remembered skimming through a post about a tool last week and fortunately I remembered the name of the tool: [ngrok](https://ngrok.com/).

#### What do I need?
In this specific case I know that Klarna will do a post request to a url which I can configure. I want to be able to debug my code and receive those requests from Klarna on my local environment while I go through the order/payment process. On the site of ngrok you can read the quote "I want to expose a local server behind a NAT or firewall to the internet." and indeed; that is exactly what I want to do.

#### Setting up Ngrok (is a breeze!)
I was up and running within 2 minutes: 

* Downloaded Ngrok from their [download page](https://ngrok.com/download). 
* Unzip ngrok.zip, execute ngrok.exe (or open a command prompt and navigate to the folder with ngrok.exe)
* As I was running the Klarna test site on my local IIS on ``klarna.localtest.me``: execute ``ngrok http klarna.localtest.me:80`` in the command prompt
    * Take note of the provided "forwarding" url (e.g. https://49ffa8de.ngrok.io), any requests to this url will end up on your local machine, in my case on the sub domain ``klarna.localtest.me``
* Add the "forwarding" url to IIS as binding for the Klarna test site
    * If you now browse to the "forwarding" url (which is publicly available) you will reach the site that is running locally
* Use the "forwarding" url in my communication with Klarna

<p class="centered-image">
	<img src="/assets/ngrok/command-prompt.png" alt="Ngrok in command prompt">
</p>

That's it, all incoming requests on the forwarding url will end up on my local dev environment!

#### Some cherries
With only the basic functionality I would've been happy already, but wait, there is more. You can easily inspect and replay requests using the web interface. And even though I hardly never close Fiddler I really really like the simplicity and usefulness.

<p class="centered-image">
	<img src="/assets/ngrok/cherries-and-cake.png" alt="Nice">
</p>

As a disclaimer I've only used ngrok for a day and I haven't explored any other functions it may provide for. I didn't try any other tools that might do the same, as setting up ngrok was flawless from the start. If I'd use it more often I will probably look into a paid account, as that will allow you to pick your own subdomain ("forwarding" url).

[Recent HN discussion](https://news.ycombinator.com/item?id=14278703)