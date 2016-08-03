/**
This component displays a table of data with a header. If props.data is undefined,
it will display an empty table with the text "There is nothing here yet." along
with an action button if specified in props.emptyButtonText.
**/
import React, {Component} from 'react';

import {Button} from './button';
import {CardHeader} from './card-header';

export class Card extends Component {
	render() {
		let {
			button,
			children,
			style,
			text
		} = this.props;
		return (
			<div style={style} className={"slds-card" + (children ? '' : ' slds-card--empty')}>
				<CardHeader text={text} button={children ? button : undefined} />
				{children
				?	<div className="slds-card__body">
						{children}
					</div>
				:	<div className="slds-card__body slds-p-horizontal--small">
						<h3 className="slds-text-heading--small slds-p-top--large slds-p-bottom--large">There is nothing here yet.</h3>
						{button}
					</div>
				}
			</div>
		);
	}
}