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
            <li>my answers</li>
        @else
            <li>{{ $user->username }} answers</li>
        @endif
    </ul>
</div>
<div class="user-answers">
    @if(Auth::check() and (Auth::id() == $user->id))
        <div class="title-user-answers-auth">
            <h1>My Answers </h1>
        </div>
    @else
        <div class="title-user-answers">
            <h1> {{ $user->username }}'s Answers</h1>
        </div>
    @endif

    <div class="answers">
        @if($answers->count() > 0)
            @foreach($answers as $answer)
            <li class="answer-card" id="{{ $answer->id }}">
                <a href="{{ route('question', ['id' => $answer->question_id]) }}" > <span> <strong class="purple">Question</strong>: <span>{{ $answer->question->title }}</span> </span></a>
                <p>{{ $answer->latestContent() }}</p>
                <ul class="answer-stats">
                    <li> Answered {{ $answer->timeDifference() }} ago </li>
                    <li> Modified {{ $answer->lastModification() }} ago </li>
                    <li> {{ $answer->comments->count() }} Comments </li>
                    <li> {{ $answer->votes }} votes </li>
                </ul>
            </li>
            @endforeach
        @else
            <div class="no-questions">
                <img class="no-questions-image" src="{{ asset('images/pikachuConfused.png') }}" alt="Psyduck Image">
                @if(Auth::check() and (Auth::id() == $user->id))
                    <p>You haven't answered any question yet.</p>
                @else
                    <p>{{ $user->username }} haven't answered any question yet.</p>
                @endif
            </div>
        @endif
    </div>

</div>

@endsection
