@extends('layouts.app')

@section('authentication')

<div class="limiter"> 
    <div class="auth-container"> 
        <form method="POST" action="{{ route('register') }}" class="auth-form">
  
            {{ csrf_field() }}
            <h1>User Register</h1>
            @if ($errors->any())
                @foreach ($errors->all() as $error)
                    <span class="error">
                        {{ $error }}
                    </span>
                @endforeach
            @endif
            <label for="name">Name</label>
            <div class="input-wrapper field"> 
                <ion-icon class="icon" name="person"></ion-icon> 
                <input class="input" type="text" name="name" placeholder="Full name" value="{{ old('name') }}" required> 
            </div> 
            
            <label for="username">Username</label>
            <div class="input-wrapper field"> 
                <ion-icon class="icon" name="person"></ion-icon> 
                <input class="input" type="text" name="username" placeholder="Username" value="{{ old('user name') }}" required> 
            </div> 

            <label for="email">Email</label>
            <div class="input-wrapper field">
                <ion-icon class="icon" name="mail"></ion-icon> 
                <input class="input" type="email" name="email" placeholder="Email" value="{{ old('email') }}" required>
            </div>

            <label for="password">Password</label>
            <div class="input-wrapper field"> 
                <ion-icon class="icon" name="lock-closed"></ion-icon>
                <input class="input" type="password" name="password" placeholder="Password" required> 
            </div>

            <label for="password-confirm">Confirm Password</label>
            <div class="input-wrapper field"> 
                <ion-icon class="icon" name="lock-closed"></ion-icon> 
                <input class="input" type="password" name="password_confirmation" placeholder="Confirm password" required>
            </div> 
            
            <div class="btn-wrapper">
                <button class="register-btn"> Register </button>
            </div>

            <div class="toggle-register">
                <span> Already registered?
                    <a href="{{ route('login') }}" class="toggle-register"> Login </a>
                </span>
            </div> 
        </form>
    </div> 
</div>

@endsection