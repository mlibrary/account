import modal from './modal';

/**
 * Fetch History
 */
const fetchHistory = (attribute) => {
  const button = document.querySelector(attribute);
  button.addEventListener('click', (event) => {
    fetch('/settings/history', {
      method: 'POST'
    }).then((response) => {
      if (response.status === 200) {
        return response.json();
      }
    }).then((data) => {
      location.reload();
    });
  });
  button.removeAttribute('disabled');
};

/**
 * Delete history
 */
(function () {
  const retainHistoryOptions = document.querySelectorAll('input[name="retain_history"]');
  retainHistoryOptions.forEach((retainHistoryOption) => {
    retainHistoryOption.addEventListener('change', (event) => {
      if (event.target.value === 'false') {
        modal();
        fetchHistory('[data-js-modal-button="delete-history"]');
      } else {
        fetchHistory('[data-js-modal="delete-history"]');
      }
    });
  });
})();
