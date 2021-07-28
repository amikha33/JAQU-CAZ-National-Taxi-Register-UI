window.onload = function() {
  const cookieControlHidden = document.getElementsByClassName('cookie-control-hidden').length > 0;
  if (cookieControlHidden) {
    setTimeout(function() {
      CookieControl.hide();
    }, 10);
  }
}
