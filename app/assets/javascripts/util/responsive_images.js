GS = GS || {};
GS.util = GS.util || {};

//determine screen size - break points to load different images
//register image for size and location
//check for image - either delete or leave or hide
//add image to correct location
//mocha - rspec
//
//add priority?
//responsive support

$(function() {
  GS.util.setupImages = function(options) {
    var mobileImage = options['mobileImage'];
    var desktopImage = options['desktopImage'];
    var domSelector = options['selector'];
    var imgClasses = options['classes'];
    var breakpoint = options['breakpoint'];
    var loadMobile= true;
    var mobileBreakPoint = 481;
    if(typeof breakpoint !== "undefined"){
        mobileBreakPoint = breakpoint;

    }
    if(typeof options['loadMobile'] !== "undefined"){
          loadMobile = options['loadMobile'];
    }
    var checkPrepForImage = function(obj, imageUrl){
      // see if any image is loaded
      // see if the image is already loaded -
      //  return false;  -- don't load the image
      // else
      //  return true
      //  empty it out -- this may change in the future to hide instead
      //
      var imgTag = obj.find("img");
      if(typeof imgTag === "undefined") return true;
      if(imgTag.attr("src") === imageUrl) return false;
      obj.empty();
      return true;
    }

    var attachImage = function(obj, src) {
      var thisImage = $("<img/>")
        .error(function() { return false; })
        .attr("src", src)
        .addClass(imgClasses);
      obj.prepend(thisImage);
      return true;
    }

    var initImages = function() {
      var imageUrl = desktopImage;
      var imageSelector = $(domSelector);
      var loadImage= true;
      if($(window).width() < mobileBreakPoint) {
        if (!loadMobile ){
            loadImage = false;
        }
        imageUrl = mobileImage;
      }
      if(loadImage && checkPrepForImage(imageSelector, imageUrl)){
        if(attachImage(imageSelector, imageUrl)){
          GS.util.log("image loaded:"+imageUrl);
        }
        else{
          GS.util.log("image failed to load:"+imageUrl);
        }
      }
    }

    initImages();
  }
});
