 Zepto(function($){
      var groups = {};
      $('.gallery a').each(function() {
        var id = parseInt($(this).attr('data-group'), 10);
        if(!groups[id]) {
          groups[id] = [];
        } 
        groups[id].push(this);
      });

      $.each(groups, function() {
        $(this).magnificPopup({
            type: 'image',
            closeOnContentClick: false,
            closeBtnInside: false,
            gallery: { enabled:true }
        })
      });

      var imageElements = $('img:not(.galleryItemThumb):not(.no-zoom)');
      if (!imageElements.length){
        return;
      }
      imageElements.magnificPopup({
        type: 'image',
        callbacks: {
          elementParse: function(item) { 
            item.src = item.el.attr('src');
          }
        },
        closeOnContentClick: true,
        closeBtnInside: false,
        fixedContentPos: true,
        mainClass: 'mfp-no-margins mfp-with-zoom', // class to remove default margin from left and right side
        image: {
          verticalFit: true,
          titleSrc: function(item) {
            return item.el.attr('title') + ' &middot; <a class="image-source-link" href="'+item.src+'" target="_blank">open original</a>';
          }
        },
        zoom: {
          enabled: true,
          duration: 300 // don't foget to change the duration also in CSS
        }
      });

      

    });