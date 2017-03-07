 Zepto(function($) {
     $("[data-toggle-button]").on("click", function(e) {
         e.preventDefault();
         $(".toggle").toggleClass("hide");
         if (window.appInsights) {
             window.appInsights.trackEvent("toggle");
             window.appInsights.flush();
         }
     });
 });