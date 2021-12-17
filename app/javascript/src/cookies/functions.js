/* eslint-disable no-restricted-syntax, guard-for-in */

const DEFAULT_COOKIE_CONSENT = {
  usage: false,
};

const COOKIE_CATEGORIES = {
  cookies_policy: 'usage',
  global_bar_seen: 'settings',
  _ga: 'usage',
  _gid: 'usage',
  _gat: 'usage',
};

export function setCookie(name, value, options) {
  let cookieString = `${name}=${value}; path=/`;
  if (options.days) {
    const date = new Date();
    date.setTime(date.getTime() + (options.days * 24 * 60 * 60 * 1000));
    cookieString = `${cookieString}; expires=${date.toGMTString()}`;
  }
  if (document.location.protocol === 'https:') {
    cookieString += '; Secure';
  }
  document.cookie = cookieString;
}

export function getCookie(name) {
  const nameEQ = `${name}=`;
  const cookies = document.cookie.split(';');
  for (let i = 0, len = cookies.length; i < len; i += 1) {
    let cookieName = cookies[i];
    while (cookieName.charAt(0) === ' ') {
      cookieName = cookieName.substring(1, cookieName.length);
    }
    if (cookieName.indexOf(nameEQ) === 0) {
      return decodeURIComponent(cookieName.substring(nameEQ.length));
    }
  }
  return null;
}

/*
  Cookie methods
  ==============
  Usage:
    Setting a cookie: cookie('global_bar_seen', 'tasty', { days: 90 });
    Reading a cookie: cookie('global_bar_seen');
    Deleting a cookie: cookie('global_bar_seen', null);
*/
export function cookie(name, value, options) {
  let optionsDays = options;
  if (typeof value !== 'undefined') {
    if (value === false || value === null) {
      return setCookie(name, '', { days: -1 });
    }
    // Default expiry date of 90 days
    if (typeof optionsDays === 'undefined') {
      optionsDays = { days: 90 };
    }
    return setCookie(name, value, optionsDays);
  }
  return getCookie(name);
}

function deleteCookie(cookieName) {
  cookie(cookieName, null);

  if (cookie(cookieName)) {
    // We need to handle deleting cookies on the domain and the .domain
    document.cookie = `${cookieName}=;expires=${new Date()};`;
    document.cookie = `${cookieName}=;expires=${new Date()};domain=${window.location.hostname};path=/`;
  }
}

export function getConsentCookie() {
  const consentCookie = cookie('cookies_policy');
  let consentCookieObj;

  if (consentCookie) {
    try {
      consentCookieObj = JSON.parse(consentCookie);
    } catch (err) {
      return null;
    }

    if (typeof consentCookieObj !== 'object' && consentCookieObj !== null) {
      consentCookieObj = JSON.parse(consentCookieObj);
    }
  } else {
    return null;
  }

  return consentCookieObj;
}

export function setConsentCookie(options) {
  let cookieConsent = getConsentCookie();

  if (!cookieConsent) {
    cookieConsent = JSON.parse(JSON.stringify(DEFAULT_COOKIE_CONSENT));
  }

  for (const cookieType in options) {
    cookieConsent[cookieType] = options[cookieType];

    // Delete cookies of that type if consent being set to false
    if (!options[cookieType]) {
      for (const cookieName in COOKIE_CATEGORIES) {
        if (COOKIE_CATEGORIES[cookieName] === cookieType) {
          deleteCookie(cookieName);
        }
      }
    }
  }

  setCookie('cookies_policy', JSON.stringify(cookieConsent), { days: 90 });
}

export function setDefaultConsentCookie() {
  setConsentCookie(DEFAULT_COOKIE_CONSENT);
}

export function approveAllCookiesTypes() {
  const approvedConsent = {
    usage: true,
  };

  setCookie('cookies_policy', JSON.stringify(approvedConsent), { days: 90 });
}

export function deleteUnconsentedCookies() {
  const currentConsent = getConsentCookie();

  for (const cookieType in currentConsent) {
    // Delete cookies of that type if consent being set to false
    if (!currentConsent[cookieType]) {
      for (const cookieName in COOKIE_CATEGORIES) {
        if (COOKIE_CATEGORIES[cookieName] === cookieType) {
          deleteCookie(cookieName);
        }
      }
    }
  }
}
/* eslint-enable no-restricted-syntax, guard-for-in */
