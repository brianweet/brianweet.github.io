---
layout: post
title:  "Probable keyboard events"
date:   2015-03-11 16:13:57
---

For my master Computer Science at [Leiden University][liacs] and for [Telenor Digital][telenordigital] I am working on a research project to improve the accuracy of the touch screen keyboard on low end devices. I think it is awesome that there are [Firefox OS phones][dolphin] available for a price as low as 2000TK (~25$). So lets try to make the user experience as good as possible! The hardware in [these][keon] low end phones has some quirks that hinder accurate typing. We will try to mitigate for those errors and come up with a model that adapts itself to the user and the phone they use.

All prototypes will be written in Javascript, as I intend to improve the performance of the Firefox OS keyboard. The ideas are generic though, so except for implementation details it should not be too hard to port these ideas to other platforms.

<!---
The model will try to improve typing accuracy for people who make recurring mistakes, e.g. when you recurringly hit (or miss!) your intended keys with a certain offset. 
-->

I will write about 4 parts of the research project, the topics are as follows

* [Implementing a touch model]({% post_url 2015-03-24-implement-touch-model %})
* [Collecting touch data and re-executing touch events]({% post_url 2015-04-07-gathering-data %})
* [Touching your keyboard with two fingers, no way!]({% post_url 2015-04-08-low-end-touchscreen-limitations %})
* Results and //TODO's

#### Accuracy and autocorrection

<div style="float: right; max-width:45%; margin-left: 20px;">
	<img style="max-height:250px;" title="Damn you autocorrect" src="http://cdn.damnyouautocorrect.com/images/meditating.jpg" align="right" />
</div>

So what what is my definition of an accurate keyboard? I would call a keyboard accurate when it allows me to make errors and still give me the result I expected. To meet the expectation of the user, most keyboards use some kind of autocorrection algorithm that tries to correct typos and misspellings. The autocorrect algorithm tries to determine the users' intention by evaluating the input against a (word frequency) dictionary/language model (LM). Corrections occur only when the algorithm finds a candidate word that meets a certain probability threshold. This threshold is important because the candidate word might not be very likely to occur. Determining when to replace the input is a difficult problem, especially when the users' input does not exist in the vocabulary (out-of-vocabulary or OOV). 


[liacs]:      		http://www.liacs.nl/
[telenordigital]: 	http://telenordigital.com/
[autocorrect]: 		http://cdn.damnyouautocorrect.com/images/meditating.jpg
[keon]: 			http://en.wikipedia.org/wiki/GeeksPhone_Keon
[dolphin]:			https://developer.mozilla.org/en-US/Firefox_OS/Phone_guide/Symphony_GoFox_F15