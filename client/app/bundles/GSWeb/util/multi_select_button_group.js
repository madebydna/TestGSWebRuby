export default {};

export function attachJQueryEventHandlers() {
  const $body = $('body');
  $body.off('click.multi-select-button-group-button').on('click.multi-select-button-group-button', '.multi-select-button-group button', e => {
    const $label = $(e.target);
    const $hiddenField = $label.closest('fieldset').find('input[type=hidden]');
    let values = $hiddenField.val().split(',');
    if ($hiddenField.val() === "") {
      values = [];
    }
    const value = $label.data('value').toString();
    const index = values.indexOf(value);
    if(index === -1) {
      values.push(value);
    } else {
      values.splice(index, 1);
    }
    $hiddenField.val(values.join(','));
    $label.toggleClass('active');
  });
}