/**
 * Close message callout
 */
(function () {
  const messageCallouts = document.querySelectorAll('.message-callout');
  messageCallouts.forEach((messageCallout) => {
    const buttonClose = messageCallout.querySelector('.button--close');
    if (buttonClose) {
      buttonClose.removeAttribute('disabled');
      buttonClose.addEventListener('click', (event) => {
        messageCallout.style.display = 'none';
      });
    }
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
