import modal from './modal';

/**
 * Get history preference
 */
let retainHistory;
const updateHistoryButton = document.getElementById('update-history');
const retainHistoryOptions = document.querySelectorAll('input[name="retain_history"]');
retainHistoryOptions.forEach((retainHistoryOption) => {
  retainHistoryOption.addEventListener('change', (event) => {
    updateHistoryButton.disabled = false;
    retainHistory = event.target.value === 'true';
    if (retainHistory) {
      updateHistoryButton.removeAttribute('data-js-modal');
    } else {
      updateHistoryButton.setAttribute('data-js-modal', 'delete-history');
    }
  });
});

/**
 * Set history preference
 */
updateHistoryButton.addEventListener('click', (event) => {
  if (!retainHistory) {
    event.preventDefault();
    modal(event.target.getAttribute('data-js-modal'));
  }
});

/**
 * Force keyboard focus in modal
 */
const getModal = document.getElementById(updateHistoryButton.getAttribute('data-js-modal'));
const closeButton = getModal.querySelector('.button--close');
const deleteHistoryButton = getModal.querySelector('[data-js-modal-button]');
let previousFocus = false;
document.addEventListener('keydown', (event) => {
  previousFocus = event.shiftKey && event.key === 'Tab';
});
document.addEventListener('focusin', (event) => {
  if (getModal.style.display !== 'none' && !getModal.querySelectorAll(':focus').length) {
    previousFocus ? deleteHistoryButton.focus() : closeButton.focus();
  }
});
