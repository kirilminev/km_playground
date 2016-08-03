import React, {Component} from 'react';

export class HeaderField extends Component {
	static propTypes = {
		label: React.PropTypes.string.isRequired
	};
	constructor() {
		super();
		this.state = {};
	}
	render() {
		return (
			<dl>
				<dt>
					<p className="slds-text-heading--label">{this.props.label}</p>
				</dt>
				<dd>
					<p className="slds-text-body--regular">{this.props.value}</p>
				</dd>
			</dl>
		);
	}
}