---
layout: post
title:  "Integrating Workfront and TFS: Step 1 of 3"
date:   2016-04-02 21:07:40
tags: [workfront, tfs, sync]
comments: true
---

In this series of posts I will write about our custom integration of Workfront with TFS (2015). 

<p class="centered-image" style="max-width: 100%">
	<img src="/assets/wf-tfs/real-love.jpg" alt="Real love">	
</p>

<p class="centered-image">
	<img src="/assets/wf-tfs/WF-TFS-1.svg" alt="Step 1">	
</p>

#### Step 1: Sync Tasks and Issues from Workfront to TFS (one-way)

At first we focus on most important information, try not to change either system too much. Our 'minimum viable product' will have to sync information about:

*	The TFS project
	* Create custom property on Workfront project in order to determine TFS project
*	The TFS area / iteration
	* Again, create custom properties on the appropriate objects
*	Issue/task Title
*	Description
	* Workfront uses line feeds (\n) and TFS uses HTML
*	Assigned to
	* The "Assigned To" field is a string in TFS, whereas Workfront allows multiple assigned to users
*	Status
	* Make a map between Workfront and TFS statuses
*	Workfront ID or RefNr
	* Implement this by using WorkItem tags
*	HyperLink to Workfront for easy access from TFS workitems
*	Parent task for structure

Our polling app will make a request to the Workfront API a few times per minute. We can build queries to retrieve new tasks, new issues, updated tasks and updates issues.
