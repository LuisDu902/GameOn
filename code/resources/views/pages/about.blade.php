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
            <li> About us</li>
        </ul>
    </div>
   
    <section class="about-section">
        <h1>About us</h1>
        <div class="about-us">
            <h2>We are a team of professional people who loves what they do</h2>
            <p>GameOn is committed to revolutionizing the online gaming landscape by creating a dynamic, unified platform that fosters collaboration, encourages knowledge-sharing, and celebrates gamers' contributions. In a world where information fragmentation and community engagement challenges persist, GameOn aims to be the go-to destination for gamers seeking connection and recognition within the gaming ecosystem.</p>
        </div>
        <div class="team">
            <h1>Meet our team</h1>
            <ul>
                <li>
                    <img src="{{ asset('images/member1.png')}}" alt="member1">
                    <span>Gabriel Ferreira</span>
                </li>
                <li>
                    <img src="{{ asset('images/member2.png')}}" alt="member2">
                    <span>Luís Du</span>
                </li>
                <li>
                    <img src="{{ asset('images/member3.png')}}" alt="member3">
                    <span>Catarina Isabel Canelas</span>
                </li>
                <li>
                    <img src="{{ asset('images/member4.png')}}" alt="member4">
                    <span>Ana Sofia Azevedo</span>
                </li>
            </ul>
      </div>
    </section>
@endsection
