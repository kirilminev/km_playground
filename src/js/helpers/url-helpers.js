/**
* Use this method to get page parameters...
*
*	getParameterByName('query', 'https://google.com/search?query=12345')
*
* 	'12345'
**/


export function getParameterByName(name, url) {
	if (!url) {
		url = window.location.href;
	}
	name = name.replace(/[\[\]]/g, "\\$&");
	let regEx = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
	let results = regEx.exec(url);
	if (!results) {
		return null;
	}
	if (!results[2]) {
		return '';
	}
	return decodeURIComponent(results[2].replace(/\+/g, " "));
}