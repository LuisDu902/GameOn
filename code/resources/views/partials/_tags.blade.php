<div class="manage-tags">
    @foreach($tags as $tag)
        <div id="tag{{ $tag->id }}" class="tags-actions" data-id="{{ $tag->id }}">
            <span>{{ $tag->name }}</span>  
            <ion-icon name="create" onclick="editChanges()"></ion-icon>
            <ion-icon name="trash" onclick="deleteTag()"> </ion-icon>    
        </div>
    @endforeach
</div>


<div id="tagDeleteModal" class="modal">
    <div class="delete-modal">
        <div class="modal-c">
            <ion-icon name="warning-outline"></ion-icon>
            <div>
            <h2>Delete tag</h2>
            <p>Are you sure you want to delete this tag? This action cannot be undone.</p>
            </div>
        </div>
        <div class="d-buttons">
            <button id="d-cancel">Cancel</button>
            <button id="d-confirm">Delete</button>
        </div>
    </div>
</div>