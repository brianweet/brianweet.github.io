---
layout: post
title:  "Low end touchscreen limitations"
date:   2015-04-08 16:13:57
categories: keyboards
---

I like to type fast. I like to type with two thumbs. When you type fast with two thumbs on a Keon or GoFox F15 phone you might notice it does not always register the keys you tried to touch. You might even end up with ***'random'*** characters you thought you did **not** touch. While both phones do have a multi-touch touchscreen, the multi-touch capabilities are somewhat limited.

<p class="center" style="width:320px">
	<img src="/assets/badtime.jpg" alt="Y U NO type slow" style="border: 1px solid #E8E8E8;">
</p>

Lets say you touch the E and the P key at the same time, a normal multi-touch screen would be able to register these two touches and the keyboard could track each of the fingers because they would both get a unique identifier. These low end touchscreens however, will only register one touch. The coordinates of this touch event are not very useful, as the screen will give you an average of the two touches. This means, if you touch the E and P key at the same time, you will end up with just a Y. As far as I found out by trial and error, the touchscreen is divided in horizontal bands (in portrait mode). These bands are not fixed and they are quite big, as can be seen in the image below. One band covers about 2 rows on the keyboard. 

<p class="center" style="width:320px">
	<img src="/assets/bands.png" alt="Touch screen bands example" style="border: 1px solid #E8E8E8;">	
	<span>Example of two touch screen bands, one red band and one yellow band. Multi-touch inside of the boxes would be registered as one touch instead of two.</span>
</p>

These bands have a huge negative effect on typing accuracy because you will see just one input character instead of two. The character you end up with depends on the sequence of touch events, but you often end up with one character <span title="might not be the actual character you touched because of averaging"><ins>_close to_</ins></span> the finger you lift from the screen last. This is bad news, the [edit distance][editdistance] between the expected output and the actual input increases with 2 operations and the autocorrect algorithm has a very hard time correcting these errors.

One idea is to use the phone in landscape mode exclusively, but to be honest I see people type in portrait mode most of the time. Forcing people to type with just one finger is a bit excessive too, so lets try to fix the multi-touch problem in portrait mode!

When you type you usually touch your keys sequentially, lifting your finger from the screen before touching the screen with another finger. For example:

<div style="width: 480px; height: 360px; margin: 10px; position: relative;"><iframe allowfullscreen frameborder="0" style="width:480px; height:360px" src="https://www.lucidchart.com/documents/embeddedchart/8a63508f-1814-491a-9b5a-55a81733bb72" id="EwXslL5~3s6p"></iframe></div>
The E key will be highlighted, the E key will be committed and shown as input, the P key will be highlighted and the P key will be committed and shown as input. It might happen that the timeframes overlap, on a normal device something like this would happen:

<div style="width: 480px; height: 360px; margin: 10px; position: relative;"><iframe allowfullscreen frameborder="0" style="width:480px; height:360px" src="https://www.lucidchart.com/documents/embeddedchart/c152892e-8693-46d2-bc79-dc9a1d68c5e3" id="LwXsu8SP7qOJ"></iframe></div>

So depending if the keyboard highlights two keys at the same time, the correct keys will be committed after the touch for that key ends. On a low end device this will happen:

<div style="width: 480px; height: 360px; margin: 10px; position: relative;"><iframe allowfullscreen frameborder="0" style="width:480px; height:360px" src="https://www.lucidchart.com/documents/embeddedchart/407b62dd-b2c2-4d2c-8056-df8d3a334238" id="GxXsdw~41llP"></iframe></div>

So the first touchend will be ignored and the keyboard receives touchmove events instead. These touchmove events might skip a few keys, these events all depend on the typing speed. But usually after some touchmove events the keyboard receives a touch position on or near the P key and the P key will be shown as input character.

Studying these sequences of events I came up with a hack/fix for the problem. In pseudo code:

* touchstart 
	* register timestamp + coordinates
* touchmove 
	* do nothing (or perhaps track movement speed?)
* touchend 
	* if distance between start and end is big enough
		* if 'speed' is high enough
			* insert start touch as separate keypress

This would mean that if all conditions are met, the user receives E and P as input even though we never received any touchend event on the E key. One downside is that users will be able to fake input like this by swiping across their screen fast enough. 
Based on experimental results with data collected from actual users, this fix results in a nice accuracy improvement! Especially with autocorrect turned on, as the algorithm performs a lot better if you have zero, one or even two transpositions compared to having both a deletion and a transposition.

The bug related to this problem can be found here: [Bug 1080652 - [Tarako] investigate discarding bogus averaged touch events when multiple touches occur in the keyboard][bug]

[editdistance]: http://en.wikipedia.org/wiki/Edit_distance
[bug]: https://bugzilla.mozilla.org/show_bug.cgi?id=1080652
[fix]: https://github.com/brianweet/gaia/commit/1ffbabd0a7f6aa55745287a6cecb0fb65d0678cb
