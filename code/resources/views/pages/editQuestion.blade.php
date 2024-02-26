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
            <li><a href="{{ route('question', ['id' => $question->id]) }}">{{ $question->id }}</a></li>
            <li>Edit</li>
        </ul>
    </div>
    <div class="edit-question-form">
        <form method="POST" enctype='multipart/form-data' data-id="{{ $question->id }}">
            @csrf
            <div class="form-group">
                <label for="title">Title <span>*</span></label>
                <textarea name="title" id="title" class="form-control" placeholder="Question title..." required>{{ $question->title }}</textarea>
            </div>
            
            <div class="form-group">
                <label for="content">Description <span>*</span></label>
                <textarea name="content" id="content" class="form-control" placeholder="Question description..." required>{{ $question->latestContent() }}</textarea>
            </div>
            
            <div class="form-grid">
                <label for="game">Game: </label>
                <select name="game_id" id="game_id" class="form-control" required>
                    <option value="0" @if(!$question->game_id) selected @endif>None</option>
                    @foreach($categories as $category)
                        <optgroup label="{{ $category->name }}">
                            @foreach($category->games as $game)
                                <option value="{{ $game->id }}" @if($game->id == $question->game_id) selected @endif>{{ $game->name }}</option>
                            @endforeach
                        </optgroup>
                    @endforeach
                </select>
                <label for="tags">Tags: </label>
                <div class="tag-con">
                    <select name="tag_id" id="tag_id" class="form-control" required>
                        <option value="None" selected>None</option>
                        @foreach($tags as $tag)
                            <option value="{{ $tag->id }}">{{ $tag->name }}</option>
                        @endforeach
                    </select>
                    <div class="tag-btns">
                        <button id="create-tag">Create new tag</button>
                    </div>
                </div>
                <div class="new-tags">
                    @foreach ($question->tags as $tag)
                        <div class="new-tag" data-tagid="{{ $tag->id }}">
                            <span>{{ $tag->name }}</span>
                            <ion-icon name="close-circle"></ion-icon>
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="upload-files">
                <label for="file">Select Files:</label>
                <input type='file' name='files[]' id="file" multiple hidden>
                <button id="up-f">Select</button>
            </div>
            <div id="file-info">Valid file types: .jpg, .png, .pdf, .gif, .doc, .docx</div>
            <div class="question-files">
                @foreach($question->documents() as $document)
                    <div class="q-file" data-filename="{{ $document->f_name }}">
                        <ion-icon name="document"></ion-icon>
                        <a href="{{ asset('question/' . $document->file_name) }}" download="{{ asset('question/' . $document->file_name) }}">
                            <span>{{ $document->f_name }}</span>
                        </a>
                        <ion-icon class="close" name="close-circle"></ion-icon>
                    </div>
                @endforeach
            </div>
            <div class="question-img">
                @foreach($question->images() as $image)
                    <div data-filename="{{ $image->f_name }}">
                        <img src="{{ asset('question/' . $image->file_name) }}" alt="{{ $image->f_name }}">
                        <ion-icon name="close-circle"></ion-icon>
                    </div>
                @endforeach
            </div>

            <button type="submit" id="save-question">Save changes</button>
        </form>
    </div>
@endsection
