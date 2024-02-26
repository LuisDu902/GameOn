<?php

namespace App\Policies;

use App\Models\Tag;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class TagPolicy
{
    public function delete(User $user)
    {
        return !$user->is_banned && $user->is_admin;
    }

    public function edit(User $user)
    {
        return !$user->is_banned && $user->is_admin;
    }
}
