---
layout: post
title:  "Tips making changes to Episerver PropertyList"
date:   2017-03-05 12:00:00
tags: [episerver, propertylist]
comments: true
---
In the [previous]({% post_url 2017-24-02-dangers-of-using-pre-release-apis %}) post I've looked at the problems that might occur when changing the name / namespace of the PropertyDefinitionTypePlugIn. 
Fortunately it is possible to make those changes without losing data. It does take a bit more effort though, as we've seen that making changes could cause our site to fail during startup.

The steps are simple but will require some attention.

#### Renaming or refactoring PropertyDefinitionTypePlugIn
Unfortunately you will have to release this in two steps. First we have to make sure both our old and new PropertyDefinitionTypePlugIn have been created. 
Only after doing so we will be able to change the BackingType and remove the old PropertyDefinitionTypePlugIn.

So the steps we have to take are:

 1. Add a new PropertyDefinitionTypePlugIn
    * Keep the old PropertyDefinitionTypePlugIn until step 5 (which is the 'be happy' step!)
 2. Add a BackingType attribute to the property you want to change, point it to the new PropertyDefinitionTypePlugIn
 3. Release
 4. **Optional:** go into Admin mode, go to the tab "Content Type" and look for the affected PageType(s).
    * The property type should now be set to the new PropertyDefinitionTypePlugIn.
 5. Data migration is done, be happy, it is now safe to remove the old PropertyDefinitionTypePlugIn and any related data classes if needed.

<p class="centered-image gallery">
	<a href="/assets/propertylist2/1.1.before-migration.png" data-group="1" class="first">
		<img src="/assets/propertylist2/1.1.before-migration.png" class="galleryItemThumb" />
	</a>
	<a href="/assets/propertylist2/1.2.admin-mode-old-backing-type.png" data-group="1"></a>
	<a href="/assets/propertylist2/2.1.during-migration.png" data-group="1"></a>
	<a href="/assets/propertylist2/2.2.admin-mode-new-backing-type.png" data-group="1"></a>
    <a href="/assets/propertylist2/3.after-migration.png" data-group="1"></a>
</p>
<strong>Click to see all images</strong>

#### Migrating data on breaking changes to the data class
Making changes to the underlying data class can break your site as well. In the error log you'll find errors related to Json (de)serialization. If you find yourself in this position you can follow steps similar to the ones above:
0. Revert the breaking changes
1. Add a new PropertyDefinitionTypePlugIn for the new data class
    * **Important:** keep the old PropertyDefinitionTypePlugIn until step 6 (which is the 'be happy' step!)
2. Add a new property to the PageType, point it to the new PropertyDefinitionTypePlugIn
3. Create some code (e.g. in a scheduled job) to migrate data from the old property to the new property. Be sure to remove the data from the old property.
    * Migrating the data will be custom code in any case, so no example here. 
4. Release and run your custom code
5. **Optional:** Go into edit mode and make sure that data has been migrated correctly
6. Be happy, see step 5. from the previous list

<p class="centered-image">
	<img src="/assets/propertylist2/very-nice.jpg" alt="Very nice">	
</p>

#### In conclusion
PropertyList has its own set of problems, especially when you have to make breaking changes to the underlying type(s). 
In this post you can find some simple steps which will take some extra effort. However, if you stick to the steps, you should be able to make any changes in a safe and simple manner.

> #### tl;dr?
 To make changes to the (underlying) data of a PropertyList; 
* Keep the old, existing type(s)
* Make your changes to new type(s)
* Release and migrate data from the old, existing type(s) to new types
* Remove the old, existing type(s)