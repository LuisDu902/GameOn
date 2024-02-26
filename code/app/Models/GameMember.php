<?php
// app/Models/GameMember.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GameMember extends Model
{
    protected $table = 'game_member';

    public $timestamps = false;

    protected $fillable = ['user_id', 'game_id'];

    public function getKey()
    {
        return $this->attributes['user_id'] . '-' . $this->attributes['game_id'];
    }

    public function getIncrementing()
    {
        return false;
    }
}
