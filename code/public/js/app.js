function createNotificationBox(title, content, type='success') {
    const notificationBox = document.querySelector('.notification-box');
    notificationBox.style.display = 'flex';

    if (type == 'error') {
        document.querySelector('#noti-icon').outerHTML = '<ion-icon name="close-circle" id="noti-icon" class="red"></ion-icon>';
    } else if (type == 'warning') {
      document.querySelector('#noti-icon').outerHTML = '<ion-icon name="alert-circle" id="noti-icon" class="yellow"></ion-icon>';
    } 
    else {
        document.querySelector('#noti-icon').outerHTML = '<ion-icon name="checkmark-circle" id="noti-icon" ></ion-icon>';
    }

    const span1 = document.querySelector('.notification-box span:first-child');
    span1.textContent = title;

    const span2 = document.querySelector('.notification-box span:last-child');
    span2.textContent = content;

    const close = document.querySelector('#close-notification');
    close.addEventListener('click', function(){
        notificationBox.style.display = 'none';
    });
}

function encodeForAjax(data) {
    if (data == null) return null;
    return Object.keys(data).map(function(k){
      return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
    }).join('&');
  }
  
function sendAjaxRequest(method, url, data, handler) {
    let request = new XMLHttpRequest();
    request.open(method, url, true);
    request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.addEventListener('load', handler);
    request.send(encodeForAjax(data));
}

function closeNotification() {
    event.target.closest('.notification-box').style.display = 'none';
}

