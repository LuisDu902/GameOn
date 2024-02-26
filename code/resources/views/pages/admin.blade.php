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
            <li> Administration</li>
        </ul>
    </div>
    <section class="admin-sec">
        <div class="admin-actions">
                <button class="selected" id="stats">Statistics</button>
                <button id="admin-users">Users</button>
                <button id="admin-games">Games</button>
                <button id="admin-tags">Tags</button>
                <button id="admin-reports">Reports</button>
        </div>
        <article>
            @include('partials._stats')
        </article>
    </section>
@endsection