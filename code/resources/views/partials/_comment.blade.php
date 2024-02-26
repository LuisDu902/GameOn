<li class="comment-container" id="comment{{ $comment->id }}" data-id="{{ $comment->id }}">
    <div>
        <img class="answer-img" src="{{ $comment->creator->getProfileImage() }}" alt="user">
        <div class="c-desc">
            <a href="{{ route('profile', ['id' => $comment->user_id ]) }}" class="purple comment-creator">{{ $comment->user->name }}</a>
            <span> {{ $comment->lastModification() }} ago </span>
        </div>
        @auth
            @if (Auth::user()->id === $comment->user_id)
                <div class="comment-dropdown">
                    <button class="drop-btn">
                        <ion-icon name="ellipsis-vertical" onclick="toggleCommentDropDown()"></ion-icon>
                    </button>
                    <div class="q-drop-content">
                        <div id="edit-question" onclick="showEditComment()">
                            <ion-icon name="create"></ion-icon>
                            <span>Edit</span>
                        </div>
                        <div onclick="showCommentDelete()">
                            <ion-icon name="trash"></ion-icon>
                            <span>Delete</span>
                        </div>
                    </div>
                </div>
            @else
            <div class="comment-dropdown">
                <button>
                    <ion-icon name="ellipsis-vertical" onclick="toggleCommentDropDown()"></ion-icon>
                </button>
                <div class="q-drop-content">
                <div onclick="openPopup3()">
                            <ion-icon name="flag"></ion-icon>
                            <span>Report</span>
                        </div>
                </div>
            </div>
            @endif
        @endauth
    </div>
    <p class="comment-content">
        {{ $comment->latestContent() }}
    </p>
</li>


<!-- Report Popup -->
<div id="reportPopup3" class="report-popup">
    <div class="report-popup-content">
        <span class="close-btn" onclick="closePopup3()">&times;</span>
        <h2>Report</h2>
        <p>Select a reason for reporting:</p>
        <form method="POST" action="{{ route('report.store3') }}">
            @csrf
            <div>
                <input type="radio" id="personal_info" name="reason" value="personal_info">
                <label for="personal_info">Sharing Personal Information</label>
            </div>
            <div>
                <input type="radio" id="copyright" name="reason" value="copyright">
                <label for="copyright">Copyright Violation</label>
            </div>
            <div>
                <input type="radio" id="spam" name="reason" value="spam">
                <label for="spam">Spam</label>
            </div>
            <div>
                <input type="radio" id="self_harm" name="reason" value="self_harm">
                <label for="self_harm">Self Harm or Suicide</label>
            </div>
            <div>
                <input type="radio" id="impersonation" name="reason" value="impersonation">
                <label for="impersonation">Impersonation</label>
            </div>
            <div>
                <input type="radio" id="harassment" name="reason" value="harassment">
                <label for="harassment">Harassment</label>
            </div>
            <div>
                <input type="radio" id="hate" name="reason" value="hate">
                <label for="hate">Hate</label>
            </div>
            <div>
                <input type="radio" id="sexual_content" name="reason" value="sexual_content">
                <label for="sexual_content">Sexual Content</label>
            </div>

            <input type="hidden" name="comment_id" value="{{ $comment->id }}">
            <input type="hidden" name="reported_id" value="{{ $comment->user_id }}">




            <p id="elaborate">Elaborate on the issue:</p>
            <textarea name="explanation"></textarea>
            <button type="submit">Submit Report</button>
        </form>
    </div>
</div>
