/* eslint-disable no-undef */
window.onload = () => {
  const cookieControlHidden = document.getElementsByClassName('cookie-control-hidden').length > 0;
  if (typeof CookieControl !== 'undefined' && cookieControlHidden) {
    setTimeout(() => {
      CookieControl.hide();
    }, 10);
  }
};
