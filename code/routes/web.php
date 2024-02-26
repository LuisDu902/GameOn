<?php

use App\Http\Controllers\AdminController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\GameCategoryController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\MailController;
use App\Http\Controllers\StaticController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\QuestionController;
use App\Http\Controllers\TagController;
use App\Http\Controllers\FileController;
use App\Http\Controllers\AnswerController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\Auth\GoogleController;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;

use App\Models\User;
use App\Models\Comment;
use Illuminate\Http\Request;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

// Home
Route::redirect('/', '/home');

// Authentication
Route::controller(LoginController::class)->group(function () {
    Route::get('/login', 'showLoginForm')->name('login');
    Route::post('/login', 'authenticate');
    Route::get('/logout', 'logout')->name('logout');
    Route::get('/recover', 'recover')->name('recover');
    Route::post('/newPassword', 'resetPassword')->name('resetPassword');
    Route::get('/newPassword', 'newPassword')->name('newPassword');
    Route::get('/emailSent', 'emailSent')->name('emailSent');
});

Route::controller(RegisterController::class)->group(function () {
    Route::get('/register', 'showRegistrationForm')->name('register');
    Route::post('/register', 'register');
});

Route::controller(MailController::class)->group(function(){
    Route::post('/recoverPassword', 'send')->name('recoverPassword');
    Route::post('/contact', 'contact')->name('contact');
});

// Static pages
Route::controller(StaticController::class)->group(function () {
    Route::get('/home', 'home')->name('home');
    Route::get('/faq', 'faq')->name('faq');
    Route::get('/about', 'about')->name('about');
    Route::get('/contact', 'contact')->name('contactUs');
});

// User
Route::controller(UserController::class)->group(function () {
    Route::get('/users/{id}', 'showUserProfile')->name('profile');
    Route::get('/users/{id}/questions', 'showUserQuestions')->name('users_questions');
    Route::get('/users/{id}/answers', 'showUserAnswers')->name('users_answers');
    Route::get('/users/{id}/notifications', 'showUserNotifications')->name('users_notifications');
    Route::get('/users/{id}/notifications/reports', 'showUserReportsNotifications')->name('users_reports_notifications');
});


// Question
Route::controller(QuestionController::class)->group(function () {
    Route::get('/questions', 'index')->name('questions');
    Route::get('/questions/search', 'search')->name('questions.search');
    Route::get('/questions/create', 'create')->name('questions.create');
    Route::get('/questions/{id}', 'show')->name('question');    
    Route::get('/questions/{id}/edit', 'edit')->name('questions.edit');
    Route::get('/questions/{id}/activity', 'activity')->name('questions.activity');
    Route::delete('/questions/{id}', 'delete')->name('questions.destroy');
});

Route::controller(ReportController::class)->group(function () {
    Route::post('/report', [ReportController::class, 'store'])->name('report.store');
    Route::post('/report2', [ReportController::class, 'store2'])->name('report.store2');
    Route::post('/report3', [ReportController::class, 'store3'])->name('report.store3');
});


// File Storage
Route::controller(FileController::class)->group(function () {
    Route::post('/api/file/upload', 'upload');
    Route::delete('/api/file/delete', 'clear');
});

// Admin Section
Route::controller(AdminController::class)->group(function () {
    Route::get('/statistics', 'stats')->name('stats');
    Route::get('/api/admin/users', 'users');
    Route::get('/api/admin/tags', 'tags');
    Route::get('/api/admin/games', 'games');
    Route::get('/api/admin/charts', 'chart');
    Route::get('/api/admin/reports', 'reports');
    Route::post('/admin/reports/update-status', 'AdminController@updateReportStatus');
});
    

// Game Category
Route::controller(GameCategoryController::class)->group(function () {
    Route::get('/categories', 'index')->name('categories');
    Route::post('/categories', 'store')->name('categories.store');
    Route::get('/categories/create', 'create')->name('categories.create');
    Route::get('/categories/{id}', 'show')->name('category');
    Route::get('/categories/{id}/edit', 'edit')->name('categories.edit');
    Route::delete('/categories/{id}', 'delete')->name('categories.destroy');
    Route::put('/categories/{id}', 'update')->name('categories.update');
});

// Game
Route::controller(GameController::class)->group(function () {
    Route::get('/game/{category_id}/create', 'create')->name('games.create');
    Route::get('/game/{id}', 'show')->name('game');
    Route::get('/game/{id}/edit', 'edit')->name('game.edit');
    Route::get('/join-game/{game}', 'joinGame')->name('join.game');
});


Route::controller(GameController::class)->group(function () {
    Route::get('/api/game', 'search');
    Route::post('/api/game', 'store')->name('games.store');
    Route::delete('/api/game/{id}', 'delete');
    Route::put('/api/game/{id}', 'update');
});


// User API
Route::controller(UserController::class)->group(function () {
    Route::get('/api/users', 'search');
    Route::post('/api/users/{id}', 'updateStatus');
    Route::post('/api/users/{id}/edit', 'edit');
    Route::delete('/api/users/{id}', 'delete')->name('users.destroy');
    Route::post('/api/users/notifications/{id}/viewed', 'viewed');
    Route::post('/api/users/notifications/{notification_id}/viewed', 'UserController@viewed');
});


// Question API
Route::controller(QuestionController::class)->group(function () {
    Route::get('/api/questions', 'list');
    Route::post('/api/questions/{id}/vote', 'vote');
    Route::post('/api/questions/{id}/unvote', 'unvote'); 
    Route::post('/api/questions/{id}/visibility', 'visibility'); 
    Route::post('/api/questions', 'store');
    Route::put('/api/questions/{id}', 'update');
    Route::post('/api/questions/{id}/follow', 'follow');
    Route::post('/api/questions/{id}/unfollow', 'unfollow');

});

// Answer API
Route::controller(AnswerController::class)->group(function () {
    Route::post('/api/answers', 'store');
    Route::get('/api/answers/{id}/edit', 'edit');
    Route::put('/api/answers/{id}', 'update');
    Route::delete('/api/answers/{id}', 'delete');
    Route::post('/api/answers/{id}/vote', 'vote');
    Route::post('/api/answers/{id}/unvote', 'unvote'); 
    Route::post('/api/answers/{id}/status', 'status'); 
});


// Comment API
Route::controller(CommentController::class)->group(function () {
    Route::post('/api/comments', 'store');
    Route::get('/api/comments/{id}/edit', 'edit');
    Route::put('/api/comments/{id}', 'update');
    Route::delete('/api/comments/{id}', 'delete');
});

// Tag API
Route::controller(TagController::class)->group(function () {
    Route::post('/api/tags', 'store');
    Route::get('/api/tags/{id}/edit', 'edit');
    Route::put('/api/tags/{id}', 'update');
    Route::delete('/api/tags/{id}', 'delete');
});

Route::get('/google/redirect', [App\Http\Controllers\Auth\GoogleController::class, 'redirectToGoogle'])->name('google.redirect');
Route::get('/google/callback', [App\Http\Controllers\Auth\GoogleController::class, 'handleGoogleCallback'])->name('google.callback');
