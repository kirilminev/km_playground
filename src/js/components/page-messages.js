import React, {Component} from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import {connect} from 'react-redux';

import {removeMessage} from '../ducks/general/actions';

import {PageMessage} from './page-message';

const baseClass = 'slds-notify_container';

class PageMessages extends Component {
	constructor(props, context) {
		super(props, context);

		this.handleRemove = this.handleRemove.bind(this);
		this.renderMessage = this.renderMessage.bind(this);
	}
	handleRemove(messageId) {
		this.props.dispatch(removeMessage(messageId));
	}
	renderMessage(message) {
		return <PageMessage key={message.key} message={message.message} messageId={message.messageId} onClick={this.handleRemove} timeOut={message.timeOut}/>;
	}
	render() {
		return (
			<div className={baseClass}>
				<ReactCSSTransitionGroup transitionName="fade" transitionAppear={true} transitionTimeout={500}>
					{this.props.messages.map(this.renderMessage)}
				</ReactCSSTransitionGroup>
			</div>
		);
	}
}

export default connect(state => ({
	messages: state.messages
}))(PageMessages);