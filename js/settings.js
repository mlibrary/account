import modal from './modal';

/**
 * Update history
 */
const updateHistory = () => {
  fetch('/settings/history', {
    method: 'POST'
  }).then((response) => {
    if (response.status === 200) {
      return response.text();
    }
  }).then((data) => {
    location.reload();
  });
};

/**
 * Get history preference
 */
let retainHistory;
const updateHistoryButton = document.getElementById('update-history');
const retainHistoryOptions = document.querySelectorAll('input[name="retain_history"]');
retainHistoryOptions.forEach((retainHistoryOption) => {
  retainHistoryOption.addEventListener('change', (event) => {
    updateHistoryButton.removeAttribute('disabled');
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
  event.target.innerHTML = 'Processing...';
  if (retainHistory) {
    updateHistory();
  } else {
    modal(event.target.getAttribute('data-js-modal'));
  }
});

/**
 * Modal button
 */
const modalButton = document.querySelector('[data-js-modal-button]');
modalButton.addEventListener('click', (event) => {
  event.target.innerHTML = 'Processing...';
  updateHistory();
});
