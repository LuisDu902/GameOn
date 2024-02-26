<?php

namespace App\Http\Controllers;
use Illuminate\Auth\Authenticatable;
use Illuminate\Support\Facades\DB;
use App\Models\Question;
use App\Models\Answer;
use App\Models\VersionContent;
use App\Models\Comment;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\GameCategory;
use App\Models\Tag;
use Illuminate\Support\Facades\Auth;

class QuestionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        if (!(auth()->check() && Auth::user()->is_admin)) {
            $questions = Question::where('is_public', true)
            ->orderBy('create_date', 'desc')
            ->paginate(10);
        } else {
            $questions = Question::orderBy('create_date', 'desc')
            ->paginate(10);
        }
       
        $categories = GameCategory::all();
        $tags = Tag::all();
        return view('pages.questions', ['title' => 'Questions Page', 'questions' => $questions, 'categories' => $categories, 'tags' => $tags]);
    }

    public function list(Request $request) 
    {
        $criteria = $request->input('criteria', '');
        $tags = explode(',', $request->tags);
        $games = explode(',', $request->games);

        if (!(auth()->check() && Auth::user()->is_admin)) {
            $query = Question::where('is_public', true);
        } else {
            $query = Question::query();
        }

        if (!empty($request->games)) {
            $query->whereIn('game_id', $games);
        }
        
        if (!empty($request->tags)) {
            $query->whereHas('tags', function ($q) use ($tags) {
                $q->whereIn('tag_id', $tags);
            });
        }

        switch ($criteria) {
            case 'popular':
                $query->orderBy('votes', 'desc');
                break;
            case 'unanswered':
                $query->where('is_solved', false)
                    ->orderBy('create_date', 'desc');
                break;
            default:
                $query->orderBy('create_date', 'desc');
                break;
        }
        
        $questions = $query->paginate(10);

        return view('partials._questions', compact('questions'))->render();
    }
    public function search(Request $request)
    {
        $query = $request->input('query');
      
        if (!(auth()->check() && Auth::user()->is_admin)) {
            $questions = Question::whereRaw('tsvectors @@ plainto_tsquery(?)', [$query])
                ->orderByRaw('ts_rank(tsvectors, plainto_tsquery(?)) DESC', [$query])
                ->where('is_public', true)
                ->paginate(10);
        } else {
            $questions = Question::whereRaw('tsvectors @@ plainto_tsquery(?)', [$query])
                ->orderByRaw('ts_rank(tsvectors, plainto_tsquery(?)) DESC', [$query])
                ->paginate(10);
        }

        return view('pages.search', ['title' => 'Search Questions Page', 'questions' => $questions]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        if (!Auth::check())  {
            return redirect('/questions');
        }
        $this->authorize('create', Question::class);

        $categories = GameCategory::all();
        $tags = Tag::all();
        return view('pages.newQuestion', ['title' => 'Create New Question Page', 'categories' => $categories, 'tags' => $tags]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        if (!Auth::check()) {
            return redirect('/questions');
        }

        $this->authorize('create', Question::class);

        $request->validate([
            'title' => 'required|max:256',
            'content' => 'required',
            'game_id' => 'nullable|exists:game,id'
        ]);
        
        $game_id = $request->input('game');
       

        $question = Question::create([
          'title' => $request->input('title'),
          'user_id' => Auth::id(),
          'create_date' => now(),
          'game_id' => $game_id == 0 ? NULL : $game_id,
        ]);

        VersionContent::create([
            'date' => now(),
            'content' => $request->input('content'),
            'content_type' => 'Question_content',
            'question_id' => $question->id
        ]);
        
        if ($request->tags !== "0") {
            $tags = explode(',', $request->tags);
        
            foreach ($tags as $tag) {
                DB::table('question_tag')->insert([
                    'question_id' => $question->id,
                    'tag_id' => $tag
                ]);
            }
        }
        
        return response()->json(['id' => $question->id]);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $question = Question::findOrFail($id);

        $this->authorize('view', $question);

        $question->increment('nr_views');
        
        return view('pages.question', ['title' => 'Question: ' . $question->title, 'question' => $question]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Request $request, $id) {
        
        $question = Question::findOrFail($id);
        
        $this->authorize('edit', $question);
        
        $categories = GameCategory::all();
        
        $tags = Tag::all();
        
        return view('pages.editQuestion', ['title' => 'Edit ' . $question->title , 'question'=> $question, 'categories' => $categories, 'tags' => $tags]);
    }

    public function update(Request $request, $id) {
        
        $request->validate([
            'title' => 'required|max:256',
            'content' => 'required',
            'game_id' => 'nullable|exists:game,id'
        ]);

        $game_id = $request->input('game');

        $question = Question::findOrFail($id);

        $this->authorize('edit', $question);

        $question->update([
            'title' => $request->input('title'),
            'game_id' => $game_id == 0 ? NULL : $game_id,
        ]);

        VersionContent::create([
            'date' => now(),
            'content' => $request->input('content'),
            'content_type' => 'Question_content',
            'question_id' => $question->id
        ]);

        DB::table('question_tag')->where('question_id', $id)->delete();

        if ($request->tags !== "0") {
            $tags = explode(',', $request->tags);
        
            foreach ($tags as $tag) {
                DB::table('question_tag')->insert([
                    'question_id' => $question->id,
                    'tag_id' => $tag
                ]);
            }
        }
        
        return response()->json();

    }

    /**
     * Remove the specified resource from storage.
     */
    public function delete(Request $request, $id)
    {

        $question = Question::find($id);
        
        $this->authorize('delete', $question);

        $question->delete();

        return redirect('/questions')->with('delete', 'Question successfully deleted!');
    }

    public function follow(Request $request, $question_id)
    {
        $question = Question::findOrFail($question_id);

        DB::table('question_followers')->insert([
            'question_id' => $question_id,
            'user_id' =>  Auth::user()->id,
        ]);

        return response()->json(['action'=> 'follow']);

    }

    public function unfollow(Request $request, $question_id)
    {
        $question = Question::findOrFail($question_id);

        DB::table('question_followers')
        ->where('user_id', Auth::user()->id)
        ->where('question_id', $question_id)
        ->delete();

        return response()->json(['action'=> 'unfollow']);
    }
    
    public function vote(Request $request, $question_id)
    {
        $question = Question::findOrFail($question_id);
        
        $this->authorize('vote', $question);
        
        $reaction = $request->input('reaction');

        DB::table('vote')->insert([
            'date' => now(),
            'vote_type' => 'Question_vote',
            'reaction' => $reaction,
            'question_id' => $question_id,
            'user_id' =>  Auth::user()->id,
        ]);

        return response()->json(['action'=> 'vote']);
    }


    public function unvote(Request $request, $question_id)
    {
        $user_id = Auth::user()->id;
        
        $question = Question::findOrFail($question_id);
        
        $this->authorize('vote', $question);
        
        DB::table('vote')
            ->where('user_id', $user_id)
            ->where('question_id', $question_id)
            ->delete();
    
        return response()->json(['action' => 'unvote']);
    }

    public function activity(Request $request, $id) {
        $question = Question::findOrFail($id);

        $this->authorize('view', $question);

        $page = $request->page ?? 1;
        $questionContents = $question->versionContent()
            ->select('content', 'date')
            ->get()
            ->map(function ($content) use ($question) {
                return [
                    'content' => $content->content,
                    'date' => $content->date,
                    'user' => $question->creator->name,
                    'type' => 'Question_content',
                    'action' => ($content->date == $question->versionContent()->orderBy('date')->first()->date) ? 'created' : 'edited',
                    'span' => 'Question',
                    'user_id' => $question->user_id
                ];
            });
    
        $answerContents = [];
        $answers = $question->answers()->with('versionContent')->get();
        foreach ($answers as $answer) {
            foreach ($answer->versionContent as $content) {
                $answerContents[] = [
                    'content' => $content->content,
                    'date' => $content->date,
                    'user' => $answer->creator->name,
                    'type' => 'Answer_content',
                    'action' => ($content->date == $answer->versionContent()->orderBy('date')->first()->date) ? 'created' : 'edited',
                    'span' => 'Answer #' . $answer->id,
                    'user_id' => $answer->user_id
                ];
            }
            foreach ($answer->comments as $comment) {
                foreach ($comment->versionContent as $content) {
                    $answerContents[] = [
                        'content' => $content->content,
                        'date' => $content->date,
                        'user' => $comment->creator->name,
                        'type' => 'Comment_content',
                        'action' => ($content->date == $comment->versionContent()->orderBy('date')->first()->date) ? 'created' : 'edited',
                        'span' => 'Comment #' . $comment->id,
                        'user_id' => $comment->user_id
                    ];
                }
            }
        }
    
        $allContents = collect($questionContents)->merge($answerContents)->sortByDesc('date');
    
        $paginatedContents = $allContents->forPage($page, 5); 
    
        return view('pages.activity', ['title' => $question->title . ' activity', 'question' => $question, 'contents' => $paginatedContents]);
    }
    

    function visibility(Request $request, $id) {
        $question = Question::findOrFail($id);
        $visibility = $request->visibility == 'public' ? TRUE : FALSE;
        $question->is_public = $visibility; 
        $question->save();
        return response()->json(['visibility' => $request->visibility]);
    }

}
