import './pages/admin_tools';

const toggleFreeFormInput = (value, selectorId) => {
  const container = document.getElementById(selectorId);
  const input = container.querySelector("input");

  if (value === "other") {
    input.disabled = false;
    input.classList.remove("dn");
    input.focus();
    input.select();
  } else {
    input.disabled = true;
    input.classList.add("dn");
  }
};

document.addEventListener("DOMContentLoaded", () => {
  const specialSelectSelectors = [
    "#organizations",
    "#roles",
    "#intended-use",
  ];

  const apiFormBody = document.querySelector(".new-api-account-form");

  specialSelectSelectors.forEach((selector) => {
    const element = document.querySelector(selector);

    element.querySelector("select").addEventListener("change", (e) => {
      const container = e.currentTarget.parentElement.parentElement;
      e.currentTarget.style.color = 'black';
      toggleFreeFormInput(e.target.value, container.id);
    });
  });

  apiFormBody.querySelectorAll('select').forEach(select => {
    select.addEventListener('change', (e) => e.currentTarget.style.color = 'black')
  });
});