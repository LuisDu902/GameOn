<?php

namespace App\Policies;

use App\Models\Answer;
use App\Models\User;

use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Support\Facades\Auth;

class AnswerPolicy {

    use HandlesAuthorization;

    public function create(User $user) {
      return !$user->is_banned;
    }

    public function view(?User $user, Answer $answer) {
      if ($answer->is_public || $user->is_admin) return true;
      return $user->id == $answer->user_id;
    }

    public function delete(User $user, Answer $answer)
    {
      if($user->is_admin) return true;
      return $user->id == $answer->user_id;
    }

    public function edit(User $user, Answer $targetAnswer)
    {
        return $user->id === $targetAnswer->user_id;
    }

    public function vote(User $user, Answer $answer)
    {
        return $user->id !== $answer->user_id;
    }
}