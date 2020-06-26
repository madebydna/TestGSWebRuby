const showInputBox = (value, selectorId) => {
  const container = document.getElementById(selectorId);
  const input = container.querySelector('input');

  if (value === 'other') {
    input.disabled = false;
    input.classList.remove('dn')
    input.focus();
    input.select();

  } else {
    input.disabled = true;
    input.classList.add('dn');
  }
}

$(function(){
  document.addEventListener('DOMContentLoaded', ()=> {

    const specialSelectSelectors = ['#organizations', '#roles', '#intended-use']

    specialSelectSelectors.forEach(selector => {
      const element = document.querySelector(selector);

      element.querySelector('select').addEventListener('change', (e) => {
        const container = e.currentTarget.parentElement.parentElement;
        showInputBox(e.target.value, container.id);
      })
    })
  })
})
