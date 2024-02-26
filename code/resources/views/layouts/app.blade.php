<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- CSRF Token -->
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ $title }}</title>
        <link rel="icon" type="image/png" href="{{ asset('images/logo.png') }}">
        <!-- Styles -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
        <link href="{{ url('css/app.css') }}" rel="stylesheet">
        <link href="{{ url('css/navbar.css') }}" rel="stylesheet">
        <link href="{{ url('css/auth.css') }}" rel="stylesheet">
        <link href="{{ url('css/sidebar.css') }}" rel="stylesheet">
        <link href="{{ url('css/footer.css') }}" rel="stylesheet">
        <link href="{{ url('css/breadcrumb.css') }}" rel="stylesheet">
        <link href="{{ url('css/profile.css') }}" rel="stylesheet">
        <link href="{{ url('css/questions.css') }}" rel="stylesheet">
        <link href="{{ url('css/pagination.css') }}" rel="stylesheet">
        <link href="{{ url('css/user.css') }}" rel="stylesheet">
        <link href="{{ url('css/category.css') }}" rel="stylesheet">
        <link href="{{ url('css/report.css') }}" rel="stylesheet">
        <link href="{{ url('css/game.css') }}" rel="stylesheet">
        <link href="{{ url('css/home.css') }}" rel="stylesheet">
        <link href="{{ url('css/question.css') }}" rel="stylesheet">
        <link href="{{ url('css/faq.css') }}" rel="stylesheet">
        <link href="{{ url('css/activity.css') }}" rel="stylesheet">
        <link href="{{ url('css/static.css') }}" rel="stylesheet">
        <link href="{{ url('css/admin.css') }}" rel="stylesheet">
        <link href="{{ url('css/notifications.css') }}" rel="stylesheet">


        <script src="{{ url('js/app.js') }}" defer></script>
        <script src="{{ url('js/admin.js') }}" defer></script>
        <script src="{{ url('js/editprofile.js') }}" defer></script>
        <script src="{{ url('js/question.js') }}" defer></script>
        <script src="{{ url('js/answer.js') }}" defer></script>
        <script src="{{ url('js/comment.js') }}" defer></script>
        <script src="{{ url('js/carousel.js') }}" defer></script>
        <script src="{{ url('js/dropdown.js') }}" defer></script>
        <script src="{{ url('js/faq.js') }}" defer></script>
        <script src="{{ url('js/game.js') }}" defer></script>
        <script src="{{ url('js/report.js') }}" defer></script>
    
        <script nomodule
            src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"
            defer>
        </script>
        
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>    
    </head>
    <body>
        @if(in_array(request()->route()->getName(), ['login', 'register', 'recover', 'newPassword', 'emailSent']))
            @yield('authentication')
        @else
            @include('layouts.header')
            <div class="notification-box"> 
                <ion-icon name="checkmark-circle" id="noti-icon" ></ion-icon>
                <div>
                    <span></span>
                    <span></span>
                </div>
                <ion-icon name="close" id="close-notification"></ion-icon>
            </div>
            @if(in_array(request()->route()->getName(), ['category', 'game']))
                <div class="purple-section"></div>
            @endif
            <main>
                @yield('content')
            </main>
            @include('layouts.footer')
        @endif
        
        <script type="module"
            src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
        <script nomodule
            src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    </body>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</html>