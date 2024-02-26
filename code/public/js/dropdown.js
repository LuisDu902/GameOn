const dropDownButton = document.querySelector('.dropbtn');

if (dropDownButton) {
    let isOpen = false;
    const dropdownContent = document.querySelector('.dropdown-content');
    
    dropDownButton.addEventListener('click', function () {
        if (isOpen) {
            dropDownButton.innerHTML = '<ion-icon name="chevron-down"></ion-icon>';
            dropdownContent.style.display = 'none';
        } else {
            dropDownButton.innerHTML = '<ion-icon name="chevron-up"></ion-icon>';
            dropdownContent.style.display = 'flex';
        }

        isOpen = !isOpen;
    });

}

const openSidebarButton = document.querySelector('.open-sidebar');

if (openSidebarButton) {
    const overlay = document.querySelector('.overlay');
    const sidebar = document.querySelector('.sidebar');
    
    openSidebarButton.addEventListener('click', () => {
        sidebar.style.left = '0';
        overlay.style.display = 'block';
    });

    overlay.addEventListener('click', () => {
        sidebar.style.left = '-400px';
        overlay.style.display = 'none';
    });
}



const questionDropDown = document.querySelector('.question-dropdown button ion-icon');

if (questionDropDown) {
    let isOpen1 = false;
    const dropdownContent = document.querySelector('.q-drop-content');
    
    questionDropDown.addEventListener('click', function () {
        if (isOpen1) {
            dropdownContent.style.display = 'none';
        } else {
            dropdownContent.style.display = 'flex';
        }
        isOpen1 = !isOpen1;
    });

    const deleteBtn = document.querySelector('#delete-question');
    const editBtn = document.querySelector('#edit-question');

    if (deleteBtn) {
        deleteBtn.addEventListener('click', function(){
            dropdownContent.style.display = 'none';
        });
    }
    if (editBtn) {
        editBtn.addEventListener('click', function(){
            dropdownContent.style.display = 'none';
        });
    }
   
}



function toggleAnswerDropDown() {
    const dropdown = event.target;
    const dropdownContent = dropdown.closest('.answer-dropdown').querySelector('.q-drop-content');
    if (dropdown.classList.contains('isOpen')) {
        dropdownContent.style.display = 'none';
        dropdown.classList.remove('isOpen');
    } else {
        dropdownContent.style.display = 'flex';
        dropdown.classList.add('isOpen');
    }
}

function toggleCommentDropDown() {
    const dropdown = event.target;
    const dropdownContent = dropdown.closest('.comment-dropdown').querySelector('.q-drop-content');
    if (dropdown.classList.contains('isOpen')) {
        dropdownContent.style.display = 'none';
        dropdown.classList.remove('isOpen');
    } else {
        dropdownContent.style.display = 'flex';
        dropdown.classList.add('isOpen');
    }
}


function toggleFilterDropDown() {
    const dropdown = event.target;
    const dropdownContent = document.querySelector('.filter-content');
    if (dropdown.classList.contains('isOpen')) {
        dropdownContent.style.display = 'none';
        dropdown.classList.remove('isOpen');
    } else {
        dropdownContent.style.display = 'grid';
        dropdown.classList.add('isOpen');
    }
}
