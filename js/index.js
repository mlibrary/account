var es = new EventSource('/stream');
es.onmessage = function(e) { 
  document.getElementById('progress').innerHTML = e.data; 
};

(function () {
  const my_form = document.querySelectorAll("[data-js-renew]")
  my_form.forEach(function(el){
    el.addEventListener('submit', function(event){
      var request = new XMLHttpRequest();
      request.open('POST', event.srcElement.action, true);
      request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
      request.send("loan_id="+ this[0].value);
      request.onload = function(){
        if(this.status == 200){
          data = JSON.parse(this.response)
        }else{
          data = JSON.parse(this.response)
        }
      };
    // ...
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
