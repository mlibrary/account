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
  /*
    Steps:
    - [x] Click event of button
    - [x] Get loan id for posting renewal
    - [ ] Visual processing
    - [ ] Receive data onload
    - [ ] Update success/error
      - [ ] On success: New due date
      - [ ] Error: Message on why it was not renewed
  */
  const renewItems = document.querySelectorAll('[data-js-renew]');
  renewItems.forEach((renewItem) => {
    renewItem.addEventListener('click', (event) => {
      const loanID = event.target.dataset.jsRenew;
      let test;
      fetch(`/renew-loan?loan_id=${loanID}`, {
        method: 'POST'
      }).then((response) => {
        return response.json();
      }).then((data) => {
        return data;
      }).catch((error) => {
        console.error('error', error);
      });
    });
    renewItem.removeAttribute('disabled');
  });
})();

(function () {
  const myForm = document.querySelectorAll('[data-js-renew]');
  myForm.forEach(function(el) {
    el.addEventListener('submit', function(event) {

      const request = new XMLHttpRequest();
      request.open('POST', event.target.action, true);
      request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
      request.send(`loan_id=${this[0].value}`);
      request.onload = function() {
        if(this.status === 200) {
          data = JSON.parse(this.response)
        } else {
          data = JSON.parse(this.response)
        }
      };
      // stop form submission
      event.preventDefault();
    })
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
