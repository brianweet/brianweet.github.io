---
layout: post
title:  "Integrating Workfront and TFS: Introduction"
date:   2016-03-29 10:30:40
tags: [workfront, tfs, sync]
comments: true
---

In this series of posts I will write about our custom integration of Workfront with TFS (2015). 

<p class="centered-image" style="max-width: 100%">
	<img src="/assets/wf-tfs/real-love.jpg" alt="Real love">	
</p>

For the past few years we have been using Workfront as our main issue tracking system. It suits our needs most of the time, with some hacks here and there.
We use it as backlog for all of our tasks, log our working hours and, after recent changes, the scrum board has become pretty useful too. 

We're a Microsoft oriented company and our team has been using TFS for quite a few years. Unfortunately we haven't been able to use any workitem related functionalities like [suspending work](https://msdn.microsoft.com/en-us/library/hh474795.aspx) in a structured way yet; the reason is not having any WorkItems in TFS.

<p class="centered-image">
	<img src="/assets/wf-tfs/what-do-we-want.jpg" alt="What do we want?">	
</p>

#### What do we want? Why do we want it?

As of recently we HAVE to reference TFS check-ins to tasks and issues in Workfront, which is 'impossible' (read: a big pain in the ass) to do by hand.

We would like to provide our developers with an easy way to link check-ins to WorkItems, as most developers I know hate doing 'paperwork' once, imagine having to do it twice ohmygod \0/.
We will sync our Workfront tasks and issues with TFS, ideally keeping both systems in 'perfect' sync.
Integrating two systems is almost never without challenges, especially when both systems have different implementations for core concepts. 

Due to foreseen and unforeseen challenges, I've decided to integrate Workfront and TFS in 3 steps:

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
*	HyperLink to Workfront for easy access from TFS WorkItems
*	Parent task for structure

#### Step 2: Push check-in info from TFS to Workfront
Step two would be to sync some data back to Workfront. Probably we will register some servicehooks in TFS (yay [TFS2015]()) to push events to a Azure Topic. 
For now, we keep using the Workfront scrum board, so the main focus of step 2 would be to update Workfront with information about check-in comments and perhaps comments on TFS workitems.

#### Step 3: Sync TFS workitem details to Workfront
Ideally we would be able to make changes to TFS workitems and see those changes reflected in Workfront. After step 3 we should be able to use both the TFS scrum board and the Workfront scrum board simultaneously.

#### Setting up Workfront
In order to sync data to TFS, we need some extra information about the projects in Workfront. I've decided to add custom forms to Workfront projects and iteration in order to make the connection with TFS projects and sprints.
You will need an admin account in Workfront in order to execute the following steps.
Log in and go to https://[your-url].attask-ondemand.com/setup

Click on 'custom forms'
<p class="centered-image">
	<img src="/assets/wf-tfs/1.0.create-custom-form.png" alt="Workfront custom forms">	
</p>

Create a custom form for Project types, add a Checkbox field and give it a name (I used 'TFS Sync').
Add a text field for the TFS project name and give it a name (I used 'TFS project name'), I did add some logic to the field but that is not necessary ('Display if TFS Sync Enabled is Selected').
<p class="centered-image">
	<img src="/assets/wf-tfs/1.1.create-form-for-project.png" alt="Add custom form for Projects">	
</p>

Create a custom form for Iteration types, add a text field for the 'TFS Iteration name'.
<p class="centered-image">
	<img src="/assets/wf-tfs/1.2.create-form-for-iteration.png" alt="Add custom form for Projects">	
</p>

#### How to sync?
Recently I've been working with [WebHooks]({% post_url 2016-01-27-aspnet-stripe-webhooks %}) and have been impressed by the flexibility and the ease of connecting two distinct systems. 
Unfortunately Workfront only supports a basic implementation of [WebHooks for documents](https://developers.workfront.com/wp-content/uploads/2015/11/WorkfrontDocumentWebhooks-4.pdf), so we have to resort to polling their RESTful API for updates.

In the upcoming posts we will integrate TFS and workfront step by step.
First we will write a polling app which retrieves updates from Workfront and another app which updates TFS accordingly:
<p class="centered-image">
	<img src="/assets/wf-tfs/WF-TFS-1.svg" alt="Step 1">	
</p>