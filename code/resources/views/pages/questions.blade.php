@extends('layouts.app')

@section('content')
    @if (session()->has('delete'))
        <div class="notification-box" id="delete-noti"> 
            <ion-icon name="checkmark-circle" id="noti-icon"></ion-icon>
            <div>
                <span> Question deleted!</span>
                <span> {{ session('delete') }} </span>
            </div>
            <ion-icon name="close" id="close-notification" onclick="closeNotification()"></ion-icon>
        </div>
    @endif
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar">
            <ion-icon name="menu"></ion-icon>
        </button>
        <ul class="breadcrumb">
            <li><a href="{{ route('home') }}">
                <ion-icon name="home-outline"></ion-icon> Home</a>
            </li>
            <li> Questions</li>
        </ul>
    </div>
    <section class="questions-sec">
        <div class="questions-actions">
            <div class="questions-sort">
                <button class="selected" id="recent">Recent</button>
                <button id="popular">Popular</button>
                <button id="unanswered">Unanswered</button>
                <div class="filter-dropdown">
                    <div id="filter-questions" onclick="toggleFilterDropDown()">
                        <ion-icon name="funnel"></ion-icon>
                        <span>Filter</span>
                    </div>
                    
                    <div class="filter-content">
                        <label for="tag_id">Tags: </label>
                        <div class="tag-con">
                            <select name="tag_id" id="tag_id" class="form-control" required onchange="addFilterTag()">
                                <option value="" selected>None</option>
                                @foreach($tags as $tag)
                                    <option value="{{ $tag->id }}">{{ $tag->name }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="filter-tags" onclick="removeFilterTag()"></div>
                        <label for="game_id">Games: </label>
                        <select name="game_id" id="game_id" class="form-control" required onchange="addFilterGame()">
                            <option value="">None</option>
                            @foreach($categories as $category)
                                <optgroup label="{{ $category->name }}">
                                    @foreach($category->games as $game)
                                        <option value="{{ $game->id }}">{{ $game->name }}</option>
                                    @endforeach
                                </optgroup>
                            @endforeach
                        </select>
                        <div class="filter-games" onclick="removeFilterGame()"></div>
                        <button class="apply-btn" onclick="applyFilters()">Apply</button>
                    </div>
                </div>
            </div>
            @if (Auth::check())
                <a href="{{ route('questions.create') }}" id="newQuestion">Ask Question</a>
            @else
                <button id="newQuestion" onclick="showLoginModal()">Ask Question</button>
                <div id="loginModal" class="modal">
                    <div class="modal-content">
                        <ion-icon name="warning-outline"></ion-icon>
                        <h2>Authentication required</h2>
                        <p>Please sign up or sign in to continue</p>
                        <div>
                            <a href="{{ route('register') }}">
                                <button>Sign Up</button>
                            </a>
                            <a href="{{ route('login') }}">
                                <button>Sign In</button>
                            </a>
                        </div>
                    </div>
                </div>
            @endif

        </div>
        <div class="questions-list">
            @include('partials._questions')
        <div>
    </section>
@endsection