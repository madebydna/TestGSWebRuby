GS.customCarouselControl = GS.customCarouselControl || {};

GS.customCarouselControl.cycle2Carousel = GS.customCarouselControl.cycle2Carousel || (function () {

      var enableMultipleCarouselsNav = function () {
        var $carousels = jQuery('.js-carousel');

        $carousels.each(function () {
          var $this = jQuery(this);
          var slideshows = $this.find('.cycle-slideshow');

          var getCarouselIndex = function (e) {
            var index = slideshows.index(e.target);
            if (index === undefined || index == slideshows.length - 1)
              index = 0;
            else
              index++;

            return index;
          }
          // from http://jquery.malsup.com/cycle2/demo/sync.php and
          // http://stackoverflow.com/questions/2146699/multiple-jquery-cycle-slideshows-with-their-own-navs

          slideshows.each(function () {
            var $this = $(this);

            $this.cycle('pause');

            $this.cycle({
              prev: $this.next('.js-prev'),
              next: $this.next('.js-next')
            });
          });

          $this.on('click', '.js-prev', function (e) {
            var index = getCarouselIndex(e);
            slideshows.eq(index).cycle('prev');
          });

          $this.on('click', '.js-next', function (e) {
            var index = getCarouselIndex(e);
            slideshows.eq(index).cycle('next');
          });

        });
      };

      return {
        enableMultipleCarouselsNav: enableMultipleCarouselsNav
      };
    })();
