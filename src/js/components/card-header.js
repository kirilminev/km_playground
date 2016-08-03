import React, {Component} from 'react';

import {Button} from './button';

const baseClass = 'slds-card__header';

export class CardHeader extends Component {
	render() {
		let {button} = this.props;
		return (
			<div className={baseClass + (button ? ' slds-grid' : '')}>
				<h2 className="slds-text-heading--small slds-truncate">{this.props.text}</h2>
				{button
				? <Button style={{margin:'auto'}} {...button.props} />
				: undefined}
			</div>
		);
	}
}