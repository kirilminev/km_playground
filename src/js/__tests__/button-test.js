import React from 'react';
import TestUtils from 'react-addons-test-utils';
import expect from 'expect';

import {Button} from '../components/button';

it('renders a button', () => {
	let tree = TestUtils.renderIntoDocument(
		<Button	label="Test"/>
	);

	let button = TestUtils.findRenderedDOMComponentWithTag(tree, 'button');
	
	expect(button.textContent).toEqual('Test');
	expect(button.className).toEqual('slds-button slds-button--neutral');
});