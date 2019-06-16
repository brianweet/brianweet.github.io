---
layout: post
title:  "Using AI to write haiku poems"
date:   2019-06-16 18:00:00
tags: [ai, gpt2, art]
comments: true
---
Every now and then, <s>usually after a bottle of wine</s>, my girlfriend asks me if I can explain her 'computer things'. She (B.A. in Art History) then <s>rambles on</s> talks with passion about how she believes that the IT-world could make a huge difference in the art world and the research that goes with it.

When I was working on my previous blog post about the language model from [OpenAI called GPT-2](https://openai.com/blog/better-language-models/), I got the 'computer things'-question again. So I <s>tried to explain</s> explained her how the language model works, which made her wonder if it was possible to combine the 'GTP-thing' and something 'artsy'. She talked about recognizable and unrecognizable patterns and how in art, too, were patterns to be found. Although I always listen to what she has to say, I cannot reproduce any of the two hundred examples she mentioned.

So here we are: in this blog post we'll try to write haiku poems using the GPT-2 language model.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">An old pond, a frog jumps, the sound of water. M Basho <a href="https://twitter.com/hashtag/haiku?src=hash&amp;ref_src=twsrc%5Etfw">#haiku</a> <a href="https://twitter.com/hashtag/Japan?src=hash&amp;ref_src=twsrc%5Etfw">#Japan</a><a href="http://t.co/GfiQP60tJ9">http://t.co/GfiQP60tJ9</a> <a href="http://t.co/L6TSdNSHoi">pic.twitter.com/L6TSdNSHoi</a></p>&mdash; Mitsuru Nagata (@nagatayakyoto) <a href="https://twitter.com/nagatayakyoto/status/624946361683701760?ref_src=twsrc%5Etfw">July 25, 2015</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

#### What is a haiku poem?

For those who don't know what a haiku is: it is a Japanese form of poetry. For some reason they teach about it in Dutch elementary school (from my N=2 survey among friends). There are a couple of rules, although they are not strictly enforced as they do not translate to English very well.

#### Features of haiku by [Literary Devices](https://literarydevices.net/haiku/)

- It contains **three** lines.
- It has **five** moras (syllables) in the first line, **seven** in the second, and **five** in the last line.
- It contains 17 syllables in total.
- A Haiku poem does not rhyme.
- Haiku poems frequently have a **kigo**, or **seasonal** reference.
- Haiku poems are usually about **nature** or natural phenomena.
- The poem has two **juxtaposed** subjects that are divided into two **contrasting** parts.
- In English, this division between two parts can be shown by a colon or a dash.

<a href="https://www.oldpondcomics.com/student.html" target="_blank">
  <img src="/assets/gpt-2-haiku/opchestnuts.gif" alt="old pond chestnuts" class="no-zoom" />
</a>

#### Haiku examples by [Literary Devices](https://literarydevices.net/haiku/)

```txt
Example #1: Old Pond (By Basho)
Old pond
a frog jumps
the sound of water
```

*In this example, we can clearly see two contrasting parts of the poem: one is about a frog that is jumping, and second is about the sound of water.*

```txt
Example #2: Book of Haikus (By Jack Kerouac)
Snow in my shoe—
Abandoned
Sparrow’s nest
```

*This haiku is presenting an image in the first part of “snow in my shoe”. In addition, there are two contrasting ideas that mingle with one another as the second part is about nature.*

```txt
Example #4: Thirds (By Jeffrey Winke)
Song birds
at the train yard’s edge
two cars coupling
```

*Personification is also a definite trait of haiku poetry. This is to assign a human quality or qualities to nonhuman things, though this is less prevalent in haiku as compared to metaphors. In this poem, personification is very well done, hence allowing the poem to speak for itself.*

### Training GPT-2

At the time of writing my [previous GPT-2 blog post]({% post_url 2019-15-04-introducing-ai-content-editor %}), the OpenAI team only released a small pre-trained model with no means of training it yourself. By now, things have changed and there's a lot of info on how to train the model using your own data. To train the model I used [Google Colab](https://colab.research.google.com/), an awesome service which allows you to use powerful vm environments with Tesla T4 GPU for free (yes, really!).

As the idea is to let the GPT-2 model 'write' haiku, I searched for a proper haiku dataset and ended up with this repo by [docmarionum1](https://github.com/docmarionum1/haikurnn/) which contains a dataset of about 140k haiku (well... sort of, more about this later).
In order to train the model I've used [this Jupyter notebook by ak9250](https://github.com/ak9250/gpt-2-colab/blob/master/GPT_2.ipynb) and updated it a bit to load my own dataset. If you want, you can try it as well. Here's the notebook I used to train our latest model with a dataset of about 15k haiku:

<a href="https://colab.research.google.com/github/brianweet/gpt-2-haiku/blob/master/train/GPT_2_Haiku.ipynb" target="_blank">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab" class="no-zoom"/>
</a>

As the dataset is relatively small, training didn't take too long. After just a couple of minutes we started to see some promising results already.

### Some preliminary results

Now for the most interesting part, can the model actually create something useful?

The results I show here are just some small excerpts generated during the training process. My girlfriend and I handpicked these haiku so they're definitely not representative. We chose these because we think they are funny, weird and perhaps a bit shocking, but also because we think they have some features of a proper haiku. We also noticed that it has a thing for moths, so we added some moth-haiku too.

The results of the high quality dataset (300KB - haikuzao) with *kigo (season)*, nature and *kireji (contrast)* are fairly decent. There is a lot of variation and most haiku sound like thoughtful poems - even the ones mentioning moths have a certain je ne sais quoi.

Any text after ``## is our commentary``.
*Tip: try to visualize the poem.*

#### run1 - haikuzao

```txt
## nature / seasonal

late summer -
on the wall
all the birds

Spring thaw
the slow drip-drip
of his sweat ## I didn't expect that

a cold morning
those eyes of mine
search for warmth

## funny-ish

nude beach -
a bird is seen ## what kind of bird? ;)
shifting positions

spring morning
the sound of birds
and the scent of birds ## Ok..? ## Ha, fried chicken.

## heavy

long July morning
bombs raining down
on an already dark street

Summer Sunday night...
I ask my ex
if she's cheating

distant thunder
she screams in pain
the car stops

## weird

Christmas Eve  -
a dead horse in the yard ## Yummy, horse meat.
for sale

Summer Sunday morning...
someone
has been watching her boobs ## bad style

## moths!

a moth hover ## moths can't spell
in front of the TV
watching TV

late evening
a moth flies
over the teakettle ## steamed moth

lonely day
the smell of a moth
on the stairs
```

That looks promising! The grammar is sound and, for us, they look like real haiku poems: able to draw a picture in your head, at times taking an unexpected turn.

<a href="https://www.oldpondcomics.com/master.html" target="_blank">
  <img src="/assets/gpt-2-haiku/op24hour15.gif" alt="an unexpected turn" class="no-zoom"/>
</a>

#### run2 - full dataset (cleaned)

Combining all datasets we found, six in total (95k haiku, at least 80% twaiku), gave us completely different results. The structure looks like a haiku, but the writing style and topics are... peculiar? We're no experts, but twaiku, a haiku posted on Twitter, might be of a different quality.

Cleaning the dataset was done in a very rough manner, removing 45K haiku, basically deleting complete outliers with long sentences or with the wrong number of lines.

Take a look at the haiku below and spot the difference:

```txt
I should be able get
 a job just so I can eat
the meal I want now

How do I keep
 myself comfortable without
my pants on at night

You should put all your
 anger into writing a song
I'm ready for it

It's nice that the
 weather's nice I really
do feel happy today

## cute
The best way to show that
 someone loves you is to let
them know with a smile

My dog is acting
 like a baby so I'm starting
his puppy naps now

I've never seen the
 stars yet, but it seems like
we are seeing them

## truthful
No one who is still
 in high school is even
trying to graduate

When you're the president
 of America your job is to
keep people happy

## dark / heavy
The best things about
 getting off life support is
your body can go ahead

I'm not your real dad
 and I don't want anything from you
you're not my boy
```

We didn't like the output from this run much, most haiku were just regular sentences formatted in a clear structure (short-long-short, like the 5-7-5 syllable structure). The topics were quite [contemporary](https://en.wikipedia.org/wiki/Contemporary_art) and contained of a lot of first-world problems.

#### run3 - haikuzao - sballas - tempslibres

These results show us how important choosing the right dataset is. As we're not doing scientific research here, we decided on what kind of result we're looking for. Therefore we chose to remove the twaiku and two other 'low quality' datasets, definitely based on our 'expert' knowledge, and ended up with about 15k haiku (~1MB txt file - haikuzao - sballas - tempslibres).

```txt
Christmas madness--
over dinner
we talk of war

## funny
spring has arrived
a half-naked woman
at the bus stop

first kiss
my neighbor's cat finishes
the dishes

a dead mouse
in my notebook-
how to start

## deep / heavy
after the funeral
the old man's granddaughter sings
herself happy

## nature / seasonal
winter wind
she whispers something
into my ear

the warmth in
the tea kettle
the cold of autumn rain

new moon --
the baby's heartbeat
in the dark

summer rain
the smell of earthy soil
between the mountains

cold creek bed -
my walking stick
drowns a deer ## ok, ok, this one's more 'dark'

rain on the lake?
the old man repeats
the same old joke

seattle ferry
the narrow passage
where the caterpillars emerge ## didn't expect them!

vacation's end
the scent of the old house
on my skin

afternoon rain
a girl with long, black hair
knits clothes

a bird's call
through the stillness
a storm begins

tuggy old cat ## let's pretend it means grumpy
waiting for the sun
to rise

winter tide
my son sings a haiku ## short song
in the rain
```

We thought these results were comparable to the results with the 'high quality' haikuzao dataset. Albeit with more variation, and less moths.

<a href="http://www.oldpondcomics.com/onebreahpoetry.html" target="_blank">
  <img src="/assets/gpt-2-haiku/ophaikubreath.gif" alt="One breath poetry - haiku" class="no-zoom">
</a>

### Things left

For us the most fun was reading all of the things the model generated. Again it blew my mind how amazing it is to have a language model that can write new, unique and 'creative' text. The samples above were randomly generated and I did not add any rules for the structure. If we want to take it a step further: it could be nice to enforce structure on the haiku. The most logic choice would be to add the 5-7-5 syllable structure. My initial guess is that it's not that hard to add. More challenging would be to be able to provide subjects the haiku should contain. We could generate samples based on some user input, for example the first sentence of the haiku, however we're no haiku experts (sorry we lied) so we thought random generation was fine as well!

All in all, we had a good laugh looking through the generated haiku, and who knows what will come up after the next <s>bottle of wine</s> interesting chat with my girlfriend.

<a href="http://www.oldpondcomics.com/575haiku.html" target="_blank">
  <img src="/assets/gpt-2-haiku/ophaiku575.gif" alt="Perfect measurements" class="no-zoom">
</a>

#### Not for the faint of heart

Even though they were sometimes a bit **\*ahem\*** questionable, we didn't want to keep these from you:

```txt
evening chill -
my uncle's cremation
is held in his garage

I know your boyfriend
 is your brother, but he's so
busy right now it's hard

a little girl
draws with her own blood
on the beach

Mother Nature's traps
find their first-ever victim
pit bull

Thanksgiving Day
killing time
in the cafeteria
```

P.S. this blog post was written by both of us, no significant others were harmed in the making of this post.

The three runs, with datasets and full output, can be found on [github](https://github.com/brianweet/gpt-2-haiku).

<style>
.twitter-tweet-rendered {
  margin-left: auto;
  margin-right: auto;
}
</style>