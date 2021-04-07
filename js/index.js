/**
 * Renew All progress data stream
 * 
 * 
 */
(function () {
  const es = new EventSource('/stream');

  es.onmessage = function(e) { 
    const el = document.getElementById('renew-all-progress')

    console.log('e.data', e.data)
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
        if(response.status === 200) {
          return response.json();
        }
        event.target.innerHTML = 'Error!';
        throw new Error(`Could not renew loan id ${loanID}.`);
      }).then((data) => {
        if(data.due_date) {
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
  const my_form = document.querySelectorAll("[data-js-renew-all]")
  my_form.forEach(function(el){
    el.addEventListener('submit', function(event){
      var request = new XMLHttpRequest();
      request.open('POST', event.srcElement.action, true);
      request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
      request.send();
      request.onload = function(){
        location.reload();
      };
    // ...
    // stop form submission
      event.preventDefault();
    })
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
  const controls = document.querySelectorAll("[data-js-submit]");

  controls.forEach(function (el) {
    el.addEventListener("change", function () {
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
  const controls = document.querySelectorAll("[data-js-loading]");

  controls.forEach(function (el) {
    el.addEventListener("click", function () {
      el.classList.add("loading");
    });
  });
})();
