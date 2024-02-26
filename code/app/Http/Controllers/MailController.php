<?php

namespace App\Http\Controllers;

use Mail;
use Illuminate\Http\Request;
use App\Mail\MailModel;
use App\Models\User;

use TransportException;
use Exception;

class MailController extends Controller
{
    function send(Request $request) {

        $missingVariables = [];
        $requiredEnvVariables = [
            'MAIL_MAILER',
            'MAIL_HOST',
            'MAIL_PORT',
            'MAIL_USERNAME',
            'MAIL_PASSWORD',
            'MAIL_ENCRYPTION',
            'MAIL_FROM_ADDRESS',
            'MAIL_FROM_NAME',
        ];
    
        foreach ($requiredEnvVariables as $envVar) {
            if (empty(env($envVar))) {
                $missingVariables[] = $envVar;
            }
        }
    
        if (empty($missingVariables)) {

            $mailData = [
                'email' => $request->email,
                'type' => 'recover'
            ];

            $user = User::where('email', $request->email)->first();

            if (!$user) {
                return redirect()->back()->with('error', 'No user with that email address');
            }

            try {
                Mail::to($request->email)->send(new MailModel($mailData));
                $status = 'Success!';
                $message = ' An email has been sent to ' . $request->email;
            } catch (Exception $e) {
                $status = 'Error!';
                $message = 'An unhandled exception occurred during the email sending process to ' . $request->email;
                dd($e);
            }

        } else {
            $status = 'Error!';
            $message = 'The SMTP server cannot be reached due to missing environment variables:';
        }

        $request->session()->flash('status', $status);
        $request->session()->flash('message', $message);
        $request->session()->flash('details', $missingVariables);
        return redirect()->route('emailSent');
    }

    function contact(Request $request) {

        $missingVariables = [];
        $requiredEnvVariables = [
            'MAIL_MAILER',
            'MAIL_HOST',
            'MAIL_PORT',
            'MAIL_USERNAME',
            'MAIL_PASSWORD',
            'MAIL_ENCRYPTION',
            'MAIL_FROM_ADDRESS',
            'MAIL_FROM_NAME',
        ];
    
        foreach ($requiredEnvVariables as $envVar) {
            if (empty(env($envVar))) {
                $missingVariables[] = $envVar;
            }
        }
    
        if (empty($missingVariables)) {

            $mailData = [
                'email' => $request->email,
                'content' => $request->content,
                'name' => $request->name,
                'type' => 'contact'  
            ];
            try {
                Mail::to('support@gameon.com')->send(new MailModel($mailData));
                $status = 'Success!';
                $message = ' An email has been sent by ' . $request->email;
            } catch (Exception $e) {
                $status = 'Error!';
                $message = 'An unhandled exception occurred during the email sending process to ' . $request->email;
                dd($e);
            }

        } else {
            $status = 'Error!';
            $message = 'The SMTP server cannot be reached due to missing environment variables:';
        }

        $request->session()->flash('status', $status);
        $request->session()->flash('message', $message);
        $request->session()->flash('details', $missingVariables);
        return redirect('/contact')->with('sent', 'Email sent!');

    }

}