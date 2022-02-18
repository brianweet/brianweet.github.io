---
layout: post
title:  "Tracking down initialization issues in an Optimizely project"
date:   2022-01-04 09:00:00
tags: [optimizely, cms, commerce]
comments: true
---

Recently I was working on an Optimizely project which had some interesting issues, which seemed to happen right after startup.
For no apparent reason some of the properties on a page were `null`.

<p class="centered-image">
	<img src="/assets/initialization-issues/1.empty-props.png" alt="Empty props">
</p>

The investigation started:

1. Check the CMS to be sure the properties are filled in
   - Yes, nothing to see here
2. Verify the id and version of the page
   - Correct
3. Clear cache and load the page again (in code)
   - Hey, now it does work properly!

Optimizely caches the page the first time it is retrieved, for some reason not all properties were populated in the cached version of the page. More specificly: the properties referencing **commerce content** were not populated.. Hmm so maybe something is wrong during the initialization of commerce somehow?!

After a bit of investigation I found some code that was executed early on in the startup process, and I could throw an exception to check the call stack and figure out what was going on:

<p class="centered-image">
	<img src="/assets/initialization-issues/2.stack.png" alt="Stack trace to find the culprit">
</p>

Looks like we've found the culprit! We have a custom actor for Optimizely Forms which is instantiated during initialization. In itself that shouldn't cause any problems, so what's the issue here?

```csharp
public class ComplaintsActor : PostSubmissionActorBase, IUIPropertyCustomCollection
{
  private readonly IProjectFormService _projectFormService;
  private readonly IContentLoader _contentLoader;

  public ComplaintsActor() : this(ServiceLocator.Current.GetInstance<IProjectFormService>(), 
      ServiceLocator.Current.GetInstance<IContentLoader>())
  {
  }

  public ComplaintsActor(IProjectFormService projectFormService, IContentLoader contentLoader)
  {
      _projectFormService = projectFormService;
      _contentLoader = contentLoader;
  }
  ...
```

Turns out we initialize a couple of services explicitly during startup by using the ServiceLocator. One of the services tries to load our mysterious page with `null` properties and it gets cached correspondingly. The fix is easy, we don't need those services right away and can just use property injection instead:

```csharp
public class ComplaintsActor : PostSubmissionActorBase, IUIPropertyCustomCollection
{
  private readonly Injected<IProjectFormService> ProjectFormService;
  private readonly Injected<IContentLoader> ContentLoader;

  public ComplaintsActor()
  {
  }
  ...
```

**Tip 1**: prevent initializing using the ServiceLocator if not necessary

**Tip 2**: prevent loading content during initialization of a service