@extends('layouts.app')

@section('content')
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar">
            <ion-icon name="menu"></ion-icon>
        </button>

        <ul class="breadcrumb">
            <li><a href="{{ route('home') }}">Home</a></li>
            <li>User Management</li>
        </ul>
    </div>

    <section class="user-manage-section">
        <h1>User Management</h1>
        <nav class="search-bar">
            <div class="filter-condition">
                <ion-icon name="funnel-outline" class="purple"></ion-icon>
                <label> Filter by </label>
                <select name="" class="filter-select" id="filter-user">
                    <option value="username"> username </option>
                    <option value="name"> name </option>
                    <option value="rank"> rank </option>
                    <option value="status"> status </option>
                </select>
            </div>
            <div class="user-search">
                <ion-icon name="search" class="purple"></ion-icon>
                <input id="search-user" type="text" placeholder="Search...">
            </div>

            <div class="order-condition">
                <ion-icon name="swap-vertical" class="purple"></ion-icon>
                <label> Order by </label>
                <select name="" class="order-select" id="order-user">
                    <option value="username"> username </option>
                    <option value="name"> name </option>
                    <option value="rank"> rank </option>
                    <option value="status"> status </option>
                </select>
            </div>
            @if (Auth::user()->is_admin && !Auth::user()->is_banned) 
                <button id="edit-status-btn">Edit</button>
            @endif
        </nav>
      
    
        
        <table class="users-table">
            <thead>
                <tr>
                    <th></th>
                    <th>Username</th>
                    <th>Name</th>
                    <th>Email Address</th>
                    <th>Rank</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @foreach($users as $user)
                <tr class="user-info">
                    <td><img src="../images/user.png" alt="User Image"></td>
                    <td><a href="#">{{ $user->username }}</a></td>
                    <td>{{ $user->name }}</td>
                    <td>{{ $user->email }}</td>
                    <td class="{{ $user->rank }}">{{ $user->rank }}</td>
                    <td>
                    <select name="" class="status hidden {{ $user->is_banned ? 'banned' : 'active' }}" id="user-status" disabled data-user={{ $user->id }}>
                        <option value="active" {{ $user->is_banned ? '' : 'selected' }}>Active</option>
                        <option value="banned" {{ $user->is_banned ? 'selected' : '' }}>Banned</option>
                    </select>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
        {{ $users->links() }}
    </section>
@endsection