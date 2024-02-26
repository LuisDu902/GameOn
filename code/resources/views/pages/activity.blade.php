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
                <li><a href="{{ route('question', ['id' => $question->id]) }}">{{ substr($question->title, 0, 300) }}...</a></li>
            @else
                <li><a href="{{ route('question', ['id' => $question->id]) }}">{{ $question->title }}</a></li>
            @endif
            <li>Activity</li>
        </ul>
    </div>
    <section class="activity-section" data-id="{{ $question->id }}">
        <h1>Post activity</h1>
        <div class="activities">
            @foreach ($contents as $content) 
                <div class="activity-wrap {{ $content['type'] }}">
                    <span class="circle">{{ $content['type'][0]  }}</span>
                    <div class="activity">
                        <span class="action">{{ $content['span'] }} </span>
                        <p class="version-content"> {{ $content['content'] }}</p>
                        <span class="date">
                            <a href="{{ route('profile', ['id' => $content['user_id']] ) }}">{{ $content['user'] }}</a> {{ $content['action'] }} at {{ $content['date']}}</span>
                    </div>
                </div>
            @endforeach
        </div>
    </section>
@endsection

