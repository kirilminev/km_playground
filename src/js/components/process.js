import React, {Component} from 'react';

import {APEX} from '../lib/constants';

export class Process extends Component {
	constructor(props, context) {
		super(props, context);

		this.renderStep = this.renderStep.bind(this);
	}
	handleClick(step) {
		if (typeof this.props.onChangeStep === 'function') {
			this.props.onChangeStep(step);
		}
	}
	renderStep(step) {
		let {
			currentStep,
			steps
		} = this.props;
		let className = 'slds-tabs--path__item';
		if (step === currentStep) {
			className += ' slds-is-current';
		}
		else {
			if (steps.indexOf(step) < steps.indexOf(currentStep)) {
				className += ' slds-is-complete';
			}
			else {
				className += ' slds-is-incomplete';
			}
		}
		return (
			<li key={step} className={className} role="presentation">
				<a className="slds-tabs--path__link" role="tab" href="javascript:void(0);" onClick={this.handleClick.bind(this, step)}>
					<span className="slds-tabs--path__stage">
						<svg aria-hidden="true" className="slds-icon slds-icon--x-small">
							<use xlinkHref={APEX.lightningDesign + '/assets/icons/utility-sprite/svg/symbols.svg#check'}></use>
						</svg>
					</span>
					<span className="slds-tabs--path__title">{step}</span>
				</a>
			</li>
		);
	}
	render() {
		let {steps} = this.props;
		return (
			<div className="slds-tabs--path" role="application">
				<ul className="slds-tabs--path__nav" role="tablist">
					{steps.map(this.renderStep)}
				</ul>
			</div>
		);
	}
}