<?php

namespace App\Http\Controllers;

use App\Models\Tag;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TagController extends Controller
{
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'name' => 'required|string|unique:tag|max:255',
            ]);

            $tag = Tag::create([
                'name' => $validatedData['name'],
            ]);
    
            return response()->json(['message' => 'Tag created successfully', 'id' => $tag->id, 'name' => $tag->name]);
        } catch (ValidationException $e) {
            return response()->json(['error' => $e->errors()], 422);
        }
    
    }

    public function edit($id) {
        $this->authorize('edit', Tag::class);
        $tag = Tag::findOrFail($id);
        return view('partials._editTag', compact('tag'))->render();
    }

    public function delete(Request $request, $id) {
        $this->authorize('delete', Tag::class);
        $tag = Tag::findOrFail($id);
        $tag->delete();
        return response()->json(['id' => $tag->id ]); 
    }

    public function update(Request $request, $id) {
        try {
            $tag = Tag::findOrFail($id);
            $request->validate([
                'name' => 'required|string|unique:tag|max:255',
            ]);
    
            $tag->name = $request->name;
    
            $tag->save();
    
            return response()->json(['id' => $tag->id, 'name' => $tag->name ]); 
        }
        catch (ValidationException $e) {
            return response()->json(['error' => $e->errors()], 422);
        }
    }

}
