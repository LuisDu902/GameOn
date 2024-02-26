<tr class="game-info" id="game{{ $game->id }}" data-id="{{ $game->id }}">
    <td><a href="{{ route('game', ['id' => $game->id]) }}">{{ $game->name }}</a></td>
    <td><a href="{{ route('category', ['id' => $game->game_category_id]) }}">{{ $game->category->name }}</a></td>
    <td>{{ $game->nr_members }}</td>
    <td>
    <a href="{{ route('game.edit', ['id' => $game->id]) }}">        
        <ion-icon name="create" id="cre-game"></ion-icon>
    </a></td>
    </td>
    <td class="delete-game"><button class="delete-game-button" onclick="showGameDelete()">
        <ion-icon name="trash"></ion-icon>
        </button>
    </td>
</tr>
