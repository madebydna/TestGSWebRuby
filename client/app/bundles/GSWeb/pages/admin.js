export const showInputBox = (value, selectorId) => {
  const container = document.getElementById(selectorId);
  const input = container.querySelector('input');

  if (value === 'other') {
    input.disabled = false;
    input.classList.remove('dn')
    input.focus();
    input.select();

  } else {
    input.disabled = true;
    input.classList.add('dn')
  }
}