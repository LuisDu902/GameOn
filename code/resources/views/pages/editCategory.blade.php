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
            <li>Create Game Category</li>
        </ul>
    </div>
    <div class="new-gamecategory-form">
        <form action="{{ route('categories.update', ['id' => $category->id]) }}" method="POST">
            @csrf
            @method('PUT')
            <div class="form-group">
                <label for="name">Game Category Title <span>*</span></label>
                <textarea name="name" id="name" class="form-control" placeholder="Game Category title..." required>{{ $category->name }}</textarea>
            </div>
            
            <div class="form-group">
                <label for="description">Description <span>*</span></label>
                <textarea name="description" id="description" class="form-control" placeholder="Game Category description..." required>{{ $category->description }}</textarea>
            </div>

            <button type="submit" id="create-game-category">Save changes</button>
        </form>
    </div>
@endsection
