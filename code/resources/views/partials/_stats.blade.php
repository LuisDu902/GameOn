<section class="stats-section">
    <div class="stat-box" id="n-questions"> 
        <ion-icon name="help-circle"></ion-icon>
        <div>
            <span>Total questions</span>
            <p>{{ $stats['num_questions'] }}</p>
        </div>
    </div>
    <div class="stat-box" id="n-answers"> 
        <ion-icon name="book"></ion-icon>
        <div>
            <span>Total answers</span>
            <p>{{ $stats['num_answers'] }}</p>
        </div>
    </div> 
    <div class="stat-box" id="n-comments"> 
        <ion-icon name="chatbox-ellipses"></ion-icon>
        <div>
            <span>Total comments</span>
            <p>{{ $stats['num_comments'] }}</p>
        </div>
    </div>
    <div id="question-stats">
        <span>Questions created (last 12 months)</span>
        <canvas id="question-chart"></canvas>
    </div>
    <div id="top-games">
        <span>Most popular games</span>
        <canvas id="game-chart"></canvas>
    </div>
    <div id="user-stats">
        <span>User distribution</span>
        <canvas id="user-chart"></canvas>
        <h3>{{ $stats['num_users'] }}</h3>
    </div>
    <div id="categories-stats">
        <span>Game categories</span>
        <canvas id="categories-chart"></canvas>
    </div>
    
</section>