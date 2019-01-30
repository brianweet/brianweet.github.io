---
layout: post
title:  "Validating property list items"
date:   2019-01-27 16:00:00
tags: [episerver, cms]
comments: true
---
This will be a very simple blog post but it might come in handy when you want to add (complex) logic to validate property list items with a custom class. Let's presume we have a page with a property list of type `CustomData`.

```csharp
[ContentType(GUID = "{EA443137-A4FD-402A-A9AB-BD0045DA700C}")]
public class ExamplePage : PageData
{
    [EditorDescriptor(EditorDescriptorType = typeof(CollectionEditorDescriptor<CustomData>))]
    public virtual  IList<CustomData> MyCustomData { get; set; }
}
public class CustomData
{
    public int FirstValue { get; set; }
    public int SecondValue { get; set; } // SecondValue should be > FirstValue
}
[PropertyDefinitionTypePlugIn]
public class CustomDataPropertyList : PropertyList<CustomData>
{
}
```

As I want to add some validation to `CustomData`, the first thing I tried was adding `IValidatableObject` to the `CustomData` class, however the `Validate` method was never called. Episerver has a couple of [built-in validation attributes](https://world.episerver.com/documentation/developer-guides/CMS/Content/Properties/property-value-list/) for validating the items of a `PropertyList` (with primitive types).

<p class="centered-image">
	<img src="/assets/validating-property-list/0.existing-validation-attributes.png" alt="Existing validation attributes">
</p>

I decided to go the same route and write a custom validation attribute and add my validation logic using an attribute.
```
[AttributeUsage(AttributeTargets.Property)]
public class CustomDataValidationAttribute : ValidationAttribute
{
    public override bool IsValid(object value)
    {
        if (!(value is CustomData customData))
        {
            return false;
        }

        return customData.FirstValue < customData.SecondValue;
    }
}

[AttributeUsage(AttributeTargets.Property)]
public class ItemCustomDataValidationAttribute : CustomDataValidationAttribute
{
    public override bool IsValid(object value)
    {
        return ListItemValidator.IsValid(value, base.IsValid);
    }
}

/// <summary>
/// Helper method. <see cref="EPiServer.DataAnnotations.Internal.ListItemValidator"/>
/// </summary>
public static class ListItemValidator
{
    public static bool IsValid(object value, Func<object, bool> itemValidator)
    {
        if (value == null)
        {
            return true;
        }

        return value is IEnumerable enumerable && enumerable.Cast<object>().All(itemValidator);
    }
}
```

`CustomDataValidationAttribute` contains the actual validation logic. `ItemCustomDataValidationAttribute` is the attribute that will be added to the PropertyList property on the ExamplePage in order to validate the items in the list. Lastly `ListItemValidator` is a helper method to iterate the list and execute the validation for each of the items in the PropertyList.
Add the `ItemCustomDataValidationAttribute` to the property and you'll receive an error message when the validation fails.
```csharp
[ContentType(GUID = "{EA443137-A4FD-402A-A9AB-BD0045DA700C}")]
public class MyPage : PageData
{
    [ItemCustomDataValidation]
    [EditorDescriptor(EditorDescriptorType = typeof(CollectionEditorDescriptor<CustomData>))]
    public virtual  IList<CustomData> MyCustomData { get; set; }
}
```
This way you can add custom logic to validate a single item, as we did in the example, or validate a list of items as a whole (just add logic to `ItemCustomDataValidationAttribute`).
