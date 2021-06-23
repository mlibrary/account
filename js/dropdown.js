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
