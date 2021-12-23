import { getConsentCookie } from './functions';

/* eslint-disable */
function initTagManager() {
  if (!window.ga || !window.ga.loaded) {
    const acceptCookies = document.getElementById('accept-cookies')
    const GtmUrlOverrides = acceptCookies.getAttribute('data-gtm-url-overrides');
    const GtmId = acceptCookies.getAttribute('data-gtm-id');

    (function (w, d, s, l, i) {
      w[l] = w[l] || []; w[l].push({
        'gtm.start':
    new Date().getTime(),
        event: 'gtm.js',
      }); const f = d.getElementsByTagName(s)[0];
      const j = d.createElement(s);
      const dl = l != 'dataLayer' ? `&l=${l}` : '';
      j.async = true;
      j.src = `https://www.googletagmanager.com/gtm.js?id=${i}${dl}${GtmUrlOverrides}`;
      f.parentNode.insertBefore(j, f);
    }(window, document, 'script', 'dataLayer', GtmId));
  }
}

function initGoogleAnalytics() {
  if (!window.ga || !window.ga.loaded) {
    const googleAnalyticsId = document.getElementById('accept-cookies').getAttribute('data-google_analytics_id');

    dataLayer.push({ event: 'analytics_consent_given' });
    (function (i, s, o, g, r, a, m) {
      i.GoogleAnalyticsObject = r; i[r] = i[r] || function () {
        (i[r].q = i[r].q || []).push(arguments);
      }, i[r].l = 1 * new Date(); a = s.createElement(o),
      m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m);
    }(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga'));
    ga('create', googleAnalyticsId, 'auto');
    ga('set', 'anonymizeIp', true);
    ga('send', 'pageview');
  }
}
/* eslint-enable */

export function enableGoogleAnalytics() {
  const cookieConsent = getConsentCookie();
  if (cookieConsent && cookieConsent.usage) {
    initTagManager();
    initGoogleAnalytics();
  }
}

export function disableGoogleAnalytics() {
  const googleAnalyticsId = document.getElementById('accept-cookies').getAttribute('data-google_analytics_id');
  const disableStr = `ga-disable-${googleAnalyticsId}`;
  window[disableStr] = true;
}
