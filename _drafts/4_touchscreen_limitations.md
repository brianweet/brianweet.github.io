---
layout: post
title:  "Low end touchscreen limitations"
date:   2015-03-24 16:13:57
---

I like to type fast. I like to type with two thumbs. When you type fast with two thumbs on a Keon or Dolphin phone you might notice it does not register keys you tried to touch but end up with ***'random'*** characters you did **not** touch. While both phones have a multi-touch touchscreen, the multi-touch capabilities are somewhat limited.

Multi-touch works fine if you touch the top and the bottom of your screen. However, if you touch the E and the P key at the same time, the keyboard registers something like a Y or a U. As far as I could find out by trial and error, the touchscreen is divided in a few of bands. Which means the touchscreen is only capable of registering one finger on the keyboard at the same time. This means, given example of touching the E and P simultaneously, you miss both the E and the P key and end up with a complete wrong character instead. This is bad news, the [edit distance][editdistance] between the expected output and the actual input increases with 2 operations and the autocorrect algorithm has a very difficult time correcting these errors. 

![Y U NO type slow](/assets/badtime.jpg)

So we could use the phone in landscape mode or try to fix the problem in portrait mode. Lets pick the latter just for fun.
When you type you usually touch your keys sequentially, for example:

-- insert sequential touch --

Our problem occurs when the timeframes overlap, as such:

-- insert overlapping touch --

The keyboard will register the touch events like this:

-- insert overlapping - one touch --

My brain went into hacky mode and came up with this solution:

* touchstart 
	* register timestamp + coords
* touchmove 
	* do nothing
* touchend 
	* if distance between start and end is big enough
		* if 'speed' is high enough
			* insert start touch as seperate keypress

Based on experimental results with my test data this hack results in a nice accuracy improvement!
The autocorrect algorithm performans a lot better if you just nearly miss one or two of your keys (transpositions) instead of having both a deletion and a transposition.

[editdistance]: http://en.wikipedia.org/wiki/Edit_distance