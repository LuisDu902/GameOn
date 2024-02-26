<section class="user-manage-section">
    <nav class="search-bar">
        <div class="filter-condition">
            <ion-icon name="funnel-outline" class="purple"></ion-icon>
            <label> Filter by </label>
            <select name="" class="filter-select" id="filter-user">
                <option value="">None</option>
                <optgroup label="Rank">
                    <option value="Bronze">Bronze</option>
                    <option value="Gold">Gold</option>
                    <option value="Master">Master</option>
                </optgroup>
                <optgroup label="Status">
                    <option value="Active">Active</option>
                    <option value="Banned">Banned</option>
                </optgroup>
            </select>
        </div>
        <div class="user-search">
            <ion-icon name="search" class="purple"></ion-icon>
            <input id="search-user" type="text" placeholder="Search...">
        </div>

        <div class="order-condition">
            <ion-icon name="swap-vertical" class="purple"></ion-icon>
            <label> Order by </label>
            <select name="" class="order-select" id="order-user">
                <option value="username"> username </option>
                <option value="name"> name </option>
                <option value="rank"> rank </option>
            </select>
        </div>
    </nav>
    <div class="users">
        @include('partials._usersTable')
    </div>
</section>

