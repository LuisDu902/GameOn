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
            <li >Game Categories</li>
        </ul>
   </div>

   <section class="categories-section">
        @if (session()->has('create'))
            <div class="notification-box" id="delete-noti"> 
                <ion-icon name="checkmark-circle" id="noti-icon"></ion-icon>
                <div>
                    <span> Category created!</span>
                    <span> {{ session('create') }} </span>
                </div>
                <ion-icon name="close" id="close-notification" onclick="closeNotification()"></ion-icon>
            </div>
        @elseif (session()->has('delete'))
            <div class="notification-box" id="delete-noti"> 
                <ion-icon name="checkmark-circle" id="noti-icon"></ion-icon>
                <div>
                    <span> Category deleted!</span>
                    <span> {{ session('delete') }} </span>
                </div>
                <ion-icon name="close" id="close-notification" onclick="closeNotification()"></ion-icon>
            </div>
        @endif
        <div class="categories-group d-flex flex-row justify-content-between pe-4">
            <h1>Game Categories</h1>
            <div class="categories-action">
                @if (Auth::check())
                    @if (Auth::user()->is_admin && !Auth::user()->is_banned)
                        <a href="{{ route('categories.create') }}" id="newQuestion">Create New Category</a>
                    @endif
                @endif
            </div>
        </div>
        <section class="categories-grid">
            @foreach($categories as $category)
                <a href="{{ route('category', ['id' => $category->id]) }}" class="category-card" id="{{ $category->name }}">
                    <h2><span class="purple">{{ $category->name }}</span> games</h2>
                    <p class="text-break">{{ $category->description }}</p>
                </a>
            @endforeach
        </section>
   </section>
@endsection