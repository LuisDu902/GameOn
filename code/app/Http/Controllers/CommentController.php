<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\VersionContent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CommentController extends Controller
{

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'content' => 'required|string',
            'answer_id' => 'required'
        ]);

        $comment = Comment::create([
            'user_id' => Auth::id(),
            'answer_id' => $request->input('answer_id'),
        ]);

        VersionContent::create([
            'date' => now(),
            'content' => $request->input('content'),
            'content_type' => 'Comment_content',
            'comment_id' => $comment->id
        ]);

        return view('partials._comment', compact('comment'))->render();
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Request $request, $id)
    {
        $comment = Comment::findOrFail($id);
        $this->authorize('edit', $comment);
        return view('partials._editComment', compact('comment'))->render();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'content' => 'required',
        ]);

        $comment = Comment::findOrFail($id);
        $this->authorize('edit', $comment);

        VersionContent::create([
            'date' => now(),
            'content' => $request->input('content'),
            'content_type' => 'Comment_content',
            'comment_id' => $comment->id
        ]);
        
        return view('partials._comment', compact('comment'))->render();
    }

    public function delete(Request $request, $id)
    {
        $comment = Comment::findOrFail($id);
        $this->authorize('delete', $comment);
        $comment->delete();
        return response()->json(['id' => $id]);
    }
}
