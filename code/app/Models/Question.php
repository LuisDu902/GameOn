<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;


// Added to define Eloquent relationships.
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\DB;

class Question extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'question';

    protected $fillable = [
        'user_id',
        'create_date',
        'title',
        'game_id'
    ];

    /**
     * Get the user that created the question.
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the asnwers to the question.
     */
    public function answers()
    {
        return $this->hasMany(Answer::class);
    }

    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class, 'game_id');
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'question_tag', 'question_id', 'tag_id');
    }
    
    public function versionContent(): HasMany 
    {
        return $this->hasMany(VersionContent::class);
    }

    /**
     * Get the latest question content.
     */
    public function latestContent()
    {
        return $this->versionContent()
        ->orderByDesc('date')
        ->first()
        ->content; 
    }

    public function images() {
        return DB::table('question_file')
        ->select('file_name', 'f_name')
        ->where('question_id', $this->id)
        ->where(function ($query) {
            $query->where('file_name', 'LIKE', '%.png')
                ->orWhere('file_name', 'LIKE', '%.jpeg')
                ->orWhere('file_name', 'LIKE', '%.jpg')
                ->orWhere('file_name', 'LIKE', '%.gif');
        })
        ->get();
    }

    public function documents() {
        return DB::table('question_file')
        ->select('file_name', 'f_name')
        ->where('question_id', $this->id)
        ->where(function ($query) {
            $query->where('file_name', 'LIKE', '%.doc')
                ->orWhere('file_name', 'LIKE', '%.docx')
                ->orWhere('file_name', 'LIKE', '%.pdf')
                ->orWhere('file_name', 'LIKE', '%.txt');
        })
        ->get();
    }
    public function topAnswer(){
        return $this->answers()
        ->orderByDesc('votes')
        ->first();
    }

    public function otherAnswers(){
        $topAnswerId = $this->topAnswer()->id ?? null;

        return $this->answers()
            ->when($topAnswerId, function ($query) use ($topAnswerId) {
                return $query->where('id', '!=', $topAnswerId);
            })->orderByDesc('votes')
            ->get();
    }

    public function timeDifference() {
        $now = now();
        $createdAt = $this->create_date;
        return $now->diffForHumans($createdAt, true);
    }

    public function lastDate()
    {
        return $this->versionContent()
        ->orderByDesc('date')
        ->first()
        ->date; 
    }

    public function lastModification() {
        $now = now();
        $modifiedAt = $this->lastDate();
        return $now->diffForHumans($modifiedAt, true);
    }
}
