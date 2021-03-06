// this is supposed to return the content to the modal and tooltip based data values.  
// I am thinking that content-type determines how it gets content.  gon, ajax, dom component
// other data values will then inform which chunk of content will fill a template
// big idea is to use a react component for templating. Then just pass in vars to set its state. :)  

export function contentManager(ele) {

  // return content based on element data values or gon or ajax
  var content = '';
  var contentType = ele.data('content-type');
  if(contentType == 'info_box'){
    content = ele.data('content-html');
  } else if (contentType == 'react') {
    var componentName = ele.data('component-name');
    var containerId = ele.data('dom-id');
    var props = ele.data('props');

    if (window.ReactOnRails && ReactOnRails.getComponent(componentName)) {
      ReactOnRails.render(componentName, props, containerId);
      content = document.getElementById(containerId).innerHTML;
    }
  }

  // this is just an example of returned content
  return content;
};
