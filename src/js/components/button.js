import React, {Component} from 'react';

const baseClass = 'slds-button';

export class Button extends Component {
	static propTypes = {
		disabled: React.PropTypes.bool,
		icon: React.PropTypes.shape({
			src: React.PropTypes.string,
			type: React.PropTypes.string,
			location: React.PropTypes.oneOf(['left', 'right'])
		}),
		label: React.PropTypes.string,
		onClick: React.PropTypes.func,
		type: React.PropTypes.oneOf(['brand', 'destructive', 'inverse', 'neutral'])
	};
	constructor(props, context) {
		super(props, context);

		this.handleClick = this.handleClick.bind(this);
	}
	handleClick() {
		if (typeof this.props.onClick === 'function') {
			this.props.onClick();
		}
	}
	render() {
		let {
			disabled,
			icon,
			label,
			style,
			type
		} = this.props;

		let iconLocation = icon ? icon.location || 'left' : 'left';

		return (
			<button style={style} className={baseClass + ' slds-button--' + (type || 'neutral')} disabled={disabled || false}	type="button" onClick={this.handleClick}>
				{iconLocation === 'right' ? label : null}
				{icon ? <svg aria-hidden className={(icon.location ? ' slds-button__icon--' + icon.location : null) + ' slds-button__icon--stateful'}>
					    	<use xlinkHref={icon.src}></use>
					    </svg>
					  : null}
				{iconLocation === 'left' ? label : null}
			</button>
		);
	}
}