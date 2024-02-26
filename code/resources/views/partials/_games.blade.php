<section class="game-manage-section">
    <nav class="search-bar">
        <div class="filter-condition">
            <ion-icon name="funnel-outline" class="purple"></ion-icon>
            <label> Category: </label>
            <select name="" class="filter-select" id="filter-game">
                <option value="0">None</option>
                @foreach($categories as $category)
                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                @endforeach
            </select>
        </div>
        <div class="game-search">
            <ion-icon name="search" class="purple"></ion-icon>
            <input id="search-game" type="text" placeholder="Search...">
        </div>

        <div class="order-condition">
            <ion-icon name="swap-vertical" class="purple"></ion-icon>
            <label> Order by </label>
            <select name="" class="order-select" id="order-game">
                <option value="name"> name </option>
                <option value="game_category_id"> category </option>
                <option value="nr_members"> members </option>
            </select>
        </div>
    </nav>
    <div class="games">
        @include('partials._gamesTable')
    </div>
</section>

