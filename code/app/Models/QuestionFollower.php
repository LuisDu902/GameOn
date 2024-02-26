<?php
// app/Models/GameMember.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuestionFollower extends Model
{
    protected $table = 'question_followers';

    public $timestamps = false;

    protected $fillable = ['user_id', 'question_id'];

    public function getKey()
    {
        return $this->attributes['user_id'] . '-' . $this->attributes['question_id'];
    }

    public function getIncrementing()
    {
        return false;
    }
}
