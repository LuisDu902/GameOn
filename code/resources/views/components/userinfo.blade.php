<tr class="user-info" id="user{{ $user->id }}" data-id="{{ $user->id }}">
    <td><img src="{{ $user->getProfileImage() }}" alt="User Image"></td>
    <td><a href="{{ route('profile', ['id' => $user->id]) }}">{{ $user->username }}</a></td>
    <td>{{ $user->name }}</td>
    <td>{{ $user->email }}</td>
    <td class="{{ $user->rank }}">{{ $user->rank }}</td>
    <td>
    <select name="" class="status {{ $user->is_banned ? 'banned' : 'active' }}" id="user-status" data-user="{{ $user->id }}" onchange="showUserStatus()">
        <option value="active" {{ $user->is_banned ? '' : 'selected' }}>Active</option>
        <option value="banned" {{ $user->is_banned ? 'selected' : '' }}>Banned</option>
    </select>
    </td>
    <td class="delete-user"><button class="delete-user-button" onclick="showUserDelete()">
        <ion-icon name="trash"></ion-icon>
        </button>
    </td>
</tr>
