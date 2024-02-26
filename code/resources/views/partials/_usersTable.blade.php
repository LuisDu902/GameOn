@if ($users->count() > 0)
    <table class="users-table">
        <thead>
            <tr>
                <th></th> <th>Username</th>
                <th>Name</th> <th>Email Address</th>
                <th>Rank</th> <th>Status</th>
                <th>Delete User</th>
            </tr>
        </thead>
        <tbody>
            @foreach($users as $user)
                <x-userinfo :user="$user"/>           
            @endforeach
        </tbody>
    </table>
    {{ $users->links() }}
    <div id="userDeleteModal" class="modal">
        <div class="delete-modal">
            <div class="modal-c">
                <ion-icon name="warning-outline"></ion-icon>
                <div>
                <h2>Delete user</h2>
                <p>Are you sure you want to delete this user? All of its questions, answers and comments will also be permanently removed. This action cannot be undone.</p>
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
        <span>No matching users</span>
    </div>
@endif   