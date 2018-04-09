---
layout: post
title:  "Don't worry, take a shower. Automating my mechanical ventilation"
date:   2018-04-02 08:00:00
tags: [home-automation, domotics]
comments: true
---

<p class="centered-image">
	<img src="/assets/domiticz-xiaomi/home-ventilation.jpg" alt="Mechanical whole-house ventilation">
</p>

Who doesn't like a nice hot shower? Every time I take a shower I forget something quite important: I have to turn on my in home ventilation system to prevent moisture buildup. The bathroom does not have a window so the only way to de-humidify the air is through the air vent. There is one minor problem though... The knob to control the the ventilation system is located in the kitchen; which is not very convenient if you just stepped under a nice hot stream of water.

### Mechanical ventilation
My apartment has an individual ventilation system, which is basically a big fan with some air ducts. I didn't know what kind of system I had, but after removing the lid I found out it is a Stork Zehnder CMFe P(erilex) fan. The kitchen has a, very simple, knob which controls the fan speed. and it has 3 settings, low (which is the minimum setting and is always-on), medium and high. There are three wires connected to the knob, one for each setting.

<p class="centered-image">
	<img src="/assets/domiticz-xiaomi/mechanical-ventilation-system.jpg" alt="Stork Zehnder CMFe P">
</p>

### What to use

In the following sections I'll go through the hardware and software used for this project. As I never done anything like this before, my focus is to get something to work. At the end of this blog post you can find a complete list of used hardware, software and extra info.

### What to use - home automation system

Initially I was reading about home automation on a Dutch tech site, called [Tweakers](https://tweakers.net/). It seemed that a lot of people were using [Domoticz](https://domoticz.com/), which is a lightweight open source home automation system. The documentation seemed quite extensive and it seems to support a lot of different systems (sensors and switches), so I decided to take it for a spin for my project.

### What to use - fan

I went online to figure out what to do with the fan, as I expected that there is more than one way to control it remotely. It left me with these options:

- Option 1, easy but expensive: put an extra switch in the bathroom, either by connecting it through a wire or by buying a remote controller/receiver set for the fan
  - Wire - too much work
  - Wireless - for about 100 euro there is an official remote sender and receiver set, with a switch that you can just stick on the wall easily
  - Wireless - for about 250 euro there's an official humidity sensor + receiver set
- Option 2, custom fan control
  - Relay switch(es) - There are three wires that control the fan speed. By adding some remote controlled relay switches it should be possible to set the fan to the required speed.
  - Variable fan speed - Reading through the manual I found out that the fan has a 0-10v input which controls the fan speed. This means that if you put 0v on the input it runs at the lowest rpm and if you put 10v on the input it runs on the highest RPM.

<p class="centered-image">
	<img src="/assets/domiticz-xiaomi/0-10v-input.jpg" alt="0-10v input">
</p>

I decided to go for the most flexible option: option 2 with variable fan speed. It turns out that it's quite easy to find a device that has 0-10v as output, as LED dimmers use that exact same range. This means that we can add a LED dimmer to the 0-10v input and control the fan speed by using the dimmer.

### What to use - sensors

I knew I still had some simple bme180 TPH (temperature, humidity and pressure) sensors laying around, which I never put to use. However, a couple of months ago, I went to a Xiaomi store in Hong Kong and I spotted some sleek looking home automation devices from Xiaomi/Aqara. The Xiaomi Mi Home system offers a cheap TPH sensor, which also houses a battery and some communication hardware in a very tiny encasing (36mm x 36mm). For about 6 euro's I decided to try it out, as I could resort to building my own device anyways. The gateway was a bit more expensive, around 20 euro's, but still cheap enough and reviews were very positive.

Domoticz also supports these sensors, albeit with some specific [installation instructions](https://www.domoticz.com/wiki/Xiaomi_Gateway_(Aqara)#Adding_the_Xiaomi_Gateway_to_Domoticz) to set up the Gateway and get the sensor values into Domoticz. This is because you have to enable developer mode, after which Domoticz will receive sensor values through the UDP developer API.

<p class="centered-image">
	<img src="/assets/domiticz-xiaomi/xiaomi-aqara-tph.jpg" alt="Xiaomi/Aqara TPH sensor">
</p>	
Here you can see me placing a TPH sensor in an air duct.

### What to use - communication
As I just started with this whole home automation, I decided to go for a cheap and simple option: 433MHz communication. To be able to transmit messages I bought a [FS1000A 433 MHz transmitter](https://www.aliexpress.com/item/433M-TX-RX-Super-regenerative-Module-Wireless-Transmitting-Module-Alarm-Transmitter-Receiver/2024422377.html) for about 1 euro. On the other end I need a LED dimmer with 0-10V output and a 433 MHz receiver. I found the [ACM-LV10 Click-on-click-off LED dimmer](http://www.mediamarkt.nl/nl/product/_klikaanklikuit-acm-lv10-mini-led-controller-1359249.html) for about 20 euro, which communicates on 433 MHz and has 0-10v output.

<p class="centered-image">
	<img src="/assets/domiticz-xiaomi/home-automation.svg" alt="Home automation diagram">
</p>

#### Wiring it all up

- Step 1 - Install Domoticz on the Raspberry, which is a peace of cake: just run `curl -L install.domoticz.com | sudo bash` see [here](https://www.domoticz.com/wiki/Raspberry_Pi#The_.22easy.22_way).
- Step 2 - Set up Xiaomi Mi Home using [this great video tutorial](https://www.youtube.com/watch?v=nkFF284OFRE)
  - Add the Xiaomi gateway and sensor in the Xiaomi app
- Step 3 - [Enable developer mode and add the Xiaomi Gateway to Domoticz](https://www.domoticz.com/wiki/Xiaomi_Gateway_(Aqara)#Adding_the_Xiaomi_Gateway_to_Domoticz)
  - You should now receive sensor updates for the Xiaomi sensor in Domoticz
- Step 4 - Wire up the 433 Mhz receiver and transmitter
  - Wiring tutorial can be found [here]()
  - Run `make all` in the RPi_utils folder
  - Run `sudo ./RFSniffer` and `sudo ./codesend 1234`. The RFSniffer should display `Received 1234`
- Step 5 - Wire up the ACM-LV10 to the CMFe logic board
  - Use an external power supply, the fan is not able to supply enough power, the 12V port is only able to supply 20mA which will cause the ACM-LC10 to turn on but it doesn't actually work
  - Flip dip switch 6 on the board in order to enable the 0-10v input
- Step 6 - Send a message to the ACM-LV10
  - First press the reset button on the device
  - Send any arbitrary code, I've used the code in [this repository](https://github.com/jeroenst/433mhzforrpi) as it has the proper protocol for Klik aan Klik uit devices
  - Interesting article to read about [communication on 433 Mhz](asd)
  

#### Hardware

- Raspberry pi 3 B+ - 40 EUR
- [433 MHz transmitter (FS1000A) and receiver XY-MK-5V) - 1 EUR](https://nl.aliexpress.com/item/433M-TX-RX-Super-regenerative-Module-Wireless-Transmitting-Module-Alarm-Transmitter-Receiver/2024422377.html)
- [Xiaomi Mi Home Gateway - 21 EUR](https://www.gearbest.com/alarm-systems/pp_345588.html)
- [Aqara Temperature Humidity Sensor - 6 EUR](https://www.gearbest.com/access-control/pp_626702.html)
- [ACM-LV10 Click-on-click-off LED dimmer - 19 EUR](http://www.mediamarkt.nl/nl/product/_klikaanklikuit-acm-lv10-mini-led-controller-1359249.html)

#### Software

- [Domoticz](https://www.domoticz.com/wiki/Raspberry_Pi#The_.22easy.22_way)




Turns out you do need a Xiaomi gateway as well, but even that only set me back about 20 euro's so I'd say it's still a cheap option as I found out it's really easy to use.


<p class="centered-image">
	<img src="/assets/domiticz-xiaomi/zehnder-cmfe-p.png" alt="Stork Zehnder CMFe P">
</p>

The mechanical ventilation system I have is a Zehnder CMFe P(erilex). It has three different settings, low (which is the minimum setting and is always-on), medium and high, controlled by the knob in the kitchen (through wires). The first thing that popped into my head is to add a (double) relay to the existing wires, this way it should be possible to set the fan to low, medium or high by using the relays. I found something more interesting while reading through the manual: the fan can be controlled by a 0-10v input. And the good thing is that it's quite easy to find a device that can output a 0-10v signal, as LED dimmers use that same range.

