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
            <li><a href="{{ route('users_notifications', ['id' => $user->id]) }}">notifications</a></li>
            <li>reports</li>
            @endif
        </ul>
    </div>

    <section class="notifications-section">
        <div class="user-notifications">
            <div class="title-user-notifications-auth">
                <h1>Report Notifications</h1>
            </div>
        </div>
        <div class="notifications">
        @foreach ($notifications as $notification) 
            @if ($notification->notification_type === 'Report_notification')
                @if ($notification->viewed)
                    <div class="notification-wrap Viewd_content">
                @else
                    <div class="notification-wrap Question_content">
                @endif
                        <span class="circle">{{ $notification->notification_type[0] }}</span>
                        <div id="notification-{{ $notification->id }}" class="notification" data-id="{{ $notification->id }}">
                            <a class="notification" href="{{ route('stats') }}">
                                <h2>Report notification</h2>
                                <p class="version-content">A report was made by some user. <span class="type">Check it out</span>!</p>
                                <span class="date">{{ $notification->report->reporter->name }} <span class="type">reported</span> {{ $notification->report->reported->name }} {{ $notification->elapsedTime() }} ago</span> 
                            </a>
                        </div>
                    </div>
            @endif
        @endforeach
        </div>
        {{ $notifications->links() }}
    </section>
@endsection


