let c_answer_id = 0;

function submitComment() {
    event.preventDefault();
    const answer = event.target.closest('.answer-details');
    const answer_id = answer.getAttribute('data-id');
    c_answer_id = answer_id;
    const content = answer.querySelector('#c-content').value;

    if (content !== '') {
        sendAjaxRequest('post', '/api/comments', {answer_id : answer_id, content: content}, submitCommentHandler);
    } else {
        createNotificationBox('Empty comment content', 'Please enter your comment before posting!', 'warning');
    }

}

function submitCommentHandler() {
    if (this.status == 200) {
        const answer = document.querySelector('#answer' + c_answer_id);
        const noComments = answer.querySelector('.no-comment');
        if (noComments) {
            noComments.remove();
        } 
        const comments = answer.querySelector('.answer-comment-list');
        comments.innerHTML += this.responseText;

        answer.querySelector('#c-content').value = '';
        createNotificationBox('Comment created!', 'Comment was created successfully!');

        const count = answer.querySelector('.comment-count');

        let nr = parseInt(count.textContent.replace(/\D/g, ''), 10) + 1;

        count.textContent = `${nr} comments`;
    }
}


function showCommentDelete() {
    const modal = document.querySelector('#answerDeleteModal');
    const title = modal.querySelector('h2'); 
    const content = modal.querySelector('p');

    title.textContent = 'Delete comment';
    content.textContent = 'Are you sure you want to delete this comment? This action cannot be undone.'

    modal.style.display = 'block';

    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };

    const cancel = document.getElementById('ad-cancel');

    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
    });

    const id = event.target.closest('.comment-container').getAttribute('data-id');
    const confirm = document.getElementById('ad-confirm');
    
    confirm.addEventListener('click', function(){
        event.preventDefault();
        sendAjaxRequest('delete', '/api/comments/' + id, {}, commentDeleteHandler);
        modal.style.display = 'none';
    });
    
}

function commentDeleteHandler() {
    if (this.status == 200) {
        const id = JSON.parse(this.responseText).id;
        const comment = document.querySelector('#comment' + id);
        const list = comment.closest('ul');
        comment.remove();
        if (!list.querySelector('li')) {
            list.innerHTML = `<li class="no-comment"> No comments yet, be the first to comment!</li>`;
        }
    }
}