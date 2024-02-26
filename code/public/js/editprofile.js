const form = document.getElementById('profileForm')

if (form) {
    document.addEventListener('DOMContentLoaded', function(){
        const inputs = form.getElementsByTagName('input');
        const textarea = form.querySelector('textarea');
    
        for (var i = 0; i < inputs.length; i++) {
            inputs[i].disabled = true;
        }
    
        textarea.disabled = true;

        const fileInput = document.getElementById('profile-image-input');
        fileInput.value = '';
    })
}

function toggleEdit() {
    const form = document.getElementById('profileForm');
    const inputs = form.getElementsByTagName('input');
    const textarea = form.querySelector('textarea');

    for (var i = 0; i < inputs.length; i++) {
        inputs[i].disabled = !inputs[i].disabled;
    }

    textarea.disabled = !textarea.disabled;

    const profileButtons = document.querySelector('.edit-profile-buttons');
    const profileButton = document.querySelector('.edit-profile-button');
    
    const profileButtonsDisplay = window.getComputedStyle(profileButtons).getPropertyValue('display');
    const profileButtonDisplay = window.getComputedStyle(profileButton).getPropertyValue('display');
    
    profileButtons.style.display = profileButtonsDisplay === 'block' ? 'none' : 'block';
    profileButton.style.display = profileButtonDisplay === 'block' ? 'none' : 'block';

    const upload = document.querySelector('.profile-left form label');
    upload.style.display = profileButtonsDisplay === 'block' ? 'none' : 'block';

    const input = document.getElementById('profile-image-input');
    const preview = document.getElementById('profile-preview');

    input.addEventListener('change', function() {
        const file = this.files[0];

        if (file) {
            const allowedExtensions = ['png', 'jpeg', 'jpg'];
            const fileExtension = file.name.split('.').pop().toLowerCase();
    
            if (allowedExtensions.includes(fileExtension)) {
                const reader = new FileReader();
    
                reader.onload = function(event) {
                    preview.src = event.target.result;
                }
                reader.readAsDataURL(file);
            } else {
                console.log('Invalid file type! Please choose a PNG, JPEG, or JPG image.');
                this.value = ''; 
            }
        } else {
            preview.src = "{{ $user->getProfileImage() }}";
        }
    });
}

function saveChanges() {

    const form = document.getElementById('profileForm');
    const inputs = form.getElementsByTagName('input');
    const textarea = form.querySelector('textarea');

    const name = document.getElementById('profile-name').value;
    const username = document.getElementById('profile-username').value;
    const email = document.getElementById('profile-email').value;
    const description = document.getElementById('profile-description').value;
    const id = form.getAttribute('data-id');

    for (var i = 0; i < inputs.length; i++) {
        inputs[i].removeAttribute('disabled');
    }

    textarea.removeAttribute('disabled');
    sendAjaxRequest('post', '/api/users/' + id + '/edit', { name: name, username: username, email: email, description: description }, profileEditdHandler);

    const fileInput = document.getElementById('profile-image-input');
   
    if (fileInput.files.length > 0) {
        const formData = new FormData();
        formData.append('file', fileInput.files[0]); 
        formData.append('id', id);
        formData.append('type', 'profile');    
        console.log(formData);

        let request = new XMLHttpRequest();
        request.open('post', '/api/file/upload', true);
        request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
        request.addEventListener('load', imageHandler);
        request.send(formData);
    }

    console.log('Changes saved');

    toggleEdit();
}

function cancelChanges() {
    const form = document.getElementById('profileForm');
    const inputs = form.getElementsByTagName('input');
    const textarea = form.querySelector('textarea');

    for (let i = 0; i < inputs.length; i++) {
        inputs[i].value = inputs[i].defaultValue;
    }

    textarea.value = textarea.defaultValue;

    console.log('Changes canceled');

    toggleEdit();
}


function profileEditdHandler(){
    if (this.status === 200) {
        let item = JSON.parse(this.responseText);
        console.log('Profile updated:', item);
        createNotificationBox('Successfully saved!', 'User profile successfully updated!')
    } else {
        console.error('Profile update failed:', this.statusText);
    }
}

function imageHandler(){
    if (this.status === 200) {
        let item = JSON.parse(this.responseText);
        const img = document.querySelector('.profile-left img');
        const profile = document.querySelector('.dropdown img');
        profile.src = img.src;
    } else {
        console.error('Profile update failed:', this.statusText);
    }
}

const viewedNotification = document.querySelectorAll('.notification');

if (viewedNotification) {
    for (const notification of viewedNotification) {
        notification.addEventListener('click', function() {
            const id = notification.getAttribute('data-id');
            sendAjaxRequest('post', '/api/users/notifications/' + id + "/viewed", {}, ViwedHandler);
        });
    }
}

function ViwedHandler(){
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        
        const viewedNotification = document.querySelector(`#notification${id}`);
        viewedNotification.classList.add('true');
        viewedNotification.classList.remove('false');

        const notificationCount = document.querySelector('.notification-count');
        const currentCount = parseInt(notificationCount.textContent, 10);
        if (!isNaN(currentCount) && currentCount > 0) {
            notificationCount.textContent = currentCount - 1;
        }
    }
}