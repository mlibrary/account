/**
 * Renew All progress data stream
 *
 *
 */
(function () {
  const es = new EventSource('/stream');

  es.onmessage = function (e) {
    // const el = document.getElementById('renew-all-progress');
    console.log('e.data', JSON.parse(e.data));
  };
})();

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

(function () {
  const renewAll = document.querySelectorAll('[data-js-renew-all]');
  renewAll.forEach((renewItem) => {
    renewItem.addEventListener('click', (event) => {
      event.target.classList.add('loading');
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
