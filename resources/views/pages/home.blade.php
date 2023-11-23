@extends('layouts.app')

@section('content')
   <div class="home-bg"></div>
   <div class="main-container">
      <div class="home-intro">
            <div class="app-description">
               <h1>GameOn</h1>
               <p>Join GameOn for a unified gaming haven where conections thrive, knowledge flows, and every contribution shines.</p>
               <h2>Every <strong>gamer</strong> has a tab open to <strong>GameOn</strong></h2>
            </div>
            <img src="../images/panda.png" alt="panda.png">
      </div>
      <div class="home-games">
            <h2>Discover your next <span class="purple">favorite game</span></h2>
            <div class="carousel-view">
               <ion-icon name="chevron-back" id="prev-game"></ion-icon>
               <div class="games-list">
                  <a href="{{ route('game', ['id' => 1]) }}" class="game"><img src="../images/roblox.jpg" alt="game"></a>
                  <a href="{{ route('game', ['id' => 1]) }}" class="game"><img src="../images/roblox.jpg" alt="game"></a>
                  <a href="{{ route('game', ['id' => 1]) }}" class="game"><img src="../images/roblox.jpg" alt="game"></a>
                  <a href="{{ route('game', ['id' => 1]) }}" class="game"><img src="../images/roblox.jpg" alt="game"></a>
                  <a href="{{ route('game', ['id' => 1]) }}" class="game"><img src="../images/roblox.jpg" alt="game"></a>
                  <a href="{{ route('game', ['id' => 1]) }}" class="game"><img src="../images/roblox.jpg" alt="game"></a>
               </div>
               <ion-icon name="chevron-forward" id="next-game"></ion-icon>
            </div>
      </div>
      <div class="features">
            <h2><span class="purple">Premium</span> Features</h2>
            <div class="feature-list">
               <div>
                  <img src="../images/support.png" alt="support">
                  <h3>Fast Support</h3>
                  <p>Get immediate access to the gaming insights you need without delay</p>
               </div>   
               <div>
                  <img src="../images/recognition.png" alt="recognition">
                  <h3>Community Recognition</h3>
                  <p>Gain acknowledgment within the gaming community for your contributions and expertise</p>      
               </div>   
               <div>
                  <img src="../images/explore.png" alt="explore">
                  <h3>Tailored Exploration</h3>
                  <p>Discover personalized gaming insights that match your preferences and style</p>
               </div>   
            </div>
      </div>
      </div>
@endsection

