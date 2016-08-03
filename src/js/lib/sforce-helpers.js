import Promise from 'bluebird';

/**
* This will allow for calling methods on "sforce.connection" with Promises
* returned.
*
* Usage...
* ```javascript
*     import {connection} from '../lib/sforce-helpers/connection';
*
*     connection('describeLayout', 'account', ['SOME_ACCOUNT_RECORD_TYPE_ID'])
*         .then(layout => {
*             // Do something with that layout bullshit yo!
*         })
*         .catch(err => { console.error(err); })
*     ;
* ```
*/

export function connection(method, ...args) {
	return new Promise((resolve, reject) => {
		let finalArgs = args.concat({onSuccess: resolve, onFailure: reject});
		window.sforce.connection[method](...finalArgs);
	});
}