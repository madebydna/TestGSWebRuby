/* Plugin for Cycle2; Copyright (c) 2012 M. Alsup; v20130528 */
//(function(e){"use strict";e(document).on("cycle-bootstrap",function(e,i,t){"carousel"===i.fx&&(t.getSlideIndex=function(e){var i=this.opts()._carouselWrap.children(),t=i.index(e);return t%i.length},t.next=function(){var e=i.reverse?-1:1;i.allowWrap===!1&&i.currSlide+e>i.slideCount-i.carouselVisible||(i.API.advanceSlide(e),i.API.trigger("cycle-next",[i]).log("cycle-next"))})}),e.fn.cycle.transitions.carousel={preInit:function(i){i.hideNonActive=!1,i.container.on("cycle-destroyed",e.proxy(this.onDestroy,i.API)),i.API.stopTransition=this.stopTransition;for(var t=0;i.startingSlide>t;t++)i.container.append(i.slides[0])},postInit:function(i){var t,n,s,o,l=i.carouselVertical;i.carouselVisible&&i.carouselVisible>i.slideCount&&(i.carouselVisible=i.slideCount-1);var r=i.carouselVisible||i.slides.length,c={display:l?"block":"inline-block",position:"static"};if(i.container.css({position:"relative",overflow:"hidden"}),i.slides.css(c),i._currSlide=i.currSlide,o=e('<div class="cycle-carousel-wrap"></div>').prependTo(i.container).css({margin:0,padding:0,top:0,left:0,position:"absolute"}).append(i.slides),i._carouselWrap=o,l||o.css("white-space","nowrap"),i.allowWrap!==!1){for(n=0;(void 0===i.carouselVisible?2:1)>n;n++){for(t=0;i.slideCount>t;t++)o.append(i.slides[t].cloneNode(!0));for(t=i.slideCount;t--;)o.prepend(i.slides[t].cloneNode(!0))}o.find(".cycle-slide-active").removeClass("cycle-slide-active"),i.slides.eq(i.startingSlide).addClass("cycle-slide-active")}i.pager&&i.allowWrap===!1&&(s=i.slideCount-r,e(i.pager).children().filter(":gt("+s+")").hide()),i._nextBoundry=i.slideCount-i.carouselVisible,this.prepareDimensions(i)},prepareDimensions:function(i){var t,n,s,o=i.carouselVertical,l=i.carouselVisible||i.slides.length;if(i.carouselFluid&&i.carouselVisible?i._carouselResizeThrottle||this.fluidSlides(i):i.carouselVisible&&i.carouselSlideDimension?(t=l*i.carouselSlideDimension,i.container[o?"height":"width"](t)):i.carouselVisible&&(t=l*e(i.slides[0])[o?"outerHeight":"outerWidth"](!0),i.container[o?"height":"width"](t)),n=i.carouselOffset||0,i.allowWrap!==!1)if(i.carouselSlideDimension)n-=(i.slideCount+i.currSlide)*i.carouselSlideDimension;else{s=i._carouselWrap.children();for(var r=0;i.slideCount+i.currSlide>r;r++)n-=e(s[r])[o?"outerHeight":"outerWidth"](!0)}i._carouselWrap.css(o?"top":"left",n)},fluidSlides:function(i){function t(){clearTimeout(s),s=setTimeout(n,20)}function n(){i._carouselWrap.stop(!1,!0);var e=i.container.width()/i.carouselVisible;e=Math.ceil(e-l),i._carouselWrap.children().width(e),i._sentinel&&i._sentinel.width(e),r(i)}var s,o=i.slides.eq(0),l=o.outerWidth()-o.width(),r=this.prepareDimensions;e(window).on("resize",t),i._carouselResizeThrottle=t,n()},transition:function(i,t,n,s,o){var l,r={},c=i.nextSlide-i.currSlide,a=i.carouselVertical,d=i.speed;if(i.allowWrap===!1){s=c>0;var u=i._currSlide,p=i.slideCount-i.carouselVisible;c>0&&i.nextSlide>p&&u==p?c=0:c>0&&i.nextSlide>p?c=i.nextSlide-u-(i.nextSlide-p):0>c&&i.currSlide>p&&i.nextSlide>p?c=0:0>c&&i.currSlide>p?c+=i.currSlide-p:u=i.currSlide,l=this.getScroll(i,a,u,c),i.API.opts()._currSlide=i.nextSlide>p?p:i.nextSlide}else s&&0===i.nextSlide?(l=this.getDim(i,i.currSlide,a),o=this.genCallback(i,s,a,o)):s||i.nextSlide!=i.slideCount-1?l=this.getScroll(i,a,i.currSlide,c):(l=this.getDim(i,i.currSlide,a),o=this.genCallback(i,s,a,o));r[a?"top":"left"]=s?"-="+l:"+="+l,i.throttleSpeed&&(d=l/e(i.slides[0])[a?"height":"width"]()*i.speed),i._carouselWrap.animate(r,d,i.easing,o)},getDim:function(i,t,n){var s=e(i.slides[t]);return s[n?"outerHeight":"outerWidth"](!0)},getScroll:function(e,i,t,n){var s,o=0;if(n>0)for(s=t;t+n>s;s++)o+=this.getDim(e,s,i);else for(s=t;s>t+n;s--)o+=this.getDim(e,s,i);return o},genCallback:function(i,t,n,s){return function(){var t=e(i.slides[i.nextSlide]).position(),o=0-t[n?"top":"left"]+(i.carouselOffset||0);i._carouselWrap.css(i.carouselVertical?"top":"left",o),s()}},stopTransition:function(){var e=this.opts();e.slides.stop(!1,!0),e._carouselWrap.stop(!1,!0)},onDestroy:function(){var i=this.opts();i._carouselResizeThrottle&&e(window).off("resize",i._carouselResizeThrottle),i.slides.prependTo(i.container),i._carouselWrap.remove()}}})(jQuery);

/*! carousel transition plugin for Cycle2;  version: 20130528 */
(function($) {
"use strict";

$( document ).on('cycle-bootstrap', function( e, opts, API ) {
    if ( opts.fx !== 'carousel' )
        return;

    API.getSlideIndex = function( el ) {
        var slides = this.opts()._carouselWrap.children();
        var i = slides.index( el );
        return i % slides.length;
    };

    // override default 'next' function
    API.next = function() {
        var count = opts.reverse ? -1 : 1;
        if ( opts.allowWrap === false && ( opts.currSlide + count ) > opts.slideCount - opts.carouselVisible )
            return;
        opts.API.advanceSlide( count );
        opts.API.trigger('cycle-next', [ opts ]).log('cycle-next');
    };

});


$.fn.cycle.transitions.carousel = {
    // transition API impl
    preInit: function( opts ) {
        opts.hideNonActive = false;

        opts.container.on('cycle-destroyed', $.proxy(this.onDestroy, opts.API));
        // override default API implementation
        opts.API.stopTransition = this.stopTransition;

        // issue #10
        for (var i=0; i < opts.startingSlide; i++) {
            opts.container.append( opts.slides[0] );
        }
    },

    // transition API impl
    postInit: function( opts ) {
        var i, j, slide, pagerCutoffIndex, wrap;
        var vert = opts.carouselVertical;
        if (opts.carouselVisible && opts.carouselVisible > opts.slideCount)
            opts.carouselVisible = opts.slideCount - 1;
        var visCount = opts.carouselVisible || opts.slides.length;
        var slideCSS = { display: vert ? 'block' : 'inline-block', position: 'static' };

        // required styles
        opts.container.css({ position: 'relative', overflow: 'hidden' });
        opts.slides.css( slideCSS );

        opts._currSlide = opts.currSlide;

        // wrap slides in a div; this div is what is animated
        wrap = $('<div class="cycle-carousel-wrap"></div>')
            .prependTo( opts.container )
            .css({ margin: 0, padding: 0, top: 0, left: 0, position: 'absolute' })
            .append( opts.slides );

        opts._carouselWrap = wrap;

        if ( !vert )
            wrap.css('white-space', 'nowrap');

        if ( opts.allowWrap !== false ) {
            // prepend and append extra slides so we don't see any empty space when we
            // near the end of the carousel.  for fluid containers, add even more clones
            // so there is plenty to fill the screen
            // @todo: optimzie this based on slide sizes

            for ( j=0; j < (opts.carouselVisible === undefined ? 2 : 1); j++ ) {
                for ( i=0; i < opts.slideCount; i++ ) {
                    wrap.append( opts.slides[i].cloneNode(true) );
                }
                i = opts.slideCount;
                while ( i-- ) { // #160, #209
                    wrap.prepend( opts.slides[i].cloneNode(true) );
                }
            }

            wrap.find('.cycle-slide-active').removeClass('cycle-slide-active');
            opts.slides.eq(opts.startingSlide).addClass('cycle-slide-active');
        }

        if ( opts.pager && opts.allowWrap === false ) {
            // hide "extra" pagers
            pagerCutoffIndex = opts.slideCount - visCount;
            $( opts.pager ).children().filter( ':gt('+pagerCutoffIndex+')' ).hide();
        }

        opts._nextBoundry = opts.slideCount - opts.carouselVisible;

        this.prepareDimensions( opts );
    },

    prepareDimensions: function( opts ) {
        var dim, offset, pagerCutoffIndex, tmp;
        var vert = opts.carouselVertical;
        var visCount = opts.carouselVisible || opts.slides.length;

        if ( opts.carouselFluid && opts.carouselVisible ) {
            if ( ! opts._carouselResizeThrottle ) {
            // fluid container AND fluid slides; slides need to be resized to fit container
                this.fluidSlides( opts );
            }
        }
        else if ( opts.carouselVisible && opts.carouselSlideDimension ) {
            dim = visCount * opts.carouselSlideDimension;
            opts.container[ vert ? 'height' : 'width' ]( dim );
        }
        else if ( opts.carouselVisible ) {
            dim = visCount * $(opts.slides[0])[vert ? 'outerHeight' : 'outerWidth'](true);
            opts.container[ vert ? 'height' : 'width' ]( dim );
        }
        // else {
        //     // fluid; don't size the container
        // }

        offset = ( opts.carouselOffset || 0 );
        if ( opts.allowWrap !== false ) {
            if ( opts.carouselSlideDimension ) {
                offset -= ( (opts.slideCount + opts.currSlide) * opts.carouselSlideDimension );
            }
            else {
                // calculate offset based on actual slide dimensions
                tmp = opts._carouselWrap.children();
                for (var j=0; j < (opts.slideCount + opts.currSlide); j++) {
                    offset -= $(tmp[j])[vert?'outerHeight':'outerWidth'](true);
                }
            }
        }

        opts._carouselWrap.css( vert ? 'top' : 'left', offset );
    },

    fluidSlides: function( opts ) {
        var timeout;
        var slide = opts.slides.eq(0);
        var adjustment = slide.outerWidth() - slide.width();
        var prepareDimensions = this.prepareDimensions;

        // throttle resize event
        $(window).on( 'resize', resizeThrottle);

        opts._carouselResizeThrottle = resizeThrottle;
        onResize();

        function resizeThrottle() {
            clearTimeout( timeout );
            timeout = setTimeout( onResize, 20 );
        }

        function onResize() {
            opts._carouselWrap.stop( false, true );
            var slideWidth = opts.container.width() / opts.carouselVisible;
            slideWidth = Math.ceil( slideWidth - adjustment );
            opts._carouselWrap.children().width( slideWidth );
            if ( opts._sentinel )
                opts._sentinel.width( slideWidth );
            prepareDimensions( opts );
        }
    },

    // transition API impl
    transition: function( opts, curr, next, fwd, callback ) {
        var moveBy, props = {};
        var hops = opts.nextSlide - opts.currSlide;
        var vert = opts.carouselVertical;
        var speed = opts.speed;

        // handle all the edge cases for wrapping & non-wrapping
        if ( opts.allowWrap === false ) {
            fwd = hops > 0;
            var currSlide = opts._currSlide;
            var maxCurr = opts.slideCount - opts.carouselVisible;
            if ( hops > 0 && opts.nextSlide > maxCurr && currSlide == maxCurr ) {
                hops = 0;
            }
            else if ( hops > 0 && opts.nextSlide > maxCurr ) {
                hops = opts.nextSlide - currSlide - (opts.nextSlide - maxCurr);
            }
            else if ( hops < 0 && opts.currSlide > maxCurr && opts.nextSlide > maxCurr ) {
                hops = 0;
            }
            else if ( hops < 0 && opts.currSlide > maxCurr ) {
                hops += opts.currSlide - maxCurr;
            }
            else
                currSlide = opts.currSlide;

            moveBy = this.getScroll( opts, vert, currSlide, hops );
            opts.API.opts()._currSlide = opts.nextSlide > maxCurr ? maxCurr : opts.nextSlide;
        }
        else {
            if ( fwd && opts.nextSlide === 0 ) {
                // moving from last slide to first
                moveBy = this.getDim( opts, opts.currSlide, vert );
                callback = this.genCallback( opts, fwd, vert, callback );
            }
            else if ( !fwd && opts.nextSlide == opts.slideCount - 1 ) {
                // moving from first slide to last
                moveBy = this.getDim( opts, opts.currSlide, vert );
                callback = this.genCallback( opts, fwd, vert, callback );
            }
            else {
                moveBy = this.getScroll( opts, vert, opts.currSlide, hops );
            }
        }

        props[ vert ? 'top' : 'left' ] = fwd ? ( "-=" + moveBy ) : ( "+=" + moveBy );

        // throttleSpeed means to scroll slides at a constant rate, rather than
        // a constant speed
        if ( opts.throttleSpeed )
            speed = (moveBy / $(opts.slides[0])[vert ? 'height' : 'width']() ) * opts.speed;

        opts._carouselWrap.animate( props, speed, opts.easing, callback );
    },

    getDim: function( opts, index, vert ) {
        var slide = $( opts.slides[index] );
        return slide[ vert ? 'outerHeight' : 'outerWidth'](true);
    },

    getScroll: function( opts, vert, currSlide, hops ) {
        var i, moveBy = 0;

        if (hops > 0) {
            for (i=currSlide; i < currSlide+hops; i++)
                moveBy += this.getDim( opts, i, vert);
        }
        else {
            for (i=currSlide; i > currSlide+hops; i--)
                moveBy += this.getDim( opts, i, vert);
        }
        return moveBy;
    },

    genCallback: function( opts, fwd, vert, callback ) {
        // returns callback fn that resets the left/top wrap position to the "real" slides
        return function() {
            var pos = $(opts.slides[opts.nextSlide]).position();
            var offset = 0 - pos[vert?'top':'left'] + (opts.carouselOffset || 0);
            opts._carouselWrap.css( opts.carouselVertical ? 'top' : 'left', offset );
            callback();
        };
    },

    // core API override
    stopTransition: function() {
        var opts = this.opts();
        opts.slides.stop( false, true );
        opts._carouselWrap.stop( false, true );
    },

    // core API supplement
    onDestroy: function( e ) {
        var opts = this.opts();
        if ( opts._carouselResizeThrottle )
            $( window ).off( 'resize', opts._carouselResizeThrottle );
        opts.slides.prependTo( opts.container );
        opts._carouselWrap.remove();
    }
};

})(jQuery);
