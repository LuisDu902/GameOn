@extends('layouts.app')

@section('authentication')

<div class="limiter"> 
    <div class="auth-container">
        <form method="POST" action="{{ route('recoverPassword') }}"class="auth-form">
            @csrf
            <h1 id="forget-title"> Forgot Password </h1>
            <div id="forget-text"><span> Enter your email address</span></div>
            @if (session('error'))
                <span class="no-user-email">
                    {{ session('error') }}
                </span>
            @endif
            <div class="input-wrapper field">
                <ion-icon class="icon" name="person"></ion-icon>
                <input class="input" type="email" name="email" placeholder="Email"
                    required>
            </div>
          
            <div class="btn-wrapper">
                <button class="continue-btn"> Continue </button>
            </div>
        </form>
    </div>
</div>

@endsection