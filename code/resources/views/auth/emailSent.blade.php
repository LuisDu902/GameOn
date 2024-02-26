@extends('layouts.app')

@section('authentication')

<div class="limiter"> 
    <div class="auth-container">
        <div class="email-sent">
            <h1> Email successfully sent!</h1>
            <ion-icon name="checkmark-circle"></ion-icon>
            <p>Please check your email for further instructions</p>
        </div>
    </div>
</div>

@endsection