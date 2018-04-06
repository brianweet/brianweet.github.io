---
layout: post
title:  "Adding custom fields to Business Foundation meta classes"
date:   2018-04-06 12:00:00
tags: [episerver, episerver-commerce]
comments: true
---

A while ago I was working on a project and I was trying to add an extra field to the CustomerAddress meta class. For some reason I couldn't find the right meta class to extend. Fortunately my friendly colleague [Patrick](https://www.patrickvankleef.com) pointed out that I was looking at the wrong meta classes (MetaDataPlus instead of Business Foundation). A couple of days ago Patrick asked me how to add an extra field to the CustomerContact, which is a BF meta class as well. I see some repetition here, so I thought I write a small blog post about it. 

We need a little bit of code, first we see an initialization module to create meta field, use ``ContactEntity.ClassName`` if you want to extend the CustomerContact:
```csharp
[InitializableModule]
[ModuleDependency(typeof(EPiServer.Commerce.Initialization.InitializationModule))]
internal class BusinessFoundationInitialization : IInitializableModule
{
    public void Initialize(InitializationEngine context)
    {
        CreateMetaField(AddressEntity.ClassName, Constants.AddressIdentifierFieldName, Constants.AddressIdentifierFieldName);
    }

    private void CreateMetaField(string metaClassName, string metaFieldName, string friendlyName, bool isNullable = true, int maxLength = 255, bool isUnique = false)
    {
        var metaClass = GetMetaClass(metaClassName);
        if (metaClass == null)
        {
            return;
        }

        var fieldExists = metaClass.Fields.Contains(metaFieldName);
        if (fieldExists)
        {
            return;
        }
        
        using(var metaFieldBuilder = new MetaFieldBuilder(metaClass))
        {
            metaFieldBuilder.MetaClass.AccessLevel = AccessLevel.Customization;
            metaFieldBuilder.CreateText(metaFieldName, friendlyName, isNullable, maxLength, isUnique);
            metaFieldBuilder.SaveChanges();
        }
    }

    private MetaClass GetMetaClass(string metaClassName)
    {
        return DataContext.Current.GetMetaClass(metaClassName);
    }

    public void Uninitialize(InitializationEngine context)
    {
    }
}
```

```csharp
public class Constants
{
    public const string AddressIdentifierFieldName = "CustomAddressIdentifier";
}
```

Once that is done; accessing the new property is straightforward:
```csharp
public static class AddressExtensions
{
    public static void SetCustomIdentifier(this CustomerAddress customerAddress, string customIdentifier)
    {
        customerAddress[Constants.AddressIdentifierFieldName] = customIdentifier;
    }

    public static string GetCustomIdentifier(this CustomerAddress customerAddress)
    {
        return customerAddress[Constants.AddressIdentifierFieldName]?.ToString() ?? string.Empty;
    }
}
```

It's as easy as that. Be sure to save your entity (e.g. CustomerContact) though. Otherwise the data will, obviously, not persist.