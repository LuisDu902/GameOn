<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Comment extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'comment';

    protected $fillable = [
        'user_id',
        'answer_id',
        'is_public',
    ];

    public function creator() {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function answer() {
        return $this->belongsTo(Answer::class, 'answer_id');
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


    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

}
