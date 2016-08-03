import React, {Component} from 'react';

import {Card} from './card';

export class Shipments extends Component {
	constructor(props, context) {
		super(props, context);
		this.state = {};
	}
	render() {
		return (
			<div>
				<Card
					columns={["Order ID", "Type", "Status"]}
					emptyButtonText="Add Shipment"
					headerClassName="slds-text-heading--small"
					iconClassName="slds-icon slds-icon--small slds-icon-standard-product"
					iconLink="/assets/icons/standard-sprite/svg/symbols.svg#product"
					text="Shipments"
				/>
			</div>
		);
	}
}