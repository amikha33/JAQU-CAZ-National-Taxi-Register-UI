import './styles.scss'

const cookieKey = 'seen_cookie_message';
const monthInMS = 2629746000;

function init() {
    if(!hasSeenMessage()){
        var banner = document.getElementById('global-cookie-message');
        banner.style.display = 'block';
        const closeLink = banner.querySelector('#close-banner');
        closeLink.addEventListener('click', () => {
            banner.style.display = 'none';
            setCookie()
        })
    }
}

function hasSeenMessage(){
    return document.cookie.indexOf(cookieKey + '=true') > -1
}

function setCookie(){
    const date = new Date();
    date.setTime(date.getTime() + monthInMS);
    document.cookie = cookieKey + '=true; expires=' + date.toGMTString();
}

export default init;
