var googleMapsScriptURL = '//maps.googleapis.com/maps/api/js?v=3.34&key=AIzaSyBjTd2dueHtfNdsOhXvo_3HQJfyYlkEv98&amp;sensor=false';

loadScript(googleMapsScriptURL, function(){
  //initialization code
});

function loadScript(url, callback){

  var script = document.createElement("script");
  script.type = "text/javascript";

  if (script.readyState){  //IE
    script.onreadystatechange = function(){
      if (script.readyState == "loaded" ||
          script.readyState == "complete"){
        script.onreadystatechange = null;
        callback();
      }
    };
  } else {  //Others
    script.onload = function(){
      callback();
    };
  }

  script.src = url;
  document.getElementsByTagName("head")[0].appendChild(script);
}

