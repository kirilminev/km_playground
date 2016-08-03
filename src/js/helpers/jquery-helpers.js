import $ from 'jquery';

export function addOptions(element, values) {
	let options = $();
	values.forEach(value => {
		let option = document.createElement('option');
		option.text = value;
		option.value = value;
		options = options.add(option);
	});
	element.append(options);
}

export function setListeners(listeners) {
	if (listeners) {
		listeners.forEach((listener) => {
			$(listener.selector).on(listener.event, listener.action);
		});
	}
}