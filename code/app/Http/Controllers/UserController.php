<?php
 
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Question;
use App\Models\Notification;

use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

use Illuminate\View\View;
use App\Models\User;

use App\Policies\UserPolicy;

use HasFactory, Notifiable;

class UserController extends Controller
{ 
    public function showUserProfile($id) {

        $user = User::find($id);

        if (!$user) {
          abort(404, 'User not found');
        }

        return view('pages.profile', ['title' => $user->name . '\'s profile', 'user' => $user]);
    }

    public function search(Request $request){
        $order = $request->input('order', 'username');
        $filter = $request->input('filter', '');
        $search = $request->input('search', '');

        $query = User::where(function ($query) use ($search) {
            $query->where('username', 'ilike', "%$search%")
                  ->orWhere('name', 'ilike', "%$search%");
        });


        if (in_array($filter, ['Bronze', 'Gold', 'Master']))  $query->where('rank', $filter);
        elseif ($filter === 'Active') $query->where('is_banned', false);
        elseif ($filter === 'Banned') $query->where('is_banned', true);

        
        $users = $query->where('id', '!=', 1)->orderBy($order)->paginate(10);

        return view('partials._usersTable', compact('users'))->render();
    }

    public function updateStatus(Request $request, $id) {
        
        $this->authorize('updateStatus', [Auth::user()]);
        
        $user = User::find($id);
        
        $user->is_banned = ($request->status == "banned"); 
        
        $user->save();
        
        return response()->json(['status'=> 'success']);
    }

    public function edit(Request $request)
    {
      $user = User::find($request->id);

      $this->authorize('update', [Auth::user(), $user]);
     
      $user->name = $request->input('name');
      $user->username = $request->input('username');

      if($request->input('email') != ""){
        $user->email = $request->input('email');
      }

      $user->description = $request->input('description');

      $user->save();
      return response()->json(['profile update'=> 'success']);
    }
   


    public function showUserQuestions($id) {

        $user = User::find($id);
        
        if (!$user) {
            abort(404);
        }

        $questions = $user->questions()->paginate(10);

        return view('pages.userQuestions', ['title' => $user->name . '\'s questions', 'user' => $user, 'questions' => $questions]);
    }

    public function showUserAnswers($id) {

        $user = User::find($id);
        
        if (!$user) {
            abort(404);
        }

        $answers = $user->answers; 
        return view('pages.userAnswers', ['title' => $user->name . '\'s answers', 'user' => $user, 'answers' => $answers]);
    }

    public function delete(Request $request, $id) {

        $user = User::find($id);
        
        if (!$user) {
            abort(404);
        }

        $this->authorize('delete', [auth()->user(), $user]);

        $user->delete();

        return response()->json(['id' => $user->id ]); 
    }



    public function showUserNotifications($id) {
        if (!Auth::check()) {
            return redirect('/home');
        }

        if (Auth()->user()->id != $id) {
            return redirect('/home');
        }

        if (!Auth::check()) {
            return redirect('/home');
        }

        if (Auth()->user()->id != $id) {
            return redirect('/home');
        }

        $user = User::find($id);
        
        if (!$user) {
            abort(404);
        }

        $notifications = $user->notifications()->orderByDesc('date')->get();
        return view('pages.userNotifications', ['title' => $user->name . ' Notifications', 'user' => $user, 'notifications' => $notifications]);
    }

    public function showUserReportsNotifications($id) {
        
        if (!Auth::check()) {
            return redirect('/home');
        }

        if (Auth()->user()->id != $id) {
            return redirect('/home');
        }

        $user = User::find($id);
        
        if (!$user) {
            abort(404);
        }

        $notifications = $user->notifications()->orderByDesc('date')->get();
        return view('pages.userReportsNotifications', ['title' => 'Reports Page', 'user' => $user, 'notifications' => $notifications]);
    }

    public function markAsViewed($id)
    {
        $notification = Notification::find($id);

        if ($notification) {
            $notification->viewed = true;
            $notification->save();

            return response()->json(['success' => true]);
        }
        
        return response()->json(['success' => false, 'message' => 'Notification not found']);
    }

    public function viewed(Request $request, $notification_id)
    {        
        DB::table('notification')
        ->where('id', $notification_id)
        ->update(['viewed' => true]);

    return response()->json(['action' => 'viewed', 'id' => $notification_id]);
    }
    
    public function getUnreadNotificationCount()
    {
        $unreadCount = Notification::where('user_id', Auth::id())
            ->where('viewed', false)
            ->count();

        return $unreadCount;
    }

}
