function showUserStatus() {
    const modal = document.querySelector('#userDeleteModal');
    modal.style.display = 'block';
    const status = event.target.value;
    const sel = event.target;

    if (status == 'banned') {
        sel.classList.remove('active');
        sel.classList.add('banned');
    } else {
        sel.classList.remove('banned');
        sel.classList.add('active');
    }

    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };
    modal.querySelector('#ad-confirm').textContent = 'Confirm';

    if (event.target.value == 'active'){
        modal.querySelector('h2').textContent = 'Activate account';
        modal.querySelector('p').textContent = 'Are you sure you want to activate this account? All its activity will become public and visible.'
    } else {
        modal.querySelector('h2').textContent = 'Ban account';
        modal.querySelector('p').textContent = 'Are you sure you want to ban this account? All its activity will become private.'
    }
    const cancel = document.getElementById('ad-cancel');
   
    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
        if (status == 'active') {
            sel.classList.remove('active');
            sel.classList.add('banned');
            sel.value = 'banned';
        } else {
            sel.classList.remove('banned');
            sel.classList.add('active');
            sel.value = 'active';
        }
    });

    const id = event.target.closest('.user-info').getAttribute('data-id');

    console.log('User ID:', id);
    const confirm = document.getElementById('ad-confirm');
    confirm.addEventListener('click', function(){
        event.preventDefault();
        sendAjaxRequest('post', '/api/users/' + id, { status: status }, statusUpdatedHandler);
        modal.style.display = 'none';
    });
    
}

function statusUpdatedHandler() {
    if (this.status === 200) {
        let item = JSON.parse(this.responseText);
        console.log('Status updated:', item);
        createNotificationBox('Successfully saved!', 'User status successfully updated!')
    } else {
        console.error('Status update failed:', this.statusText);
    }
}

function userListHandler() {
    if (this.status === 200) {
        const table = document.querySelector('.users');
        table.innerHTML = this.response;
        const links = document.querySelectorAll('.custom-pagination a');
        for (const link of links){
            link.addEventListener('click', function(){
                event.preventDefault()
                const url = new URL(link.href);
                sendAjaxRequest('get', '/api/users' + url.search + '&' + encodeForAjax({search: search_user.value, filter: filter_user.value, order: order_user.value}), {}, userListHandler);
            });
        }
    } else {
        console.error('User list failed:', this.statusText);
    }
}


function gameListHandler() {
    if (this.status === 200) {
        const table = document.querySelector('.games');
        table.innerHTML = this.response;
        const links = document.querySelectorAll('.custom-pagination a');
        for (const link of links){
            link.addEventListener('click', function(){
                event.preventDefault(); 
                const url = new URL(link.href);
                sendAjaxRequest('get', '/api/game' + url.search + '&' + encodeForAjax({search: search_game.value, filter: filter_game.value, order: order_game.value}), {}, gameListHandler);
            
            });
        }
    } else {
        console.error('Game list failed:', this.statusText);
    }
}

function showUserDelete() {
    const modal = document.querySelector('#userDeleteModal');
    modal.style.display = 'block';

    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };

    const cancel = document.getElementById('ad-cancel');

    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
    });

    const id = event.target.closest('.user-info').getAttribute('data-id');

    console.log('User ID:', id);
    
    const confirm = document.getElementById('ad-confirm');
    
    confirm.addEventListener('click', function(){
        event.preventDefault();
        sendAjaxRequest('delete', '/api/users/' + id, {}, userDeleteHandler);
    });
    
}


function userDeleteHandler() {
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        const user = document.querySelector(`#user${id}`);
        const modal = document.querySelector('#userDeleteModal');
        modal.style.display = 'none';
        user.remove();
        createNotificationBox('Successfully deleted!', 'User deleted successfully!');
    }
}
 

const adminActions = document.querySelectorAll('.admin-actions button');

if (adminActions) {
    adminActions.forEach(button => {
        button.addEventListener('click', function () {
            adminActions.forEach(btn => btn.classList.remove('selected'));
            this.classList.add('selected');
            if (this.textContent !== 'Statistics')
                sendAjaxRequest('get', '/api/admin/' + this.textContent.toLowerCase(), {}, toggleAdminSection);
            else {
                window.location.href = '/statistics';
            }
        });
    });
}

let order_user, search_user, filter_user, order_game, search_game, filter_game;


function toggleAdminSection() {
    const article = document.querySelector('.admin-sec article');
    article.innerHTML = this.responseText;
   
    if (document.querySelector('.user-manage-section')) {
        order_user = document.querySelector('#order-user');
        search_user = document.querySelector('#search-user');
        filter_user = document.querySelector('#filter-user');
        order_user.addEventListener('change', function() {
            sendAjaxRequest('get', '/api/users?' + encodeForAjax({search: search_user.value, filter: filter_user.value, order: order_user.value}), {}, userListHandler);
        });
        search_user.addEventListener('input', function() {
            sendAjaxRequest('get', '/api/users?' + encodeForAjax({search: search_user.value, filter: filter_user.value, order: order_user.value}), {}, userListHandler);
        });
        filter_user.addEventListener('change', function() {
            sendAjaxRequest('get', '/api/users?' + encodeForAjax({search: search_user.value, filter: filter_user.value, order: order_user.value}), {}, userListHandler);
        });

        const links = document.querySelectorAll('.custom-pagination a');
        for (const link of links){
            link.addEventListener('click', function(){
                event.preventDefault()
                const url = new URL(link.href);
                sendAjaxRequest('get', '/api/users' + url.search + '&' + encodeForAjax({search: search_user.value, filter: filter_user.value, order: order_user.value}), {}, userListHandler);
            });
        }

    } else if (document.querySelector('.game-manage-section')) {
        order_game = document.querySelector('#order-game');
        search_game = document.querySelector('#search-game');
        filter_game = document.querySelector('#filter-game');
        order_game.addEventListener('change', function() {
            sendAjaxRequest('get', '/api/game?' + encodeForAjax({search: search_game.value, filter: filter_game.value, order: order_game.value}), {}, gameListHandler);
        });
        search_game.addEventListener('input', function() {
            sendAjaxRequest('get', '/api/game?' + encodeForAjax({search: search_game.value, filter: filter_game.value, order: order_game.value}), {}, gameListHandler);
        });
        filter_game.addEventListener('change', function() {
            sendAjaxRequest('get', '/api/game?' + encodeForAjax({search: search_game.value, filter: filter_game.value, order: order_game.value}), {}, gameListHandler);
        });

        const links = document.querySelectorAll('.custom-pagination a');
        for (const link of links){
            link.addEventListener('click', function(){
                event.preventDefault(); 
                const url = new URL(link.href);
                sendAjaxRequest('get', '/api/game' + url.search + '&' + encodeForAjax({search: search_game.value, filter: filter_game.value, order: order_game.value}), {}, gameListHandler);
            
            });
        }
    } else if (document.querySelector('#report-page')) {
        const links = document.querySelectorAll('.custom-pagination a');
        for (const link of links){
            link.addEventListener('click', function(){
                event.preventDefault()
                const url = new URL(link.href);
                sendAjaxRequest('get', '/api/admin/reports' + url.search, {}, reportListHandler);
            });
        }
    }
}

function reportListHandler() {
    if (this.status === 200) {
        document.querySelector('.admin-sec article').innerHTML = this.responseText;
        const links = document.querySelectorAll('.custom-pagination a');
        for (const link of links){
            link.addEventListener('click', function(){
                event.preventDefault()
                const url = new URL(link.href);
                sendAjaxRequest('get', '/api/admin/reports' + url.search, {}, reportListHandler);
            });
        }
    }
}

const questionChart = document.getElementById('question-chart');
const userChart = document.getElementById('user-chart');
const categoryChart = document.getElementById('categories-chart')
const gameChart = document.getElementById('game-chart');
const tagsChart = document.getElementById('game-chart');

if (questionChart) {
   createCharts();
}

function createCharts(){
    sendAjaxRequest('get', 'api/admin/charts?' + encodeForAjax({type: 'questions'}), {}, createQuestionChart);
    sendAjaxRequest('get', 'api/admin/charts?' + encodeForAjax({type: 'users'}), {}, createUserChart);
    sendAjaxRequest('get', 'api/admin/charts?' + encodeForAjax({type: 'categories'}), {}, createCategoryChart);
    sendAjaxRequest('get', 'api/admin/charts?' + encodeForAjax({type: 'games'}), {}, createGameChart);
}

function createQuestionChart() {
    if (this.status == 200) {
        const response = JSON.parse(this.responseText);
       
        new Chart(questionChart, {
            type: 'line',
            data: {
                labels: response.labels,
                datasets: [{
                    label: 'Questions',
                    data: response.data,
                    fill: false,
                    borderColor: 'rgba(124,91,240,255)',
                    tension: 0.1
                }]
            },
            options: {
                plugins: {
                    legend: {
                        display: false 
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false
                    }
                }
            }
        });
    } 
}

function createUserChart() {
    if (this.status == 200) {
        const response = JSON.parse(this.responseText);
        new Chart(userChart, {
            type: 'doughnut',
            data: {
                labels: response.labels,
                datasets: [{
                  label: 'Users',
                  data: response.data,
                  backgroundColor: [
                    'rgb(159, 71, 71)', 
                    'rgb(251, 165, 34)', 
                    'rgb(124,91,240)'  
                ],
                }]
            },
            options: {
                cutout: '70%',
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                },
            }
          });
    }
   
}

function createCategoryChart() {
    if (this.status == 200) {
        const response = JSON.parse(this.responseText);
        new Chart(categoryChart, {
            type: 'bar',
            data: {
                labels: response.labels,
                datasets: [{
                  label: 'Number of games in each category',
                  data: response.data,
                  backgroundColor: ['rgb(210, 207, 255)']
                }]
            },
            options: {
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                },
            }
          });
    }
}

function createGameChart() {
    if (this.status == 200) {
        const response = JSON.parse(this.responseText);
        new Chart(gameChart, {
            type: 'bar',
            data: {
                labels: response.labels,
                datasets: [{
                  data: response.data,
                  backgroundColor: ['rgb(210, 207, 255)']
                }]
            },
            options: {
                indexAxis: 'y',
                plugins: {
                    legend: {
                        display: false
                    },
                },
            }
          });
    }
}

function showDeleteCategory() {
    const modal = document.getElementById('deleteModal');
    modal.style.display = 'block';

    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };

    const cancel = document.getElementById('d-cancel');

    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
    });
}



let oldTag = "";

function editChanges(){
    event.preventDefault();
    const tagContainer = event.target.closest('.tags-actions');
    oldTag = tagContainer.outerHTML; 
    const id = tagContainer.getAttribute('data-id');
    console.log(id);
    sendAjaxRequest('get', '/api/tags/' + id + "/edit", {}, showEditTag);
}

function showEditTag() {
    if (this.status == 200) {
        let tmp = document.createElement('div');
        tmp.innerHTML = this.responseText;
        const id = tmp.querySelector('.edit-tag').getAttribute('data-id');

        const container = document.querySelector('#tag' + id);
        if (container) {
            container.outerHTML = this.responseText;
        }
    }
}




function deleteTag() {
    const tagContainer = event.target.closest('.tags-actions');
    const id = tagContainer.getAttribute('data-id');

    const modal = document.querySelector('#tagDeleteModal');
    modal.style.display = 'block';

    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };

    const cancel = document.getElementById('d-cancel');

    cancel.addEventListener('click', function(){
        modal.style.display = 'none';
    });

    const confirm = document.getElementById('d-confirm');
    confirm.addEventListener('click', function(){
        event.preventDefault();
        sendAjaxRequest('delete', '/api/tags/' + id, {}, tagDeleteHandler);
        modal.style.display = 'none';
    });

}

function tagDeleteHandler() {
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        const tag = document.querySelector(`#tag${id}`);
        tag.remove();
        createNotificationBox('Successfully deleted!', 'Tag deleted successfully!');
    }
}

function restoreTag() {
    const tagContainer = event.target.closest('.edit-tag');
    tagContainer.outerHTML = oldTag;
}

function updateTag() {
    const id = document.querySelector('.edit-tag').getAttribute('data-id');
    const name = document.querySelector('.edit-tag input').value;
    if (name != '') {
        sendAjaxRequest('put', '/api/tags/' + id, {name: name}, tagUpdateHandler);
    } else {
        createNotificationBox('Empty tag name', 'Please enter your tag name before saving!', 'warning');
    }
}


function tagUpdateHandler() {
    if (this.status === 200) {
        const response = JSON.parse(this.responseText);
        const id = response.id;
        const name = response.name;
        const tag = document.querySelector(`#tag${id}`);
        tag.outerHTML = `               <div id="tag${id}" class="tags-actions" data-id="${id}">
            <ion-icon name="create" onclick="editChanges()"></ion-icon>
            <span>${name}</span>  
            <ion-icon name="trash" onclick="deleteTag()"> </ion-icon>    
        </div>`;
        createNotificationBox('Successfully saved!', 'Tag successfully saved!');
    } else {
        const errorResponse = JSON.parse(this.responseText);
        createNotificationBox('Something went wrong!', errorResponse.error.name, 'error');
    }
}

