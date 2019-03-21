---
layout: post
title:  "Part 1: prices, markets and taxes for B2B and B2C"
date:   2019-03-14 14:00:00
tags: [episerver, episerver-commerce]
comments: true
---

In the following two blog posts I'll take a look at the decisions and caveats you'll run into while implementing both a B2B and a B2C site in one Episerver solution. By default Episerver supports couple of different market and tax configurations. We'll take a look at this example market configuration:

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/0.market-config.png" alt="Market config">
</p>

As you can see we have configured a couple of markets for B2B and B2C, both in Norway and the U.S.

In the last column there's a setting 'Prices include Tax'; when we're importing prices we often have a decision to make: do we want to import the prices including or excluding tax?

Depending on your particular project, this can be either a business decision or a development decision. As you can see we've chosen to import prices including tax for B2C_no. As always, there are pros and cons to either implementation and I'll try to cover them in this blog series.

First we'll take a quick look at the requirements for doing tax calculation in Episerver.

## Setting up and calculating taxes

Requirements:

1. Tax (jurisdiction) configuration in Commerce Manager
2. Tax category on variation
3. Shipping address in cart

The first requirement is the fact that you have to set up taxes using [Commerce manager](http://webhelp.episerver.com/latest/commerce/system-administration/configuring-taxes.htm) (hereafter called CM).
You'll have to set up Tax Jurisdiction Groups, Tax Jurisdictions and Taxes for the countries and/or the states you want to operate in. For example, for Norway we have:

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/1.commerce-manager-tax-configuration.gif" alt="Episerver Commerce Manager tax configuration">
</p>

- Jurisdiction
  - Default Norway - Country code NOR
- Jurisdiction Group
  - Norway - Default Norway Jurisdiction
- Taxes
  - Default sales tax
    - Tax category - Default
    - Tax rate - 25%
  - Shipping tax
    - Tax category - Default
    - Tax rate - 25%

The second requirement is quite simple, we have to configure the Tax category on the pricing tab of a variation:

<p class="centered-image">
	<img src="/assets/prices-markets-and-taxes/2.variation-tax-category.png" alt="Variation tax category">
</p>

During the tax configuration in CM you'll notice that you have to enter at least a country code for the Tax Jurisdiction. Accordingly, in order to do any tax calculation you will need to have a shipping address with at least a country code that matches your Tax Jurisdiction.

## Setting up a default shipping address

The third and last requirement is regarding the shipping address. Let's take a look at how to setting up a default shipping address for all customers.

When a new anonymous customer adds a variation to his or her cart, they will not get any tax amount back. This is because the anonymous user will not have any addresses set up yet. You'll need to set up a (default) shipping address for every user. We can do this in many ways, for example by using [geolocation]({% post_url 2017-10-08-redirects-geolocation %}), but for now we'll use simple market configuration to set up our default address.

We're using our own NuGet package for cart, but [Quicksilver](https://github.com/episerver/Quicksilver/blob/master/Sources/EPiServer.Reference.Commerce.Site/Features/Cart/Services/CartService.cs#L268) has a similar `LoadOrCreateCart` method where we can make sure we have an address to use for tax calculation. As mentioned, we will use market configuration (the first market country) but you could implement your own logic if you want:


```csharp
public class CartService : ICartService
{
    //...
    public virtual ICart LoadOrCreateCart(string name)
    {
        var cart = _orderRepository.LoadOrCreateCart<ICart>(_customerContext.CurrentContactId, name, _currentMarket);
        if (cart == null)
        {
            return null;
        }

        SetCartCurrency(cart, _currencyService.GetCurrentCurrency());
        SetDefaultShippingAddress(cart);
        return cart;
    }

    /// <summary>
    /// Initialize cart using a default shipping address, which is used in tax calculations.
    /// Creates an address using the first country of the market.
    /// </summary>
    public virtual void SetDefaultShippingAddress(ICart cart)
    {
        var shipment = cart.GetFirstShipment();
        if (shipment == null || shipment.ShippingAddress != null)
        {
            return;
        }

        var market = _marketService.GetMarket(cart.MarketId);
        var countryCode = market.Countries.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(countryCode))
        {
            return;
        }

        var address = cart.CreateOrderAddress(_orderGroupFactory, DefaultShippingAddressId);
        address.CountryCode = countryCode;
        shipment.ShippingAddress = address;

        ValidateCart(cart);
    }
    //...
}
```

## Calculating taxes using tax calculators

Now that we've everything set up, we can calculate taxes for our cart using `IOrderGroupCalculator` and calling `_orderGroupCalculator.GetOrderGroupTotals(cart)` to calculate the totals. You can also calculate the taxes per ILineItem by using `ILineItemCalculator` or `ITaxCalculator` and calling `_lineItemCalculator.GetSalesTax(lineItem, market, currency, shippingAddress)`. Similarly you have `IShippingCalculator`, `IShippingTaxCalculator` to calculate taxes based on a shipments.

#### Tax calculator limitations

Unfortunately the tax calculators have some limitations, if you only have a variation code and want to calculate the tax or the price including tax, there's not really a nice way to do so. You will need to create an `ILineItem` and a `IOrderAddress` to be able to use the `GetSalesTax` method. However, there are other options you could consider and we'll cover those in the upcoming blog post.

## Conclusion

In this blog post we've looked at the three requirements for setting up tax calculation work using Episerver Commerce. 

In the next blog post we will dive a bit deeper and discuss the difference between **using prices including or excluding tax**.

We will also take a look at how you can run **both a B2B site and a B2C site** in the same solution.
