import $ from 'jquery'; window.$ = window.jQuery = $;
import {Details} from '../classes/details';
import '../classes/shipment';

const listeners = [
	{
		selector: ".slds-tabs--default__link",
		event: "click",
		action: function() {
			$(".slds-active").removeClass("slds-active");
			$(this).parent().addClass("slds-active");
			var content = $("#" + $(this).attr("id") + "--content");
			if ($(content).hasClass("slds-hide")) {
				$(".slds-show").removeClass("slds-show").addClass("slds-hide");
				$(content).removeClass("slds-hide").addClass("slds-show");
			}
		}
	}
];

class AccountDetails extends Details {
	constructor(listeners) {
		super(listeners);
	}
}

let details = new AccountDetails(listeners);