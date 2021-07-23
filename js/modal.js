const modal = (attributeValue) => {
  const modal = document.getElementById(attributeValue);
  modal.style.display = 'flex';
  const buttons = modal.querySelectorAll('button');
  buttons.forEach((button) => {
    button.disabled = false;
    if (button.classList.contains('button--close')) {
      button.focus();
    }
  });
};

export default modal;
