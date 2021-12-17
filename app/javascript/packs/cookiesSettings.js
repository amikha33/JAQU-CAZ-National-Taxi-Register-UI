import {
  approveAllCookiesTypes, cookie, setConsentCookie, getConsentCookie,
} from '../src/cookies/functions';
import { disableGoogleAnalytics } from '../src/cookies/googleAnalytics';

function setupRadioButtonOn() {
  const cookieConsent = getConsentCookie();
  if (cookieConsent && cookieConsent.usage) {
    const cookiesSettingsOn = document.getElementById('cookies-settings-on');
    cookiesSettingsOn.checked = true;
  }
}

function showCookiesSettingsNotification() {
  const cookiesSettingsNotification = document.getElementById('cookies-settings-notification');
  cookiesSettingsNotification.hidden = false;
  cookiesSettingsNotification.focus();
}

function setupRadioButtons() {
  const saveCookiesButton = document.getElementById('save-cookies-settings');
  saveCookiesButton.addEventListener('click', (event) => {
    event.preventDefault();
    const form = document.getElementById('cookies-settings-form');
    const cookiesSettingsValue = form.querySelector('input[name="cookies-settings"]:checked').value;

    if (cookiesSettingsValue === 'on') {
      approveAllCookiesTypes();
    } else {
      setConsentCookie({ usage: false });
      disableGoogleAnalytics();
    }

    cookie('global_bar_seen', true, { days: 90 });
    showCookiesSettingsNotification();
  });
}

setupRadioButtonOn();
setupRadioButtons();
