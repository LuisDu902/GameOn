@extends('layouts.app')

@section('content')
    @if (session()->has('sent'))
        <div class="notification-box" id="delete-noti"> 
            <ion-icon name="checkmark-circle" id="noti-icon"></ion-icon>
            <div>
                <span> Email sent!</span>
                <span> Thanks for contacting us! </span>
            </div>
            <ion-icon name="close" id="close-notification" onclick="closeNotification()"></ion-icon>
        </div>
    @endif
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar">
            <ion-icon name="menu"></ion-icon>
        </button>
        <ul class="breadcrumb">
            <li><a href="{{ route('home') }}">
                <ion-icon name="home-outline"></ion-icon> Home</a>
            </li>
            <li> Contact us</li>
        </ul>
    </div>
   
    <section class="contact-section">
        
        <h1>Contact us</h1>
        <div class="contact-wrapper">
            <div>
                <p>Let’s talk about your website or project.
                    Send us a message and we will be in touch within two business days.</p>
                <img src="{{ asset('images/contact.png') }}" alt="contact-image">
            </div>
            
            <form id="contactForm" method="POST" action="{{ route('contact') }}">
                {{ csrf_field() }}
                <div class="contact-input">
                    <label class="field-label" for="contact-name"> Name <span
                            class="purple">*</span> </label>
                    <input id="contact-name" type="text" name="name" placeholder="Your name"
                        required>
                </div>
    
                <div class="contact-input">
                    <label class="field-label" for="contact-email"> Email Address
                        <span class="purple">*</span> </label>
                    <input id="contact-email" type="email" name="email"
                        placeholder="Your email address" required>
                </div>
                <div class="contact-input">
                    <label class="field-label" for="content">
                        Message </label>
                        <textarea id="content" name="content" placeholder="Your message"></textarea>
                </div>
                <button type="submit">Submit</button>
            </form>
        </div>
        

    </section>
@endsection
