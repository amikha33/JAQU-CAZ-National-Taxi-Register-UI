import '../styles/application.scss';
import '../src/GovUKAssets';
import { initAll } from 'govuk-frontend/govuk/all.js';
import { enableGoogleAnalytics } from '../src/cookies/googleAnalytics';
import cookiesBanner from '../src/cookies/cookiesBanner';

require("@rails/ujs").start();

document.body.classList.add('js-enabled');
initAll();

enableGoogleAnalytics();
cookiesBanner();
