<li class="comment-container" id="comment{{ $comment->id }}" data-id="{{ $comment->id }}">
    <div>
        <img class="answer-img" src="{{ $comment->creator->getProfileImage() }}" alt="user">
        <div class="c-desc">
            <a href="{{ route('profile', ['id' => $comment->user_id ]) }}" class="purple">{{ $comment->user->name }}</a>
        </div>
        <div class="edit-comment-btns">
            <button id="cancel-answer-edit" onclick="restoreComment()"> Cancel </button>
            <button id="save-answer-edit" onclick="updateComment()"> Save </button>
        </div>
    </div>
    <textarea name="content" id="comment-content" class="form-control" placeholder="Enter your comment here..." required>{{ $comment->latestContent() }}</textarea>
</li>