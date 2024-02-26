@extends('layouts.app')

@section('authentication')

<div class="limiter"> 
    <div class="auth-container">
        <form method="POST" action="{{ route('resetPassword') }}" class="auth-form">
            @csrf
            <h1 id="password-title"> New password </h1>
            <input type="hidden" name="email" value="{{ $email }}">
            @if ($errors->any())
                @foreach ($errors->all() as $error)
                <span class="error">
                    {{ $error }}
                </span>
                @endforeach
            @endif
            <label for="password">Password</label>
            <div class="input-wrapper field">
                <ion-icon class="icon" name="lock-closed"></ion-icon>
                <input class="input" type="password" name="password"
                    placeholder="New Password" required>
            </div>
            <label for="password-confirm">Confirm Password</label>
            <div class="input-wrapper field"> 
                <ion-icon class="icon" name="lock-closed"></ion-icon> 
                <input class="input" type="password" name="password_confirmation" placeholder="Confirm password" required>
            </div> 
            <div class="btn-wrapper">
                <button class="change-btn"> Change </button>
            </div>
        </form>
        
    </div>
</div>

@endsection