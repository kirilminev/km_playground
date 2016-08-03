import React, {Component} from 'react';
import {APEX} from '../lib/constants';

export class PageMessage extends Component {
	constructor(props, context) {
		super(props, context);

		if (props.timeOut) {
			setTimeout(() => {
				props.onClick(props.messageId);
			}, props.timeOut);
		}

		this.handleClick = this.handleClick.bind(this);
	}
	handleClick() {
		if (typeof this.props.onClick === 'function') {
			console.log(this.props.key);
			this.props.onClick(this.props.messageId);
		}
	}
	render() {
		let {message} = this.props;
		return (
			<div className="slds-notify slds-notify--alert slds-theme--error slds-theme--alert-texture" role="alert">
				<button className="slds-button slds-button--icon-inverse slds-notify__close" onClick={this.handleClick}>
					<svg aria-hidden="true" className="slds-button__icon">
						<use xlinkHref={APEX.lightningDesign + '/assets/icons/utility-sprite/svg/symbols.svg#close'}></use>
					</svg>
				</button>
				<div className="notify__content">
					<h2 className="slds-text-heading--small">{message}</h2>
				</div>
			</div>
		);
	}
}