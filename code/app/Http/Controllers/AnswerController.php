<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use App\Models\Answer;
use App\Models\VersionContent;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;

class AnswerController extends Controller
{
    
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $this->authorize('create', Answer::class);

        $request->validate([
            'content' => 'required|string',
            'question_id' => 'required'
        ]);
        
        $answer = Answer::create([
            'user_id' => Auth::id(),
            'question_id' => $request->input('question_id'),
        ]);
      
        $answer->votes = 0;

        VersionContent::create([
            'date' => now(),
            'content' => $request->input('content'),
            'content_type' => 'Answer_content',
            'answer_id' => $answer->id
        ]);

        return view('partials._answer', compact('answer'))->render();
    }


    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Request $request, $id)
    {
        $answer = Answer::findOrFail($id);

        $this->authorize('edit', $answer);

        return view('partials._editAnswer', compact('answer'))->render();
    }

    public function update(Request $request, $id) {
        $request->validate([
            'content' => 'required',
        ]);

        $answer = Answer::findOrFail($id);

        $this->authorize('edit', $answer);

        VersionContent::create([
            'date' => now(),
            'content' => $request->input('content'),
            'content_type' => 'Answer_content',
            'answer_id' => $answer->id
        ]);
        
        return view('partials._answer', compact('answer'))->render();

    }

    /**
     * Remove the specified resource from storage.
     */
    public function delete(Request $request, $id)
    {

        $answer = Answer::find($id);
        
        $this->authorize('delete', $answer);

        $answer->delete();

        return response()->json(["success" => true, 'id' => $id], 200);
    }

    public function vote(Request $request, $answer_id)
    {        
        $reaction = $request->input('reaction');

        $answer = Answer::find($answer_id);
        
        $this->authorize('vote', $answer);

        DB::table('vote')->insert([
            'date' => now(),
            'vote_type' => 'Answer_vote',
            'reaction' => $reaction,
            'answer_id' => $answer_id,
            'user_id' =>  Auth::user()->id,
        ]);

        return response()->json(['action'=> 'vote', 'id' => $answer_id]);
    }


    public function unvote(Request $request, $answer_id)
    {
        $user_id = Auth::user()->id;

        $answer = Answer::find($answer_id);
        
        $this->authorize('vote', $answer);
        
        DB::table('vote')
            ->where('user_id', $user_id)
            ->where('answer_id', $answer_id)
            ->delete();
    
        return response()->json(['action' => 'unvote', 'id' => $answer_id]);
    }

    public function status(Request $request, $answer_id)
    {
        $answer = Answer::findOrFail($answer_id);
        $status = $request->status == 'correct' ? TRUE : FALSE;
        $answer->is_correct = $status;
        $answer->save();
        return response()->json(['status' => $request->status, 'id' => $answer->id]);
    }
}
