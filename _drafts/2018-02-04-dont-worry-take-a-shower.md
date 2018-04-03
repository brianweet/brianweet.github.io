---
layout: post
title:  "Don't worry, take a shower. Automating my mechanical ventilation"
date:   2018-04-02 08:00:00
tags: [home-automation, domotics]
comments: true
---

<p class="centered-image">
	<img src="/assets/home-automation/home-ventilation.jpg" alt="Mechanical whole-house ventilation">
</p>

Who doesn't like a nice hot shower? Every time I take a shower I forget something quite important: I have to turn on my in home ventilation system to prevent moisture buildup. The bathroom does not have a window so the only way to de-humidify the air is through the air vent. One minor problem though... The knob to control the the ventilation system is located in the kitchen; which is not very convenient if you just stepped under a nic-e hot stream of water.

<p class="centered-image">
	<img src="/assets/home-automation/3-level-knob.png" alt="Ventilation control knob">
</p>

### Current set up
My apartment has an individual home ventilation system, after removing the lid I found out it is a Stork Zehnder CMFe P(erilex) fan. The kitchen has a, very simple, knob which controls the fan speed. and it has 3 settings, low (which is the minimum setting and is always-on), medium and high. There are three wires connected to the knob, one for each setting.

<p class="centered-image">
	<img src="/assets/home-automation/zehnder-cmfe-p.png" alt="Stork Zehnder CMFe P">
</p>

### What to use

In the following sections I'll go through all of the hardware and software used for this project. At the end of this blog post you can find a complete list of hardware and extra info.

### What to use - home automation system

Initially I was reading about home automation on a Dutch tech site, called [Tweakers](https://tweakers.net/). It seemed that a lot of people were using [domoticz](https://domoticz.com/), which is a lightweight open source home automation system. The documentation seemed quite extensive and it seems to support a lot of different systems, so I decided to take it for a spin for my project.

### What to use - fan

I went online to figure out what to do with the fan, as I expected that there would be a couple of ways to control it remotely. It left me with these options:

- Option 1, easy but expensive: put an extra switch in the bathroom, either by connecting it through a wire or by buying a remote controller/receiver set for the fan
  - Wire - too much work
  - Wireless - for about 100 euro there is an official remote sender and receiver set, with a switch that you can just stick on the wall easily
  - Wireless - for about 250 euro there's a humidity sensor + receiver set
- Option 2, custom fan control
  - Relay switch(es) - There are three wires that control the fan speed. By adding some remote controlled relay switches it should be possible to set the fan to the required speed.
  - Variable fan speed - Reading through the manual I found out that the fan has a 0-10v input which controls the fan speed. This means that if you put 0v on the input it runs at the lowest rpm and if you put 10v on the input it runs on the highest RPM.

<p class="centered-image">
	<img src="/assets/home-automation/0-10v-input.png" alt="0-10v input">
</p>

I decided to go for the most flexible option: option 2 with variable fan speed. It turns out that it's quite easy to find a device that has 0-10v as output, as LED dimmers use that exact same range. This means that we can add a LED dimmer to the 0-10v input and control the fan speed by using the dimmer.

### What to use - sensors

I knew I still had some simple bme180 TPH (temperature, humidity and pressure) sensors laying around, which I never put to use. However, a couple of months ago, I went to a Xiaomi store in Hong Kong and I spotted some sleek home automation devices Xiaomi/Aqara. They offer a TPH sensor, which also houses a battery and means of communication in a very tiny package. For about 6 euro's I decided to try it out, as I could always resort to building my own device anyways. The gateway was a bit more expensive, around 20 euro's, but still cheap enough and reviews were very positive.

Domoticz also supports these sensors, albeit with some specific [installation instructions](https://www.domoticz.com/wiki/Xiaomi_Gateway_(Aqara)#Adding_the_Xiaomi_Gateway_to_Domoticz) to set up the Gateway.

<p class="centered-image">
	<img src="/assets/home-automation/xiaomi-aqara-tph.png" alt="Xiaomi/Aqara TPH sensor">
</p>

### What to use - custom communication
As I just started with this whole home automation, I decided to go for a cheap and simple option: 433mhz communication. I bought a [ACM-LV10 Click-on-click-off LED dimmer](http://www.mediamarkt.nl/nl/product/_klikaanklikuit-acm-lv10-mini-led-controller-1359249.html), which communicates on 433mhz and has 0-10v output.




Turns out you do need a Xiaomi gateway as well, but even that only set me back about 20 euro's so I'd say it's still a cheap option as I found out it's really easy to use.


<p class="centered-image">
	<img src="/assets/home-automation/zehnder-cmfe-p.png" alt="Stork Zehnder CMFe P">
</p>

The mechanical ventilation system I have is a Zehnder CMFe P(erilex). It has three different settings, low (which is the minimum setting and is always-on), medium and high, controlled by the knob in the kitchen (through wires). The first thing that popped into my head is to add a (double) relay to the existing wires, this way it should be possible to set the fan to low, medium or high by using the relays. I found something more interesting while reading through the manual: the fan can be controlled by a 0-10v input. And the good thing is that it's quite easy to find a device that can output a 0-10v signal, as LED dimmers use that same range.

