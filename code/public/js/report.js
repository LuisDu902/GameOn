function openPopup() {
    document.getElementById("reportPopup").style.display = "block";
   
}

function closePopup() {
    document.getElementById("reportPopup").style.display = "none";
}

function openPopup2() {
    document.getElementById("reportPopup2").style.display = "block";   
}

function closePopup2() {
    document.getElementById("reportPopup2").style.display = "none";
}
function openPopup3() {
    document.getElementById("reportPopup3").style.display = "block";   
}

function closePopup3() {
    document.getElementById("reportPopup3").style.display = "none";
}


function changeReportStatus(element) {
    var reportId = element.getAttribute('data-report');
    var status = element.value;

    fetch('/admin/reports/update-status', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') 
        },
        body: JSON.stringify({ reportId: reportId, status: status })
    })
    .then(response => response.json())
.then(data => {
        if(data.success) {
            var solvedOption = element.querySelector('.status-solved');
            var unsolvedOption = element.querySelector('.status-unsolved');
            if (status == "1") {
                solvedOption.selected = true;
                unsolvedOption.selected = false;
            } else {
                solvedOption.selected = false;
                unsolvedOption.selected = true;
            };
        } 
    });
}


