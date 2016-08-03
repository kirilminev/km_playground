import React, {Component} from 'react';

import {Button} from './button';

export class ButtonGroup extends Component {
	static propTypes = {
		buttons: React.PropTypes.array
	};
	constructor(props, context) {
		super(props, context);
		this.state = {};

		this.renderButton = this.renderButton.bind(this);
	}
	renderButton(data) {
		return (
			<Button
				key={data.label}
				icon={data.icon}
				label={data.label}
				onClick={data.onClick}
				size={data.size}
				type={data.type}
			/>
		);
	}
	render() {
		return (
			<div className="slds-button-group" role="group">
				{this.props.buttons.map(this.renderButton)}
			</div>
		);
	}
}