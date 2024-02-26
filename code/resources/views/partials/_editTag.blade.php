<div id="tag{{ $tag->id }}" class="edit-tag" data-id="{{ $tag->id }}">
    <input type="text" value="{{ $tag->name }}">
    <ion-icon name="close-circle-outline" class="cancel" onclick="restoreTag()"></ion-icon>
    <ion-icon name="checkmark-circle-outline" class="confirm" onclick="updateTag()"></ion-icon>
</div>
    
