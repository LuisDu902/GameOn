<header>
    <nav class="navbar">
        <a class="logo" href="{{ route('home') }}">
            <img src="{{ asset('images/white_logo.png') }}" alt="logo">
            <strong>GameOn</strong>
        </a>
        <ul class="nav-links">
            <li><a href="{{ route('questions') }}">Questions</a></li>
            <li><a href="{{ route('categories') }}">Game Categories</a></li>
        </ul>

        <form class="search-box" method="GET" action="{{ route('questions.search') }}">
            @csrf
            <input type="text" id="search-input" name="query"
                placeholder="Search for posts...">
            <button type="submit" id="search-button" >
                <ion-icon name="search"></ion-icon>
            </button>
        </form>

        @if (Auth::check())
        <div class="left">
            @if (Auth::user()->is_admin && !Auth::user()->is_banned)
                <a href="{{ route('stats') }}" class="admin">
                    Admin Section
                </a>
            @endif

            <a href="{{ route('users_notifications', ['id' => Auth::user()->id]) }}"class="notifications">
                <ion-icon name="notifications"></ion-icon>
                @php
                    $unreadCount = (new \App\Http\Controllers\UserController())->getUnreadNotificationCount();
                @endphp
            </a>
            @if ($unreadCount > 0)
                <span class="notification-count">
                    {{ $unreadCount }}
                </span>
            @endif

            <div class="dropdown">
                
                <div class="user">
                    <img src="{{ Auth::user()->getProfileImage() }}" alt="user-profile">
                    <strong class="username white"> {{ Auth::user()->username }} </strong>
                    <button class="dropbtn white">
                        <ion-icon name="chevron-down"></ion-icon>
                    </button>
                </div>
                <div class="dropdown-content">
                    <a href="{{ route('profile', ['id' => Auth::user()->id]) }}">
                        <ion-icon name="person-circle"></ion-icon>
                        <span>Profile</span>
                    </a>
                    <a href="{{ route('users_questions', ['id' => Auth::user()->id]) }}">
                        <ion-icon name="help-circle"></ion-icon>
                        <span> My Questions</span>
                    </a>
                    <a href="{{ route('users_answers', ['id' => Auth::user()->id]) }}">
                    <ion-icon name="book"></ion-icon>
                        <span> My Answers</span>
                    </a>
                    <a href="{{ route('users_notifications', ['id' => Auth::user()->id]) }}">
                        <ion-icon name="notifications"></ion-icon>
                        <span> Notifications</span>
                        @php
                            $unreadCount = (new \App\Http\Controllers\UserController())->getUnreadNotificationCount();
                        @endphp
                        @if ($unreadCount > 0)
                        <span class="notification-count">
                            {{ $unreadCount }}
                        </span>
                        @endif
                    </a>
                    <a href="{{ url('/logout') }}">
                        <ion-icon name="log-out"></ion-icon>
                        <span> Sign out</span>
                    </a>
                </div>
            </div>
        </div>
        @else
            <div class="buttons">
                <a href="{{ route('register') }}">
                    <button class="sign-up-btn">Sign Up</button></a>
                <a href="{{ route('login') }}">
                    <button class="sign-in-btn">Sign In</button></a>
            </div>
        @endif
        

    </nav>
</header>



              