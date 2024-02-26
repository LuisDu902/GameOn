<?php

namespace App\Http\Controllers;

use App\Models\GameCategory;
use App\Models\Game;
use Illuminate\Http\Request;

class GameCategoryController extends Controller
{
    public function store(Request $request)
    {

        $this->authorize('create', GameCategory::class);

        $request->validate([
            'name' => 'required|max:256',
            'description' => 'required'
        ]);
        
        $gameCategory = GameCategory::create([
            'name' => $request->input('name'),
            'description' => trim($request->input('description'))
        ]);

        return redirect('/categories')->with('create', 'Category successfully created!');
    }
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $categories = GameCategory::all();
        return view('pages.categories', ['title' => 'Categories Page', 'categories' => $categories]);
    }


    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $gameCategory = GameCategory::findOrFail($id);
        return view('pages.category', ['title' => 'Category: ' . $gameCategory->name, 'category' => $gameCategory]);
    }

    public function create()
    {
        $this->authorize('create', GameCategory::class);
        return view('pages.newCategory', ['title' => 'Create New Category Page']);
    }

    public function edit(Request $request, $id) {
        $this->authorize('edit', GameCategory::class);
        $category = GameCategory::findOrFail($id);
        return view('pages.editCategory', ['title' => 'Edit ' . $category->name, 'category'=> $category]);
    }

    public function update(Request $request, $id)
    {
        $this->authorize('edit', GameCategory::class);
        $request->validate([
            'name' => 'required|max:256',
            'description' => 'required'
        ]);

        $category = GameCategory::findOrFail($id);

        $category->name = $request->name;
        $category->description = $request->description;
        
        $category->save();
        
        return redirect("/categories/$id")->with('update', 'Category successfully updated!');
    }


    public function delete(Request $request, $id)
    {
        $this->authorize('delete', GameCategory::class);
        $category = GameCategory::findOrFail($id);
        $category->delete();
        return redirect('/categories')->with('delete', 'Category successfully deleted!');
    }

}
