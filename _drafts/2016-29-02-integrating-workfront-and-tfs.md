---
layout: post
title:  "Integrating WorkFront and TFS: step 1"
date:   2016-02-29 21:07:40
tags: [workfront, tfs, sync]
comments: true
---

In this series of posts I will write about our custom integration of WorkFront with TFS (2015). 

<p class="centered-image" style="max-width: 100%">
	<img src="/assets/wf-tfs/real-love.jpg" alt="Real love">	
</p>

For the past few years we have been using WorkFront as our main issue tracking system. It suits our needs most of the time, with some hacks here and there.
We use it as mainly as backlog for all of our tasks, log our working hours and, after recent changes, the scrum board has become pretty useful too. 
As of recently we have to link check-ins in TFS to tasks and issues in WorkFront, which is a big pain in the ass to do by hand.

<p class="centered-image">
	<img src="/assets/wf-tfs/what-do-we-want.jpg" alt="What do we want?">	
</p>

#### What do we want

We defined custom properties for our WorkFront issues and tasks, due to laws/regulations we need to link our WorkFront issues and tasks to specific commits in TFS.
So ideally we would like to keep TFS and WorkFront in perfect sync, creating WorkItems for every WorkFront item. 
Creating integrations between two systems is almost never without problems, especially when both systems have different implementations for core concepts.  

We decided to integrate WorkFront and TFS in 3 steps:

#### Step 1: Sync Tasks and Issues from WorkFront to TFS (one-way)

At first we focus on most important information, try not to change either system too much. Our 'minimum viable product' will have to sync information about:

*	The TFS project
	* Create custom property on WorkFront project in order to determine TFS project
*	The TFS area / iteration
	* Again, create custom properties on the appropriate objects
*	Issue/task Title
*	Description
	* WorkFront uses line feeds (\n) and TFS uses HTML
*	Assigned to
	* Assigned to is a string in TFS, WorkFront allows multiple assigned to users
*	Status
	* Make a map between WorkFront and TFS statuses
*	WorkFront ID or RefNr
	* Implement this by using WorkItem tags
*	HyperLink to WorkFront
*	Parent task

#### How to sync?
Recently I've been working with [WebHooks]({% post_url 2016-01-27-aspnet-stripe-webhooks %}) and have been impressed by the flexibility and the ease of connecting two distinct systems. 
Unfortunately WorkFront only supports a basic implementation of [WebHooks for documents](https://developers.workfront.com/wp-content/uploads/2015/11/WorkfrontDocumentWebhooks-4.pdf), so we have to resort to polling their RESTful API for updates.

