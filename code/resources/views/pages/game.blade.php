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
            <li class="white"><a href="{{ route('category', ['id' => $game->category->id]) }}" class="white">{{ $game->category->name }}</a></li>
            <li class="white"> {{ $game->name }}</li>
        </ul>
    </div>

   <article class="game">
        <img src="{{ $game->getImage() }}" alt="game image" class="game-img">
        @if(session('status'))
            <div id="myModal" class="modal">
                <div class="modal-content">
                    <span class="close" onclick="closeModal()">&times;</span>
                    <p id="popup-message"></p>
                </div>
            </div>
            <script>
                var userJoined = @json(session('user_joined'));
                function showModal(message) {
                    var modal = document.getElementById('myModal');
                    document.getElementById('popup-message').innerText = message;
                    modal.style.display = 'block';
                }

                function closeModal() {
                    var modal = document.getElementById('myModal');
                    modal.style.display = 'none';
                }

                if (userJoined) {
                    showModal("You have joined the game!");
                    document.getElementById('joinGame').innerText = "Leave Game";
                } else {
                    showModal("You have left the game!");
                    document.getElementById('joinGame').innerText = "Join Game";
                }
            </script>
        @endif

        <div class="flex">
            <h1>{{ $game->name }}</h1>
            @auth
                @if(session('user_joined'))
                    <a href="{{ route('join.game', ['game' => $game->id]) }}" id="joinGame">Leave Game</a>
                @else
                    <a href="{{ route('join.game', ['game' => $game->id]) }}" id="joinGame">Join Game</a>
                @endif
            @endauth
        </div>
        <p class="g-desc">{{ $game->description }}</p>
        <ul class="g-stats">
            <li> {{ $game->members->count() }} Members </li>
            <li> {{ $game->questions->count() }} Question </li>
            <li> {{ $game->answers->first()->total_answers ?? 0 }} Answers </li>
            <li> {{ $game->votes->first()->total_votes ?? 0 }} Votes </li>
        </ul>
       
        <h2 class="q">Questions</h2>
        </div>
        <div class="questions-list">
            @include('partials._questions', ['questions' => $questions])
            {{ $questions->links() }}
        <div>
    </article>
   
@endsection