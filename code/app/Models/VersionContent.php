<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VersionContent extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'version_content';

    protected $fillable = [
        'date',
        'content',
        'content_type',
        'question_id',
        'answer_id',
        'comment_id',
    ];

    public function question() {
        return $this->belongsTo(Question::class, 'question_id');
    }

    public function answer() {
        return $this->belongsTo(Answer::class, 'answer_id');
    }

    public function comment() {
        return $this->belongsTo(Comment::class, 'comment_id');
    }
}
