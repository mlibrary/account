/**
 * Close message callout
 */
(function () {
  const messageCallouts = document.querySelectorAll('.can-close');
  messageCallouts.forEach((messageCallout) => {
    const buttonsClose = messageCallout.querySelectorAll('.close-message');
    buttonsClose.forEach((buttonClose) => {
      buttonClose.removeAttribute('disabled');
      buttonClose.addEventListener('click', (event) => {
        messageCallout.style.display = 'none';
      });
    });
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
        event.target.addAttribute('disabled');
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
  const breakpoint = 1000;
  const dropdowns = document.querySelectorAll('[data-dropdown]');
  dropdowns.forEach((dropdown) => {
    const getID = dropdown.getAttribute('data-dropdown');
    const getDropdown = document.getElementById(getID);
    let getAriaExpanded = dropdown.getAttribute('aria-expanded');
    // Convert value to boolean
    getAriaExpanded = getAriaExpanded === true;
    dropdown.addEventListener('click', (event) => {
      // Toggle `aria-expanded` as true or false
      getAriaExpanded = !getAriaExpanded;
      event.target.setAttribute('aria-expanded', getAriaExpanded);
      // Toggle display for dropdown
      getDropdown.style.display = getAriaExpanded ? 'block' : 'none';
      // Toggle arrow up or down
      dropdown.children[2].setAttribute('name', getAriaExpanded ? 'keyboard-arrow-up' : 'keyboard-arrow-down');
    });
    // Close dropdown if `Escape` has been pressed or clicked outside of dropdown
    ['click', 'keyup'].forEach((listener) => {
      document.addEventListener(listener, (event) => {
        if (
          getAriaExpanded === true &&
          (
            (listener === 'click' && event.target !== dropdown) ||
            event.key === 'Escape'
          )
        ) {
          dropdown.click();
        }
      });
    });
    window.addEventListener('resize', (event) => {
      if (
        (window.innerWidth <= breakpoint && !getAriaExpanded) ||
        (window.innerWidth > breakpoint && getAriaExpanded)
      ) {
        dropdown.click();
      }
    });
    window.dispatchEvent(new Event('resize'));
  });
})();
