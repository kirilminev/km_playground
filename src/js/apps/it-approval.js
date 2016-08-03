import React, {Component} from 'react'; window.React = React;
import ReactDOM from 'react-dom';
import {APEX} from '../lib/constants';
import {Card} from '../components/card';

class ItApproval extends Component {
	constructor(props, context) {
		super(props, context);
		this.state = {};
	}
	render() {
		return (
			<div>
				{this.props.status === "not started"
				?	<Card
						columns={[""]}
						emptyButtonText="Get Started"
						headerClassName="slds-text-heading--small"
						iconClassName="slds-icon slds-icon--small slds-icon-standard-product"
						iconLink="/assets/icons/standard-sprite/svg/symbols.svg#product"
						text="IT Approval"
					/>
				: 	null}
			</div>
		);
	}
}

ReactDOM.render(
	<ItApproval
	/>,
	document.getElementById("ItApproval")
);