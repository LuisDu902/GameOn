<h1>Password Recovery</h1>
<p>Hello! </p>
<p>We received a request to reset your password.</p>
<p>To reset your password, click the link below:</p>
<p><a href="{{ route('newPassword') . '?email=' . $mailData['email'] }}">Reset Password</a></p>
<p>If you didn't request this change, please ignore this message.</p>
<p>Thank you,</p>
<p>The GameOn Team</p>