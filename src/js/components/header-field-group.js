import React, {Component} from 'react';

import {HeaderField} from './header-field';

export class HeaderFieldGroup extends Component {
	static propTypes = {
		fields: React.PropTypes.array.isRequired
	};
	constructor(props, context) {
		super(props, context);
		this.state = {};

		this.renderHeaderField = this.renderHeaderField.bind(this);
	}
	renderHeaderField(data) {
		return (
			<div key={data.label} className={"slds-col--padded slds-size--1-of-" + this.props.fields.length}>
				<HeaderField
					key={data.label}
					label={data.label}
					value={data.value}
				/>
			</div>
		);
	}
	render() {
		return (
			<div className={this.props.className}>
				{this.props.fields.map(this.renderHeaderField)}
			</div>
		);
	}
}