<?php

namespace App\Providers;

// use Illuminate\Support\Facades\Gate;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        'App\Models\User' => 'App\Policies\UserPolicy',
        'App\Models\Question' => 'App\Policies\QuestionPolicy',
        'App\Models\Answer' => 'App\Policies\AnswerPolicy',
        'App\Models\Comment' => 'App\Policies\CommentPolicy'
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void {
        $this->registerPolicies();
    }
}