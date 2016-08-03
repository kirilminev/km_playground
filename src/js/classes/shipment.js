import $ from 'jquery';
import {datepicker} from 'jquery-ui';

window.adjustPickupCalendar = arrivalDate => {
	let theDayAfter = new Date(arrivalDate);
	theDayAfter.setDate(theDayAfter.getDate() + 1);
	$('[id$=new-shipment-pickup-date]').datepicker({
		dateFormat: "mm/dd/yy",
		beforeShowDay: date => {
			let todaysDate = new Date();
			todaysDate.setHours(0,0,0,0);
			let formattedDate = (date.getMonth() + 1); 
	        if (date.getMonth() < 9) {
	            formattedDate = "0" + formattedDate; 
	        }
	        formattedDate += "-"; 
	        
	        if (date.getDate() < 10) {
	        	formattedDate += "0"; 
	        }
	        formattedDate += date.getDate() + "-" + date.getFullYear();

	        if ($.inArray(formattedDate, availableDates) != -1) {
	            return [true, "standard-date", ""]; 
	        }
	        else {
				return [false, "", "Unavailable"]; 
	        }
	    }
	});
	$('[id$=new-shipment-pickup-date]').datepicker("option", "minDate", theDayAfter);
}

window.afterCancelShipment = hasErrors => {
	if (hasErrors === false) {
		clearShipment();
		$('.new-shipment-section').slideToggle();
		$('.new-shipment-button').prop('disabled', false);
	}
	else {
		$('.new-shipment-button').prop('disabled', true);
	}
}

window.afterCloseShipment = () => {
	$('.new-shipment-button').prop('disabled', false);
	$('.address-field').prop('readonly', false);
	$('.save-and-submit').show();
	refreshContact();
}

window.afterEditShipment = (shipped, requestedDate) => {
	$('.new-shipment-button').prop('disabled', true);
	$('.new-shipment-section').show("fade");
	makeMultiSelectDropDowns();
	if (shipped === false) {
		makeDatePickers();
		$('.primary-contact').prop('readonly', false);
		$('.primary-contact').parent().find('a').show();
		$('.address-field').prop('readonly', false);
		$('.save-and-submit').show();
		if (Date.parse(requestedDate) === Date.parse(availableDates[0])) {
			$('.am-delivery').removeAttr('disabled');
		}
		else {
			$('.am-delivery').attr('disabled', 'disabled');
		}
		if ($('[id$=is-expedited').val() === 'true') {
			$('.expedite-reason').removeAttr('disabled');
		}
		else {
			$('.expedite-reason').attr('disabled', 'disabled');
		}
	}
	else {
		$('.expedite-reason').attr('disabled', 'disabled');
		$('.date-picker-field').prop('readonly', true);
		$('.am-delivery').attr('disabled', 'disabled');
		$('.primary-contact').prop('readonly', true);
		$('.primary-contact').parent().find('a').hide();
		$('.address-field').prop('readonly', true);
		$('.save-and-submit').hide();
	}
}

window.afterSaveShipment = hasErrors => {
	if (hasErrors === false) {
		$('.new-shipment-section').slideToggle();
		$('.new-shipment-button').prop('disabled', false);
		$('.product-selector').multiselect('uncheckAll');
		$('.package-selector').multiselect('uncheckAll');
		refreshContact();
	}
	else {
		$('.new-shipment-button').prop('disabled', true);
	}
}

window.cancel = (orderId, shipmentId) => {
	alertify.set({
		labels: {
			ok: 'Cancel It!',
			cancel: 'Go Back'
		}
	});
	alertify.confirm("Are you sure you want to cancel this order?", confirm => {
		if (confirm) {
			if (orderId == shipmentId) {
				cancelAndClearShipment(orderId);
			}
			else {
				cancelShipment(orderId);
			}
		}
	});
}

window.closeShipment = () => {
	$('.new-shipment-section').slideToggle();
	$('.product-selector').multiselect('uncheckAll');
	$('.package-selector').multiselect('uncheckAll');
}

window.makeDatePickers = () => {
	$('.date-picker-field').prop('readonly', true);
	$("[id$=new-shipment-pickup-date]").prop('readonly', true);
	$('.date-picker-field').datepicker({
		dateFormat: 'mm/dd/yy',
		minDate: 1,
		beforeShowDay: date => {
			let todaysDate = new Date();
			todaysDate.setHours(0,0,0,0);
			let formattedDate = (date.getMonth()+1); 
	        if (date.getMonth() < 9) {
	            formattedDate = "0" + formattedDate; 
	        }
	        formattedDate += "-"; 
	        
	        if (date.getDate() < 10) {
	        	formattedDate += "0"; 
	        }
	        formattedDate += date.getDate() + "-" + date.getFullYear(); 
	        	        
	        if (date.valueOf() === todaysDate.valueOf()) {
	        	return [false, "todays-date", "Today"];
	        }
	        else {
	        	let aDay = 24 * 60 * 60 * 1000;
		        if ($.inArray(formattedDate, availableDates) != -1) {
		        	if ($.inArray(formattedDate, expediteDates) != -1) {
		        		return [true, "expedite-date", "Expedite"];
		        	}
		        	return [true, "standard-date", "Standard Shipping"];
		        }
		        else {
		        	return [false, "", "Unavailable"];
		        }
	    	}
		},
		onSelect: date => {
			if ($.inArray(date.split('/').join('-'), expediteDates) != -1) {
				$('[id$=is-expedited').val(true);
				$('.expedite-reason').removeAttr('disabled');
				if (date.split("/").join("-") === availableDates[0]) {
					$('.am-delivery').removeAttr('disabled');
				}
				else {
					$('.am-delivery').attr('disabled', 'disabled');
					$('.am-delivery').prop('checked', false);
				}
			}
			else {
				$('[id$=is-expedited]').val(false);
				$('.expedite-reason').val('');
				$('.am-delivery').prop('checked', false);
				$('.expedite-reason').attr('disabled', 'disabled');
				$('.am-delivery').attr('disabled', 'disabled');
			}
			$('[id$=new-shipment-pickup-date]').val('');
			adjustPickupCalendar(date);
		}
	});
}

window.makeMultiSelectDropDowns = () => {
	$('.package-selector').multiselect({
		noneSelectedText: "Select Package",
		show: "fade",
		hide: "fade",
		header: "Package Catalog",
		multiple: false,
		selectedList: 1
	}).multiselectfilter({
		autoReset: true
	});
	$('.product-selector').multiselect({
		noneSelectedText: "Select Product(s)",
		show: "fade",
		hide: "fade",
		header: "Product Catalog"
	}).multiselectfilter({
		autoReset: true
	});
}

window.modify = orderId => {
	if ($('.new-shipment-section').css('display') != 'none') {
		alertify.set({
			labels: {
				ok: 'Continue',
				cancel: 'Go Back'
			}
		});
		alertify.confirm('You currently have an order open. Are you sure you want to close it and open this order instead?', confirm => {
			if (confirm) {
				$('.new-shipment-section').toggle();
				editShipment(orderId);
			}
		});
	}
	else {
		editShipment(orderId);
	}
}

window.newShipment = () => {
	makeDatePickers();
	makeMultiSelectDropDowns();
	$(".new-shipment-section").toggle("fade");
	$(".new-shipment-button").prop("disabled", true);
}

window.uncheckAll = selector => {
	$(selector).multiselect('uncheckAll');
}

window.validateQuantity = input => {
	let quantity = ~~Number($(input).val());
	if (String(quantity) === $(input).val() && quantity > 0) {
		$(input).css("background-color", "white");
	}
	else {
		$(input).val("");
		$(input).css("background-color", "pink");
	}
}