<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;
use Illuminate\Mail\Mailables\Address;

class MailModel extends Mailable
{
    public $mailData;


    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($mailData)
    {
        // Necessary to pass data from the controller.
        $this->mailData = $mailData;
    }

    /**
     * Get the message envelope.
     *
     * @return \Illuminate\Mail\Mailables\Envelope
     */
    public function envelope()
    {
        if ($this->mailData['type'] === 'recover'){
            return new Envelope(
                from: new Address(env('MAIL_FROM_ADDRESS'), env('MAIL_FROM_NAME')),
                subject: 'Recover password',
            );
        } else {
            return new Envelope(
                from: new Address($this->mailData['email'], $this->mailData['name']),
                subject: 'Contact',
            );
        }  
    }
    
    /**
     * Get the message content definition.
     *
     * @return \Illuminate\Mail\Mailables\Content
     */
    public function content()
    {
        if ($this->mailData['type'] === 'recover'){
            return new Content(
                view: 'emails.recoverEmail',
            );
        } else {
            return new Content(
                view: 'emails.contact',
            );
        }  
        
    }
}
