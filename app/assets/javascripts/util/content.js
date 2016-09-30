// this is supposed to return the content to the modal and tooltip based data values.  

// I am thinking that content-type determines how it gets content.  gon, ajax, dom component

// other data values will then inform which chunk of content will fill a template

// big idea is to use a react component for templating. Then just pass in vars to set its state. :)  

GS.content = GS.content || {};
var counter = 0;
GS.content.contentManager = function(ele) {

  // return content based on element data values or gon or ajax

  var contentType = ele.data('content-type');
  counter += 1;
  if(counter % 2 == 0){
    return  '<div>I love you! '+ contentType +'</div>';
  }
  else{
    return  '<div>You love me! '+ contentType +'</div>';
  }

};