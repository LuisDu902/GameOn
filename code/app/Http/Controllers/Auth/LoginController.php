<?php
 
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

use Illuminate\View\View;
use Illuminate\Support\Facades\Hash;


class LoginController extends Controller
{

    /**
     * Display a login form.
     */
    public function showLoginForm()
    {
        if (Auth::check()) {
            return redirect('/home');
        } else {
            return view('auth.login', ['title' => 'Login Page']);
        }
    }

    /**
     * Handle an authentication attempt.
     */
    public function authenticate(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);
 
        if (Auth::attempt($credentials, $request->filled('remember'))) {
            $request->session()->regenerate();
 
            return redirect()->intended('/home');
        }
 
        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ])->onlyInput('email');
    }

    /**
     * Log out the user from application.
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('home')
            ->withSuccess('You have logged out successfully!');
    } 

    public function recover() {
        return view('auth.recover', ['title' => 'Recover password']);
    }

    public function newPassword(Request $request) {
        $email = $request->input('email');
        return view('auth.newPassword', ['title' => 'New password', 'email' => $email]);
    }

    public function emailSent() {
        return view('auth.emailSent', ['title' => 'Email sent']);
    }

    public function resetPassword(Request $request) {

        $request->validate([
            'password' => 'required|min:8|confirmed', 
        ]);
        
        $user = User::where('email', $request->email)->first();

        $user->password = Hash::make($request->password);

        $user->save();
        
        return redirect()->route('login')->with('success', 'Password reset successful!');
    }   
}
