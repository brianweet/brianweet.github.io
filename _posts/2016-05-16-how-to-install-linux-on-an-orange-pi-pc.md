---
layout: post
title:  "How to install Debian Linux on an Orange Pi PC with node-RED"
date:   2016-05-16 11:07:40
tags: [orangepi, nodered, iot]
comments: true
---

About a month ago I went to the dutch [IoT tech day 2016](http://www.iottechday.nl/), which offered a lot of interesting talks and workshops about Internet of Things. One of my favorite sessions was the hackathon by [TTN](http://thethingsnetwork.org/), where we used a [The Things Uno](https://shop.thethingsnetwork.com/index.php/product/the-things-uno/) device to send sensor data to the LoRa network set-up by the guys from TTN. My sensor of choice was a moisture sensor, which I used in order to measure the moisture content of my cheese sandwich. Nobody likes a wet sandwich right!?

<p class="centered-image">
	<img src="/assets/orange-pi-install/say-cheese.jpg" alt="Say cheese	">	
</p>

To process messages from our devices we used Node-RED; which is a great visual tool for wiring together hardware devices. I created a Node-RED flow to update a real-time JSON database (firebase in this case) which was pretty easy and fun. But the title of this post is about the [Orange Pi PC](http://www.orangepi.org/orangepipc/) so lets cut to the chase!

### The Orange PI PC

During one of the breaks I decided to enter a contest with some coding questions and I was so lucky to win an [Orange Pi PC](http://www.orangepi.org/orangepipc/).
The Node-RED environment we used during the hackathon was only available for one day, which gave me a perfect use case for my new Orange Pi!

I read some post about the Orange Pi PC and most of them were quite negative, so my expectations were not too high. After a few hours of Google'ing and some trial and error I've found a nice image and decided to write this post for further reference. My requirements were quite succinct: I'd like a stable linux image to run Node-RED on.

#### What did I use?

* Orange Pi PC (obviously)
* Samsung 16GB micro SD EVO UHS-I Class 10 48MB/s 
* jacer's Debian Jessie image, [download link](https://mega.nz/#F!y0Y0SZhJ!RD5an8l9qEo_RppBsxxbrQ!y9ZDECra) [forum topic](http://www.orangepi.org/orangepibbsen/forum.php?mod=viewthread&tid=867)
* [Win32DiskImager](https://sourceforge.net/projects/win32diskimager/) 
* [scargill's install script](https://bitbucket.org/snippets/scargill/Md4jr)

So the first step is to download the Debian Jessie image and extract 'Debian8_jacer_2.rar' until you end up with two files: (1) 'Debian8_jacer_2.img' and (2) 'Script.bin and Uimage for OPI-PC_extract to FAT partition.zip'.

In order to write the image file to our SD card we need a tool. I am using Windows and therefore I installed [Win32DiskImager](https://sourceforge.net/projects/win32diskimager/) which is a tool to write img files to your sd card.
Start Win32DiskImager, select 'Debian8_jacer_2.img' and make sure the right device is selected (in my case F:) and write the img to the SD card.
Writing the img file to my SD card took about 3 minutes, with a write speed of about 13~15MB/s.
We're almost ready to boot our Orange Pi, but first I extracted 'uImage' from file (2) to the SD card. Go to your SD card and rename 'script.bin.OPI-PC_1080p60_hdmi_cpu1.2G_gpio30pin' to 'script.bin' and we're ready to go! (I decided to use the 1.2G version as I read a lot of complaints about overheating Orange Pi's and I do not need the CPU power -yet-)

<p class="centered-image">
	<img src="/assets/orange-pi-install/happy-red-led.jpg" alt="Happy red led">	
</p>

Don't be fooled by the red led, everybody knows red is a positive color right? On the Orange Pi the red led means it found a SD card with a correct boot loader. Diagnostics on the Orange Pi are horrible, just hope for a red led because that is basically the only feedback you'll get.

#### Connecting to the Orange Pi
I've connected a monitor with HDMI to the Pi and a basic USB mouse/keyboard. You could also connect to the Pi by using SSH.
In both cases you can log in with the combination orangepi/orangepi. 

#### Resize partition
After booting, log in with the user orangepi and start a terminal session. You will receive a warning message about the size of your partition. If you'd like to resize the partition to the max available size, you can run 'sudo fs_resize'. After resizing you should reboot first.

<p class="centered-image">
	<img src="/assets/orange-pi-install/after_resize.png" alt="Resizing">	
</p>

#### Scargill's install script
I found an [awesome install script](https://bitbucket.org/snippets/scargill/Md4jr) made by Peter Scargill which automates the installation of node-RED, Mosquitto, Apache, SQL-Lite and some other tools (you get to choose what you want to install). Installing everything took about 50 minutes on my Pi, probably a bit slow because of the max CPU frequency of 1.2Ghz.

The scrips disables the graphical UI, if you'd like to keep the graphical UI, you could change the install script (comment [line 417](https://bitbucket.org/snippets/scargill/Md4jr#snippet.txt-417) or run `sudo systemctl set-default graphical.target` and reboot.

If you'd like to access data on your Pi easily, you could change [script line 187](https://bitbucket.org/snippets/scargill/Md4jr#snippet.txt-187) in order to enable network shares.

I've been running this set-up for a few weeks now, without any problems. CPU temp usually around 45°C, which is about 25°C above room temperature.

#### Summary of the running software

* SSH deamon
* FTP server - ftp://orangepi:password@orangepi
* Apache - http://orangepi
* phpliteadmin - http://orangepi/phpliteadmin
* Webmin (very useful system administration tool) - http://orangepi:10000
* Node-RED - http://orangepi:1880
* Mosquitto MQTT broker - http://orangepi:1883
