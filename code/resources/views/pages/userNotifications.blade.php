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
                <li>notifications</li>
            @endif
        </ul>
    </div>


    <section class="notifications-section">
        <div class="user-notifications">
            <div class="title-user-notifications-auth">
                <h1>Notifications </h1>
            </div>
            @if (Auth::user()->is_admin && !Auth::user()->is_banned)
            <a href="{{ route('users_reports_notifications', ['id' => Auth::user()->id]) }}" id="userReportNotification">Users Reports Notifications</a>
        @endif
        </div>
        <div class="notifications">
        @foreach ($notifications as $notification) 
            @if ($notification->notification_type != 'Report_notification')
                @if ($notification->viewed)
                    <div class="notification-wrap Viewd_content">
                @else
                    <div class="notification-wrap Question_content">
                @endif
                        <span class="circle">{{ $notification->notification_type[0] }}</span>
                        <div id="notification-{{ $notification->id }}" class="notification" data-id="{{ $notification->id }}">
                            @if ($notification->notification_type === 'Question_notification')
                                <a class="notification" href="{{ route('question', ['id' => $notification->answer->question->id]) }}">
                                    <h2>Question notification: "{{ $notification->answer->question->title }}"</h2>
                                    <p class="version-content">A new <span class="type">answer</span> was added to the question you follow.</p>
                                    <p class="version-content">"{{ $notification->answer->latestContent() }}"</p>
                                    <span class="date">{{ $notification->answer->creator->name }} <span class="type">answered</span> at {{ $notification->date }}</span>
                                </a>

                            @elseif ($notification->notification_type === 'Answer_notification')
                                <a class="notification" href="{{ route('question', ['id' => $notification->answer->question_id]) }}">
                                    <h2>Answer notification</h2>
                                    <p class="version-content">"{{ $notification->answer->latestContent() }}"</p>
                                    <span class="date">{{ $notification->answer->creator->name }} <span class="type">answered</span> to your question at {{ $notification->date }}</span>
                                </a>

                            @elseif ($notification->notification_type === 'Comment_notification')
                                <a class="notification" href="{{ route('question', ['id' => $notification->comment->answer->question_id]) }}">
                                    <h2>Comment notification</h2>
                                    <p class="version-content">"{{ $notification->comment->latestContent() }}"</p>
                                    <span class="date">{{ $notification->comment->creator->name }} <span class="type">commented</span> on your answer at {{ $notification->date }}</span>
                                </a>

                            @elseif ($notification->notification_type === 'Rank_notification')
                                <a class="notification" href="{{ route('profile', ['id' => $user->id]) }}">
                                    <h2>Rank notification</h2>
                                    <p class="version-content">You're rank has been updated. <span class="type">Check it out</span>!</p>
                                    <span class="date">At {{ $notification->date }}</span>
                                </a>

                            @elseif ($notification->notification_type === 'Vote_notification')
                                @if ($notification->vote->vote_type === "Question_vote")
                                    <a class="notification" href="{{ route('question', ['id' => $notification->vote->question_id]) }}">
                                        <h2>Vote notification</h2>
                                        <p class="version-content">Someone voted on your <span class="type">question</span></p>
                                        <span class="date">{{ $notification->vote->creator->name }} <span class="type">voted</span> on your question at {{ $notification->date }}</span>
                                    </a>
                                @elseif ($notification->vote->vote_type === "Answer_vote")
                                    <a class="notification" href="{{ route('question', ['id' => $notification->vote->answer->question_id]) }}">
                                        <h2>Vote notification</h2>
                                        <p class="version-content">Someone voted on your <span class="type">answer</span></p>
                                        <span class="date">{{ $notification->vote->creator->name }} <span class="type">voted</span> on your answer at {{ $notification->date }}</span>
                                    </a>
                                @endif

                            @elseif ($notification->notification_type === 'Badge_notification')
                                <a class="notification" href="{{ route('profile', ['id' => $user->id]) }}">
                                    <h2>Badge notification</h2>
                                    <p class="version-content">You have received a new badge. <span class="type">Check them</span> out in your profile page!</p>
                                    <span class="date">At {{ $notification->date }}</span>
                                </a>
                            @elseif ($notification->notification_type === 'Game_notification')
                                <a class="notification" href="{{ route('game', ['id' => $notification->question->game_id]) }}">
                                    <h2>{{$notification->question->game->name}} notification</h2>
                                    <p class="version-content">New content was added to the game you follow. <span class="type">Check it out</span>!</p>
                                    <p class="version-content">"{{ $notification->question->latestContent()}}"</p>
                                    <span class="date">{{ $notification->question->creator->name }} <span class="type">asked</span> at {{ $notification->date }}</span>
                                </a>
                            @endif
                        </div>
                    </div>
            @endif

        @endforeach
        </div>
    </section>
@endsection


