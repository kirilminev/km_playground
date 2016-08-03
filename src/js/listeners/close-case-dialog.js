import $ from 'jquery';
import {APEX} from '../lib/constants';
import {RemoteAction} from '../lib/remoting-helpers';

export const listeners = [
	{
		selector: "#close-case-cancel",
		event: "click",
		action: function() {
			$("#close-case").hide("fade");
		}
	},
	{
		selector: "#close-case-save",
		event: "click",
		action: function() {
			let assets = [];
			$("#asset-table").children().each((index, row) => {
				row = $(row);
				if (row.data("asset")) {
					let asset = row.data("asset");
					
					if (row.find("#installed").prop("checked")) {
						let todaysDate = new Date();
						asset.InstalledDate__c = todaysDate.setHours(0,0,0,0);
						asset.Installation_Status__c = "Active";
						asset.Status = "Installed";
					}
					else {
						asset.Installation_Status__c = "Inactive";
						asset.Status = "Returning";
					}
					asset.Outlet_Lock_Reason__c = row.find("#outlet-lock-reason").val();
					asset.Status = row.find("#installed").prop("checked") === true ? "Installed" : "Returning";
					assets.push(asset);
				}
			});
			$("#close-case").hide("fade");
			$("[id$=save-status]").find("span").show();
			
			new RemoteAction(APEX.close, APEX.caseId, assets)
				.invoke()
				.then(() => {
					window.location.reload();
				})
				.catch(err => {
					alertify.error(err);
					$("[id$=save-status]").find("span").hide();
				});
		}
	},
	{
		selector: ".slds-tabs--default__link",
		event: "click",
		action: function() {
			$(".slds-active").removeClass("slds-active");
			$(this).parent().addClass("slds-active");
			let content = $("#" + $(this).attr("id") + "--content");
			if (content.hasClass("slds-hide")) {
				$(".slds-show").removeClass("slds-show").addClass("slds-hide");
				content.removeClass("slds-hide").addClass("slds-show");
			}
		}
	},
	{
		selector: "[id$=new-shipment-requested-date]",
		event: "change",
		action: function() {
			adjustPickupCalendar($(this).val());
			$("[id$=new-shipment-pickup-date]").val("");
		}
	}
];