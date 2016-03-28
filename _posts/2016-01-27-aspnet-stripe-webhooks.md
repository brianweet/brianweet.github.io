---
layout: post
title:  "Implementing Stripe Webhooks using ASP.NET WebHooks Preview"
date:   2016-01-27 01:10:57
tags: [webhooks, stripe]
comments: true
---

In this post I will show you how to use ASP.NET WebHooks Preview to integrate with Stripe WebHooks. We will use the ASP.NET Stripe WebHooks Receiver beta6 for this. 
We could implement a WebHook receiver ourselves, in this case I am going to use the ASP.NET library as it provides us with a nice model to consume WebHooks from different providers.
Some useful links:

* [ASP.NET WebHooks Preview](https://github.com/aspnet/WebHooks)
* [ASP.NET WebHooks Documentation](https://docs.asp.net/projects/aspnetwebhooks/en/latest/)
* [Stripe WebHooks](https://stripe.com/docs/webhooks)
* [NuGet package for the Stripe Receiver](https://www.nuget.org/packages/Microsoft.AspNet.WebHooks.Receivers.Stripe/)

#### Creating a receiver
Lets create a new Web API project:
<p class="centered-image">
	<img src="/assets/stripe-webhooks/new-project.png" alt="Strong sign error">	
</p>

First we initialize the WebHookConfig by adding <code>config.InitializeReceiveStripeWebHooks();</code> to WebApiConfig.Register:
{% highlight C# %}
public static class WebApiConfig
{
    public static void Register(HttpConfiguration config)
    {
        // Web API configuration and services

        // Web API routes
        config.MapHttpAttributeRoutes();

        config.Routes.MapHttpRoute(
            name: "DefaultApi",
            routeTemplate: "api/{controller}/{id}",
            defaults: new { id = RouteParameter.Optional }
        );

        // Initialize Stripe WebHook receiver
        config.InitializeReceiveStripeWebHooks();
    }
}
{% endhighlight %}

The next step is to add a WebHookHandler to our project, we use MStripeWebHookReceiver.Name to determine the receiver name:
{% highlight C# %}
public class StripeWebHookHandler : WebHookHandler
{
    public StripeWebHookHandler()
    {
        this.Receiver = StripeWebHookReceiver.ReceiverName;
    }

    public override Task ExecuteAsync(string generator, WebHookHandlerContext context)
    {
        // For more information about Stripe WebHook payloads, please see 
        // 'https://stripe.com/docs/webhooks'
        StripeEvent entry = context.GetDataOrDefault<StripeEvent>();

        // We can trace to see what is going on.
        Trace.WriteLine(entry.ToString());

        // Switch over the event types if you want to
        switch (entry.Type)
        {
            default:
                // Information can be returned in a plain text response
                context.Response = context.Request.CreateResponse();
                context.Response.Content = new StringContent(string.Format("Hello {0} event!", entry.Type));
                break;
        }

        return Task.FromResult(true);
    }
}
{% endhighlight %}

we now have a custom handler for events sent to our stripe receiver URI: 
<code>http(s)://&lt;yourhost&gt;/api/webhooks/incoming/stripe/</code>
In case of a new WebHook request, the WebHookReceiversController will try to find a receiver registered with the name "stripe". In our case it will find the StripeWebHookReceiver which handles the incoming request and verifies the incoming data for us. Verification is done by retrieving the actual event through the Stripe API, using the 'id' field from the incoming WebHook request. The verification is necessary because anyone could send anything to our WebHook, by retrieving the data from Stripe you know that the data actually exists in your account. You can make use of the [Stripe IP Addresses](https://stripe.com/docs/ips) but still you'd like to check if you're able to access the received event with your current API Key.

Registering the Stripe API Secret Key with our own application is easy. Just save your key in the Web.Config like so (or use azure app settings):
{% highlight XML %}
<configuration>
  ...
  <appSettings>
    <add key="MS_WebHookReceiverSecret_Stripe" value="YOUR_SECRET_TOKEN" />
  </appSettings>
  ...
</configuration>
{% endhighlight %}
You can find your own Secret API key on the [Stripe API Keys page](https://dashboard.stripe.com/account/apikeys). I am using the Test Key right now, which offers the same functionality as the Live Key exept for making actual bank transactions obviously.
<p class="centered-image">
	<img src="/assets/stripe-webhooks/api-key.png" alt="API Key">
</p>
Copy the key to your web.config and deploy your application somewhere. Any arbitrary location that can be accessed by the Stripe servers should be fine, both http and https are supported at the moment. 
There are [ways](http://www.ultrahook.com/) to run webhooks on a dev environment but I haven't tried it yet).


And last but not least, register your webhook URI on the [WebHooks page](https://dashboard.stripe.com/account/webhooks).
<p class="centered-image">
	<img src="/assets/stripe-webhooks/webhook-uris.png" alt="WebHook uri">
</p>


#### Let's test our implementation
There are two ways to test our WebHooks implementation. There are quite a lot of events, the full list can be found [here](https://stripe.com/docs/api#event_types). 

In order to test our WebHook and the various events, we only have one option at the moment. That option is to create create actual instances of the objects that trigger events in test mode. Invoices and payments created in test mode or with the test API key will not trigger any actual payment. However in order to test for example ending trial periods, you have to create a subscription with a trial period for a user in order to trigger the event.

The Stripe Webhooks page has an option to send test webhooks. The WebHooks library however handler these events without calling our own StripeWebHookHandler though. I am currently working on a pull request which enables us to handle these test events ourselves.

--edit--
[Pull request](https://github.com/aspnet/WebHooks/pull/40) has landed, there's now a [sample project](https://github.com/aspnet/WebHooks/tree/master/samples/StripeReceiver) and you can set MS_WebHookStripeInTestMode to true if you want to receive test requests from Stripe.