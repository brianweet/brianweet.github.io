---
layout: post
title:  "Logging Find serialization exceptions"
date:   2019-03-29 12:00:00
tags: [episerver, episerver-find]
comments: true
---

One of our projects had some problems running the `EPiServer Find Content Indexing Job`. The job completed successfully, however the history tab revealed a lot of errors. They all looked like this:

```
An exception occurred while indexing content
[Link 1548__CatalogContent] [GUID 00000000-0000-6842-0000-000000006356]
[Type DefaultVariationContent] [Name LG 43UJ630V ]:
The remote server returned an error: (403) Forbidden.
Your key is not authorized to access (POST) '/_bulk' (see log for more information)
```

We know which content failed to index, but we do not see why. Usually the log file / log tool has more information. In this case however, the log file provided similar information.. All we know is that it is trying to index a variation but it just seems to fail:
```
2019-03-27 16:56:25,340 DEBUG [73] EPiServer.Logging.Compatibility.LogManager+CompatibilityWrapper.DebugFormat -
Sending 1 ContentData items to Find Indexer
2019-03-27 16:56:25,367 INFO [73] EPiServer.Logging.Compatibility.LogManager+CompatibilityWrapper.WarnFormat -
Indexing failed (http error), attempt 1 out of 3:
EPiServer.Find.ServiceException: The remote server returned an error: (403) Forbidden.
Your key is not authorized to access (POST) '/_bulk' --->
System.Net.WebException: The remote server returned an error: (403) Forbidden.
   at System.Net.HttpWebRequest.GetResponse()
   at EPiServer.Find.Connection.JsonRequest.GetResponseStream()
   at EPiServer.Find.Api.Command.GetResponse[TResult](IJsonRequest request)
   --- End of inner exception stack trace ---
   at EPiServer.Find.Api.Command.GetResponse[TResult](IJsonRequest request)
   at EPiServer.Find.Api.BulkCommand.Execute(List`1& serializationFailures)
   at EPiServer.Find.Api.BulkCommand.Execute()
   at EPiServer.Find.Cms.ContentIndexer.IndexWithRetry(IContent[] contents,
    Int32 maxRetries, Boolean deleteLanguageRoutingDuplicatesOnIndex)
```

<p class="centered-image">
	<img src="/assets/find-serialization-exceptions/1.fiddler.png" alt="Epi find 403 in Fiddler">
</p>

Running fiddler proxy locally I could see `403` requests that were being done to the Find API, the body was empty and the Find API returns a `403` in that case. If this happens to you, it means that the indexing job is not able to serialize your content. Jeroen Stemerdink wrote a blog about [Check your content for indexing errors](https://jstemerdink.wordpress.com/2018/09/13/check-your-content-for-indexing-errors/). By adding the [SerializationValidator](https://gist.github.com/jstemerdink/d7553deefb4cae809bd4b47bcec0a673) you should get a nice error message in the CMS in case serialization fails.

However, the SerializationValidator did not throw any exception for my failing content... Fortunately Episerver support came to the rescue and suggested attaching a `ITraceWriter` to the Find indexing serializer. It's pretty easy once you know how to do that:
```csharp
[ModuleDependency(typeof(FindCommerceInitializationModule), typeof(IndexingModule))]
public class FindInitialization : IConfigurableModule
{
    private static bool _initialized;

    public void Initialize(InitializationEngine context)
    {
        if (_initialized)
        {
            return;
        }

        // Customize the default serializer and attach a ITraceWriter
        SearchClient.Instance.Conventions.CustomizeSerializer =
            serializer => serializer.TraceWriter = new FindErrorLogTraceWriter();

        _initialized = true;
    }

    public void Uninitialize(InitializationEngine context)
    {
    }
}

// Custom trace writer to log all errors
public class FindErrorLogTraceWriter : ITraceWriter
{
    private static readonly ILogger Logger = LogManager.GetLogger(typeof(FindErrorLogTraceWriter));

    // Only interested in the errors
    public TraceLevel LevelFilter => TraceLevel.Error;

    public void Trace(TraceLevel level, string message, Exception ex)
    {
        Logger.Error(message, ex);
    }
}
```

Et voilà! We now have a proper stack trace which contains information about the serialization error:

```
2019-03-29 15:55:45,306 [12] ERROR EPiServer.Find.Cms.ContentIndexer:
An exception occurred while indexing content
[Link 1548__CatalogContent] [GUID 00000000-0000-6842-0000-000000006356]
[Type DefaultVariationContent] [Name LG 43UJ630V ]:
The remote server returned an error: (403) Forbidden.
EPiServer.Find.ServiceException: The remote server returned an error: (403) Forbidden.
Your key is not authorized to access (POST) '/_bulk' --->
System.Net.WebException: The remote server returned an error: (403) Forbidden.
...more info here...

2019-03-29 15:55:45,403 [12] ERROR GetaCommerce.Web.Initialization.FindErrorLogTraceWriter:
Error serializing EPiServer.Find.Api.BulkIndexAction. Error getting value from 'TestExceptionField' on 'Castle.Proxies.DefaultVariationContentProxy'.
Newtonsoft.Json.JsonSerializationException:
    Error getting value from 'TestExceptionField' on 'Castle.Proxies.DefaultVariationContentProxy'. --->
    System.NullReferenceException: Object reference not set to an instance of an object.
   at GetaCommerce.Web.Features.Product.Models.TestService.GetStartPageName() in D:\-\Product\Models\DefaultVariationContent.cs:line 373
   at GetaCommerce.Web.Features.Product.Models.DefaultVariationContent.get_TestExceptionField() in D:\-\Product\Models\DefaultVariationContent.cs:line 291
   at GetTestExceptionField(Object )
   at Newtonsoft.Json.Serialization.DynamicValueProvider.GetValue(Object target)
   --- End of inner exception stack trace ---
   ...more info here...
   at Newtonsoft.Json.Serialization.JsonSerializerInternalWriter.Serialize(JsonWriter jsonWriter,
    Object value, Type objectType)
```

In the stack trace above you can see that we're trying to serialize `DefaultVariationContentProxy.TestExceptionField`, which calls `TestService.GetStartPageName`. The `GetStartPageName` method tries to use `ContentReference.StartPage` without checking for `null`, which it is in the context of a scheduled job.

### Conclusion

In this post we've seen how to log errors that are being thrown by the serializer used by the Find index job. The problem that these error don't propagate will be fixed in the future, however by customizing the serializer with `SearchClient.Instance.Conventions.CustomizeSerializer` adding a custom `ITraceWriter` you should be able to log all serialization exceptions thrown by the Find indexing job already.

Episerver support mentioned that the `403` bug is scheduled to solved in version 13.2 of Episerver Find.