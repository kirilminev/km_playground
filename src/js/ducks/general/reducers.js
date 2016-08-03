import {handleAction} from 'redux-actions';
import * as actionTypes from './action-types';

export const addMessage = handleAction(actionTypes.ADD_MESSAGE, {
	next(state = { messages: [] }, action) {
		return action.payload
			   ? Object.assign({}, state, { messages: [...state.messages, action.payload] })
			   : state
		;
	},
	throw(state = { messages: [] }, action) {
		return action.error
			   ? Object.assign({}, state, { messages: [...state.messages, action.error] })
			   : state
		;
	}
});

export const removeMessage = handleAction(actionTypes.REMOVE_MESSAGE, {
	next(state = { messages: [] }, action) {
		return action.payload
			   ? Object.assign({}, state, { messages: state.messages.filter(message => message.messageId !== action.payload) })
			   : state
		;
	},
	throw(state = { messages: [] }, action) {
		return action.error
			   ? Object.assign({}, state, { messages: [...state.messages, action.error] })
			   : state
		;
	}
});