import 'core-js';
import React, {Component} from 'react'; window.React = React;
import ReactDOM from 'react-dom';
import {
	applyMiddleware,
	createStore,
	combineReducers
} from 'redux';
import createLoggerMiddleware from 'redux-logger';
import promiseMiddleware from 'redux-promise';
import {Provider} from 'react-redux';

import {APEX} from '../lib/constants';
import reducers from '../ducks/general';
import slingshotReducers from '../ducks/slingshot';

import Slingshot from '../components/slingshot';

const reducerSet = []
	.concat(Object.values(reducers))
	.concat(Object.values(slingshotReducers));

function rootReducer(state, action) {
	return reducerSet
		.reduce((prevState, reducer) => reducer(prevState, action), state)
	;
}

const store = applyMiddleware(
	promiseMiddleware,
	createLoggerMiddleware({
		//[logger config](https://github.com/fcomb/redux-logger#options)
		actionTransformer: action => ({
			...action,
			type: String(action.type)
		})
	})
)(createStore)
(rootReducer, {
	alternateContact: {},
	contact: {},
	itapproval: {},
	messages: [],
	options: { ShipToPracticeManager: true },
	providers: [],
	schedulabledays: {Monday: false, Tuesday: false, Wednesday: false, Thursday: false, Friday: false, Saturday: false},
	specialties: {},
	workorder: {}
});

ReactDOM.render(
	<Provider store={store}>
		<Slingshot />
	</Provider>,
	document.getElementById('root')
);