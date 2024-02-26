@if ($reports->count() > 0)
    <table class="users-table" id="report-page">
        <thead>
            <tr>
                <th></th> <th>Reporter</th>
                <th>Reported</th> <th>Explanation</th>
                <th>Reason</th> <th>Status</th>
            </tr>
        </thead>
        <tbody>
            @foreach($reports as $report)
                <x-reportinfo :report="$report"/>           
            @endforeach
        </tbody>
    </table>
    {{ $reports->links() }}
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
        <span>There are no reports</span>
    </div>
@endif   