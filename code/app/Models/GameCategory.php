<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GameCategory extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'game_category';

    protected $fillable = [
        'name',
        'description',
    ];

    public function games()
    {
        return $this->hasMany(Game::class);
    }

}
