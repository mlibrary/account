/**
 * Renew all eligible items
 */

// Progress bar elements
const progressBar = document.querySelector('.progress-bar');
const progress = progressBar.querySelector('progress');
const progressValue = progress.getAttribute('value');
const progressMax = progress.getAttribute('max');
const progressDescription = progressBar.querySelector('#progress-description');
const progressDescriptionRenewed = progressDescription.querySelector('.renewed-loans');
const progressDescriptionTotal = progressDescription.querySelector('.total-loans');

// Fetch all current items
async function getAllItems () {
  try {
    const response = await fetch('/current-checkouts/u-m-library/all');
    return response.json();
  } catch (error) {
    console.error(error);
  }
}

// Filter items by those that are eligible for renewal
async function getEligibleItems () {
  const allItems = await getAllItems();
  const filteredRenewableItems = allItems.filter((item) => {
    return item.renewable;
  }).map((item) => {
    return item.loan_id;
  });
  return filteredRenewableItems;
}

// Renew eligible item
function renewEligibleItem (loanID, step, lastItem) {
  fetch(`/renew-loan?loan_id=${loanID}`, {
    method: 'POST'
  }).then((response) => {
    return response.json();
  }).then((data) => {
    // Convert current progress value to an integer, and add the step
    const newValue = parseInt(progress.getAttribute('value')) + step;
    // Set new value to maximum amount if ends up being larger
    progress.setAttribute('value', newValue > progressMax ? progressMax : newValue);
    // Update renewed count
    progressDescriptionRenewed.innerText++;
    // Update due date of loans if on current page
    if (data.due_date) {
      document.querySelector(`[data-loan-due-date="${loanID}"]`).innerHTML = data.due_date;
    }
    return lastItem;
  }).then((lastItem) => {
    if (lastItem) {
      // Hide the progress bar
      progressBar.style.display = 'none';
      // Show message
    }
  }).catch((error) => {
    console.error(error);
  });
}

// Get the `Renew all eligible` button
const renewAllEligibleButton = document.querySelector('[data-js-renew-all]');
// Wait until eligible items have been retrieved
getEligibleItems().then((items) => {
  // Update loan count on button and progress details
  renewAllEligibleButton.dataset.jsRenewAll = progressDescriptionTotal.innerText = items.length;
  // Undisable button if there are loans that can be renewed
  renewAllEligibleButton.disabled = items.length === 0;
  return items;
}).then((items) => {
  renewAllEligibleButton.addEventListener('click', async function (event) {
    progress.setAttribute('value', progressValue);
    const progressStep = Math.ceil(progressMax / items.length);
    progressDescriptionRenewed.innerText = 0;
    progressBar.style.display = 'block';
    Promise.allSettled(items.map((loanID, index) => {
      return renewEligibleItem(loanID, progressStep, items.length === index + 1);
    }));
  });
});

/**
 * Renew single item
 */
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
