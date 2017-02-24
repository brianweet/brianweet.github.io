---
layout: post
title:  "The dangers of using pre-release API's"
date:   2017-02-24 12:00:00
tags: [episerver, propertylist]
comments: true
---

In this blog post I will take a look at some of the do's and don'ts of using PropertyList<T>. PropertyList<T> has been around for a while and some
<a href="http://world.episerver.com/blogs/per-magne-skuseth/dates/2015/11/trying-out-propertylistt/">nice</a>
<a href="https://gregwiechec.com/2016/07/trying-out-propertyvaluelist/">blogposts</a> have been written about the subject. If you create a new PropertyDefinition based on PropertyList you might notice that PropertyList is still a pre-release API (Assembly: EPiServer, Version=10.4.2.0): 
> NOTE: This is a pre-release API that is UNSTABLE and might not satisfy the compatibility requirements as denoted by its associated normal version.

But we didn't seem to have too much problems with PropertyList<T>, so what could be the reason for it to be a pre-release API still?
To demonstrate the dangers of using a pre-release API I've used the example code from the first blogpost mentioned above.

#### Adding PropertyList<T> property to a page 
First we have the PropertyDefinitionType and the PropertyListBase (notice the Typo):

{% highlight C# %}
namespace AlloyDemoKit.Models.Pages.Test.Property
{
    [PropertyDefinitionTypePlugIn]
    public class TypoListProperty : PropertyListBase<MyCustomData>
    {    }

    public class PropertyListBase<T> : PropertyList<T> ...
}
{% endhighlight %}

Then we create a simple model that we want to store in a list:
{% highlight C# %}
namespace AlloyDemoKit.Models.Pages.Test.Models
{
    public class MyCustomData
    {
        public string Name { get; set; }
        public DateTime Date { get; set; }
    }
}
{% endhighlight %}

And lastly string it all up together and add a property to a pagetype:
{% highlight C# %}
namespace AlloyDemoKit.Models.Pages.Test
{
    [SiteContentType(GUID = "D792C43C-47E3-496E-8BA8-D0D43B4B1C76")]
    public class PropertyListProblemsPage : PageData
    {
        [EditorDescriptor(EditorDescriptorType = typeof(CollectionEditorDescriptor<MyCustomData>))]
        public virtual IList<MyCustomData> MyCustomDataCollection { get; set; }
    }
}
{% endhighlight %}

Doing so will allow you to use a list of MyCustomData to our PropertyListProblemsPage (uhoh, sounds like trouble already).

<p class="centered-image">
	<img src="/assets/propertylist/1.added-data.png" alt="Add data to PropertyList">	
</p>

#### Fixing a typo
I just noticed that my PropertyDefinitionTypePlugIn has a type, namely it is called TypoListProperty instead of MyCustomDataListProperty.
So let's change the class name to MyCustomDataListProperty and see what happens next.

<p class="centered-image">
	<img src="/assets/propertylist/2.initialization-error.png" alt="Add data to PropertyList">	
</p>

We can't seem to access the site OR the CMS anymore! This error only occurs if there's data in the current draft of the page. Let's see what kind of useful information the error log has for us:
{% highlight XML %}
2017-02-24 14:49:01,326 [24] ERROR EPiServer.Framework.Initialization.InitializationEngine: Initialize action failed for 'Initialize on class EPiServer.Initialization.Internal.ModelSyncInitialization, EPiServer, Version=10.4.2.0, Culture=neutral, PublicKeyToken=8fe83dea738b45b7'
System.AggregateException: One or more errors occurred. ---> Newtonsoft.Json.JsonReaderException: Unexpected character encountered while parsing value: [. Path '', line 1, position 1.
   at Newtonsoft.Json.JsonTextReader.ReadStringValue(ReadType readType)
   at Newtonsoft.Json.JsonTextReader.ReadAsString()
   at Newtonsoft.Json.Serialization.JsonSerializerInternalReader.ReadForType(JsonReader reader, JsonContract contract, Boolean hasConverter)
   at Newtonsoft.Json.Serialization.JsonSerializerInternalReader.Deserialize(JsonReader reader, Type objectType, Boolean checkAdditionalContent)
   at Newtonsoft.Json.JsonSerializer.DeserializeInternal(JsonReader reader, Type objectType)
   at EPiServer.Framework.Serialization.Json.Internal.JsonObjectSerializer.Deserialize(TextReader reader, Type objectType)
   at EPiServer.Framework.Serialization.ObjectSerializerExtensions.Deserialize(IObjectSerializer serializer, String value, Type objectType)
   at EPiServer.DataAccess.Internal.LazyPropertyValueLoader.SetValue(PropertyData property, PropertyDataRecord dataRecord, Func`3 valueConverter)
   at EPiServer.DataAccess.Internal.ContentLoadDB.LoadContentInternal(ContentReference contentLink, Int32 languageBranchId, DbDataReader reader)
   at EPiServer.DataAccess.Internal.ContentLoadDB.<>c__DisplayClass4_0.<LoadVersion>b__0()
   at EPiServer.Data.Providers.Internal.SqlDatabaseExecutor.<>c__DisplayClass28_0`1.<Execute>b__0()
   at EPiServer.Data.Providers.SqlTransientErrorsRetryPolicy.Execute[TResult](Func`1 method)
   at EPiServer.Core.ContentProvider.<>c__DisplayClass115_0.<LoadContentFromCacheOrRepository>b__0()
   at EPiServer.Framework.Cache.ObjectInstanceCacheExtensions.ReadThroughWithWait[T](IObjectInstanceCache cache, String cacheKey, Func`1 readValue, Func`2 evictionPolicy)
   at EPiServer.Framework.Cache.ObjectInstanceCacheExtensions.ReadThrough[T](IObjectInstanceCache cache, String key, Func`1 readValue, Func`2 evictionPolicy, ReadStrategy readStrategy)
   at EPiServer.Core.ContentProvider.LoadContentFromCacheOrRepository(ContentReference contentreference, ILanguageSelector selector)
   at EPiServer.Core.Internal.ProviderPipelineImplementation.GetItem(ContentProvider provider, ContentReference contentLink, LoaderOptions loaderOptions)
   at EPiServer.Core.Internal.DefaultContentLoader.TryGet[T](ContentReference contentLink, LoaderOptions loaderOptions, T& content)
   at EPiServer.Core.Internal.DefaultContentLoader.Get[T](ContentReference contentLink, LoaderOptions loaderOptions)
   at EPiServer.DataAbstraction.RuntimeModel.Internal.ContentTypeModelRegister.ValidateChangeOfModelType(PropertyDefinitionModel propertyModel, String modelName)
   at EPiServer.DataAbstraction.RuntimeModel.Internal.ContentTypeModelRegister.SetStateForPropertyDefinitionModels(ContentTypeModel model)
   at EPiServer.DataAbstraction.RuntimeModel.Internal.ContentTypeModelRegister.<AnalyzeProperties>b__14_0(ContentTypeModel model)
   at System.Threading.Tasks.Parallel.<>c__DisplayClass17_0`1.<ForWorker>b__1()
   at System.Threading.Tasks.Task.InnerInvokeWithArg(Task childTask)
   at System.Threading.Tasks.Task.<>c__DisplayClass176_0.<ExecuteSelfReplicating>b__0(Object )
{% endhighlight XML %}
Not that useful now is it? The same behaviour occurs if you were to change the namespace, for example during refactoring.
The error shown above is during initialization, however it seems that all front facing pages seem to break before your app recycles. 
After the app recycle however you will not be able to access the CMS anymore.

So what if we change logging to log all messages? We get a little bit closer because of the warning but still way too obscure:

{% highlight XML %}
2017-02-24 15:07:16,482 [12] WARN EPiServer.Construction.Internal.PropertyDataFactory: Unable to create a PropertyData instance of Type: 'AlloyDemoKit.Models.Pages.Test.Property.TypoListProperty' Assembly: 'AlloyDemoKit'. Will fallback using the data type instead.
....
2017-02-24 15:07:16,795 [12] ERROR EPiServer.Framework.Cache.ObjectInstanceCacheExtensions: Failed to Read cacheKey = 'EPContentVersion:334_563'
Newtonsoft.Json.JsonReaderException: Unexpected character encountered while parsing value: [. Path '', line 1, position 1.
   at Newtonsoft.Json.JsonTextReader.ReadStringValue(ReadType readType)
....
2017-02-24 15:07:17,114 [1] ERROR EPiServer.Framework.Initialization.InitializationEngine: Initialize action failed for 'Initialize on class EPiServer.Initialization.Internal.ModelSyncInitialization, EPiServer, Version=10.4.2.0, Culture=neutral, PublicKeyToken=8fe83dea738b45b7'
System.AggregateException: One or more errors occurred. ---> Newtonsoft.Json.JsonReaderException: Unexpected character encountered while parsing value: [. Path '', line 1, position 1.
   at Newtonsoft.Json.JsonTextReader.ReadStringValue(ReadType readType)
{% endhighlight XML %}

#### What if this happens in production?
Obviously this error should've already occured on your test or staging environment. But what if, in worst case, you have to fix this on a production environment.
If this error occurs in production you don't have a lot of options. The CMS isn't available so you'll have to do some digging in the database.

<p class="centered-image">
	<img src="/assets/propertylist/3.database.png" alt="Database">	
</p>
First you'll have to find you property definition in the [tblPropertyDefinition] table. Use the pkID to find both the data in the [tblContentProperty] and the [tblWorkContentProperty] table.
If you delete the data from those two tables you'll be able to start your site again. Make sure to save the data if you want to keep it. After deleting the data, go to the admin mode, find the problematic property and switch it from Type "TypoListProperty" to "MyCustomDataListProperty".  

#### What can we learn from this?
In general it is advised to not use pre-release APIs at all. However if you're willing to take the gamble, be prepared to run into problems like I've described in this post.
I've seen this error before but didn't give it much notice, I always have a working database backup ready during development which increases the risk of having a mistake like this occuring on test.
 
#### How to change the namespace or rename TypoListProperty?
In my next blogpost I'll show you how to move data in case you want to rename or refactor your ListProperty. I'll also take a look at implementing PropertyList in a different, more safe, way.


