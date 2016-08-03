import React, {Component} from 'react';

import {APEX} from '../lib/constants';
import {connection} from '../lib/sforce-helpers';

import {Button} from './button';
import {Card} from './card';

export class Assets extends Component {
	constructor(props, context) {
		super(props, context);
		this.state = {};
		console.log("assets constructor.");

		this.update = this.update.bind(this);
	}
	componentDidMount() {
		connection("describeLayout", "account", APEX.account_recordtype_id)
			.then(layout => {
				console.log(layout);
			})
			.catch(err => {
				console.error(err);
			});
	}
	update() {
		AccountDetailsController.updateAssets((result, event) => {
			console.log(result);
		});
	}
	render() {
		return (
			<div>
				<Card
					columns={[
						{"name" : "Name", "label" : "Asset ID"},
						{"name" : "Type__c", "label" : "Type"},
						{"name" : "status", "label" : "Status"},
						{"name" : "last_seen_at", "label" : "Last Seen At"}
					]}
					data={this.state.assets}
					emptyButtonText="Add Asset"
					headerClassName="slds-text-heading--small"
					iconClassName="slds-icon slds-icon--small slds-icon-standard-asset"
					iconLink="/assets/icons/standard-sprite/svg/symbols.svg#asset"
					text="Assets"
				/>
				<Button
					label="Update"
					onClick={this.update}
					size="large"
					type="brand"
				/>
			</div>
		);
	}
}