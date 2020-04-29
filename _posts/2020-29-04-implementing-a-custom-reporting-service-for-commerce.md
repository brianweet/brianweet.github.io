---
layout: post
title:  "Implementing a custom reporting service for commerce"
date:   2020-04-29 10:30:00
tags: [episerver, episerver-commerce]
comments: true
---

I've been trying out the [BETA functionality for generating commerce reports](https://world.episerver.com/documentation/developer-guides/commerce/reports/Collect-data-for-reports) in Episerver. By default, it will create an CSV export of all orders made that day and it allows for some extensibility. In this post I'll show you how you can add extra data to the report and I'll show you how to customize the report completely by implementing your own IReportingService.

## Reports for Commerce

Sales reports in [Commerce Manager](https://webhelp.episerver.com/latest/en/commerce/reporting/reporting-commerce-data.htm) (CM) have existed for a long time. But, as Episerver is slowly phasing out CM, it comes to no surprise that they've started to move some of that functionality to the CMS as well.
Episerver has enabled the BETA functionality for Commerce Reports by default. Reports are created by the scheduled job called `Collect Report Data`, which will create a zipped up CSV file with the orders for that day:

<p class="centered-image">
	<img src="/assets/epi-reporting/0.commerce-report.png" alt="Commerce report">
</p>

It's not hard to add custom data to this report, as described on [this page on World](https://world.episerver.com/documentation/developer-guides/commerce/reports/Collect-data-for-reports/#additional_properties):

```csharp
// Implement your own additional data handler
public class MyReportingAdditionalDataHandler : ReportingAdditionalDataHandler
{
    private readonly IOrderRepository _orderRepository;

    public MyReportingAdditionalDataHandler(IOrderRepository orderRepository)
    {
        _orderRepository = orderRepository;
    }

    public override IEnumerable<string> GetAdditionalData(int lineItemId, int orderGroupId)
    {
        var order = _orderRepository.Load<IPurchaseOrder>(orderGroupId);
        return new string[]
        {
            // Add additional data here
            order?.Properties["MyCustomProp"]?.ToString()
        };
    }
}

//Register it in
public class StructureMapRegistry : Registry
{
    public StructureMapRegistry()
    {
        //...
        For<ReportingAdditionalDataHandler>().Singleton().Use<MyReportingAdditionalDataHandler>();
    }
}
```

However, the extensibility is a bit lacking a bit as you can't add any headers to the csv file. Next to that, **it doesn't seem to escape CSV data properly yet**, for which a bug has been created (COM-11284, not public yet). I ended up with invalid CSV as some product names contained a comma, which broke the CSV.

## Implementing a custom reporting service

Fortunately it is really easy to implement your own reporting service! All you have to do is implement a IReportingService yourself. By doing so, you're free to implement anything you want. What I'll do is:

- Re-use the code from Epi in order to gather order data
  - My service will be quite similar to the one from Episerver, with some additional fields
- Map it to a custom object
  - Simple POCO object with some header names
- Write it as CSV inside a zip file
  - I'll use the CsvHelper library, which will handle writing CSV for me

The code:

```csharp
public class ReportingService : IReportingService
{
    private readonly IBlobFactory _blobFactory;
    private readonly IContentRepository _contentRepository;
    private readonly IUrlSegmentGenerator _urlSegmentGenerator;
    private readonly ReportingDataLoader _reportingDataLoader;
    private readonly OrderReportingMapper _orderReportingMapper;

    public ReportingService(
        IBlobFactory blobFactory,
        IContentRepository contentRepository,
        IUrlSegmentGenerator urlSegmentGenerator,
        ReportingDataLoader reportingDataLoader,
        OrderReportingMapper orderReportingMapper)
    {
        _blobFactory = blobFactory;
        _contentRepository = contentRepository;
        _urlSegmentGenerator = urlSegmentGenerator;
        _reportingDataLoader = reportingDataLoader;
        _orderReportingMapper = orderReportingMapper;
    }

    public virtual ContentReference ExportOrderDataAsCsv(
        DateTime fromDate,
        DateTime toDate)
    {
        // This is where the reports are stored by epi
        var reportingMediaData = _contentRepository.GetDefault<ReportingMediaData>(CommerceReportingFolder.ReportingRoot);
        // We can create a blob to hold our data
        var blob = _blobFactory.CreateBlob(reportingMediaData.BinaryDataContainer, ".commercereport");
        // Default naming
        var str = "OrderData-from-" + fromDate.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture) + "-to-" + toDate.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);

        // Open blob, create an zip archive and a csv entry
        using (var stream = blob.OpenWrite())
        using (var zipArchive = new ZipArchive(stream, ZipArchiveMode.Create, false))
        using (var entryStream = zipArchive.CreateEntry(str + ".csv").Open())
        using (var streamWriter = new StreamWriter(entryStream))
        using (var csv = new CsvWriter(streamWriter, CultureInfo.InvariantCulture))
        {
            // Use default functionality to load order report data
            var data = _reportingDataLoader.GetReportingData(
                fromDate.ToUniversalTime(),
                toDate.ToUniversalTime()
            );
            // Use a custom mapper and write csv
            csv.WriteRecords(_orderReportingMapper.Map(data));
        }

        // Default functionality, 'overwrite' any existing report
        reportingMediaData.BinaryData = blob;
        reportingMediaData.Name = str + ".zip";
        DeleteDuplicatedReport(reportingMediaData.Name);
        return _contentRepository.Save(reportingMediaData, SaveAction.Publish, AccessLevel.NoAccess);
    }
    //Removed the rest for brevity
}

// Simple mapper to create a POCO
public class OrderReportingMapper
{
    public IEnumerable<OrderLineItemRecord> Map(IEnumerable<LineItemReportingModel> orders)
    {
        return orders.Select(MapItem);
    }

    private OrderLineItemRecord MapItem(LineItemReportingModel item)
    {
        // Add additional vipps data to commerce-reports
        var order = _orderRepository.Load<IPurchaseOrder>(item.OrderGroupId);

        return new OrderLineItemRecord
        {
            LineItemId = item.LineItemId,
            MyCustomProp = order?.Properties["MyCustomProp"]?.ToString()
        };
    }
}

// POCO for writing csv
using CsvHelper.Configuration.Attributes;
public class OrderLineItemRecord
{
    [Name("Line Item Id")]
    public int LineItemId { get; set; }
    [Name("My Custom Prop")]
    public int MyCustomProp { get; set; }
}
```

A complete implementation can be found on [on GitHub](https://gist.github.com/brianweet/e5229dd34aed66875a7db39babb607b3).
When you run the `Collect Report Data` job, your custom report will be generated and can be downloaded from the reports tab.

## Conclusion

In this blog post we've looked at the BETA functionality for generating reports in the CMS. We've seen how to add additional data to the default CSV report. And we've implemented a custom reporting service which will allow you to easily export files whatever you need.
