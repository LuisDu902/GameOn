<?php

namespace App\Http\Controllers;

use App\Models\Game;
use Illuminate\Http\Request;

class StaticController extends Controller
{
    public function home(){
        $games = Game::inRandomOrder()->limit(5)->get();
        return view('pages.home', ['title' => 'Home Page', 'games' => $games]);
    }
    
    public function faq(){
        return view('pages.faq', ['title' => 'FAQ Page', ]);
    }

    public function about(){
        return view('pages.about', ['title' => 'About us Page', ]);
    }

    public function contact(){
        return view('pages.contact', ['title' => 'Contact us Page'] );
    }
}
