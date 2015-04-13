---
layout: post
title:  "Results and //TODOs"
date:   2015-04-12 16:13:57
---

Preliminary results
A = autocorrect
MT = multi-touch fix
TM = touch model
Error percentage is calculated by taking the Levenshtein distance to the correct sentence

| User          | Uncorrected   |   A   |  A+MT  |  A+TM  |  A+MT+TM  | Sentences |
| ------------- | -------------:| -----:| ------:| ------:| ---------:| ---------:|
| 1 	        |  6.43% 		| 5.36% |  5.00% | 	3.10% | 	2.62% | 		32| 24-03 15:53
| 2 	        |  19.03%		|15.03% | 13.86% | 15.36% |    11.85% |			25| 17-03 16:28
| 3 	        |  14.59%    	|14.95% | 8.06 % | 13.15% | 	7.45% |			77| 24-03 18:56
| 4 	        |  20.47% 		|16.99% | 16.71% | 14.07% |    14.07% |			24| 27-03 15:51 (24-03 16:08)
| 5 	        |  8.52% 	 	| 5.21% |  1.58% | 5.05 % | 	1.42% |			23| 24-03 14:55
| 6 	        |  18.90%		|17.96% | 12.97% | 17.18% |    11.86% |			55| 27-03 16:08 (24-03 16:15)
| 7 	        |  15.70%		|12.18% | 10.96% | 10.96% | 	8.93% | 		29| 24-03 19:59
| 8 	        |  10.04%		| 8.18% |  7.19% | 	6.69% | 	6.57% | 		33| 18-03 16:00

Todo
 * Build touch model while the user is typing. Instead of using pre-annotated data
 * Use the touch model information during autocorrect (use probabilities for nearby keys)
 * Improve autocorrect to detect separate words. Should be able to insert space
 * Handle corrections even if user is typing a new word (fast type / slow device)
 * Take context into account (n-gram model)