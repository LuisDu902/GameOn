
@extends('layouts.app')

@section('content')
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar">
            <ion-icon name="menu"></ion-icon>
        </button>
        <ul class="breadcrumb">
            <li><a href="{{ route('home') }}">
                <ion-icon name="home-outline"></ion-icon> Home</a>
            </li>
            <li><a href="{{ route('questions') }}">Questions</a></li>
            @if (strlen($question->latestContent()) >= 300)
                <li>{{ substr($question->title, 0, 300) }}...</li>
            @else
                <li>{{ $question->title }}</li>
            @endif
        </ul>
    </div>
    
    <section class="question-detail-section" data-id="{{$question->id}}" {{ Auth::check() ? 'data-user=' . Auth::id() . ' data-username=' . Auth::user()->username . '' : '' }}>
        
        @include('partials._questionDetail', ['question' => $question])

        @if ($question->answers->isNotEmpty())
            <div class="top-answer">
                <h2>Top answer</h2>
                @include('partials._answer', ['answer' => $question->topAnswer()])
            </div>
                <div class="other-answers">
                    @if ($question->otherAnswers()->isNotEmpty())
                        <h2>Other answers</h2>
                        @foreach ($question->otherAnswers() as $answer)
                            @include('partials._answer', ['answer' => $answer])
                        @endforeach
                    @endif
                </div>
        @elseif (!Auth::check())
            <div class="no-answers">
                <img class="no-answers-image" src="{{ asset('images/pikachuConfused.png') }}" alt="Psyduck Image">
                <p>No answers for this question yet.</p>
            </div>
            <div class="other-answers">
            </div>
        @endif
        
        @if (Auth::check() && Auth::user()->id !== $question->user_id && !Auth::user()->is_banned)  
        <div id="answerFormContainer" class="answerFormContainer">
            <form>
                <div class="form-group">
                    <label for="content">Answer <span>*</span></label>
                    <textarea name="content" id="content" class="form-control" placeholder="Enter your answer here..." required></textarea>
                </div>
                <div class="upload-files">
                    <label for="file">Select Files:</label>
                    <input type='file' name='files[]' id="file" multiple hidden onchange="fileInputChange()">
                    <button id="answer-up-f" onclick="uploadAFiles()">Select</button>
                </div>
                <div id="a-file-info">Valid file types: .jpg, .png, .pdf, .gif, .doc, .docx</div>
                <div class="answer-files"></div>
                <div class="answer-images"></div>
                <button id="create-answer" onclick="createAnswer()">Post Answer</button>
            </form>
        </div>
        @endif
        <div id="loginModal" class="modal">
            <div class="modal-content">
                <ion-icon name="warning-outline"></ion-icon>
                <h2>Authentication required</h2>
                <p>Please sign up or sign in to continue</p>
                <div>
                    <a href="{{ route('register') }}">
                        Sign Up
                    </a>
                    <a href="{{ route('login') }}">
                        Sign In
                    </a>
                </div>
            </div>
        </div>

        <div id="deleteModal" class="modal">
            <div class="delete-modal">
                <div class="modal-c">
                    <ion-icon name="warning-outline"></ion-icon>
                    <div>
                    <h2>Delete question</h2>
                    <p>Are you sure you want to delete this question? All of its answers and comments will be permanently removed. This action cannot be undone.</p>
                    </div>
                </div>
                <div class="d-buttons">
                    <button id="d-cancel">Cancel</button>
                    <form method="POST" action="/questions/{{ $question->id }}">
                        @csrf
                        @method('DELETE')
                        <button id="d-confirm">Delete</button>
                    </form>
                </div>
            </div>
        </div>
        
        <div id="answerDeleteModal" class="modal">
            <div class="delete-modal">
                <div class="modal-c">
                    <ion-icon name="warning-outline"></ion-icon>
                    <div>
                    <h2></h2>
                    <p></p>
                    </div>
                </div>
                <div class="d-buttons">
                    <button id="ad-cancel">Cancel</button>
                    <form method="POST">
                        @csrf
                        @method('DELETE')
                        <button id="ad-confirm"></button>
                    </form>
                </div>
            </div>
        </div>

    </section>
@endsection
