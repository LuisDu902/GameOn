<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Comment;

use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Support\Facades\Auth;

class CommentPolicy {

    use HandlesAuthorization;

    public function delete(User $user, Comment $comment)
    {
      if($user->is_admin) return true;
      return $user->id == $comment->user_id;
    }

    public function edit(User $user, Comment $comment)
    {
        return $user->id === $comment->user_id;
    }

}