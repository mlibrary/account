/**
 * Update SMS
 */
(function () {
  const updateSMS = document.querySelectorAll('[data-js-sms]');
  updateSMS.forEach((smsUpdate) => {
    smsUpdate.addEventListener('click', (event) => {
      const phoneNumber = document.getElementById('sms-number').value;
      if (/^[0-9]{3}-[0-9]{3}-[0-9]{4}/.test(phoneNumber)) {
        event.target.innerHTML = 'Processing...';
        fetch(`/sms?phone-number=${phoneNumber}`, {
          method: 'POST'
        }).then((response) => {
          if (response.status === 200) {
            return response.text();
          }
          event.target.innerHTML = 'Error!';
          throw new Error(`Could not update phone number: ${phoneNumber}.`);
        }).then((data) => {
          event.target.innerHTML = 'Updated!';
        }).catch((error) => {
          console.error(error);
        });
      } else {
        event.target.innerHTML = 'NOPE';
      }
    });
    smsUpdate.removeAttribute('disabled');
  });
})();
