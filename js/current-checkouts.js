/**
 * Renew All progress data stream
 */
(function () {
  const eventSource = new EventSource('/stream');
  const progressContainer = document.querySelector('.progress-container');
  const progressHeading = progressContainer.querySelector('.progress-heading');
  const progressStepsText = progressContainer.querySelector('.progress-label-text');
  const progressSteps = ['Fetching loans...', 'Renewing loans...', 'Wrapping up...'];
  const progressLoanCount = document.querySelector('[data-js-renew-all]').getAttribute('data-js-renew-all');
  const progressBar = progressContainer.querySelector('progress');
  const progressPercent = progressContainer.querySelector('.progress-percent');

  eventSource.onmessage = (event) => {
    const eventData = JSON.parse(event.data);
    progressHeading.textContent = `Step ${eventData.step} of 3`;
    progressStepsText.textContent = progressSteps[eventData.step - 1];
    const progressCount = Math.ceil((100 / progressLoanCount) * eventData.count);
    progressBar.value = progressCount;
    progressBar.setAttribute('aria-valuenow', progressCount);
    progressBar.textContent = `${progressCount}% complete`;
    progressPercent.textContent = `${eventData.renewed} of ${progressLoanCount} renewed`;
  };
})();

/**
 * Renew single item
 */
(function () {
  const renewItems = document.querySelectorAll('[data-js-renew]');
  renewItems.forEach((renewItem) => {
    renewItem.addEventListener('click', (event) => {
      event.target.innerHTML = 'Processing...';
      const loanID = event.target.dataset.jsRenew;
      fetch(`/renew-loan?loan_id=${loanID}`, {
        method: 'POST'
      }).then((response) => {
        if (response.status === 200) {
          return response.json();
        }
        event.target.innerHTML = 'Error!';
        throw new Error(`Could not renew loan id ${loanID}.`);
      }).then((data) => {
        if (data.due_date) {
          document.querySelector(`[data-loan-due-date="${loanID}"]`).innerHTML = data.due_date;
          event.target.innerHTML = 'Renewed!';
          event.target.disabled = true;
        }
        return data;
      }).catch((error) => {
        console.error(error);
      });
    });
    renewItem.disabled = false;
  });
})();

/**
 * Renew all items
 */
(function () {
  const renewAll = document.querySelectorAll('[data-js-renew-all]');
  renewAll.forEach((renewItem) => {
    renewItem.addEventListener('click', (event) => {
      event.target.classList.add('loading');
      document.querySelector('.progress-container').style.display = 'block';
      fetch('/current-checkouts/u-m-library', {
        method: 'POST'
      }).then((response) => {
        if (response.status === 200) {
          return response.json();
        }
      }).then((data) => {
        location.reload();
      });
    });
    renewItem.disabled = false;
  });
})();
