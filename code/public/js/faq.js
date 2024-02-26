const faqDropdowns = document.querySelectorAll(".faq-dropdown");

if (faqDropdowns) {
    faqDropdowns.forEach(function(faqDropdown) {
        const faqAnswer = faqDropdown.querySelector(".faq-answer");
        let isOpen = false;
        const title = faqDropdown.querySelector(".faq-question");
        const faqIcon = faqDropdown.querySelector(".faq-dropdown ion-icon");
        faqDropdown.addEventListener("click", function() {
            if (isOpen) {
                faqAnswer.style.maxHeight = "0";
                faqDropdown.style.border = "1px solid #e6e7f3";
                title.style.color = "black";
                faqIcon.classList.remove("rotate");
            } else {
                faqAnswer.style.maxHeight = faqAnswer.scrollHeight + "px";
                faqDropdown.style.border = "1px solid #6D49EB";
                title.style.color = "#6D49EB";
                faqIcon.classList.add("rotate");
            }
            isOpen = !isOpen;
        });
    });
}