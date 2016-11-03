// this is to control modal ( so no modal when a tooltip is launched ) and to populate content in the tooltip.

$(function() {
  // $('.gs-tipso')
  // if(!('ontouchstart' in window)) {
  //   $('.gs-tipso').tipso({
  //     onBeforeShow: function (ele, tipso) {
  //       // disable modal
  //       var temp = ele.data('remodal-target');
  //       ele.attr('data-remodal-target-disabled', temp);
  //       ele.removeAttr('data-remodal-target');
  //
  //       // update content
  //       var content = GS.content.contentManager(ele);
  //       $('.gs-tipso').tipso('update', 'content', content);
  //     },
  //     onHide: function (ele, tipso) {
  //       // enable modal
  //       var temp = ele.data('remodal-target-disabled');
  //       ele.attr('data-remodal-target', temp);
  //       ele.removeAttr('data-remodal-target-disabled');
  //     }
  //   });
  // }

  function testPointerFunction(e){
    document.getElementById( "o" ).innerHTML = "that was a " +
        e.pointerType + " " + e.type + " on a "+ e.target.nodeName;
  }

  var classname = document.getElementsByClassName("gs-tipso");
  for (var i = 0; i < classname.length; i++) {
    classname[i].addEventListener('pointerenter', testPointerFunction, false);
  }
});


// document.getElementsByClassName( "gs-tipso" ).addEventListener( "pointerenter", function( e ) {
//   console.log("e.pointerType"+e.pointerType);
//   document.getElementById( "o" ).innerHTML = "that was a " +
//       e.pointerType + " " + e.type + " on a "+ e.target.nodeName;
// } );

// examples

    // tooltip with modal - target needs to match id for modal - doesn't need to be an a tag
      // <a data-remodal-target="modal_test" data-content-type="fancy"  class="tooltip">
      // place a spinny in for a placeholder - or you can populate with content    
      // <div class="remodal modal" data-remodal-id="modal_test">Add Spinny</div>

    // tooltip - tooltip content populated by GS.content using data elements as parameters
      // <a data-content-type="fancy"  class="tooltip">

    // modal - tooltip content populated by GS.content using data elements as parameters
      // <a data-remodal-target="modal_test" data-content-type="fancy">
      // <div class="remodal modal" data-remodal-id="modal_test">Add Spinny</div>