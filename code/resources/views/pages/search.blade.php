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
            <li> Search Results</li>
        </ul>
    </div>
    <section class="questions-sec">
        <h1>Search results</h1>
        <div class="questions-list">
            @include('partials._questions')
        <div>
    </section>
@endsection
