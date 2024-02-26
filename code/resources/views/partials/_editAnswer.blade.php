<div class="answer-details" id="answer{{ $answer->id }}" data-id="{{ $answer->id }}">
    <div class="vote-btns answer-btns" data-id="{{ $answer->id }}">
        <button class="up-vote">
            <ion-icon id="own-up" class= "notvoted" name="caret-up" onclick="showVoteWarning()"></ion-icon>
        </button>
        <span>{{ $answer->votes }}</span>
        <button class="down-vote">
            <ion-icon id="own-down" class= "notvoted" name="caret-down" onclick="showVoteWarning()"></ion-icon>
        </button>
    </div>
    <div class="answer-content"> 
        <div class="a-content">
            <img class="answer-img" src="{{ $answer->creator->getProfileImage() }}" alt="user">
            <textarea name="content" id="edit-content" class="form-control" placeholder="Enter your answer here..." required>{{ $answer->latestContent() }}</textarea>
            <div class="edit-answer-btns">
                <button id="cancel-answer-edit" onclick="restoreAnswer()"> Cancel </button>
                <button id="save-answer-edit" onclick="updateAnswer()"> Save </button>
            </div>
        </div>
        <div class="edit-upload-files">
            <label for="file">Select Files:</label>
            <input type='file' name='files[]' id="answer-file" multiple hidden onchange="uploadAnswerFile()">
            <button id="answer-up-f" onclick="uploadAnswerFiles()">Select</button>
        </div>
        <div id="edit-a-file-info">Valid file types: .jpg, .png, .pdf, .gif, .doc, .docx</div>
        <div class="edit-a-files" onclick="removeAnswerDocs()">
            @foreach($answer->documents() as $document)
                <div class="edit-a-file">
                    <ion-icon name="document"></ion-icon>
                    <a href="{{ asset('answer/' . $document->file_name) }}" download="{{ asset('answer/' . $document->file_name) }}">
                        <span>{{ $document->f_name }}</span>
                    </a>
                    <ion-icon name="close-circle" class="close"></ion-icon>
                </div>
            @endforeach
        </div>
        <div class="edit-a-img" onclick="removeAnswerImages()">
            @foreach($answer->images() as $image)
            <div class="edit-img">
                <img src="{{ asset('answer/' . $image->file_name) }}" alt="{{ $image->f_name }}" data-name="{{ $image->f_name }}">
                <ion-icon name="close-circle" class="close"></ion-icon>
            </div>     
            @endforeach
        </div>
    </div>
</div>

