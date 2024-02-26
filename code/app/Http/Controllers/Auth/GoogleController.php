<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Socialite;
use App\Models\User;
use Auth;
use Illuminate\Support\Facades\Hash;

class GoogleController extends Controller
{
    public function redirectToGoogle()
    {
        return Socialite::driver('google')->redirect();
    }

    public function handleGoogleCallback()
    {
        try {
            $googleUser = Socialite::driver('google')->user();
            $user = User::where('email', $googleUser->email)->first();

            if ($user) {
                Auth::login($user);
                return redirect('/home');
            } else {
                $newUser = User::create([
                    'name' => $googleUser->name,
                    'username' => explode('@', $googleUser->email)[0],
                    'email' => $googleUser->email,
                    'password' => Hash::make('your-random-password'), // Replace with a better random password logic
                    'description' => 'Google user',
                    // other default values
                ]);

                Auth::login($newUser);
                return redirect('/home');
            }
        } catch (Exception $e) {
            dd($e->getMessage());
        }
    }
}
