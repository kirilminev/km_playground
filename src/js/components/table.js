import React, {Component} from 'react';

export class Table extends Component {
	static propTypes = {
		columns: React.PropTypes.array.isRequired,
		data: React.PropTypes.array
	};
	constructor(props, context) {
		super(props, context);
		this.state = {};

		this.renderColumnHeader = this.renderColumnHeader.bind(this);
		this.renderRow = this.renderRow.bind(this);
	}
	renderColumnHeader(data) {
		return (
			<th scope="col">
				<span className="slds-truncate">{data.label}</span>
			</th>
		);
	}
	renderRow(data) {
		var cells = [];
		this.props.columns.forEach((column) => {
			cells.push(<td className={"slds-size--1-of-" + this.props.columns.length} data-label={column.label}>{data[column.name]}</td>);
		});
		return (
			<tr className="slds-hint-parent">
				{cells}
			</tr>
		);
	}
	render() {
		return (
			<table className="slds-table slds-table--bordered">
				<thead>
					<tr className="slds-text-heading--label">
						{this.props.columns.map(this.renderColumnHeader)}
					</tr>
				</thead>
				<tbody>
					{this.props.data.map(this.renderRow)}
				</tbody>
			</table>
		);
	}
}