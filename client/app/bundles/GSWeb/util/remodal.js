import { contentManager } from './content';
// TODO: import jQuery

// What this does is catch a click to launch a remodal.  It is calling the contentManager with the object that
// was clicked.  Then it grabs the target and populates it with the content.

export function init() {
  $('body').on('click', '[data-remodal-target]',function(){
    var temp = $(this).data('remodal-target');
    var modal_to_get_content = $('[data-remodal-id='+temp+']');
    var content = '<button data-remodal-action="close" class="remodal-close"></button>';
    content += '<div class="remodal-content">'+ contentManager($(this))+'</div>';
    modal_to_get_content.html(content);
  });
}
