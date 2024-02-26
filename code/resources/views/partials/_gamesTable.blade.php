@if ($games->count() > 0)
    <table class="games-table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Active Members</th> <th>Edit Game</th>
                <th>Delete Game</th>
            </tr>
        </thead>
        <tbody>
            @foreach($games as $game)
                <x-gameinfo :game="$game"/>           
            @endforeach
        </tbody>
    </table>
    {{ $games->links() }}
    <div id="gameDeleteModal" class="modal">
        <div class="delete-modal">
            <div class="modal-c">
                <ion-icon name="warning-outline"></ion-icon>
                <div>
                <h2>Delete game</h2>
                <p>Are you sure you want to delete this game? This action cannot be undone.</p>
                </div>
            </div>
            <div class="d-buttons">
                <button id="ad-cancel">Cancel</button>
                <button id="ad-confirm">Delete</button>
            </div>
        </div>
    </div>
@else
    <div class="no-records">
        <img src="{{ asset('images/nothing.png') }}" alt="nothing">
        <span>No matching games</span>
    </div>
@endif   