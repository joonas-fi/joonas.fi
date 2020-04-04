---
layout:     post
title:      'Home automation ideas & my setup'
date:       2020-01-19 10:50:00
tags:       ['home automation']
permalink:  /2020/01/19/home-automation-ideas-and-my-setup/
---

I've got so many good automation ideas from other people, so it's fair that I pay it
forward by listing my own automations so other people can get ideas! I also describe my
setup, gear and my no-cloud policy etc.

Contents:

- [My automations](#my-automations)
- [My gear](#my-gear)
- [Dashboards](#dashboards)
- [No-cloud policy](#no-cloud-policy)
- [Am I happy with the gear?](#am-i-happy-with-the-gear)
- [Roadmap](#roadmap)
- [Links to YouTube](#links-to-youtube)


My automations
--------------

A lazy dump of my automations:

- When nobody's home and I open the apartment door (door/window sensor) and it's dark,
  a hallway light turns on.

- When the last person leaves the apartment, there's a button next to the apartment door
  that makes all the lights/devices turn off.

- When I walk into the kitchen, the bathroom or the bedroom, a light turns on (movement sensor).

- When I sit in the dinner table, the light above it turns on (the chair has a vibration
  sensor).

- When the mail comes, I get a notification (vibration sensor in mailbox hatch).

- When I sit at my work computer, my work lights turn on and when I leave the computer,
  they turn off ([EventGhost](http://www.eventghost.net/) communicates idle + un-idle events
  to my automation software)

- I have my own home office and it has a "doorbell" - just a simple button that makes my
  office lights blink and the music mute for a few seconds (I send event to EventGhost
  that triggers mute + delay + unmute). Why: I might not hear knocks on the door if I'm
  listening to music with headphones.

- When I say `alexa, good night` bedroom lights turn off

- A physical button wired as "last person goes to sleep", which turns off all devices
  (but doesn't set the "nobody's home" -mode like the apartment door button does).

- My ceiling fan is automation-controllable because I hacked a Sonoff Basic
  (wifi-controllable relay) into it.

- I have a couple of water leak sensors so that I get an alert if there's a leak.


Most of the rules are only enabled if it's dark, which is calculated from sun's angle for
this time and location.

Also most of the rules are tied into "somebody's at home" (a human), so if my dog is
home alone and he's walking, it won't trigger the lights.

Everything is controllable by:

- Voice

- Most (but not all) by a physical switch

- From smartphone app 


My gear
-------

First, a drawing:

![Diagram of my home automation architecture](/images/2020/home-automation-diagram.png)

I've got Amazon Echo Dots in almost every room.

All my lights are IKEA Trådfri (except LED strips). I also have the Trådfri remote which
I don't use to directly control lights, but instead they're buttons which I can map to
anything I want in the software.

All my sensors & most buttons are [Xiaomi Aqara](https://www.aqara.com/en/home.html) - I've got:

- Temperature/humidity/air pressure sensor in every room, also outside

- Vibration sensor

- Door/window sensor

- Physical two-button switch (has single/double/hold/etc. clicks), physical one-button
  switch (has single/double/etc. clicks)

- Water leak sensor

I've got a couple Sonoff Basics for turning dumb devices (ceiling fan, built-in lights)
into smart devices.

I also have bluetooth-based LED light strip controllers, but I can't recommend them
(more of this later).

The automations run locally on a Raspberry Pi 3.


Dashboards
----------

I've got dashboards with Prometheus + Grafana from metrics exported by my automation software.

Battery statuses:

![](/images/2020/home-automation-dashboard-batterystatuses.png)

Weather data:

![](/images/2020/home-automation-dashboard-weather.png)

Inside temperatures:

![](/images/2020/home-automation-dashboard-inside-temperatures.png)


No-cloud policy
---------------

My smarthome has a no-cloud policy: I don't want any company:

- Knowing how I use my devices

- Setting times when I'm forced to update software/firmware

- Deciding when my
  [devices stop working](https://www.meethue.com/en-us/support/end-of-support-policy)

- Having possibly insecure/unpatched devices being connected to internet

- Having proprietary software controlling my devices

- Having their cloud (or my internet) go down affect my smart home

How?

- I run all the smarts locally - none of the devices connect to internet

  * With the exception of Echo Dots - Amazon can only mine my voice commands but not
    any other automations.

- I don't use any official (IKEA, Xiaomi) Zigbee gateways, but instead for Zigbee comms I
  use [CC2531](https://www.zigbee2mqtt.io/information/supported_adapters.html) and
  [Zigbee2mqtt](https://www.zigbee2mqtt.io/) to bridge the devices into my Home Automation software.

- I wrote my own home automation software, called
  [Hautomo](https://github.com/function61/hautomo), but you certainly don't have to -
  [Home Assistant](https://www.home-assistant.io/) is open source, free and can run locally.


Am I happy with the gear?
-------------------------

Everything pretty much works, except the bluetooth-based LED light strip controllers. They
have connectivity problems a couple times a month where the device stops being able to be
controlled for like 5 minutes. I need to replace these when I get the time.

All my Zigbee gear (Xiaomi Aqara, IKEA Trådfri) and wifi gear (Sonoff Basic) mostly works
perfectly.

I've had a couple issues where one of the Aqara movement sensors seems to disconnect from
the network and it comes itself back within a couple of days - but that's happened 2-3
times a year. I wish to investigate this, because it's annoying - but it's not a show-stopper.

Overall, I'm happy and can recommend most of my setup.


Roadmap
-------

I wish to get a vacuum robot, but I need to research one with good features/price and one
that is compatible with my no-cloud policy and preferably open source.

Maybe get a security camera at the apartment door.

Make a classy looking [smart mirror](https://www.youtube.com/watch?v=fkVBAcvbrjU).


Links to YouTube
----------------

- [The Hook Up](https://www.youtube.com/channel/UC2gyzKcHbYfqoXA5xbyGXtQ) - great Smart Home channel

- [Paul Hibbert](https://www.youtube.com/channel/UCYLnawaM-36HncBBUeWrlGA) - great Smart Home channel

- [Vacuum Wars](https://www.youtube.com/channel/UCvavJlMjlTd4wLwi9yKCtew) - channel dedicated to vacuum robots
