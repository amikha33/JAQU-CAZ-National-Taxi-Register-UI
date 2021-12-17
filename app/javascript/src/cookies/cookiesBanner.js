import {
  setDefaultConsentCookie,
  deleteUnconsentedCookies,
  cookie,
  approveAllCookiesTypes, setConsentCookie,
} from './functions';

/* eslint-disable no-shadow */
function isInCookiesPage() {
  return window.location.pathname === '/cookies';
}

function isInIframe() {
  return window.parent && window.location !== window.parent.location;
}

function showCookiesBanner() {
  const cookiesBanner = document.getElementById('cookies-banner');
  if (!isInCookiesPage() && !isInIframe()) {
    const shouldHaveCookieMessage = (cookiesBanner && cookie('global_bar_seen') !== 'true');

    if (shouldHaveCookieMessage) {
      cookiesBanner.style.display = 'block';

      // Set the default consent cookie if it isn't already present
      if (!cookie('cookies_policy')) {
        setDefaultConsentCookie();
      }

      deleteUnconsentedCookies();
    } else {
      cookiesBanner.style.display = 'none';
    }
  } else {
    cookiesBanner.style.display = 'none';
  }
}

function hideCookieMessage(message) {
  cookie('global_bar_seen', true, { days: 90 });

  const cookieBannerMainContent = document.getElementById('js-cookies-banner-wrapper');
  cookieBannerMainContent.hidden = true;

  const cookieBannerConfirmationMessage = document.getElementById('cookie-banner-message');
  cookieBannerConfirmationMessage.style.display = 'block';
  cookieBannerConfirmationMessage.hidden = false;

  const cookieBannerConfirmationMessageText = document.getElementById('confirmation-message-text');
  cookieBannerConfirmationMessageText.insertAdjacentHTML('afterbegin', message);

  const hideConfirmationMessageButton = document.getElementById('hide-confirmation-message');
  hideConfirmationMessageButton.addEventListener('click', (e) => {
    e.preventDefault();
    const cookiesBanner = document.getElementById('cookies-banner');
    cookiesBanner.style.display = 'none';
  });

  cookieBannerConfirmationMessage.focus();
}

function rejectCookies() {
  const rejectCookiesButton = document.getElementById('reject-cookies');
  rejectCookiesButton.addEventListener('click', (event) => {
    event.preventDefault();
    setConsentCookie({ usage: false });

    const message = 'You have rejected additional cookies. ';
    hideCookieMessage(message);
  });
}

function acceptCookies() {
  const acceptCookiesButton = document.getElementById('accept-cookies');
  acceptCookiesButton.addEventListener('click', (event) => {
    event.preventDefault();
    approveAllCookiesTypes();

    const message = 'You have accepted additional cookies. ';
    hideCookieMessage(message);
  });
}

function setupCookieBanner() {
  acceptCookies();
  rejectCookies();
}

export default function cookiesBanner() {
  showCookiesBanner();
  setupCookieBanner();
}
/* eslint-enable no-shadow */
