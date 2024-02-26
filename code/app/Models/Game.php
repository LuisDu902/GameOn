<?php

namespace App\Models;

use App\Http\Controllers\FileController;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Game extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'game';

    protected $fillable = [
        'name',
        'description',
        'nr_members',
        'game_category_id',
    ];

    public function members()
    {
        return $this->belongsToMany(User::class, 'game_member', 'game_id', 'user_id');
    }

    public function answers()
    {
        return $this->hasManyThrough(Answer::class, Question::class)
            ->selectRaw('game_id, COUNT(answer.id) as total_answers')
            ->groupBy('game_id');
    }

    public function questions()
    {
        return $this->hasMany(Question::class);
    }

    public function votes(){
        return $this->hasMany(Question::class)
            ->selectRaw('game_id, SUM(votes) as total_votes')
            ->groupBy('game_id');
    }

    public function category()
    {
        return $this->belongsTo(GameCategory::class, 'game_category_id');
    }

    public function getImage() {
        return FileController::get('game', $this->id);
    }    
}
