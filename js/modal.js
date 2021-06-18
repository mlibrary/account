const modal = () => {
  const attribute = 'data-js-modal';
  const modalTriggers = document.querySelectorAll(`[${attribute}]`);
  modalTriggers.forEach((modalTrigger) => {
    modalTrigger.addEventListener('click', (event) => {
      const modal = document.getElementById(event.target.getAttribute(attribute));
      modal.style.display = 'flex';
      const buttons = modal.querySelectorAll('button');
      buttons.forEach((button) => {
        button.removeAttribute('disabled');
      });
    });
  });
};

export default modal;
