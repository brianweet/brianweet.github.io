---
layout: post
title:  "Collecting touch data and re-executing touch events"
date:   2015-03-24 16:13:57
---

To develop a touch model I need data. I couldn't find any public dataset with user typing data so I decided to create an app to collect data myself. The app and the dataset will be publicly available and could be used to improve or compare keyboard performance. [Timdream][timdream] has a nice project called [Online demo page for Mozilla Firefox OS Keyboard][timdreamdemo] which I used as a base for the app. The benefit of his online demo is that it runs on nearly any device.

<p class="center" style="width:320px">
	<iframe width="320" height="480" src="http://timdream.org/gaia-keyboard-demo/" frameborder="0" style="border: 1px solid #E8E8E8;">
	</iframe>
</p>

The data collection app shows the user a sentence that he/she has to type. The sentences are part of the [Enron mobile dataset][enron]. I used the memorable sentences and removed numbers and characters that could not be found on the first 'page' of the default english qwerty layout. Users are not able to see their input, therefore I removed the backspace key as well. By doing so, we will end up with touch information of users that try to type a sentence without doing any corrections.

<p class="center" style="width:320px">
	<img src="/assets/app.png" alt="app" style="border: 1px solid #E8E8E8;">	
</p>

Collecting data is pretty straightforward. First we log information about the users' device, the size of the keyboard and the size of the keys. Every touch event gets logged which means we will end up with information about the event type (touchstart/touchmove/touchend), the dimensions (coordinates, radius, touch identifier), an event timestamp and the target key that the user hit first. All touch events belong to a certain sentence, which means we know what the user was trying to type. After finishing a sentence, the uncorrected keyboard input is logged, which allows us to calculate the error rate and the distance between the expected sentence and the uncorrected keyboard input without having to re-execute the touch events.

-- insert touchevent data example --

To re-execute the recorded touch data I forked the gaia keyboard demo project again. 

[timdream]: https://github.com/timdream
[timdreamdemo]: https://github.com/timdream/gaia-keyboard-demo
[enron]: http://keithv.com/software/enronmobile/