<?php

namespace App\Http\Controllers;
use App\Models\Answer;
use App\Models\Question;
use App\Models\Report;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'reason' => 'required|string',
            'explanation' => 'string',
            'question_id' => 'required|integer',
           
        ]);

        $question = Question::findOrFail($data['question_id']);

        $data['reported_id'] = $question->user_id;
        $data['date'] = now(); 
        $data['reporter_id'] = auth()->id();
        $data['is_solved'] = false;
        $data['report_type'] = 'Question_report'; 
        Report::create($data);

        return back()->with('success', 'Report submitted successfully.');
    }

    public function store2(Request $request)
    {
        $data = $request->validate([
            'reason' => 'required|string',
            'explanation' => 'string',
            'reported_id' => 'required|string',
            'answer_id' => 'required|string',
           
        ]);

        
        $data['date'] = now(); 
        $data['reporter_id'] = auth()->id(); 
        $data['is_solved'] = false; 
        $data['report_type'] = 'Answer_report';

        Report::create($data);

        return back()->with('success', 'Report submitted successfully.');
    }

    public function store3(Request $request)
    {
        $data = $request->validate([
            'reason' => 'required|string',
            'explanation' => 'string',
            'reported_id' => 'required|string',
            'comment_id' => 'required|string',
          
        ]);

        
        $data['date'] = now();
        $data['reporter_id'] = auth()->id(); 
        $data['is_solved'] = false; 
        $data['report_type'] = 'Comment_report'; 

        Report::create($data);

        return back()->with('success', 'Report submitted successfully.');
    }
}
