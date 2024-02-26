<?php

namespace App\Policies;

use App\Models\GameCategory;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class GameCategoryPolicy
{
    public function create(User $user) {
        return !$user->is_banned && $user->is_admin;
    }

    public function delete(User $user)
    {
        return !$user->is_banned && $user->is_admin;
    }

    public function edit(User $user)
    {
        return !$user->is_banned && $user->is_admin;
    }

}
