---
layout: post
title:  "Collecting touch data and re-executing touch events"
date:   2015-04-07 16:13:57
---

I couldn't find any public dataset with user typing data so I decided to create an app to collect data. The app and the dataset will be publicly available and can be used to improve or compare keyboard performance. [Timdream][timdream] has a nice project called [Online demo page for Mozilla Firefox OS Keyboard][timdreamdemo] which I used as a base for the app. The benefit of his online demo is that it runs on nearly any device.

The data collection app shows the user a sentence that he/she has to type. The sentences are part of the [Enron mobile dataset][enron]. I used the memorable sentences and removed numbers and characters that could not be found on the first 'page' of the default English qwerty layout. Users are not able to see their input, and I removed the backspace key as well. By doing so, the dataset consists of touch information of users that try to type a sentence without doing any corrections.

<p class="center" style="width:320px">
	<img src="/assets/app.png" alt="app" style="border: 1px solid #E8E8E8;">	
</p>

Collecting data is pretty straightforward. First we log information about the users' device, the size of the keyboard and the size of the keys. Every touch event gets logged which means we will end up with information about the event type (touchstart/touchmove/touchend), the dimensions (coordinates, radius, touch identifier), a timestamp and the target key. All touch events belong to a certain sentence, which means we know what the user was trying to type. When the user is done typing a sentence, the uncorrected keyboard input is logged, which allows us to calculate the error rate and the distance between the expected sentence and the uncorrected keyboard input without having to re-execute the touch events. 

Because we know what the user is trying to type, it is possible to annotate touch events quite easily. We just iterate the recorded touch events chronologically and search for touchend events. Each touchend event will result in a single input character and we can annotate it with the character the user was trying to type.

<p class="center" style="width:320px">
	<img src="/assets/brianweet_typing_session.png" alt="app" style="border: 1px solid #E8E8E8;">	
	<span>One of my typing sessions. Green dots are on target, red dots missed my intended target.</span>
</p>

### Execute recorded touch events again

So we have data, now what? We would like to be able to re-execute or emulate the users' typing efforts, allowing us to change the underlying keyboard and compare algorithm performance. To re-execute the recorded touch data I forked the gaia keyboard demo project once more. The 'emulator project' runs in an iframe. The benefit of an iframe is that it is trivial to change the dimensions of the iframe. We have to do because we want to keep the app as generic as possible, therefore we resize the iframe based on the data we recorded about the users' device dimensions. 
To emulate a sentence, an array of touch events is sent to the iframe by using [postMessage][iframepost]. Inside the iframe we create (fake) touch events and schedule them according to the recorded information. To test a different algorithm, we could simply load a different version of our keyboard in the iframe. After executing all touch events we get a result back from the iframe, we can use this result to compare word error rates between different correction algorithms.   

<p class="center" style="width:320px">
	<video width="320" height="478" autoplay controls loop>
		  <source src="/assets/emulate_movie.webm" type="video/webm">
		  <source src="/assets/emulate_movie.ogv" type="video/ogg">
		  <source src="/assets/emulate_movie.mp4" type="video/mp4">
		Your browser does not support the video tag.
	</video> 
	<span>Executing recorded data, user tries to type 'Where do you want to meet to walk over there'.</span>
</p>

[timdream]: https://github.com/timdream
[timdreamdemo]: https://github.com/timdream/gaia-keyboard-demo
[enron]: http://keithv.com/software/enronmobile/
[iframepost]: https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage