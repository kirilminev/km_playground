import {APEX} from '../../lib/constants';
import {RemoteAction} from '../../helpers/remoting-helpers';
import {getParameterByName} from '../../helpers/url-helpers';

import {addMessage} from '../general/actions';

import {createAction} from 'redux-actions';
import * as actionTypes from './action-types';

export const addProvider = createAction(actionTypes.ADD_PROVIDER, (provider = {}) => ({...provider, key: provider.Id || Date.now()}));
export const getOptions = createAction(actionTypes.GET_OPTIONS, dispatch => {
	new RemoteAction(APEX.getOptions, getParameterByName('refnum'))
		.invoke({escape: false})
		.then(result => {
			dispatch(receiveOptions(result));
		})
		.catch(error => {

		});
});
export const receiveOptions = createAction(actionTypes.RECEIVE_OPTIONS);
export const removeProvider = createAction(actionTypes.REMOVE_PROVIDER);
export const setAccount = createAction(actionTypes.SET_ACCOUNT);
export const setLoadingState = createAction(actionTypes.SET_LOADING_STATE);
export const setStep = createAction(actionTypes.SET_STEP);
export const save = createAction(actionTypes.SAVE, (args, dispatch) => {
	dispatch(setLoadingState(true));
	new RemoteAction(APEX.save, ...args)
		.invoke()
		.then(result => {
			window.location.href = 'http://www.contextmediahealth.com/congratulations/';
		})
		.catch(error => {
			dispatch(setLoadingState(false));
			dispatch(addMessage('There was an unexpected error while submitting this form. Double check that all required fields have been filled out prior to submitting again.'));
		})
});
export const updateModel = createAction(actionTypes.UPDATE_MODEL);
export const updateProvider = createAction(actionTypes.UPDATE_PROVIDER);