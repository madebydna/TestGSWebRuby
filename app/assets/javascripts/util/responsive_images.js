GS = GS || {};
GS.util = GS.util || {};

$(function(){
    GS.util.setupImages = function(options) {
        var mobileImage = options['mobileImage'];
        var desktopImage = options['desktopImage'];

        var isImageLoaded = function(imageContainerSelector) {
            var img = $(imageContainerSelector).find('img')[0];
            if (!(typeof img == 'undefined')) {
                return img.complete;
            } else {
                return false;
            }
        }

        var isMobile = function(container) {
            var nameRegex = new RegExp('_mobile....$')
            return nameRegex.test($(container).find('img').attr('src'))
        }

        var attachImage = function(container, src) {
            if (src == '') {
                $(container).empty();
                return false;
            }

            var thisImage = $("<img/>")
                .error(function() { console.log("error loading image"); })
                .attr("src", src)
                .addClass('scaling')
            $(container).empty();
            $(container).prepend(thisImage);
        }

        var shouldSwitch = function(container) {
            if (isImageLoaded(container)) {
                var img = $(container).find('img')[0];
                if($(window).width() < 480) {
                    if ((typeof img === 'undefined') || (!isMobile(container))) {
                        return true; // attachImage(container, mobileImage);
                    }
                } else {
                    if ((typeof $(container).find('img')[0] === 'undefined') || (isMobile(container))) {
                        return true; // attachImage(container, desktopImage);
                    }

                }
            } else {
                return false;
            }
        }

        var initImages = function() {
            $(options['selector']).each(function() {
                if($(window).width() > 480) {
                    if (!isImageLoaded(this) || shouldSwitch(this)) {
                        attachImage(this, desktopImage);
                    }
                } else {
                    if (!isImageLoaded(this) || shouldSwitch(this)) {
                        attachImage(this, mobileImage);
                    }
                }
            });
        }

        initImages();

        var reinitTimer;
        $(window).resize(function() {
            clearTimeout(reinitTimer);
            console.log('resize')       ;
            reinitTimer = setTimeout(initImages, 100);
        });
    }
});