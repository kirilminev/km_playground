import {APEX} from '../../lib/constants';
import {RemoteAction} from '../../helpers/remoting-helpers';

import {createAction} from 'redux-actions';
import * as actionTypes from './action-types';

export const addMessage = createAction(actionTypes.ADD_MESSAGE, (message, timeOut) => ({
	key: Date.now(),
	message: message,
	messageId: Date.now(),
	timeOut: timeOut
}));
export const removeMessage = createAction(actionTypes.REMOVE_MESSAGE);