let tags = [];
let games = [];
let selectHtml = '';
let rTags = '';
let rGames = '';
let validFiles = [];
let fileNames = [];
let count = 0;
let deletedFiles = [];
let currentPage = 1;

const questionsBtns = document.querySelectorAll('.questions-sort>button');

if (questionsBtns) {

    document.addEventListener('DOMContentLoaded', function() {
        const selects = document.querySelectorAll('.filter-content select');
        for (const select of selects) select.value = 0;
    });

    questionsBtns.forEach(button => {
        button.addEventListener('click', function () {
            questionsBtns.forEach(btn => btn.classList.remove('selected'));
            this.classList.add('selected');
        });
    });

    function removeFilterTag() {
        if (event.target.tagName === 'ION-ICON') {
            const tagDiv = event.target.parentElement;
            const tagId = tagDiv.getAttribute('data-tagid');

            const index = tags.indexOf(tagId);
            if (index !== -1) {
                tags.splice(index, 1);
            }

            tagDiv.remove();
        }
    }

    function removeFilterGame() {
        if (event.target.tagName === 'ION-ICON') {
            const gameDiv = event.target.parentElement;
            const gameId = gameDiv.getAttribute('data-gameid');

            const index = games.indexOf(gameId);
            if (index !== -1) {
                games.splice(index, 1);
            }

            gameDiv.remove();
        }
    }

    function addFilterTag() {
        const tagId = event.target.value;
        const selectedOption = event.target.options[event.target.selectedIndex];
        const tagName = selectedOption.textContent;
        filterTagsDiv = document.querySelector('.filter-tags');
        if (tagId != 0) {
            if (!tags.includes(tagId)) {
                tags.push(tagId);
                filterTagsDiv.innerHTML += ` <div class="filter-tag" data-tagid=${tagId}><span>${tagName}</span><ion-icon name="close-circle"></ion-icon></div>`;
            }
        }
    }

    function addFilterGame() {
        const gameId = event.target.value;
        const selectedOption = event.target.options[event.target.selectedIndex];
        const gameName = selectedOption.textContent;
        filterGamesDiv = document.querySelector('.filter-games');
        if (gameId != 0) {
            if (!games.includes(gameId)) {
                games.push(gameId);
                filterGamesDiv.innerHTML += ` <div class="filter-tag" data-gameid=${gameId}><span>${gameName}</span><ion-icon name="close-circle"></ion-icon></div>`;
            }
        }
    }

    function applyFilters() {
        rTags = tags.join(',');
        rGames = games.join(',');
        const criteria = document.querySelector('.questions-sort .selected').id;
        currentPage = 1;
        sendAjaxRequest('get', '/api/questions?' + encodeForAjax({criteria: criteria, page: currentPage, tags: rTags, games: rGames}), {}, questionListHandler);
        document.querySelector('.filter-content').style.display = 'none';
        createNotificationBox('Filter applied!', 'Filters applied to questions!');
        document.querySelector('#filter-questions').classList.add('filtered');
    }
}

const questions_section = document.querySelector('.questions-sec');


if (questions_section) {

    const recent_btn = document.querySelector('#recent');
    const popular_btn = document.querySelector('#popular');
    const unanswered_btn = document.querySelector('#unanswered');
    if (recent_btn) {
        recent_btn.addEventListener('click', function(){
            currentPage = 1;
            sendAjaxRequest('get', '/api/questions?' + encodeForAjax({criteria: 'recent', page: currentPage, tags: rTags, games: rGames}), {}, questionListHandler);
        })
        popular_btn.addEventListener('click', function(){
            currentPage = 1;
            sendAjaxRequest('get', '/api/questions?' + encodeForAjax({criteria: 'popular', page: currentPage, tags: rTags, games: rGames}), {}, questionListHandler);
        })
        unanswered_btn.addEventListener('click', function(){
            currentPage = 1;
            sendAjaxRequest('get', '/api/questions?' + encodeForAjax({criteria: 'unanswered', page: currentPage, tags: rTags, games: rGames}), {}, questionListHandler);
        })
    
        document.addEventListener('scroll', infiniteScroll);
        function infiniteScroll(){
            const scrollableHeight = document.documentElement.scrollHeight - window.innerHeight;
            if (window.scrollY >= scrollableHeight) {
                const criteria = document.querySelector('.questions-sort .selected').id;
                currentPage++;
                sendAjaxRequest('get', '/api/questions?' + encodeForAjax({criteria: criteria, page: currentPage, tags: rTags, games: rGames}), {}, questionListHandler);
            }
        }
    }
}

function questionListHandler() {
    if (this.status === 200) {
        const table = document.querySelector('.questions');
        var tmp = document.createElement('div');
        tmp.innerHTML = this.response;
        const lastPage = tmp.querySelector('.no-questions');
        if (currentPage == 1) {
            const noQ = document.querySelector('.no-questions');
            if (lastPage && table) {
                table.outerHTML = tmp.innerHTML;
            } else if (!lastPage && !table) {
                const newQuestions = tmp.querySelector('ul').innerHTML;
                noQ.outerHTML = `<ul class="questions">${newQuestions}</ul>`;
                console.log(currentPage);
                document.addEventListener('scroll', infiniteScroll);
            }
            else if (table){
                const newQuestions = tmp.querySelector('ul').innerHTML;
                table.innerHTML = newQuestions;
                console.log(currentPage);
                document.addEventListener('scroll', infiniteScroll);
            }
            
            return;
        }
        if (lastPage && currentPage > 1) {
            currentPage--;
        } else {
            const newQuestions = tmp.querySelector('ul').innerHTML;
            table.innerHTML += newQuestions;
            console.log(currentPage);
            document.addEventListener('scroll', infiniteScroll);
        }
        
    } else {
        console.error('Question list failed:', this.statusText);
    }
}

/* Question detail page */

const questionContainer = document.querySelector('.question-detail-section');

if (questionContainer) {
    const upVote = document.getElementById('up');
    const downVote =  document.getElementById('down');
    const questionId = questionContainer.dataset.id;
    const userId = questionContainer.getAttribute('data-user');
    const deleteBtn = document.querySelector('#delete-question');

    function followQuestion() {
        const action = document.querySelector('#f-action');
        if (action.textContent == 'Follow') {
            createNotificationBox('Following question', 'You will be notified when there are updates to this question!')
            sendAjaxRequest('post', '/api/questions/' + questionId + '/follow', {}, toggleFollowHandler);    
        } else {
            createNotificationBox('Unfollow question', 'You will not receive more notifications on this question!')
            sendAjaxRequest('post', '/api/questions/' + questionId + '/unfollow', {}, toggleFollowHandler);    
        }
    }

    function toggleFollowHandler() {
        if (this.status == 200) {
            const type = JSON.parse(this.response).action;
            const followBtn = document.querySelector('#followQuestion');
            if (type == 'follow') {
                followBtn.innerHTML = `<ion-icon name="heart-dislike-circle"></ion-icon>
                <span id="f-action">Unfollow</span>`;
            } else {
                followBtn.innerHTML = `<ion-icon name="bookmark"></ion-icon>
                <span id="f-action">Follow</span>`;
            }
        }
    }

    if (!userId) {
        const no_up = document.querySelectorAll('.no-up');
        const no_down = document.querySelectorAll('.no-down');
        no_up.forEach(element => {
            element.addEventListener('click', showLoginModal);
        });
    
        no_down.forEach(element => {
            element.addEventListener('click', showLoginModal);
        });
    }

    if (upVote) {
    upVote.addEventListener('click', function(){
        if(upVote.classList.contains('hasvoted')){
            sendAjaxRequest('post', '/api/questions/' + questionId + "/unvote", {}, upVoteHandler);
        } else {
            if (downVote.classList.contains('hasvoted')) {
                sendAjaxRequest('post', '/api/questions/' + questionId + "/unvote", {}, downVoteHandler);
            }
            sendAjaxRequest('post', '/api/questions/' + questionId + "/vote", {reaction: true}, upVoteHandler);
        }
    });}

    if (downVote) {
    downVote.addEventListener('click', function(){
        if(downVote.classList.contains('hasvoted')){
            sendAjaxRequest('post', '/api/questions/' + questionId + "/unvote", {}, downVoteHandler);
        } else {
            if (upVote.classList.contains('hasvoted')) {
                sendAjaxRequest('post', '/api/questions/' + questionId + "/unvote", {}, upVoteHandler);
            }
            sendAjaxRequest('post', '/api/questions/' + questionId + "/vote", {reaction: false}, downVoteHandler);
        }
    });}

    if (deleteBtn) {
        deleteBtn.addEventListener('click', showDeleteModal);
    }

}


function showDeleteModal() {
    const modal = document.getElementById('deleteModal');
    modal.style.display = 'block';

    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };

    const cancel = document.getElementById('d-cancel');

    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
    });
}

function showLoginModal() {

    const modal = document.getElementById('loginModal');
    modal.style.display = 'block';
    
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };
}


function upVoteHandler(){
    const upVote = document.getElementById('up');
   
    const nr = document.querySelector('.vote-btns span');
    if (this.status == 200){
        if (this.responseText == '{"action":"vote"}'){
            upVote.classList.add('hasvoted');
            upVote.classList.remove('notvoted');
            nr.textContent = parseInt(nr.textContent, 10) + 1;
        }
        else if (this.responseText == '{"action":"unvote"}') {
            upVote.classList.add('notvoted');
            upVote.classList.remove('hasvoted');
            nr.textContent = parseInt(nr.textContent, 10) - 1;
        }
    } 
}

function downVoteHandler(){
    const downVote =  document.getElementById('down');
    const nr = document.querySelector('.vote-btns span');
    if (this.status == 200){
        if (this.responseText == '{"action":"vote"}'){
            downVote.classList.add('hasvoted');
            downVote.classList.remove('notvoted');
            nr.textContent = parseInt(nr.textContent, 10) - 1;
        }
        else if (this.responseText == '{"action":"unvote"}') {
            downVote.classList.add('notvoted');
            downVote.classList.remove('hasvoted');
            nr.textContent = parseInt(nr.textContent, 10) + 1;
        }
    }
}

/* Create question page */

const newPage = document.querySelector('.new-question-form form');


if (newPage) {
    
    const selectTag = document.getElementById('tag_id');
    const newTagsDiv = document.querySelector('.new-tags');
    const uploadButton = document.getElementById('up-f');
    const fileInput = document.getElementById('file');
    const questionImages = document.querySelector('.question-img');
    const questionDocs = document.querySelector('.question-files');
    const createTag = document.getElementById('create-tag');
    const createBtn = document.getElementById('create-question');

    selectTag.addEventListener('change', tagHandler);

    newTagsDiv.addEventListener('click', () => removeTag(event));

    if (createTag) {
        createTag.addEventListener('click', createTagHandler);
    }

    uploadButton.addEventListener('click', function(){
        event.preventDefault();
        fileInput.click(); 
    })

    fileInput.addEventListener('change', function() {
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
                    questionDocs.innerHTML += `<div data-filename="${file.name}">
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
                    questionImages.innerHTML += `<div data-filename="${file.name}">
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
    });

    questionImages.addEventListener('click', () => removeImage(event));

    questionDocs.addEventListener('click', () => removeDocument(event));

    createBtn.addEventListener('click', function(){
        event.preventDefault();
        const title = document.getElementById('title').value;
        const content = document.getElementById('content').value;
        const chosenGame = document.getElementById('game_id').value;
        const cTags = tags.join(',');
        if (title === '') {
            createNotificationBox('Empty question title', 'Please enter your question title!', 'warning');
            document.getElementById('title').focus();
        } else if (content === '') {
            createNotificationBox('Empty question content', 'Please enter your question content!', 'warning');
            document.getElementById('content').focus();
        } else {
            sendAjaxRequest('post', '/api/questions', {title: title, content: content, tags: (cTags.length == 0 ? '0' : cTags), game: chosenGame}, createHandler);
        }
    });
}

function createTagHandler() {
    const tagBtns = document.querySelector('.tag-btns');
    const selectTag = document.getElementById('tag_id');
    selectHtml = selectTag.outerHTML;
    tagBtns.innerHTML = `<button id="cancel-tag">Cancel</button>
    <button id="conf-tag">Create</button>`;

    const tagsLabel = document.querySelector('label[for="tags"]');
    tagsLabel.textContent = 'New tag:';
    selectTag.outerHTML = '<input type="text" name="tag-name" placeholder="New tag name..." required>';

    const confirm = document.getElementById('conf-tag');
    confirm.addEventListener('click', async function(){
        event.preventDefault();
        const newTag = document.querySelector('.tag-con input');
        if (newTag.value !== '') {
            sendAjaxRequest('post', '/api/tags', {name: newTag.value}, newTagHandler);
        }
    });

    const cancel = document.getElementById('cancel-tag');
    cancel.addEventListener('click', () => { event.preventDefault(); closeTag()});   

}

function closeTag() {
    const tagsLabel = document.querySelector('label[for="tags"]');
    const tagBtns = document.querySelector('.tag-btns');
    tagsLabel.textContent = 'Tags:';
    document.querySelector('.tag-con input').outerHTML = selectHtml;
    tagBtns.innerHTML = '<button id="create-tag">Create new tag</button>';
    const createTag = document.getElementById('create-tag');
    createTag.addEventListener('click', createTagHandler);
    const select = document.getElementById('tag_id');
    select.addEventListener('change', tagHandler);
}

function tagHandler() {
    const selectTag = document.getElementById('tag_id');
    const newTagsDiv = document.querySelector('.new-tags');
    const selectedOption = selectTag.options[selectTag.selectedIndex];
    if (selectedOption.value !== "None") {
        const tagId = selectedOption.value;
        const tagName = selectedOption.text;
        if (!tags.includes(tagId)) {
            tags.push(tagId);
            newTagsDiv.innerHTML += ` <div class="new-tag" data-tagid=${tagId}><span>${tagName}</span><ion-icon name="close-circle"></ion-icon></div>`;
        }
    }
}

function newTagHandler() {
    if (this.status == 200) {
        const tagId = JSON.parse(this.responseText).id;
        const name = JSON.parse(this.responseText).name;
        createNotificationBox('Successfully created!', 'A new tag has created successfully!');
        selectHtml = selectHtml.replace('</select>', '');
        selectHtml += `<option value="${tagId}"> ${ name }</option>`;
        selectHtml += '</select>';
        closeTag();
        tags.push(tagId);
        const newTagsDiv = document.querySelector('.new-tags');
        newTagsDiv.innerHTML += ` <div class="new-tag" data-tagid=${tagId}><span>${name}</span><ion-icon name="close-circle"></ion-icon></div>`;

    } else {
        const errorResponse = JSON.parse(this.responseText);
        createNotificationBox('Something went wrong!', errorResponse.error.name, 'error');
        const input = document.querySelector('.tag-con input');
        input.focus();
    }
}

function removeTag(event) {
    if (event.target.tagName === 'ION-ICON') {
        const tagDiv = event.target.parentElement;
        const tagId = tagDiv.getAttribute('data-tagid');

        const index = tags.indexOf(tagId);
        if (index !== -1) {
            tags.splice(index, 1);
        }

        tagDiv.remove();
    }
}


function removeImage(event) {
    if (event.target.tagName === 'ION-ICON') {
        const imgDiv = event.target.parentElement;
        const filenameToRemove = imgDiv.getAttribute('data-filename');
        fileNames = fileNames.filter(name => name !== filenameToRemove);
        deletedFiles.push(filenameToRemove);
        const indexToRemove = validFiles.findIndex(file => file.name === filenameToRemove);
        if (indexToRemove !== -1) {
            validFiles.splice(indexToRemove, 1);
        }
        imgDiv.remove();
    }
}

function removeDocument(event) {
    if (event.target.tagName === 'ION-ICON') {
        const docDiv = event.target.parentElement;
        const filenameToRemove = docDiv.getAttribute('data-filename');
        fileNames = fileNames.filter(name => name !== filenameToRemove);
        deletedFiles.push(filenameToRemove);
        const indexToRemove = validFiles.findIndex(file => file.name === filenameToRemove);
        if (indexToRemove !== -1) {
            validFiles.splice(indexToRemove, 1);
        }
        docDiv.remove();
    }
}

function createHandler() {
    if (this.status === 200) {
        const id = JSON.parse(this.response).id;
        
        if (validFiles.length > 0) {
            count = 0;
            validFiles.map(function(file) {
                let formData = new FormData();
                formData.append('file', file); 
                formData.append('id', id);
                formData.append('type', 'question');    
                sendFile(formData);
            });
        } else {
            window.location.href = '/questions';
        }
    }
}

function sendFile(formData) {
    let request = new XMLHttpRequest();
    request.open('post', '/api/file/upload', true);
    request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
    request.addEventListener('load', questionFileHandler);
    request.send(formData);
}

function questionFileHandler() {
    count++;
    if (count == validFiles.length) {
        if (newPage) window.location.href = '/questions';
        else window.location.href = '/questions/' + JSON.parse(this.responseText).id;
    }
}

/* Edit question page */

const editPage = document.querySelector('.edit-question-form form');

if (editPage) {
    
    const selectTag = document.getElementById('tag_id');
    const newTagsDiv = document.querySelector('.new-tags');
    const uploadButton = document.getElementById('up-f');
    const fileInput = document.getElementById('file');
    const questionImages = document.querySelector('.question-img');
    const questionDocs = document.querySelector('.question-files');
    const createTag = document.getElementById('create-tag');
    const imageFiles = document.querySelectorAll('.question-img img');
    const docFiles = document.querySelectorAll('.question-files span');
    const oldTags = document.querySelectorAll('.new-tags div');
    const saveBtn = document.querySelector('#save-question');


    for (const tag of oldTags) {
        tags.push(tag.getAttribute('data-tagid'));
    }

    for (const document of docFiles) {
        fileNames.push(document.textContent);
    }
    for (const image of imageFiles) {
        fileNames.push(image.alt);
    }
    
    const oldFiles = fileNames;
    selectTag.addEventListener('change', tagHandler);

    newTagsDiv.addEventListener('click', () => removeTag(event));

    if (createTag) {
        createTag.addEventListener('click', createTagHandler);
    }

    uploadButton.addEventListener('click', function(){
        event.preventDefault();
        fileInput.click(); 
    })

    fileInput.addEventListener('change', function() {
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
                    questionDocs.innerHTML += `<div data-filename="${file.name}>
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
                    questionImages.innerHTML += `<div data-filename="${file.name}">
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
    });

    questionImages.addEventListener('click', () => removeImage(event));

    questionDocs.addEventListener('click', () => removeDocument(event));

    saveBtn.addEventListener('click', function() {
        event.preventDefault();

        const filesToDelete = oldFiles.filter(element => deletedFiles.includes(element));
        
        const id = editPage.getAttribute('data-id');
        const title = document.getElementById('title').value;
        const content = document.getElementById('content').value;
        const chosenGame = document.getElementById('game_id').value;
        const cTags = tags.join(',');
        sendAjaxRequest('put', '/api/questions/' + id, {title: title, content: content, tags: (cTags.length == 0 ? '0' : cTags), game: chosenGame}, () => {});

        if (filesToDelete.length > 0) {
            for (const fileName of filesToDelete) {
                sendAjaxRequest('delete', '/api/file/delete', {type: 'question', id: id, name: fileName}, () => {});
            }
        }

        if (validFiles.length > 0) {
            count = 0;
            validFiles.map(function(file) {
                let formData = new FormData();
                formData.append('file', file); 
                formData.append('id', id);
                formData.append('type', 'question');    
                sendFile(formData);
            });
        } else {
            window.location.href = '/questions/' + id;
        }
    })
}



function showVoteWarning() {
    createNotificationBox('Action not authorized!', 'You cannot vote on your own posts!', 'error');
}


function showVisibilityToggle() {

    const icon = document.querySelector('#question-visibility ion-icon');
    const id = document.querySelector('.question-detail-section').getAttribute('data-id');

    if (icon.getAttribute('name') == 'eye') {
        const modal = document.querySelector('#answerDeleteModal');
        modal.style.display = 'block';

        const title = modal.querySelector('h2'); 
        const content = modal.querySelector('p');

        title.textContent = 'Post visibility';
        content.textContent = 'Are you sure you want to make this question private? All of its answers and content will not be visible.';


        window.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        };

        const cancel = document.getElementById('ad-cancel');

        cancel.addEventListener('click', function(){
            modal.style.display = 'none';
        });

        
        const confirm = document.getElementById('ad-confirm');
        confirm.textContent = 'Confirm';
        confirm.addEventListener('click', function(){
            event.preventDefault();
            if (title.textContent == 'Post visibility') {
                modal.style.display = 'none';
                sendAjaxRequest('post', '/api/questions/' + id + '/visibility', {visibility : 'private'}, visibilityHandler);
            }
        });
    } else {
        sendAjaxRequest('post', '/api/questions/' + id + '/visibility', {visibility : 'public'}, visibilityHandler);
    }
}


function visibilityHandler() {
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const icon = document.querySelector('#question-visibility ion-icon');
        
        if (response.visibility == 'public') {
            icon.outerHTML = `<ion-icon name="eye"></ion-icon>`;
            createNotificationBox('Sucessfully updated!', 'Question visibility set to public!');
        } else {
            console.log('hi');
            icon.outerHTML = `<ion-icon name="eye-off"></ion-icon>`;
            createNotificationBox('Sucessfully updated!', 'Question visibility set to private!');
        }

    }
}



function removeFilterTag() {
    if (event.target.tagName === 'ION-ICON') {
        const tagDiv = event.target.parentElement;
        const tagId = tagDiv.getAttribute('data-tagid');

        const index = tags.indexOf(tagId);
        if (index !== -1) {
            tags.splice(index, 1);
        }

        tagDiv.remove();
    }
}
const upA = document.getElementById('answer-up-f')
const fileInfoA = document.getElementById('a-file-info');

const upB = document.getElementById('up-f');
const fileInfoB = document.getElementById('file-info');

if (upB) {
    upB.addEventListener('mouseover', function() {
        fileInfoB.style.display = 'block';
    });
    
    upB.addEventListener('mouseout', function() {
        fileInfoB.style.display = 'none';
    });
}


if (upA) {
    upA.addEventListener('mouseover', function() {
        fileInfoA.style.display = 'block';
    });
    
    upA.addEventListener('mouseout', function() {
        fileInfoA.style.display = 'none';
    });
}


const activity = document.querySelector('.activity-section');
const activityList = document.querySelector('.activities');

let activityPage = 1;

if (activity) {
    const question_id = activity.getAttribute('data-id'); 

    document.addEventListener('scroll', scrooll);
    function scrooll(){
        const scrollableHeight = document.documentElement.scrollHeight - window.innerHeight;
        if (window.scrollY >= scrollableHeight) {
            activityPage++;
            sendAjaxRequest('get', '/questions/' + question_id + '/activity?' + encodeForAjax({page: activityPage}), {}, activityHandler);
        }
    }
}

function activityHandler() {
    
    var tempElement = document.createElement('div');
    tempElement.innerHTML = this.responseText;

    var targetSection = tempElement.querySelector('.activities');

    if (targetSection) {
        activityList.innerHTML += targetSection.innerHTML;
    } 
}
