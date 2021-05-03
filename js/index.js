/**
 * Renew All progress data stream
 */
if (window.location.pathname === '/current-checkouts/checkouts') {
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
}

/**
 * Close message callout
 */
(function () {
  const messageCallouts = document.querySelectorAll('.message-callout');
  messageCallouts.forEach((messageCallout) => {
    const buttonClose = messageCallout.querySelector('.button--close');
    buttonClose.removeAttribute('disabled');
    buttonClose.addEventListener('click', (event) => {
      messageCallout.style.display = 'none';
    });
  });
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
        }
        return data;
      }).catch((error) => {
        console.error(error);
      });
    });
    renewItem.removeAttribute('disabled');
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
      fetch('/current-checkouts/checkouts', {
        method: 'POST'
      }).then((response) => {
        if (response.status === 200) {
          return response.json();
        }
      }).then((data) => {
        location.reload();
      });
    });
    renewItem.removeAttribute('disabled');
  });
})();

/**
 * Cancel single item
 */
(function () {
  const cancelItems = document.querySelectorAll('[data-js-cancel]');
  cancelItems.forEach((cancelItem) => {
    cancelItem.addEventListener('click', (event) => {
      event.target.innerHTML = 'Processing...';
      const requestID = event.target.dataset.jsCancel;
      fetch(`/pending-requests/u-m-library/cancel-request?request_id=${requestID}`, {
        method: 'POST'
      }).then((response) => {
        if (response.status === 200) {
          return response.json();
        }
        event.target.innerHTML = 'Error!';
        throw new Error(`Could not cancel request id ${requestID}.`);
      }).then((data) => {
        event.target.innerHTML = 'Canceled!';
        return data;
      }).catch((error) => {
        console.error(error);
      });
    });
    cancelItem.removeAttribute('disabled');
  });
})();

/**
 * Handle self-submitting input controls.
 *
 * <form>
 *   <select data-js-submit>...</select>
 * </form>
 */
(function () {
  const controls = document.querySelectorAll('[data-js-submit]');

  controls.forEach(function (el) {
    el.addEventListener('change', function () {
      this.form.submit();
    });
  });
})();

/**
 * Handle loading indicators
 *
 * <button data-js-loading>
 */
(function () {
  const controls = document.querySelectorAll('[data-js-loading]');

  controls.forEach(function (el) {
    el.addEventListener('click', function () {
      el.classList.add('loading');
    });
  });
})();

/*
 * Dropdown Menu
 */
(function () {
  const dropdowns = document.querySelectorAll('[data-dropdown]');
  dropdowns.forEach((dropdown) => {
    const getID = dropdown.getAttribute('data-dropdown');
    const getDropdown = document.getElementById(getID);
    let getAriaExpanded = dropdown.getAttribute('aria-expanded');
    dropdown.addEventListener('click', (event) => {
      // Toggle `aria-expanded` as true or false
      getAriaExpanded = getAriaExpanded !== true;
      event.target.setAttribute('aria-expanded', getAriaExpanded);
      // Toggle display for dropdown
      getDropdown.style.display = getAriaExpanded ? 'block' : 'none';
      // Toggle arrow up or down
      dropdown.children[2].setAttribute('name', getAriaExpanded ? 'keyboard-arrow-up' : 'keyboard-arrow-down');
    });
    [dropdown, getDropdown].forEach((element) => {
      element.addEventListener('keyup', (event) => {
        if (event.key === 'Escape') {
          dropdown.click();
        }
      });
    });
  });
})();
