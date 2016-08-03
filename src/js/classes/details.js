import $ from 'jquery';
import {setListeners} from '../lib/jquery-helpers';

export class Details {
	constructor(listeners) {
		setListeners(listeners);
	}
}