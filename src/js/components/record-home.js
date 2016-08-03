import React, {Component} from 'react';
import {APEX} from '../lib/constants';

export class RecordHome extends Component {
	render() {
		let {
			icon,
			info,
			title
		} = this.props;
		return (
			<div className="slds-page-header" role="banner">
				<div className="slds-media">
					{icon
					? 	<div className="slds-media__figure">
							<svg aria-hidden="true" className="slds-icon slds-icon--large slds-icon-standard-account">
								<use xlinkHref={APEX.lightningDesign + icon}></use>
							</svg>
						</div>
					: 	undefined}
					<div className="slds-media__body">
						<p className="slds-page-header__title slds-align-middle">{title}</p>
						{info
						? 	<p className="slds-text-body--small slds-page-header__info">{info}</p>
						: 	undefined}
					</div>
				</div>
			</div>
		);
	}
}