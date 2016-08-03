import React, {Component} from 'react';
import {APEX} from '../lib/constants';

import {Button} from './button';

const BASE_ICON_CLASS = "slds-icon";

export class Media extends Component {
	static propTypes = {
		button: React.PropTypes.shape({
			icon: React.PropTypes.shape({
				src: React.PropTypes.string,
				size: React.PropTypes.string,
				type: React.PropTypes.oneOf(["brand", "destructive", "inverse", "neutral"])
			}),
			label: React.PropTypes.string,
			size: React.PropTypes.string,
			type: React.PropTypes.string
		}),
		icon: React.PropTypes.shape({
			class: React.PropTypes.string,
			size: React.PropTypes.oneOf(["x-small", "small", "large"]),
			src: React.PropTypes.string,
			type: React.PropTypes.string,
			location: React.PropTypes.oneOf(["left", "right"])
		}).isRequired,
		label: React.PropTypes.string.isRequired,
		text: React.PropTypes.string.isRequired
	};
	constructor(props, context) {
		super(props, context);
		this.state = {};
	}
	render() {
		return (
			<div className="slds-media">
				<div className="slds-media__figure">
					<svg aria-hidden className={BASE_ICON_CLASS + " slds-icon--" + (this.props.icon.size || "large") + " " + this.props.icon.class}>
						<use xlinkHref={APEX.lightning_design + this.props.icon.src}></use>
					</svg>
				</div>
				<div className="slds-media__body">
					{this.props.label === undefined
						? null
						: <p className="slds-text-heading--label">{this.props.label}</p>}
					<div className="slds-grid">
						<h1 className={this.props.headerClassName} title={this.props.text}>{this.props.text}</h1>
						<div className="slds-col slds-shrink-none">
							{this.props.button === undefined
								? null
								: <Button
									icon={this.props.button.icon}
									label={this.props.button.label}
									onClick={this.props.button.onClick}
									size={this.props.button.size}
									type={this.props.button.type}
								  />}
						</div>
					</div>
				</div>
			</div>
		);
	}
}