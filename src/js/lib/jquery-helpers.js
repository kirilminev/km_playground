import $ from 'jquery';

/**
* DO NOT USE
* This is deprecated, use the jquery-helpers module located in the  helpers dir instead!
*
**/

export function setListeners(listeners) {
	if (listeners) {
		listeners.forEach((listener) => {
			$(listener.selector).on(listener.event, listener.action);
		});
	}
}