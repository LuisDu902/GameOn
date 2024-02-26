@extends('layouts.app')

@section('content')
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar">
            <ion-icon name="menu"></ion-icon>
        </button>
        <ul class="breadcrumb">
            <li>
                <a href="{{ route('home') }}"> 
                    <ion-icon name="home-outline"></ion-icon> Home
                </a>
            </li>
            <li><a href="{{ route('categories') }}">Game Categories</a></li>
            <li><a href="{{ route('category', ['id' => $category->id]) }}"> {{ $category->name }}</a></li>
            <li>Create Game</li>
        </ul>
    </div>
    <section class="game-section">
        <div class="new-game-form" data-id="{{$category->id}}">
            <form action="{{ route('games.store', ['category_id' => $category->id]) }}" method="POST" enctype="multipart/form-data">
                @csrf
                <div class="form-group">
                    <label for="name">Game Title <span>*</span></label>
                    <textarea name="name" id="name" class="form-control" placeholder="Game title..." required></textarea>
                </div>
                
                <div class="form-group">
                    <label for="description">Description <span>*</span></label>
                    <textarea name="description" id="description" class="form-control" placeholder="Game description..." required></textarea>
                </div>
                <div class="upload-files">
                    <label for="file">Select image:</label>
                    <input type='file' id="file" accept="image/*" hidden>
                    <button id="up-image">Select</button>
                </div>
                <img src="{{ asset('/game/default.png') }}" alt="default game">
                <button type="submit" id="create-game" onclick="createGame()">Create Game</button>
            </form>
        </div>
    </section>
@endsection
