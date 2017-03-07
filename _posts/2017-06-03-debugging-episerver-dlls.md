---
layout: post
title:  "Debugging Episerver dlls (or basically anything)"
date:   2017-03-06 12:00:00
tags: [episerver, debugging]
comments: true
---

<div class="toggle"> 
    A decompiler is an unknown tool to Episerver developers.
    <a href="http://world.episerver.com/Search?searchQuery=decompile" target="_blank">Nobody</a> would dare 
    to use it on Episerver dlls as it is against the EULA. You'll never run into any problems 
    where some extra insight is necessary. Same goes for bugs, those are non-existant anyways.
    Even though debugging symbols have been available in the past. There is absolutely no way 
    to debug Episerver dlls.
</div>

<p class="centered-image toggle" data-toggle-button>
	<img src="/assets/debugging/nothing-to-see.jpg" alt="Nothing to see">
</p>

<div class="toggle hide">
    A decompiler is a good friend of many Episerver developers. The docs are pretty extensive 
    but you might find yourself in a position where you want to know how to implement certain 
    functionality. Next to that you could be running into a bug in the framework, which could 
    be like looking for a needle in a haystack. Unfortunately there are no debugging symbols 
    available for us Episerver developers (I've heard that the symbols have been available in 
    the past though).
</div>

<a href="#" class="toggle" data-toggle-button>
    Really?! Click here! Thruth or dare
    <i class="fa fa-birthday-cake"></i>
</a>

<div class="toggle hide">

    Anyways, it is possible to debug basically any dll. A great tool for this is JetBrains dotPeek.
    You can follow the steps for setting up dotPeek on the 
    <a href="https://www.jetbrains.com/help/decompiler/10.0/Using_product_as_a_Symbol_Server.html" target="_blank">
    JetBrains help page</a>.
    After that just start dotPeek, start the symbol server and drag the episerver dll 
    to the assembly explorer (as I've set up dotPeek to serve just those dlls). 
    After doing so you have to add the symbol server url in Visual studio by going to tools->options->Debugging->Symbols.
    You'll  have to disable 'Just My Code' on tools->options->Debugging->General and press 
    the 'Load' button on the 'No Symbols Loaded' page. 
    You can now step through and place breakpoints in epi code <i class="fa fa-smile-o"></i>. Some extra info can be found
<a href="http://hmemcpy.com/2014/07/how-to-debug-anything-with-visual-studio-and-jetbrains-dotpeek-v1-2/" target="_blank">
here</a> and
<a href="http://stackoverflow.com/questions/26518013/dotpeek-issue-debugging-3rd-party-dll#answer-26523669" target="_blank">
here</a>

    <p class="centered-image gallery">
        <a href="/assets/debugging/1.normal.png" data-group="1" class="first">
            <img src="/assets/debugging/1.normal.png" class="galleryItemThumb" />
            <i class="fa fa-search"></i>
            <strong>Click to see all images</strong>
        </a>
        <a href="/assets/debugging/2.dotpeek.png" data-group="1"></a>
        <a href="/assets/debugging/3.options.png" data-group="1"></a>
        <a href="/assets/debugging/4.callstack.png" data-group="1"></a>
        <a href="/assets/debugging/5.breakpoint.png" data-group="1"></a>
    </p>

</div>

> #### tl;dr?
* Click on "Really?! Click here! Thruth or dare <i class="fa fa-birthday-cake"></i>"
* Install dotPeek, start dotPeek, start the symbol server
* Add any dll (episerver.dll perhaps?) to Assembly explorer in dotPeek
* Add your symbol server url to vs-tools->options->Debugging->Symbols
* Disable 'Just My Code' on vs-tools->options->Debugging->General
* Now you can load debug symbols for epi during debugging
* Other option is to place pdb file in bin next to episerver.dll
* [More](http://hmemcpy.com/2014/07/how-to-debug-anything-with-visual-studio-and-jetbrains-dotpeek-v1-2/) [info](http://stackoverflow.com/questions/26518013/dotpeek-issue-debugging-3rd-party-dll#answer-26523669)