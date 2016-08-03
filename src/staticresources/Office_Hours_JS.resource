function init(accountId){

	console.log("in init method, accountId: " + accountId);

	var office_hours_range = [];
	
	office_hours_range.push("hh:mm");

	for (var i = 1; i < 24; i++) {
		office_hours_range.push(i + ":00");
		office_hours_range.push(i + ":30");
	}

    addOptions("#select-start-monday", office_hours_range);
    addOptions("#select-end-monday", office_hours_range);
    addOptions("#select-start-tuesday", office_hours_range);
    addOptions("#select-end-tuesday", office_hours_range);


    $("#btnSave").click(function(){saveOfficeHours();});

    var cts = new remoteObj.Contact();
        cts.retrieve({ limit: 10 }, function(error, records, event){ 
            console.log(records);
        });
        

}

function addOptions(id, values){
    var options = $();
    values.forEach(function(value){
        var option = document.createElement('option');
        option.value = value;
        option.text = value;
        options = options.add(option);
    });
    $(id).append(options);
}


//todo: 1) build json object, 2) store under account Office_Hours_Json__c field 3) transform saved json into readable text and save on another text read-only field
function saveOfficeHours() {
	
	var officeHoursResult = {};

	$("form#office-hours-form select").each(function(){

		console.log("this.id: " + $(this)[0].id + " value: " + $(this)[0].value);
		
		switch($(this)[0].id.split("-")[2]) {
			case "monday":
				console.log("found monday, period: " + $(this)[0].id.split("-")[1] + " value: " + $(this)[0].value);
				officeHoursResult.Monday = [[$(this)[0].value, $("#select-end-monday").val()]];
			break;

			case "tuesday":

				officeHoursResult.Tuesday = [[$(this)[0].value, $("#select-end-tuesday").val()]];
			break;

		}

		console.log("json result: " + JSON.stringify(officeHoursResult));
		
		debugger;

	}); 
}

