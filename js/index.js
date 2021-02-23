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
