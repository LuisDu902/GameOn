@extends('layouts.app')

@section('content')
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar white">
            <ion-icon name="menu"></ion-icon>
        </button>
        <ul class="breadcrumb">
            <li class="white">
                <a href="{{ route('home') }}" class="white"> 
                    <ion-icon name="home-outline" class="white"></ion-icon> Home
                </a>
            </li>
            <li class="white"><a href="{{ route('categories') }}" class="white">Game Categories</a></li>
            <li class="white"> {{ $category->name }}</li>
        </ul>
    </div>
   <article class="category-section">
        @if(session()->has('update'))
            <div class="notification-box" id="delete-noti"> 
                <ion-icon name="checkmark-circle" id="noti-icon"></ion-icon>
                <div>
                    <span> Category updated!</span>
                    <span> {{ session('update') }} </span>
                </div>
                <ion-icon name="close" id="close-notification" onclick="closeNotification()"></ion-icon>
            </div>
        @endif
        <div class="category-section-total" data-cat="{{$category->id}}">
            <h1 class="category-title white">{{ $category->name }}</h1>
            <div class="category-description">
                <div class="category-drop">
                    <h2> Description </h2>   
                    @auth
                        @if (Auth::user()->is_admin && !Auth::user()->is_banned)
                            <div class="c-drop-content">
                                <a href="{{ route('categories.edit', ['id' => $category->id]) }}" id="edit-category">
                                    <ion-icon name="create"></ion-icon>
                                    <span>Edit</span>
                                </a>
                                <div id="delete-category" onclick="showDeleteCategory()">
                                    <ion-icon name="trash"></ion-icon>
                                    <span>Delete</span>
                                </div>
                            </div>
                        @endif
                    @endauth
                </div>
                <p>{{ $category->description }}</p>
            </div>
            <div class="category-games">
                <div class="games-group d-flex flex-row justify-content-between pe-4">
                    <h2> Games </h2>
                    <div class="games-action">
                        @if (Auth::check())
                            @if (Auth::user()->is_admin && !Auth::user()->is_banned)
                                <a href="{{ route('games.create', ['category_id' => $category->id]) }}" id="newQuestion">Create New Game</a>
                            @endif
                        @endif
                    </div>
                </div>
                <div class="games-grid">
                    @if ($category->games->count() > 0)
                        @foreach($category->games as $game)
                            <a href="{{ route('game', ['id' => $game->id]) }}" class="game-card">
                                <img src="{{ $game->getImage() }}" alt="game-image"></img>
                            </a>
                        @endforeach
                    @else
                        <div class="no-games mx-auto">
                            <p>This game category doesn't have any games added yet.</p>
                        </div>
                    @endif
                </div>
            </div>
        </div>  
    </article>

    <div id="deleteModal" class="modal">
        <div class="delete-modal">
            <div class="modal-c">
                <ion-icon name="warning-outline"></ion-icon>
                <div>
                <h2>Delete category</h2>
                <p>Are you sure you want to delete this category? All of its games and members will be permanently removed. This action cannot be undone.</p>
                </div>
            </div>
            <div class="d-buttons">
                <button id="d-cancel">Cancel</button>
                <form method="POST" action="/categories/{{ $category->id }}">
                    @csrf
                    @method('DELETE')
                    <button id="d-confirm">Delete</button>
                </form>
            </div>
        </div>
    </div>
@endsection