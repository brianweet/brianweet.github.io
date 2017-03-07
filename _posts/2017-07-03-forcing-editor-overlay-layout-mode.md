---
layout: post
title:  "Forcing editor overlay layout mode"
date:   2017-03-07 12:00:00
tags: [episerver, cms]
comments: true
---

In this post I'll show you how to change the drag and drop direction within a ContentArea. First let me 
start with some examples of the default functionality. Editors can drag and drop ContentAreaItems around 
pretty easily, as shown in the following gif.

<p class="centered-image">
	<img src="/assets/editor-layout/drag-and-drop.gif" alt="Drag and drop">
</p>

What you'll probably notice in this gif is the drag and drop direction inside the ContentArea. 
On a big viewport you can drag ContentAreaItems **horizontally** whereas on a smaller viewport you can drag ContentAreaItems **vertically**. To determine the drag and drop direction 
episerver implemented some advanced(?) checks, which takes styling of all ContentAreaItems into account.
``` js
//This can be found in ContentArea.js (debug clientResources)
_setupDirectionality: function () {
            // summary:
            //      Iterates over the sourceItemNodes children checking if any is floating.
            // tags:
            //      private
            var horizontal;

            if (/vertical|horizontal/.test(this.layout)) {
                horizontal = this.layout === "horizontal";
            } else {
                horizontal = array.some(this._getBlockNodes(), function (node) {
                    var style = domStyle.getComputedStyle(node),
                        floating = /left|right/.test(style.cssFloat),
                        inline = /inline|inline-block/.test(style.display);

                    return floating || inline;
                });
            }

            this._source.setHorizontal(horizontal);
        },
```

In one of our projects we were using some fancy styling and a library to position our blocks. During the implementation
of the design we ran into some problems though, as the block drag and drop direction was always wrong (always vertical).

<p class="centered-image">
	<img src="/assets/editor-layout/wrong-direction.png" alt="Wrong direction">
</p>

So first I tried to understand the rules for determining horizontal or vertical drag and drop.
After some time and some &^*% I noticed the ``if`` statement ``/vertical|horizontal/.test(this.layout)``.

Wait a second, I can set the direction myself!

Doing this is pretty easy but documentation is next to nonexistent (at least for my Google skills). 
Create a ContentAreaEditorDescriptor like so:
``` csharp
    [EditorDescriptorRegistration(TargetType = typeof(ContentArea), UIHint = UiHints.FixedLayoutContentArea)]
    public class FixedLayoutContentAreaEditorDescriptor : ContentAreaEditorDescriptor
    {
        public FixedLayoutContentAreaEditorDescriptor()
        {
            // This forces the overlay layout to be horizontal (fix for drag and drop)
            OverlayConfiguration.Add("layout", "horizontal");
        }
    }

    public static class UiHints
    {
        public const string FixedLayoutContentArea = "FixedLayoutContentArea";
    }
```

And all there's left is to add a UIHint to your ContentArea property:
``` csharp
 public class StartPage : SitePageData
    {
        [UIHint(UiHints.FixedLayoutContentArea)]
        [Display(
            GroupName = SystemTabNames.Content,
            Order = 320)]
        [CultureSpecific]
        public virtual ContentArea MainContentArea { get; set; }
```

#### But?
Sure the drag and drop direction isn't dynamically determined anymore. But at least this workaround
puts us in control in case we want to!


<p class="centered-image">
	<img src="/assets/editor-layout/which-direction.jpg" alt="Which direction?">
</p>

> #### tl;dr?
* Epi might calculate the wrong drag and drop direction for ContentAreaItems
* You can force the direction yourself, using a custom ContentAreaEditorDescriptor and adding a UIHint