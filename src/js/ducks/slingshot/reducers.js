import {handleAction} from 'redux-actions';
import * as actionTypes from './action-types';

export const addProvider = handleAction(actionTypes.ADD_PROVIDER, {
	next(state = { providers: [] }, action) {
		return action.payload
			   ? Object.assign({}, state, { providers: [...state.providers, action.payload] })
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

export const getOptions = handleAction(actionTypes.GET_OPTIONS, {
	next(state = { status: '' }, action) {
		return action.payload
			   ? Object.assign({}, state, { status: action.payload })
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

export const receiveOptions = handleAction(actionTypes.RECEIVE_OPTIONS, {
	next(state = { options: {} }, action) {
		return action.payload
			   ? Object.assign({}, state, { options: Object.assign({}, state.options, action.payload) })
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

export const removeProvider = handleAction(actionTypes.REMOVE_PROVIDER, {
	next(state = { providers: [] }, action) {
		return action.payload
			   ? Object.assign({}, state, { providers: state.providers.filter(provider => provider.key !== action.payload) })
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

export const setAccount = handleAction(actionTypes.SET_ACCOUNT, {
	next(state = { account: undefined }, action) {
		return action.payload
			   ? Object.assign({}, state, { account: action.payload })
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

export const setLoadingState = handleAction(actionTypes.SET_LOADING_STATE, {
	next(state = { loading: false }, action) {
		return Object.assign({}, state, { loading: action.payload });
	},
	throw(state = { messages: [] }, action) {
		return action.error
			   ? Object.assign({}, state, { messages: [...state.messages, action.error] })
			   : state
		;
	}
});

export const setStep = handleAction(actionTypes.SET_STEP, {
	next(state = { currentStep: undefined }, action) {
		return action.payload
			   ? Object.assign({}, state, { currentStep: action.payload })
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

export const updateModel = handleAction(actionTypes.UPDATE_MODEL, {
	next(state = {}, action) {
		return action.payload
			   ? Object.assign({}, state, action.payload)
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

export const updateProvider = handleAction(actionTypes.UPDATE_PROVIDER, {
	next(state = {}, action) {
		return action.payload
			   ? Object.assign({}, state, {providers: state.providers.map(provider => {
					if (provider.key === action.payload.key) {
						return Object.assign({}, provider, action.payload);
					}
					return provider;
			   })})
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