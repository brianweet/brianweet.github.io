---
layout: post
title:  "Don't worry, take a shower. Automating my mechanical ventilation"
date:   2018-04-02 08:00:00
tags: [home-automation, domotics]
comments: true
---

Almost every time I take a shower I forget something: to turn the knob for my Whole-House mechanical ventilation system. The knob is located in the kitchen; which is not very convenient when you just stepped under a nice hot stream of water.
I went online to figure out what to do, which left me with a couple of options:
- Option 1, easy but expensive: put an extra knob in the bathroom, either by connecting it with a wire or by buying a remote controller / receiver set for my fan
- Option 2, more work but cheap: add a humidity sensor and try to control the fan speed based on that

I decided to do some field work to figure out which sensors to use, what kind of ventilation system I have and how I could wire everything up so I could control the fan automatically.

I knew I still had some simple bme180 TPH (temperature, humidity and pressure) sensors laying around, but a couple of months ago, in Hong Kong, I spotted some sleek devices from Xiaomi/Aqara. As I could buy one for about 6 euro's I decided to try it out, as I could always resort to building my own device anyways.

<p class="centered-image">
	<img src="/assets/home-automation/xiaomi-aqara-tph.png" alt="Xiaomi/Aqara TPH sensor">
</p>

Turns out you do need a Xiaomi gateway as well, but even that only set me back about 20 euro's so I'd say it's still a cheap option as I found out it's really easy to use.


<p class="centered-image">
	<img src="/assets/home-automation/zehnder-cmfe-p.png" alt="Stork Zehnder CMFe P">
</p>

The mechanical ventilation system I have is a Zehnder CMFe P(erilex), with three different settings, low (always-on), medium and high, controlled by the knob in the kitchen (through wires). The first thing that popped into my head is to add a (double) relay to the existing wires, this way it should be possible to set the fan to low, medium or high by using the relays. I found something more interesting while reading through the manual: the fan can be controlled by a 0-10v input. And the good thing is that it's quite easy to find a device that can output a 0-10v signal, as LED dimmers use that same range.

