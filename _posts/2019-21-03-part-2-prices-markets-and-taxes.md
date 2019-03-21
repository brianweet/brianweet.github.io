---
layout: post
title:  "Part 2: prices, markets and taxes for B2B and B2C"
date:   2019-03-21 14:00:00
tags: [episerver, episerver-commerce]
comments: true
---

In this blog post we'll continue on the topic of prices, markets and taxes in one Episerver solution. As promised, we'll take a look at **using prices including or excluding tax** and adding support for **both a B2B site and a B2C site**. Just to refresh our memory, we'll take a look at this market configuration:

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/0.market-config.png" alt="Market config">
</p>

*As you can see we've configured `B2C_no` with `Prices Include Tax` set to `true` and on `B2C_us` it is set to `false`*

## Using prices including tax (EU)

As of [Episerver Commerce 12](https://world.episerver.com/documentation/upgrading/episerver-commerce/commerce-12/breaking-changes-commerce-12/) it is supported by default to using prices including tax. You might ask, why would you pick one over the other?

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/5.includes-tax.png" alt="Includes tax">
</p>

*Display prices including tax on the product list and the cart*

The answer is two-fold, the **first** reason is simple if you think about *performance*, if you import prices including tax you don't have to calculate taxes on top of the price when you want to use them. Even though calculation is optimized to a certain extent, it's not necessary to do calculations at all if you have prices including tax in the first place.

In the U.S. it's quite common to display prices excluding tax, even on B2C sites. This is not the case in the EU, where people are used to seeing prices including tax on customer facing sites. As mentioned in the previous post, if you have a price excluding tax, it's not that convenient to calculate price including tax if you don't have a proper cart. It's possible but requires you to construct some cart related objects (implementing `ILineItem` and `IOrderAddress`) in order to calculate the price including tax. Therefore it might be more convenient to move this to your import process, instead of doing it when you want to display page full of products with prices.

Let's compare including and excluding taxes for B2C_no, the end result *should* be the same as long as you call Episerver's `ITaxCalculator` with the correct parameters:

| Market        | Prices Include Tax     | Price in db  | Tax               | Price inc. tax |
| ------------- |:----------------------:|:------------:|:----------------- |:-------------- |
| B2C_no        | true                   | NOK 1600     | 25% / NOK 320   * | NOK 1600       |
| B2C_no        | false                  | NOK 1280     | 25% / NOK 320   * | NOK 1600     * |

*\* means that this has to be calculated*

Notice that I used *should* in my previous sentence, as it might be that you end up with *rounding* issues while using the `ITaxCalculator`. Which brings us to the **second** reason to import prices including tax: having a hard requirement on customer facing prices (price has to be exactly 19.99). This does depend on the type and quantity of product you sell and the calculation you have to do (e.g. square meter prices have to end up at exactly the correct price). Usually these rounding issues have to be solved somehow and could be the reason to simply use prices that do not have to be altered before displaying them.

## Using prices excluding tax (US)

The default way of handling taxes in Episerver has been to calculate taxes on top of prices. At first, depending on where you're from, it might be a bit confusing how this works and why it's done like this. But the reason is pretty simple: Episerver Commerce was mostly focused on the U.S. market and tax calculation is (quite a lot) more complex in the U.S.

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/3.State_Sales_Tax_Rates.jpg" alt="State sales tax rates">
</p>

By <a href="//commons.wikimedia.org/wiki/User:Wikideas1" title="User:Wikideas1">Wikideas1</a> - <span class="int-own-work" lang="en">Own work</span> <a rel="nofollow" class="external free" href="https://taxfoundation.org/state-corporate-income-tax-rates-and-brackets-2015/">https://taxfoundation.org/state-corporate-income-tax-rates-and-brackets-2015/</a>, <a href="https://creativecommons.org/licenses/by-sa/4.0" title="Creative Commons Attribution-Share Alike 4.0">CC BY-SA 4.0</a>, <a href="https://commons.wikimedia.org/w/index.php?curid=57036307">Link</a>

In general, you'd want to use prices excluding tax, especially if the tax rates vary within your market, which depends on the location of the customer. I heard that even in Norway this might be the case, as Svalbard apparently has some custom tax rules.

For the U.S. you'll probably have a big list of taxes that differ per state. The tax rates also [change from time to time](https://taxfoundation.org/sales-tax-rates-2019/) which means we might want to create a repeatable process or use an external system to update our tax rates from (Epi does have import functionality built-in).

<video loop controls="true" width='100%' height='100%' poster="/assets/prices-markets-and-taxes/svalbard.png">
    <source src="/assets/prices-markets-and-taxes/svalbard.mp4" type='video/mp4;' />
    <img src="/assets/prices-markets-and-taxes/svalbard.png" title="Your browser does not support the <video> tag"/>
</video>
*[Geta](https://getadigital.com/do-you-want-to-work-at-geta/) company trip to Svalbard, celebrating that we did not have to pay any sales tax there*

## Combining B2B and B2C sites

Once you've set up your taxes, you've imported the prices including tax for European B2C sites and the rest without tax. Everything on B2C seems to work, taxes get calculated properly because we [set the default shipping address](% post_url 2019-14-03-part-1-prices-markets-and-taxes %) and everyone is happy. Until you switch back to your B2B site and you suddenly notice that taxes are being calculated there as well. We have to disable tax calculation, but how? 🤔

By default Episerver doesn't really support mixing B2B and B2C sites through configuration. But it's not that hard to make it work: we've discussed the tax calculators a bit already but in this case all we have to do is make sure the tax calculators are not being used on our B2B site.

We decided to use a certain naming convention for our market ids, B2B markets start with `B2B` prefix and B2C markets with a `B2C` prefix. Therefore we can implement something like this to verify if we're dealing with a B2B market (only one method for brevity):
```csharp
 public static class MarketExtensions
{
    private const string B2BMarketPrefix = "B2B";
    public static bool IsB2B(this MarketId marketId)
    {
        return marketId.Value.StartsWith(B2BMarketPrefix, StringComparison.InvariantCultureIgnoreCase);
    }
}
```

Then we add some decorators for `ITaxCalculator` and `IShippingCalculator` in order to intercept certain calls for calculating taxes.

```csharp
public class B2BTaxCalculatorDecorator : ITaxCalculator
{
    private readonly ITaxCalculator _inner;
    public B2BTaxCalculatorDecorator(ITaxCalculator inner)
    {
        _inner = inner;
    }

     public Money GetSalesTax(ILineItem lineItem, IMarket market, IOrderAddress shippingAddress, Money basePrice)
    {
        if (market.IsB2B())
        {
            return new Money(0, basePrice.Currency);
        }
        return _inner.GetSalesTax(lineItem, market, shippingAddress, basePrice);
    }
    // You get the idea, same for the rest
}

public class B2BShippingCalculatorDecorator : IShippingCalculator
{
    private readonly IShippingCalculator _inner;
    public B2BShippingCalculatorDecorator(IShippingCalculator inner)
    {
        _inner = inner;
    }

    public Money GetShippingTax(IShipment shipment, IMarket market, Currency currency)
    {
        if (market.IsB2B())
        {
            return new Money(0, currency);
        }
        return _inner.GetShippingTax(shipment, market, currency);
    }
    // Do this for all tax related methods
    // Pass the rest straight to _inner
}
```
And all that's left is to register our decorators:
```csharp
public class StructureMapRegistry : Registry
{
    public StructureMapRegistry()
    {
        // In structure map registry
        For<ITaxCalculator>().DecorateAllWith<B2BTaxCalculatorDecorator>();
        For<IShippingCalculator>().DecorateAllWith<B2BShippingCalculatorDecorator>();
    }
}
```

Now we can sit back and enjoy our B2B and B2C sites running next to each other.

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/4.sit-back-relax-enjoy-the-show.jpg" alt="Sit back and enjoy the show">
</p>

### Conclusion

In this post we've looked at the `Price Include Tax` market setting in Episerver Commerce, we've seen how we can *improve performance* by using `Price Include Tax` and how it could help in case you run into *rounding* issues.

After setting up markets, taxes and making a decision on our price import, we still had a small problem with our *B2B* sites as we did not want any tax calculation there. We've seen how we can easily disable tax calculation for *B2B* by using a decorator for both `ITaxCalculator` and `IShippingCalculator`.