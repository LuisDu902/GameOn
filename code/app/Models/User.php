<?php

namespace App\Models;

use Auth;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Support\Facades\DB;

// Added to define Eloquent relationships.
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;


use App\Http\Controllers\FileController;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'description',
        'rank',
        'badges',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'badges' => 'array',
    ];


    public function questions() : HasMany {
        return $this->hasMany(Question::class);
    }
    public function games() : HasMany {
        return $this->hasMany(Game::class);
    }

    public function answers() : HasMany {
        return $this->hasMany(Answer::class);
    }

    public function notifications() : HasMany {
        return $this->hasMany(Notification::class);
    }

    public function comments() : HasMany {
        return $this->hasMany(Comment::class);
    }

    public function badges(): BelongsToMany
    {
        return $this->belongsToMany(Badge::class, 'user_badge', 'user_id', 'badge_id');
    }

    public function getProfileImage() {
        return FileController::get('profile', $this->id);
    }    

     public function hasVoted($type, $id)
    {
        if ($type === 'question') {
            return DB::table('vote')
                ->where('vote_type', 'Question_vote')
                ->where('question_id', $id)
                ->where('user_id', $this->id)
                ->exists();   
        } else if ($type === 'answer'){
            return DB::table('vote')
                ->where('vote_type', 'Answer_vote')
                ->where('answer_id', $id)
                ->where('user_id', $this->id)
                ->exists();
        }
    }

    public function isFollowing($questionId) {
        $count = DB::table('question_followers')
            ->where('user_id', $this->id)
            ->where('question_id', $questionId)
            ->count();

        return $count > 0; 
    }
    
    public function voteType($type, $id)
    {
        if ($type === 'question') {
            $vote = DB::table('vote')
                ->where('vote_type', 'Question_vote')
                ->where('question_id', $id)
                ->where('user_id', $this->id)
                ->first();
        } else if ($type === 'answer'){
            $vote = DB::table('vote')
                ->where('vote_type', 'Answer_vote')
                ->where('answer_id', $id)
                ->where('user_id', $this->id)
                ->first();
        }
        return $vote ? $vote->reaction : null;
    }
    
}
