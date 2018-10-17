---
layout: post
title:  "Web of things: a 'thing' wrapper around my home ventilation fan"
date:   2018-10-17 12:00:00
tags: [iot, wot, web-development, home-automation]
comments: true
---

A while ago I've created a system to be able to control my [home ventilation fan]({% post_url 2018-15-04-dont-worry-take-a-shower %}) by using a 433mhz remote dimmer. In this post I will be using [Mozilla IoT](https://iot.mozilla.org/) to create a 'Web Thing' out of that same home ventilation fan.

The main reason is that I want to be able to control my 'Things' easily, as I'm a web developer I prefer to use common web technologies to control my Things. The [Web Thing API](https://iot.mozilla.org/wot/) initiative tries to standardize the definition of a Thing and it's properties, which already seems to support my simple requirements.

For example; a Things Gateway UI with various Web Things.

<p class="centered-image">
	<img src="https://2r4s9p1yi1fa2jd7j43zph8r-wpengine.netdna-ssl.com/files/2018/10/Screen-Shot-2018-10-09-at-16.17.59.png" alt="Mozilla Things Gateway">
</p>

## Installing the gateway

I will need set-up two essential pieces... within my network. First I need a Things Gateway in order to monitor and control the Web Things in my network. Fortunately Mozilla provides instructions to [set-up such a gateway](https://iot.mozilla.org/gateway/). As I didn't want to reinstall my raspberry pi I've chosen to check out the code and set up the gateway myself, using the [installation instructions](https://github.com/mozilla-iot/gateway/blob/master/README.md).

If you need any help with this let me know, for me it went very smooth and within no-time I had a Things Gateway set up with a public url provided by Mozilla. Basically I followed the instructions, the scripts in the [gateway/image](https://github.com/mozilla-iot/gateway/tree/master/image) folder are very helpful as well.

<p class="centered-image">
	<img src="/assets/mozilla-iot/empty-gateway.png" alt="Empty Things gateway">
</p>

## Wrapping the fan with a Web Thing

The second step is to create a Web Thing that exposes certain properties, in this case an on and off switch and a dim/level property. The fan has 16 different speed levels and can be turned off (basically means we end up with 17 levels, as 'off' is the lowest setting). Turning the fan off actually sets it to 'idle', it's mandatory for the fan to be running as that is needed to ventilate the house.

In my previous blog post I've already created some scripts that allow me to control the fan. On my raspberry I have a script called `set-fan-level.sh`, calling this script will turn on the fan and set it to a certain speed. For example `./set-level-fan.sh 15` turns on the fan on full speed and `./set-level-fan.sh 0` turns on the fan at the speed level just above 'idle'.

In order to create a web thing I've used the `webthing` npm package. I've created a Web Thing with two properties, an [OnOffProperty](https://iot.mozilla.org/schemas/#OnOffProperty) and a [LevelProperty](https://iot.mozilla.org/schemas/#LevelProperty).

The LevelProperty determines the speed of the fan, if I change the speed of the fan I immediately turn on the fan as well.

The OnOffProperty reads the value of the LevelProperty and turns on the fan by calling the `set-fan-level.sh` script, or it turns the fan off by calling the `stop-fan.sh` script.

Without further ado, here is the code:
```ts

import { runScript } from './run-script';
const { Property, Thing, Value } = require('webthing');
const path = require('path');

const startFanScript = path.resolve(__dirname, '../fan-scripts/set-level-fan.sh');
const stopFanScript = path.resolve(__dirname, '../fan-scripts/stop-fan.sh');
const onOffPropertyName = 'on';
const fanLevelPropertyName = 'level';

export class WebFanThing extends Thing {
    constructor() {
        super('Home ventilation fan', ['OnOffSwitch'], 'Home ventilation fan');
        this.addProperty(
            new Property(
                this,
                onOffPropertyName,
                new Value(false, (v: boolean) => {
                    console.log('On-State is now', v);
                    const levelProp = this.getProperty(fanLevelPropertyName);
                    if (v) {
                        runScript(startFanScript, [`${levelProp}`]);
                    } else {
                        runScript(stopFanScript);
                    }
                }),
                {
                    '@type': 'OnOffProperty',
                    label: 'On/Off',
                    type: 'boolean',
                    description: 'Whether the fan is turned on',
                }
            )
        );
        this.addProperty(
            new Property(
                this,
                fanLevelPropertyName,
                new Value(15, (v: number) => {
                    console.log('Fan level is now', v);

                    // Schedule 'turn fan on'
                    setTimeout(() => {
                        const onOffProp = this.findProperty(onOffPropertyName);
                        onOffProp.setValue(true);
                    }, 0);
                }),
                {
                    '@type': 'LevelProperty',
                    label: 'Fan speed level',
                    type: 'number',
                    description: 'The fan level from 0-15',
                    minimum: 0,
                    maximum: 15,
                }
            )
        );
    }
}
```

As you can see the implementation is pretty straight forward. I've defined the fan as a OnOffSwitch, this allows me to switch it off easily from the Things Gateway UI. The LevelProperty can be set in the Web Thing 'details, and it ensures the OnOffProperty is set to true.

<p class="image">
	<img src="/assets/mozilla-iot/webthing-setup-and-trigger.gif" alt="Web Things set up and trigger">
</p>

But how does the geteway find the Web Thing? Of course this is no magic, but fortunately the `webthing` package does most of the work for you. All you have to do is set up what kind of thing you have (single or multiple) and which port you want to use and you're done:
```ts
const { SingleThing, WebThingServer } = require('webthing');
import { WebFanThing } from './webfan-thing';

function runServer() {
    const thing = new WebFanThing();

    // If adding more than one thing, use MultipleThings() with a name.
    // In the single thing case, the thing's name will be broadcast.
    const server = new WebThingServer(new SingleThing(thing), 8888);

    process.on('SIGINT', () => {
        server.stop();
        process.exit();
    });

    server.start();
    console.log('Web fan server started');
}

runServer();
```

You can see the capabilities of your Web Thing by browsing to the url `http://raspberry-ip-address:8888`.

```json
{
  "name": "Home ventilation fan",
  "href": "\/",
  "@context": "https:\/\/iot.mozilla.org\/schemas",
  "@type": [
    "OnOffSwitch"
  ],
  "properties": {
    "on": {
      "@type": "OnOffProperty",
      "label": "On\/Off",
      "type": "boolean",
      "description": "Whether the fan is turned on",
      "href": "\/properties\/on"
    },
    "level": {
      "@type": "LevelProperty",
      "label": "Fan speed level",
      "type": "number",
      "description": "The fan level from 0-15",
      "minimum": 0,
      "maximum": 15,
      "href": "\/properties\/level"
    }
  },
  "actions": {},
  "events": {},
  "links": [
    {
      "rel": "properties",
      "href": "\/properties"
    },
    {
      "rel": "actions",
      "href": "\/actions"
    },
    {
      "rel": "events",
      "href": "\/events"
    },
    {
      "rel": "alternate",
      "href": "ws:\/\/192.168.0.210:8888"
    }
  ],
  "description": "Home ventilation fan"
}
```

You can use normal REST operations against the properties, for example a GET on `/properties/level` gives me `{"level":7}`. If I want to change the level I can do a simple PUT with the new level:

```
PUT http://192.168.0.210:8888/properties/level HTTP/1.1
User-Agent: Fiddler
Host: 192.168.0.210:8888
Content-Type: application/json; charset=utf-8
Content-Length: 12

{"level":15}
```

## Conclusion

I hope I have showed you how easy it is to wrap an existing (physical) device using the Web Things API. The first thing I did was to install the Things Gateway on my Raspberry pi in order to monitor and control the Web Things in my network.

Then I've defined a Web Thing for my home ventilation fan and exposed it by using the `webthings` npm package. The Things Gateway is accessible from outside of my network and they provide a nice PWA that you can install (if you have android at least).