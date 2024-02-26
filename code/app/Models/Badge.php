<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;


// Added to define Eloquent relationships.
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\DB;

class Badge extends Model
{
    use HasFactory;

    public $timestamps  = false;

    protected $table = 'badge';

    protected $fillable = [
        'name',
    ];
    
}
