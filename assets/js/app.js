 Zepto(function($) {
     $("[data-toggle-button]").on("click", function(e) {
         e.preventDefault();
         $(".toggle").toggleClass("hide");
         if (window.appInsights) {
             window.appInsights.trackEvent("toggle");
             window.appInsights.flush();
         }
     });

     function getColor(temperature){
            var minTemp = 15;
            var maxTemp = 30;
            var percent;
            if (temperature < minTemp) {
                return 'rgb(0,0,255)';
            } else if(temperature > maxTemp){
                return 'rgb(255,0,0)';
            } else {
                percent = (temperature-minTemp)/(maxTemp-minTemp) * 100;
            }

        r = percent>50 ? 255 : Math.floor((percent*2)*255/100);
        g = percent<50 ? 255 : Math.floor(255-(percent*2-100)*255/100);
        return 'rgba('+r+','+g+',0, 0.5)';
    }

     function getMeasurement() {
         $.getJSON("http://iotroom.azurewebsites.net/api/measurements", function(measurement){
            var $measurements = $("[data-measurements]");
            var $temperature = $measurements.find("[data-temperature]");
            var $timestamp = $measurements.find("[data-timestamp]");
            
            $measurements.addClass("measurements--visible");
            $temperature.text(measurement.temperature);

            $temperature[0].style.backgroundColor = getColor(measurement.temperature);
            $timestamp.text(new Date(measurement.time).toLocaleString());
         });
     }

     getMeasurement();
     setInterval(function(){
         var $measurements = $("[data-measurements]");
         $measurements.removeClass("measurements--visible");

         setTimeout(function() {
            getMeasurement();    
         }, 200);
     }, 2 * 60 * 1000);
 });