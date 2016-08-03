import $ from 'jquery'; window.$ = window.jQuery = $;
import {APEX} from '../lib/constants';
import {RemoteAction} from '../lib/remoting-helpers';
import {listeners} from '../listeners/close-case-dialog';
import {
	addOptions,
	setListeners
} from '../helpers/jquery-helpers';
import '../classes/shipment';

class CaseDetails {
	constructor(listeners) {
		new RemoteAction(APEX.getOptions, APEX.caseId)
			.invoke()
			.then(options => {
				if (options.assets.length > 0) {
					$("#empty-assets-text").hide();
					options.assets.forEach(asset => {
						let assetRow = $("#asset-template").clone();
						assetRow.data("asset", asset);
						addOptions(assetRow.find('#outlet-lock-reason'), options.outletLockReasons);
						assetRow.children().each((index, cell) => {
							cell = $(cell);
							switch (cell.attr("data-label")) {
								case "Installed":
									cell.find("input").prop("checked", asset.Status === "Installed");
									break;
								case "Outlet Lock":
									cell.find("#outlet-lock-reason").val(asset.Outlet_Lock_Reason__c).prop("selected", true);
									break;
							}
							if (cell.attr("fieldname")) {
								if (cell.attr("fieldname") === "Product2") {
									if (asset.Product2) {
										cell.text(asset.Product2.ProductCode);
									}
								}
								else {
									cell.text(asset[cell.attr("fieldname")]);
								}
							}
						});
						assetRow.show();
						$("#asset-table").append(assetRow);
					});
				}
				else {
					$("#assets-table").hide();
				}
				
				if (options.case.Status === "Closed") {
					$(".slds-checkbox").find("input").prop("disabled", true);
					$(".slds-select").prop("disabled", "disabled");
				}
			})
			.catch(err => {
				alertify.error(err);
			});

		setListeners(listeners);
	}
}

let details = new CaseDetails(listeners);