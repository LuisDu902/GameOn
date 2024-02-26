const answerVote = document.querySelectorAll('.answer-btns');

if (answerVote) {
    for (const answer of answerVote) {
        answer.addEventListener('click', function() {
            const id = answer.getAttribute('data-id');
            
            if (event.target.tagName === 'ION-ICON'){
                const upVote = answer.querySelector('.up-vote ion-icon');
                const downVote = answer.querySelector('.down-vote ion-icon');

                if (event.target.closest('.up-vote')) {
                    if(upVote.classList.contains('hasvoted')){
                        sendAjaxRequest('post', '/api/answers/' + id + "/unvote", {}, uVoteHandler);
                    } else {
                        if (downVote.classList.contains('hasvoted')) {
                            sendAjaxRequest('post', '/api/answers/' + id + "/unvote", {}, dVoteHandler);
                        }
                        sendAjaxRequest('post', '/api/answers/' + id + "/vote", {reaction: true}, uVoteHandler);
                    }
                } else if (event.target.closest('.down-vote')) {
                    if(downVote.classList.contains('hasvoted')){
                        sendAjaxRequest('post', '/api/answers/' + id + "/unvote", {}, dVoteHandler);
                    } else {
                        if (upVote.classList.contains('hasvoted')) {
                            sendAjaxRequest('post', '/api/answers/' + id + "/unvote", {}, uVoteHandler);
                        }
                        sendAjaxRequest('post', '/api/answers/' + id + "/vote", {reaction: false}, dVoteHandler);
                    }
                }
            }
        });
    }
}

function uVoteHandler(){
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        const answer = document.querySelector(`#answer${id}`);
        const upVote = answer.querySelector('.up-vote ion-icon');
        const nr = answer.querySelector('.answer-btns span');
        if (response.action == 'vote'){
            upVote.classList.add('hasvoted');
            upVote.classList.remove('notvoted');
            nr.textContent = parseInt(nr.textContent, 10) + 1;
        }
        else if (response.action == 'unvote') {
            upVote.classList.add('notvoted');
            upVote.classList.remove('hasvoted');
            nr.textContent = parseInt(nr.textContent, 10) - 1;
        }
    }
}

function dVoteHandler(){
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        const answer = document.querySelector(`#answer${id}`);
        const downVote = answer.querySelector('.down-vote ion-icon');
        const nr = answer.querySelector('.answer-btns span');
        if (response.action == 'vote'){
            downVote.classList.add('hasvoted');
            downVote.classList.remove('notvoted');
            nr.textContent = parseInt(nr.textContent, 10) - 1;
        }
        else if (response.action == 'unvote') {
            downVote.classList.add('notvoted');
            downVote.classList.remove('hasvoted');
            nr.textContent = parseInt(nr.textContent, 10) + 1;
        }
    }
}


function showAnswerDelete() {
    const modal = document.querySelector('#answerDeleteModal');
    modal.style.display = 'block';

    const title = modal.querySelector('h2'); 
    const content = modal.querySelector('p');

    title.textContent = 'Delete answer';
    content.textContent = 'Are you sure you want to delete this answer? All of its comments will be permanently removed. This action cannot be undone.';


    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };

    const cancel = document.getElementById('ad-cancel');

    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
    });

    const id = event.target.closest('.answer-details').getAttribute('data-id');
    
    const confirm = document.getElementById('ad-confirm');
    confirm.textContent = 'Delete';
    confirm.addEventListener('click', function(){
        event.preventDefault();
        if (title.textContent == 'Delete answer')
            sendAjaxRequest('delete', '/api/answers/' + id, {}, answerDeleteHandler);
    });
    
}


function answerDeleteHandler() {
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        const answer = document.querySelector(`#answer${id}`);
        const modal = document.querySelector('#answerDeleteModal');
        modal.style.display = 'none';
        answer.remove();
        createNotificationBox('Successfully saved!', 'Answer deleted successfully!');

        const other = document.querySelector('.other-answers');

        const top = document.querySelector('.top-answer');

        const hasTopAnswer = top.querySelector('.answer-details');
        if (!hasTopAnswer) {
            const nextAnswer = other.querySelector('.answer-details');
            if (nextAnswer) {
                top.innerHTML += nextAnswer.outerHTML;
                nextAnswer.remove();
            } else {
                top.remove();
            }
            
        } else {
            const hasMoreAnswers = other.querySelector('.answer-details');
        
            if (!hasMoreAnswers) {
                other.querySelector('h2').remove();
            }
        }
    }
}


const answerPage = document.querySelector('#answerFormContainer form');

if (answerPage) {

    document.addEventListener('DOMContentLoaded', function() {
        const textareas = document.querySelectorAll('textarea');
        textareas.forEach(function(textarea) {
          textarea.value = '';
        });
    });

    const answerImages = document.querySelector('.answer-images');
    const answerDocs = document.querySelector('.answer-files');

    function uploadAFiles() {
        event.preventDefault();
        const fileInput = document.getElementById('file');
        fileInput.click();
    }

    function fileInputChange() {
        const fileInput = document.getElementById('file');
        const files = fileInput.files; 
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const imageExtentions = ["png", "jpeg", "jpg", "gif"];
            const documentExtentions = ["doc", "docx", "txt", "pdf"];
            const fileExtension = file.name.split('.').pop().toLowerCase();
            
            if (fileNames.includes(file.name)) {
                createNotificationBox('Repeated file!', 'This file was already upload!', 'warning');
                continue;
            }
            else if (documentExtentions.includes(fileExtension)) {
                validFiles.push(file);
                fileNames.push(file.name);
                const reader = new FileReader();

                reader.onload = function(event) {
                    const fileDataUrl = event.target.result;
                    answerDocs.innerHTML += `<div data-filename="${file.name}">
                        <ion-icon name="document"></ion-icon>
                        <a href="${fileDataUrl}" download="${file.name}">
                            <span>${file.name}</span>
                        </a>
                        <ion-icon name="close-circle" class="close"></ion-icon>
                    </div>`;
                }
                reader.readAsDataURL(file);

            }  else if (imageExtentions.includes(fileExtension)){
                validFiles.push(file);
                fileNames.push(file.name);
                const reader = new FileReader();
                
                reader.onload = function(event) {
                    const src = event.target.result;
                    answerImages.innerHTML += `<div data-filename="${file.name}">
                        <img src="${src}">
                        <ion-icon name="close-circle"></ion-icon>
                    </div>`;
                }
                reader.readAsDataURL(file);
            }
            else {
                createNotificationBox('Invalid file type!', 'Please choose a valid file type to upload!', 'error');
                this.value = ''; 
            }
            
        }
    }

    answerImages.addEventListener('click', () => removeImage(event));

    answerDocs.addEventListener('click', () => removeDocument(event));


    function createAnswer(){
        event.preventDefault();
        const content = document.getElementById('content').value;
        const question = document.querySelector('.question-detail-section').getAttribute('data-id');
        if (content !== '')
            sendAjaxRequest('post', '/api/answers', {content: content, question_id: question}, createAnswerHandler);
        else {
            createNotificationBox('Empty answer content', 'Please enter your answer content!', 'warning');
            document.getElementById('content').focus();
        }
    }
}

function answerFileHandler() {
    count++;
    if (validFiles.length == count) {
        const id = JSON.parse(this.responseText).id;
        const answer = document.getElementById('answer' + id);
        const aFiles = document.querySelectorAll('.answer-files div');
        const aImgs = document.querySelectorAll('.answer-images img');
        
        const answerF = answer.querySelector('.a-files');
        const answerI = answer.querySelector('.a-img');

        for (const image of aImgs) {
            answerI.innerHTML += image.outerHTML;
        }

        for (const file of aFiles) {
            file.querySelector('.close').remove();
            file.classList.add('a-file');
            answerF.innerHTML += file.outerHTML;
        }

        document.querySelector('.answer-files').innerHTML = ``;
        document.querySelector('.answer-images').innerHTML = ``;
        validFiles = [];
        fileNames = [];
        count = 0;
    }
}

let oldAnswerFiles = [];

function createAnswerHandler(){
    if (this.status == 200) {
        const otherAnswers = document.querySelector('.other-answers');
        if (otherAnswers) {
            if (!otherAnswers.querySelector('h2')) {
                otherAnswers.innerHTML += ' <h2>Other answers</h2>'
            }
            otherAnswers.innerHTML += this.responseText;
        }
        else {
            const answers = document.querySelector('.answerFormContainer');
            answers.outerHTML = `
            <div class="top-answer">
                <h2>Top answer</h2>
                ${this.responseText}
            </div><div class="other-answers"></div>` + answers.outerHTML;
        }

        let tmp = document.createElement('div');
        tmp.innerHTML = this.responseText;
        const id = tmp.querySelector('.answer-details').getAttribute('data-id');

        createNotificationBox('Answer created!', 'Answer created successfully!');
        document.querySelector('#answerFormContainer form textarea').value = ''; 
        
        if (validFiles.length > 0) {
            count = 0;
            validFiles.map(async function(file) {
                let formData = new FormData();
                formData.append('file', file); 
                formData.append('id', id);
                formData.append('type', 'answer');    
                let request = new XMLHttpRequest();
                request.open('post', '/api/file/upload', true);
                request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
                request.addEventListener('load', answerFileHandler);
                request.send(formData);
            });
        } else {
            validFiles = [];
            fileNames = [];
            count = 0;
        }
       
    }
 
}

let oldAnswer = "";

function showEditAnswer() {
    const answer = event.target.closest('.answer-details');
    oldAnswer = answer.outerHTML;
    const id = answer.getAttribute('data-id');
    
    validFiles = [];
    fileNames = [];
    count = 0;
    deletedFiles = [];
    oldAnswerFiles = [];

    const docFiles = answer.querySelectorAll('.a-file span');
    const imageFiles = answer.querySelectorAll('.a-img img');
    console.log(imageFiles);
    for (const document of docFiles) {
        fileNames.push(document.textContent);
    }
    for (const image of imageFiles) {
        fileNames.push(image.getAttribute('data-name'));
    }

    oldAnswerFiles = fileNames;
    console.log(fileNames);
    sendAjaxRequest('get', '/api/answers/' + id + '/edit', {}, toggleEditAnswer);

}


function toggleEditAnswer() {
    if (this.status == 200) {
        const editAnswer = this.responseText;
        var tmp = document.createElement('div');
        tmp.innerHTML = editAnswer;
        const id = tmp.querySelector('.answer-details').getAttribute('data-id');

        const answer = document.querySelector('#answer' + id);
        answer.outerHTML = editAnswer;
    }
}

function restoreAnswer() {
    const answer = event.target.closest('.answer-details');
    answer.outerHTML = oldAnswer;
}

function removeAnswerImages() {
    if (event.target.tagName === 'ION-ICON') {
        const imgDiv = event.target.parentElement;
        const filenameToRemove = imgDiv.querySelector('img').alt;
        fileNames = fileNames.filter(name => name !== filenameToRemove);
        deletedFiles.push(filenameToRemove);
        const indexToRemove = validFiles.findIndex(file => file.name === filenameToRemove);
        if (indexToRemove !== -1) {
            validFiles.splice(indexToRemove, 1);
        }
        imgDiv.remove();
    }
}

function removeAnswerDocs() {
    if (event.target.tagName === 'ION-ICON') {
        const docDiv = event.target.parentElement;
        const filenameToRemove = docDiv.querySelector('span').textContent;
        console.log(filenameToRemove)
        fileNames = fileNames.filter(name => name !== filenameToRemove);
        deletedFiles.push(filenameToRemove);
        const indexToRemove = validFiles.findIndex(file => file.name === filenameToRemove);
        if (indexToRemove !== -1) {
            validFiles.splice(indexToRemove, 1);
        }
        docDiv.remove();
    }
}

function uploadAnswerFiles() {
    event.preventDefault();
    const fileInput = document.getElementById('answer-file');
    fileInput.click();
}

function uploadAnswerFile() {
    const answerDocs = document.querySelector('.edit-a-files');
    const answerImages = document.querySelector('.edit-a-img');
    const fileInput = document.getElementById('answer-file');
    const files = fileInput.files; 
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const imageExtentions = ["png", "jpeg", "jpg", "gif"];
        const documentExtentions = ["doc", "docx", "txt", "pdf"];
        const fileExtension = file.name.split('.').pop().toLowerCase();
        
        if (fileNames.includes(file.name)) {
            createNotificationBox('Repeated file!', 'This file was already upload!', 'warning');
            continue;
        }
        else if (documentExtentions.includes(fileExtension)) {
            validFiles.push(file);
            fileNames.push(file.name);
            const reader = new FileReader();

            reader.onload = function(event) {
                const fileDataUrl = event.target.result;
                answerDocs.innerHTML += `<div class="edit-a-file">
                    <ion-icon name="document"></ion-icon>
                    <a href="${fileDataUrl}" download="${file.name}">
                        <span>${file.name}</span>
                    </a>
                    <ion-icon name="close-circle" class="close"></ion-icon>
                </div>`;
            }
            reader.readAsDataURL(file);

        }  else if (imageExtentions.includes(fileExtension)){
            validFiles.push(file);
            fileNames.push(file.name);
            const reader = new FileReader();
            
            reader.onload = function(event) {
                const src = event.target.result;
                answerImages.innerHTML += `<div class="edit-img">
                    <img src="${src}" alt="${file.name}">
                    <ion-icon name="close-circle"></ion-icon>
                </div>`;
            }
            reader.readAsDataURL(file);
        }
        else {
            createNotificationBox('Invalid file type!', 'Please choose a valid file type to upload!', 'error');
            this.value = ''; 
        }
    }
}


function updateAnswer() {
    const filesToDelete = oldAnswerFiles.filter(element => deletedFiles.includes(element));
    const id = event.target.closest('.answer-details').getAttribute('data-id');
    
    if (filesToDelete.length > 0) {
        for (const fileName of filesToDelete) {
            sendAjaxRequest('delete', '/api/file/delete', {type: 'answer', id: id, name: fileName}, () => {});
        }
    }

    if (validFiles.length > 0) {
        count = 0;
        validFiles.map(function(file) {
            let formData = new FormData();
            formData.append('file', file); 
            formData.append('id', id);
            formData.append('type', 'answer');    
            let request = new XMLHttpRequest();
            request.open('post', '/api/file/upload', true);
            request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
            request.addEventListener('load', editAnswerFileHandler);
            request.send(formData);
        });
    } else {
        const content = document.querySelector('#edit-content').value;
        if (content !== '') {
            sendAjaxRequest('put', '/api/answers/' + id, {content: content}, editedAnswerHandler);
        } else {
            createNotificationBox('Empty answer content', 'Please enter your answer before saving!', 'warning');
        }
    }
}


function editAnswerFileHandler() {
    count++;
    if (count == validFiles.length) {
        const content = document.querySelector('#edit-content').value;
        const id = JSON.parse(this.responseText).id;
        if (content !== '') {
            sendAjaxRequest('put', '/api/answers/' + id, {content: content}, editedAnswerHandler);
        } else {
            createNotificationBox('Empty answer content', 'Please enter your answer before saving!', 'warning');
        }
    }
}

function editedAnswerHandler() {
    const updatedAnswer = this.responseText;
    var tmp = document.createElement('div');
    tmp.innerHTML = updatedAnswer;
    const id = tmp.querySelector('.answer-details').getAttribute('data-id');

    const answer = document.querySelector('#answer' + id);

    answer.outerHTML = updatedAnswer;
    createNotificationBox('Answer edited!', 'Answer was edited successfully!');

}

function markAsCorrect() {
    const id = event.target.closest('.answer-details').getAttribute('data-id');
    sendAjaxRequest('post', '/api/answers/' + id + '/status', {status: 'correct'}, correctAnswerHander);
}


function markAsWrong() {
    const id = event.target.closest('.answer-details').getAttribute('data-id');
    sendAjaxRequest('post', '/api/answers/' + id + '/status', {status: 'wrong'}, correctAnswerHander);
}

function correctAnswerHander() {
    if (this.status === 200) {
        const status = JSON.parse(this.responseText).status;
        const id = JSON.parse(this.responseText).id;
        const answer = document.querySelector(`#answer` + id);
        const btn = answer.querySelector('#mark-answer');
        if (status == 'correct') {
            const list = answer.querySelector('.answer-content ul');
            list.innerHTML += `<li class="correct-answer">CORRECT ANSWER ✔</li>`;
            btn.outerHTML = `<div id="mark-answer" onclick="markAsWrong()">
                    <ion-icon name="close-circle"></ion-icon>
                    <span>Wrong</span>
                </div>`;
            createNotificationBox('Correct answer!', 'The answer was marked as correct!');
        } else {
            const elem = answer.querySelector('.answer-content .correct-answer');
            elem.remove();
            btn.outerHTML = `<div id="mark-answer" onclick="markAsCorrect()">
                    <ion-icon name="checkmark-circle"></ion-icon>
                    <span>Correct</span>
                </div>`;
            createNotificationBox('Wrong answer!', 'The answer was marked as incorrect!');

        }
    }
}