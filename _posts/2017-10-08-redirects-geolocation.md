---
layout: post
title:  "Using geolocation to improve market and language selection"
date:   2017-08-10 12:00:00
tags: [geolocation, episerver]
comments: true
---

Episerver has a [well documented](http://world.episerver.com/documentation/developer-guides/CMS/globalization/) way of determining which content language to use for displaying content to the user. One of the more powerful options is to enable the ``pageUseBrowserLanguagePreferences`` setting as it will allow Episerver to determine the preferred language by using the [language preferences](https://www.w3.org/International/questions/qa-lang-priorities) from the browser. In general, these language preference headers are sent in the header of every request by the browser and should give the server an idea of which language the user would prefer to see content in. 

In this blog I will take a look at how to use the users' geolocation in order to make a better prediction about the language and market that is most useful for them. I will also discuss some options to improve on Episervers' current browser language implementation.

#### NuGet package
If you want to something similar to what I've described in this post, please try out the NuGet packages referenced on the [Geta GitHub repo](https://github.com/Geta/EPi.GeolocationTools). **Not available on the Episerver NuGet feed yet.**

#### Markets
If you compare commerce projects to non-commerce projects, you could find that there are different rules for finding the correct language. Each market has its own available countries and languages. It could be that a language version is not available for that market. It could also be the other way around:

<p class="centered-image">
	<img src="/assets/geolocation/1.market-language-selector.gif" alt="Select market and language">	
</p>

In the example above the language "English" is available for all markets. This means that, by knowing just the users' preferred language, you are not able to determine the applicable market. Instead, we could try to retrieve the market based on the users' location and pick the language that fits best.
In Epi Commerce you can configure countries and languages that apply to a market.

<p class="centered-image">
	<img src="/assets/geolocation/1.1.market-settings.png" alt="Market settings">	
</p>

The idea is pretty simple, first find the market(s) for the users' country, after that, retrieve the available browser languages and check if they are available on the market. This functionality is available in the NuGet package, like so:

```csharp
public class MarketExample : Controller
{
    private readonly ICurrentMarket _currentMarket;
    private readonly ICommerceGeolocationService _commerceGeolocationService;

    public MarketExample(
        ICurrentMarket currentMarket, 
        ICommerceGeolocationService commerceGeolocationService)
    {
        _currentMarket = currentMarket;
        _commerceGeolocationService = commerceGeolocationService;
    }

    public void Index()
    {
        // Get current market based on geolocation and browser preferences, can be null
        var (market, language, location) = _commerceGeolocationService.GetMarket(Request);
        
        // This one will be cached by storing the result in a cookie
        // Will fall back to first enabled market or the default market
        var sameMarket = _currentMarket.GetCurrentMarket();
    }
}
```

Or you could use the provided implementation of ICurrentMarket, CurrentMarketFromGeolocation, by configuring it in StructureMap:
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

#### Language branch

On a non-commerce site you could also make use of the users' location in order to determine a language branch. If you find that enabling the ``pageUseBrowserLanguagePreferences`` setting doesn't cut it, or you want to have a bit more control, you could use the ``GeolocationService`` found in the NuGet package ``Geta.EPi.GeolocationTools``. It has a couple of methods which help you finding a languageBranch based on the users' browser settings, their IP address or both. With this you could, for example, create a ActionFilterAttribute that automatically redirects a user based on their IP address and browser settings. 
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
Example use of IGeolocationService
```csharp
public class LanguageBranchExample : Controller
{
    private readonly IGeolocationService _geolocationService;
    public LanguageBranchExample(IGeolocationService geolocationService)
    {
        _geolocationService = geolocationService;
    }

    public void Index()
    {
        // Gets the language based on the users' location and their browser preferences, depending on what is available.
        // 1. Language branch for both the users' country and their browser preferences
        // 2. Language branch for users' browser preferences
        // 3. Fallback language
        var languageBranch = _geolocationService.GetLanguage(Request);
    }
}
```

#### Future improvements
As I was born and raised in the Netherlands, my native language is Dutch and not English. However, for most tech related devices/sites/content I prefer to use English. Both my phone and laptop are set to use English for example. Anyone who remembers those nicely translated .NET framework error messages?

<p class="centered-image">
	<img src="/assets/geolocation/2.translated-exception.png" alt="This is what translated exceptions look like">	
</p>
<p>
    <strong>This is what Dutch error messages look like, even to me</strong>
</p>

One of the future improvements for this NuGet package is to add a block which prompts the user to switch to a different language version or market. So instead of forcing a market/language we might want to ask the user for input first.

Another future improvement is to change the logic for matching prefered browser languages. The first version of this library will match browser languages by full locale, so for example: a user with `en-US` will not match with a language branch `en`. It is quite probable that a user would prefer `en` over `fr` if they have `en-US` set up as preferred browser language, and maybe even vice versa (on a sidenote, Episerver also only checks on full locale for the ``pageUseBrowserLanguagePreferences`` setting).

<p class="centered-image">
	<img src="https://m.popkey.co/20f09e/qrVG5.gif" alt="Nothing to see here">	
</p>


> #### tl;dr?
* New NuGet packages to determine market and language based on geolocation and browser language preferences (not available yet)