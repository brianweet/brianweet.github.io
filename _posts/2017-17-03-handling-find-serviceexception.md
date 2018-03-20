---
layout: post
title:  "Handling Episerver find exceptions"
date:   2017-03-17 12:00:00
tags: [episerver, episerver-find]
comments: true
---

This week the Episerver find service experienced had degraded performance for 12+ hours. If you're not handling [exceptions from find](http://world.episerver.com/blogs/Jonas-Bergqvist/Dates/2016/12/exceptions-in-find/) in an adequate way, you will probably learn the hard way how much your site relies on Episerver find. As far as I could tell the outage was mostly related to indexing not querying, unfortunately there's not detailed information on the [status page](http://status.episerver.com/incidents/1yyt405cf6md). In any case you want to handle exceptions gracefully, so I thought I'd share a bit of code which helps you to do so.

In the [aforementioned](http://world.episerver.com/blogs/Jonas-Bergqvist/Dates/2016/12/exceptions-in-find/) blogpost you can find the exceptions that are related to Episerver find. So the first step is to catch both ``EPiServer.Find.ServiceException`` and ``EPiServer.Find.ClientException``. This can be done with a try catch like, f.e.
``` csharp
try
{
    var search = SearchClient.Instance.Search<SomePage>();
    var contentResult = search
        .GetContentResult(cacheForSeconds, cacheForEditorsAndAdmins);
}
catch (Exception ex) when (ex is ClientException || ex is ServiceException)
{
    // Into the void! I mean log the error
}
```

To make life a bit more convenient I've decided to create an extension method, similar to GetContentResult, named GetContentResultSafe. I'm not the biggest fan of extension methods but in this case it seems pretty reasonable.
```csharp
public static class TypeSearchExtensionMethods
{
        /// <summary>
        /// Catches ServiceException and ClientException and returns an EmptyContentResult
        /// </summary>
        public static IContentResult<TContentData> GetContentResultSafe<TContentData>(
            this ITypeSearch<TContentData> search,
            int cacheForSeconds = 60,
            bool cacheForEditorsAndAdmins = false) where TContentData : IContentData
        {
            IContentResult<TContentData> contentResult;
            try
            {
                contentResult = search
                    .GetContentResult(cacheForSeconds, cacheForEditorsAndAdmins);
            }
            catch (Exception ex) when (ex is ClientException || ex is ServiceException)
            {
                Logger.Error("Could not retrieve data from find, returning empty contentresult", ex);
                contentResult = new EmptyContentResult<TContentData>();
            }
            return contentResult;
        }
}
```

Which allowes you to call ``search.GetContentResultSafe`` in a similar manner as you would normally do with ``search.GetContentResult``.
If you've examined the previous example closely you might notice an unknown class name: ``EmptyContentResult``. As catching the error is one thing, 
but then you have to make a decision what to return. Returning null will probably result in an exception in the calling code, especially if you use it in a chain / with fluent extensions. So for me the best thing would be to return an empty object, which you can create like this
```csharp
public class EmptyContentResult<T> : ContentResult<T> where T : IContentData
{
    public EmptyContentResult() : base(
        Enumerable.Empty<T>(),
        new SearchResults<ContentInLanguageReference>(
            new SearchResult<ContentInLanguageReference>() {
                Facets = new FacetResults(),
                Hits = new HitCollection<ContentInLanguageReference>() {
                    Hits = Enumerable.Empty<SearchHit<ContentInLanguageReference>>().ToList()
                },
                Shards = new Shards()
            }))
    { }
}
```

Obviously, if you want to check if you don't have any results because of a find exception you'll still have to check the type of the result you get. But at least you will not end up with null reference exceptions if you forget to place a nice ¿questionmark? while accessing any of the properties.

Lastly, during developing I usually want to know which exceptions occur. To do so I just make sure we don't catch the exception in debug mode. 
```csharp
...
try
{
    contentResult = search
        .GetContentResult(cacheForSeconds, cacheForEditorsAndAdmins);
}
catch (Exception ex) when (CatchFindException(ex))
{

}
...

        public static bool CatchFindException(Exception ex)
        {
#if DEBUG
            return false;
#endif
#if !DEBUG
            return
                ex is ClientException ||
                ex is ServiceException;
#endif
        }
```

<p class="centered-image">
	<img src="/assets/something-wrong.jpg" alt="Something wrong?">
</p>
<a href="http://imgur.com/ACmQRMl" target="_blank">
<strong>The "most productive" exception handling ever</strong>
</a>


> #### tl;dr?
* Catch EPiServer.Find.ServiceException and EPiServer.Find.ClientException for every call to find
* This post contains code for an extensionmethod 'GetContentResultSafe' and which returns an empty object (instead of null)