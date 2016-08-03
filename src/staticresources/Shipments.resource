/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports) {

	"use strict";

	window.adjustPickupCalendar = function (arrivalDate) {
		var theDayAfter = new Date(arrivalDate);
		theDayAfter.setDate(theDayAfter.getDate() + 1);
		$("[id$=new-shipment-pickup-date]").datepicker({
			dateFormat: "mm/dd/yy",
			beforeShowDay: function beforeShowDay(date) {
				var todaysDate = new Date();
				todaysDate.setHours(0, 0, 0, 0);
				var formattedDate = date.getMonth() + 1;
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
				} else {
					return [false, "", "Unavailable"];
				}
			}
		});
		$("[id$=new-shipment-pickup-date]").datepicker("option", "minDate", theDayAfter);
	};

	window.afterCancelShipment = function (hasErrors) {
		if (hasErrors === false) {
			clearShipment();
			$('.new-shipment-section').slideToggle();
			$('.new-shipment-button').prop('disabled', false);
		} else {
			$('.new-shipment-button').prop('disabled', true);
		}
	};

	window.afterCloseShipment = function () {
		$('.new-shipment-button').prop('disabled', false);
		$('.address-field').prop('readonly', false);
		$('.save-and-submit').show();
		refreshContact();
	};

	window.afterEditShipment = function (shipped, requestedDate) {
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
				$('.am-delivery-section').show();
			}
		} else {
			$('.date-picker-field').prop('readonly', true);
			$('.am-delivery-section').attr('disabled', 'disabled');
			$('.am-delivery-section').show();
			$('.primary-contact').prop('readonly', true);
			$('.primary-contact').parent().find('a').hide();
			$('.address-field').prop('readonly', true);
			$('.save-and-submit').hide();
		}
	};

	window.afterSaveShipment = function (hasErrors) {
		if (hasErrors === false) {
			$('.new-shipment-section').slideToggle();
			$('.new-shipment-button').prop('disabled', false);
			$('.product-selector').multiselect('uncheckAll');
			$('.package-selector').multiselect('uncheckAll');
			refreshContact();
		} else {
			$('.new-shipment-button').prop('disabled', true);
		}
	};

	window.cancel = function (orderId, shipmentId) {
		alertify.set({
			labels: {
				ok: 'Cancel It!',
				cancel: 'Go Back'
			}
		});
		alertify.confirm("Are you sure you want to cancel this order?", function (confirm) {
			if (confirm) {
				if (orderId == shipmentId) {
					cancelAndClearShipment(orderId);
				} else {
					cancelShipment(orderId);
				}
			}
		});
	};

	window.closeShipment = function () {
		$('.new-shipment-section').slideToggle();
		$('.product-selector').multiselect('uncheckAll');
		$('.package-selector').multiselect('uncheckAll');
	};

	window.highlightRows = function () {
		$('.shipping-item-pb-table tbody tr').each(function () {
			if ($.inArray($(undefined).find('td:nth-child(2)').text(), window.productCodes) != -1) {
				$(undefined).effect('highlight', { color: 'lightgreen' }, 1000);
			}
		});
	};

	window.makeDatePickers = function () {
		$('.date-picker-field').prop('readonly', true);
		$('.date-picker-field').datepicker({
			dateFormat: 'mm/dd/yy',
			minDate: 1,
			beforeShowDay: function beforeShowDay(date) {
				var todaysDate = new Date();
				todaysDate.setHours(0, 0, 0, 0);
				var formattedDate = date.getMonth() + 1;
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
				} else {
					var aDay = 24 * 60 * 60 * 1000;
					if ($.inArray(formattedDate, availableDates) != -1) {
						if ($.inArray(formattedDate, expediteDates) != -1) {
							return [true, "expedite-date", "Expedite"];
						}
						return [true, "standard-date", "Standard Shipping"];
					} else {
						return [false, "", "Unavailable"];
					}
				}
			},
			onSelect: function onSelect(date) {
				if ($.inArray(date.split('/').join('-'), expediteDates) != -1) {
					alertify.set({
						labels: {
							ok: 'OK',
							cancel: 'Cancel'
						}
					});
					alertify.prompt('You have chosen a date of arrival which will require this shipment to be expedited. Please enter a reason for expediting this shipment.', function (confirm, str) {
						if (confirm) {
							if (str === '') {
								alertify.error('You must enter a reason for expediting this shipment.');
								$('.date-picker-field').val('');
							} else {
								//A reason was entered, so continue with the expedited shipment.
								$('[id$=is-expedited').val(true);
								$('[id$=expedite-reason]').val(str);
								//See if this particular day is the next available day, and if it is, present the user with the AM delivery option.
								if (date.split("/").join("-") === availableDates[0]) {
									$(".am-delivery-section").show("fade");
								}
							}
						} else {
							$('.date-picker-field').val('');
						}
					});
				} else {
					$('[id$=is-expedited]').val(false);
					$('[id$=expedite-reason]').val('');
				}
			}
		});
	};

	window.makeMultiSelectDropDowns = function () {
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
	};

	window.modify = function (orderId) {
		if ($('.new-shipment-section').css('display') != 'none') {
			alertify.set({
				labels: {
					ok: 'Continue',
					cancel: 'Go Back'
				}
			});
			alertify.confirm('You currently have an order open. Are you sure you want to close it and open this order instead?', function (confirm) {
				if (confirm) {
					$('.new-shipment-section').toggle();
					editShipment(orderId);
				}
			});
		} else {
			editShipment(orderId);
		}
	};

	window.newShipment = function () {
		makeDatePickers();
		makeMultiSelectDropDowns();
		$(".new-shipment-section").toggle("fade");
		$(".new-shipment-button").prop("disabled", true);
	};

	window.validateQuantity = function (input) {
		var quantity = ~ ~Number($(input).val());
		if (String(quantity) === $(input).val() && quantity > 0) {
			$(input).css("background-color", "white");
		} else {
			$(input).val("");
			$(input).css("background-color", "pink");
		}
	};

/***/ }
/******/ ]);