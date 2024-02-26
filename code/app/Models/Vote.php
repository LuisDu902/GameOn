<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vote extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'vote';

    public function creator() {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function answer() {
        return $this->belongsTo(Answer::class, 'answer_id');
    }

    public function question() {
        return $this->belongsTo(Question::class, 'question_id');
    }
}
