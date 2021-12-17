import { getConsentCookie } from './functions';

/* eslint-disable */
function initTagManager() {
  if (!window.ga || !window.ga.loaded) {
    (function (w, d, s, l, i) {
      w[l] = w[l] || []; w[l].push({
        'gtm.start':
    new Date().getTime(),
        event: 'gtm.js',
      }); const f = d.getElementsByTagName(s)[0];
      const j = d.createElement(s);
      const dl = l != 'dataLayer' ? `&l=${l}` : '';
      j.async = true;
      j.src = `https://www.googletagmanager.com/gtm.js?id=${i}${dl}${process.env.GTM_URL_OVERRIDES}`;
      f.parentNode.insertBefore(j, f);
    }(window, document, 'script', 'dataLayer', process.env.GTM_ID));
  }
}

function initGoogleAnalytics() {
  if (!window.ga || !window.ga.loaded) {
    dataLayer.push({ event: 'analytics_consent_given' });
    (function (i, s, o, g, r, a, m) {
      i.GoogleAnalyticsObject = r; i[r] = i[r] || function () {
        (i[r].q = i[r].q || []).push(arguments);
      }, i[r].l = 1 * new Date(); a = s.createElement(o),
      m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m);
    }(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga'));
    ga('create', process.env.GOOGLE_ANALYTICS_ID, 'auto');
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
  const disableStr = `ga-disable-${process.env.GOOGLE_ANALYTICS_ID}`;
  window[disableStr] = true;
}
