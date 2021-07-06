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
