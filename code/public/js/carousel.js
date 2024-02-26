const carousel = document.querySelector('.carousel-view');


if (carousel) {
    const prev = document.querySelector('#prev-game');
    const list = document.querySelector('.games-list');
    const next = document.querySelector('#next-game');

    prev.addEventListener('click',()=>{
        list.scrollLeft -= 480;
    })

    next.addEventListener('click',()=>{
        list.scrollLeft += 480;
    })
}
