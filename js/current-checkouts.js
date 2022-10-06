/**
 * Renew individual items
 */

const errorMessage = (loanID) => {
  let message = 'Could not retrieve loans.';
  if (loanID) {
    message = `Could not renew loan id ${loanID}.`;
  }
  throw new Error(message);
};

const renewingLoan = async (loanID) => {
  try {
    const response = await fetch(`/renew-loan?loan_id=${loanID}`, {
      method: 'POST'
    });
    if (await response.status !== 200) {
      errorMessage(loanID);
    }
    return await response.json();
  } catch (error) {}
};

const renewingItem = async (loanID) => {
  try {
    const renewLoan = await renewingLoan(loanID);
    if (!renewLoan) {
      errorMessage(loanID);
    }
    // Update due date of loans if on current page
    const loanDueDate = document.querySelector(`[data-loan-due-date="${loanID}"]`);
    if (renewLoan.due_date && loanDueDate) {
      loanDueDate.innerHTML = renewLoan.due_date;
    }
    return renewLoan;
  } catch (error) {}
};

const renewItemButtons = document.querySelectorAll('[data-js-renew]');

renewItemButtons.forEach((renewItemButton) => {
  renewItemButton.addEventListener('click', async (event) => {
    event.target.innerHTML = 'Processing...';
    const loanID = event.target.dataset.jsRenew;
    try {
      const renewItem = await renewingItem(loanID);
      if (!renewItem) {
        errorMessage(loanID);
      }
      event.target.innerHTML = 'Renewed!';
      event.target.disabled = true;
      return renewItem;
    } catch (error) {
      event.target.innerHTML = 'Error!';
      console.error(error);
    }
  });
  renewItemButton.disabled = false;
});

/**
 * Renew eligible items
 */

const getAllItems = async () => {
  try {
    const response = await fetch('/current-checkouts/u-m-library/all');
    if (await response.status !== 200) {
      errorMessage();
    }
    return await response.json();
  } catch (error) {}
};

const renewAllEligibleButton = document.querySelector('[data-js-renew-all]');
// Progress bar elements
const progressBar = document.querySelector('.progress-bar');
const progress = progressBar.querySelector('progress');
const progressDescription = progressBar.querySelector('#progress-description');
const progressDescriptionRenewed = progressDescription.querySelector('.renewed-loans');
const progressDescriptionTotal = progressDescription.querySelector('.total-loans');

const getEligibleItems = async () => {
  try {
    const allItems = await getAllItems();
    if (!allItems) {
      errorMessage();
    }
    // Filter items by those that are eligible for renewal, and grab the loan ID
    const filteredEligibleItems = allItems
      .filter((item) => {
        return item.renewable;
      }).map((item) => {
        return item.loan_id;
      });
    const totalEligibleItems = filteredEligibleItems.length;
    // Update loan count on button and progress details
    renewAllEligibleButton.dataset.jsRenewAll = progressDescriptionTotal.innerText = totalEligibleItems;
    progress.setAttribute('max', totalEligibleItems);
    // Undisable button if there are loans that can be renewed
    renewAllEligibleButton.disabled = totalEligibleItems === 0;
    // Reset progress
    progress.setAttribute('value', 0);
    progressDescriptionRenewed.innerText = 0;
    return filteredEligibleItems;
  } catch (error) {}
};

(async function () {
  await getEligibleItems();
}());

renewAllEligibleButton.addEventListener('click', async function (event) {
  // Start loading animation
  event.target.classList.add('loading');
  // Show progress bar
  progressBar.style.display = 'block';
  progress.setAttribute('aria-busy', true);
  try {
    const eligibleItems = await getEligibleItems();
    if (!eligibleItems) {
      errorMessage();
    }
    return await Promise.allSettled(eligibleItems.map((eligibleItem, index) => {
      // Update renewal progress
      const currentCount = index + 1;
      progressDescriptionRenewed.innerText = progress.value = currentCount;
      return renewingItem(eligibleItem);
    }));
    // Assign message
  } catch (error) {
    // Assign message
  } finally {
    // Stop loading animation
    event.target.classList.remove('loading');
    // Hide progress bar
    progressBar.style.display = 'none';
    progress.setAttribute('aria-busy', false);
    // Show message
    // Fetch items again
    await getEligibleItems();
  }
});
