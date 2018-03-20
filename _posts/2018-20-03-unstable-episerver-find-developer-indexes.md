---
layout: post
title:  "Unstable Episerver Find developer (demo) indexes"
date:   2018-03-20 08:00:00
tags: [episerver, episerver-find]
comments: true
---

Lately a lot of people had [problems](https://world.episerver.com/forum/developer-forum/EPiServer-Search/Thread-Container/2017/7/issues-with-new-developer-indexes)  with the free Episerver Find developer indexes (or so called demo indexes). Intermittently these indexes stopped working, sometimes for a short period but occasionally they seemed to have died completely. One solution was to create a new index, which gets old after creating a couple each day, especially as they don't seem to work straight away.

<p class="centered-image">
	<img src="/assets/epi-find/wtf-grandma.jpg" alt="WTF grandma">
</p>

#### The problem
I usually work on Commerce projects and it's not possible to start the application without Find being available!
I decided to take a look at what's causing it and what you can do to (temporarily) fix this problem. The error I'm getting is a "503 Service Unavailable" or a "(401) Unauthorized" which apparently means there's something wrong with the index. That's bad as is but it should not prevent our application from starting. Here are some examples of the error:

<p class="centered-image">
	<img src="/assets/epi-find/initialization-exception.png" alt="503 find initialization exception">
</p>

```
[WebException: The remote server returned an error: (401) Unauthorized.]
   System.Net.HttpWebRequest.GetResponse() +1695
   EPiServer.Find.Connection.JsonRequest.GetResponseStream() +111
   EPiServer.Find.Api.Command.GetResponse(IJsonRequest request) +42

[ServiceException: The remote server returned an error: (401) Unauthorized.
Unauthorized]
   EPiServer.Find.Api.Command.GetResponse(IJsonRequest request) +63
   EPiServer.Find.Api.PutMappingCommand.Execute() +37
   EPiServer.Find.ClientConventions.NestedConventions.AddNestedType(Type declaringType, String name) +116
   System.Collections.Generic.List`1.ForEach(Action`1 action) +14674174
   EPiServer.Find.Commerce.CatalogContentClientConventions.ApplyNestedConventions(NestedConventions nestedConventions) +89
   EPiServer.Find.Commerce.CatalogContentClientConventions.ApplyConventions(IClientConventions clientConventions) +69
   EPiServer.Find.Commerce.FindCommerceInitializationModule.Initialize(InitializationEngine context) +47
   EPiServer.Framework.Initialization.Internal.ModuleNode.Execute(Action a, String key) +55
   EPiServer.Framework.Initialization.Internal.ModuleNode.Initialize(InitializationEngine context) +123
   EPiServer.Framework.Initialization.InitializationEngine.InitializeModules() +248

[InitializationException: Initialize action failed for Initialize on class EPiServer.Find.Commerce.FindCommerceInitializationModule, EPiServer.Find.Commerce, Version=10.1.1.0, Culture=neutral, PublicKeyToken=8fe83dea738b45b7]
   EPiServer.Framework.Initialization.InitializationEngine.InitializeModules() +834
   EPiServer.Framework.Initialization.InitializationEngine.ExecuteTransition(Boolean continueTransitions) +198
   EPiServer.Framework.Initialization.InitializationModule.EngineExecute(HostType hostType, Action`1 engineAction) +876
   EPiServer.Framework.Initialization.InitializationModule.FrameworkInitialization(HostType hostType) +225
   EPiServer.Global..ctor() +103
   GetaCommerce.Web.Global..ctor() +43
   ASP.global_asax..ctor() +48
```

If you examine this error, you might notice that the FindCommerceInitializationModule is trying to apply some nested conventions for the catalog content.

#### Workaround 1: Using Fiddler
As I always have Fiddler running locally, the easiest way for me to is to open up Fiddler and check what's happening. As expected, I notice the 503 response on a request that is trying to add nested conventions for commerce (for example for prices). I decided to add a rule to the Fiddler AutoResponder with the following data, which will allow our site to start:

```
HTTP/1.1 200 OK
content-type: application/json; charset=UTF-8
Content-Length: 31

{"ok":true,"acknowledged":true}
```

<p class="centered-image">
	<img src="/assets/epi-find/fake-response-fiddler.png" alt="Fake fiddler response">
</p>

It's as easy as dragging and dropping the failing request to the AutoResponder rules and pointing it to a file with this simple response data.

#### Workaround 2: Adding an interceptor
This second workaround involves some code to intercept the call to CatalogContentClientConventions. It will allow you to catch the Exception that is being thrown and continue from there (as in, ignore and start the app already).
I've found this code on the [Forum](https://world.episerver.com/forum/developer-forum/EPiServer-Search/Thread-Container/2017/1/exception-when-starting-website/), see this [gist](https://gist.github.com/jstemerdink/6aff0f7de4aa22c803bb4ad0250bec0c) by [Jeroen Stemerdink](https://world.episerver.com/Blogs/Jeroen-Stemerdink/).

```csharp
public class FindExceptionInterceptor : IInterceptor
{
    public void Intercept(IInvocation invocation)
    {
        try
        {
            invocation.Proceed();
        }
        catch (ClientException)
        {
        }
        catch (ServiceException)
        {
        }
    }
}

public class StructureMapRegistry : Registry
{
    public StructureMapRegistry()
    {
        var proxyGenerator = new ProxyGenerator();
        For<CatalogContentClientConventions>().Use<CatalogContentClientConventions>()
            .DecorateWith(t => proxyGenerator.CreateClassProxyWithTarget(t, new FindExceptionInterceptor()));
    }
}
```

#### Digging a little deeper
As it turns out the FindCommerceInitializationModule actually has an appSetting `episerver:findcommerce.IgnoreWebExceptionOnInitialization` which sounds like it should do what we want: ignore exceptions upon initialization. There is a try catch around the code that throws the exception, however it only catches WebExceptions whereas the current exception is a ServiceException. I am going to create a support ticket for this, as I think we should be able to use this appSetting to make sure we can start our application even if Find is a bit flaky. 

#### Conclusion
It is possible to start your app when Episerver Find isn't working properly. Be aware though, none of these workarounds are actual solutions and they might cause Find to behave unexpectedly.