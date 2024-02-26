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
            <li><a href="{{ route('profile', ['id' => $user->id]) }}">{{ $user->username }}</a></li>
            @if(Auth::check() and (Auth::id() == $user->id))
                <li>my questions</li>
            @else
                <li>{{ $user->username }} questions</li>
            @endif
        </ul>
    </div>
    <div class="user-questions">
        @if(Auth::check() and (Auth::id() == $user->id))
            <div class="title-user-questions-auth">
                <h1>My Questions </h1>
            </div>
        @else
            <div class="title-user-questions">
                <h1> {{ $user->username }}'s Questions</h1>
            </div>
        @endif

        <div class="questions">
            @include('partials._questions', ['questions' => $questions])
        </div>
    </div>


@endsection