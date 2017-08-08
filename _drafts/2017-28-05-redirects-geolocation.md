---
layout: post
title:  "Using geolocation to improve market and language selection"
date:   2017-05-28 12:00:00
tags: [geolocation,  episerver]
comments: true
---

Episerver has a [well documented](http://world.episerver.com/documentation/developer-guides/CMS/globalization/) way of determining which content language to use for displaying content to the user. One of the more powerful options is to enable the ``pageUseBrowserLanguagePreferences`` setting as it will allow Episerver to determine the preferred language by using the [language preferences](https://www.w3.org/International/questions/qa-lang-priorities) from the browser. In general, these language preference headers are sent in the header of every request by the browser and should give the server an idea of which language the user would prefer to see content in. In this blog I will take a look at how to use the users' geolocation in order to make a better prediction about the language and market that is most useful for them. I will also discuss some options to improve on Episervers' current browser language implementation.

#### NuGet package
If you want to something similar to what I've described in this post, please try out these NuGet packages: [asdf](http://asdf)

#### Markets
If you compare commerce projects to non-commerce projects, you could find that there are different rules for finding the correct language. Each market has its own available countries and languages. It could be that a language version is not available for that market. It could also be the other way around:

<p class="centered-image">
	<img src="/assets/geolocation/1.market-language-selector.gif" alt="Select market and language">	
</p>

In the example above the language "English" is available for all markets. This means that, by knowing just the users' preferred language, you are not able to determine the applicable market. Instead, we could try to retrieve the market based on the users' location and pick the language that fits best.
In Epi Commerce you can configure countries and languages that apply to a market.

<p class="centered-image">
	<img src="/assets/geolocation/1.market-settings.png" alt="Market settings">	
</p>

The idea is pretty simple, first find the market(s) for the users' country, after that, retrieve the available browser languages and check if they are available on the market. This functionality is available in the NuGet package, like so:

```csharp
public class MarketExample : Controller
{
    private readonly IGeolocationService _geolocationService;
    private readonly ICommerceGeolocationService _commerceGeolocationService;

    public MarketExample(
        IGeolocationService geolocationService, 
        ICommerceGeolocationService commerceGeolocationService)
    {
        _geolocationService = geolocationService;
        _commerceGeolocationService = commerceGeolocationService;
    }

    public void Example()
    {
        // Get location based on IP address
        var location = _geolocationService.GetLocation(Request);
        // Get market based on country
        var market = _commerceGeolocationService.GetMarket(location);
        // Get language based on browser preferences and available languages on market
        var language = _commerceGeolocationService.GetLanguage(Request, market);

        // Or a bit more concise
        var (market, language, location) = _commerceGeolocationService.GetMarket(Request);
    }
}
```

Or you could use the provided implementation of ICurrentMarket by registering it with your IoC container:
```csharp
 public class StructureMapRegistry : Registry
{
    public StructureMapRegistry()
    {
        For<ICurrentMarket>().Use<CurrentMarketFromGeolocation>()}
    }
}
```
The CurrentMarketFromGeolocation uses the ICommerceGeolocationService to retrieve the correct market, which is being cached by storing it in a cookie.

### Language branch

On a non-commerce site you could also make use of the users' location in order to determine a language branch. If you find that enabling the ``pageUseBrowserLanguagePreferences`` setting doesn't cut it, or you want to have a bit more control, you could use the ``GeolocationService`` found in the NuGet package ``xxxxx``. It has a couple of methods which try to find the correct languageBranch based on the users' browser settings, their IP address or both. With this you could, for example, create a ActionFilterAttribute that automatically redirects a user based on their IP address and browser settings.
```csharp
public class RedirectExampleController :  PageController<StartPage>
{
    [RedirectBasedOnGeolocation]  // This will check the users' location and redirect to the correct language branch
    public ActionResult Index(StartPage currentPage)
    {
...

public class RedirectBasedOnGeolocationAttribute : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext filterContext)
    {
        var geolocationService = ServiceLocator.Current.GetInstance<IGeolocationService>();
        var languageBranch = geolocationService.GetLanguage(filterContext.RequestContext.HttpContext.Request);
        filterContext.Result = new RedirectResult($"/{languageBranch.LanguageID}");
    }
}

```
* GeolocationService

#### Future improvements
As I was born and raised in the Netherlands, my native language is Dutch and not English. However, for most tech related devices/sites/content I prefer to use English. Both my phone and laptop are set to use English for example. Anyone who remembers those nicely translated error messages?

<p class="centered-image">
	<img src="/assets/geolocation/2.translated-exception.png" alt="This is what translated exceptions look like">	
</p>
<p>
    <strong>This is what Dutch error messages look like, even to me</strong>
</p>

One of the improvements can be to add a block which prompts the user to switch to a different language version or market. For this improvements both the provided services will come in handy as they provide us with ways to figure out which market and/or language options we can offer the user.

The library will match browser languages by full locale, so for example: a user with `en-US` will not match with a language branch `en`. An improvement would be to find  matches by looking at the  language as fallback for the full locale. It is quite probable that a user would prefer `en` over `fr` if they have `en-US` set up as preferred browser language, and maybe even vice versa. (on a sidenote, Episerver also only checks on full locale for the ``pageUseBrowserLanguagePreferences`` setting)


> #### tl;dr?
* New NuGet package to redirect users based on Geolocation
* Use the service to get correct language branch based on ip address
* Use the attribute to an action to redirect the user automatically