const modal = () => {
  const attribute = 'data-js-modal';
  const modalTriggers = document.querySelectorAll(`[${attribute}]`);
  modalTriggers.forEach((modalTrigger) => {
    const modal = document.getElementById(modalTrigger.getAttribute(attribute));
    if (modal) {
      modalTrigger.addEventListener('click', (event) => {
        modal.style.display = 'flex';
      });
    }
  });
};

export default modal;
