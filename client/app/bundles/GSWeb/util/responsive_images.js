import log from 'util/log';

export function setupImages(options) {

  let mobileImage = options['mobileImage'];
  let desktopImage = options['desktopImage'];
  let domSelector = options['selector'];
  let imgClasses = options['classes'];
  let breakpoint = options['breakpoint'];
  let loadMobile= true;
  let mobileBreakPoint = 481;
  if(typeof breakpoint !== "undefined"){
      mobileBreakPoint = breakpoint;
  }
  if(typeof options['loadMobile'] !== "undefined"){
        loadMobile = options['loadMobile'];
  }
  const checkPrepForImage = function(obj, imageUrl){
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

  const attachImage = function(obj, src) {
    var thisImage = $("<img/>")
      .error(function() { return false; })
      .attr("src", src)
      .addClass(imgClasses);
    obj.prepend(thisImage);
    return true;
  }

  const initImages = function() {
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
        log("image loaded:"+imageUrl);
      }
      else{
        log("image failed to load:"+imageUrl);
      }
    }
  }

  initImages();
}
