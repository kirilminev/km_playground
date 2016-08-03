import $ from 'jquery'; window.$ = window.jQuery = $;
import 'jquery-ui/effect-fade';

import {RemoteAction} from '../lib/remoting-helpers';
import {signupListeners} from '../listeners/signup-listeners';
import {setListeners} from '../lib/jquery-helpers';

import '../classes/signup';
import {APEX} from '../lib/constants';

class Signup {
	constructor() {
		new RemoteAction(SignupController.getOptions)
				.invoke({escape: false})
				.then(result => {
					let clinicSpecialties = $();

					result.clinicSpecialty.forEach(specialty => {
						let specialtyTemplate = $('#checkbox-template div').clone();
						specialtyTemplate.find('.slds-form-element__label').text(specialty);
						specialtyTemplate.find('input').attr('id', specialty).data('demographics', result.demographics[specialty]);
						specialtyTemplate.find('input').change(function() {
							if ($('#specialties-form').find('input:checked').length > 0 && $("[specialty='All']").length === 0) {
								buildDemographics("All", result.demographics.All);
							}
							if ($(this).prop('checked')) {
								buildDemographics(specialty, $(this).data('demographics'));
								$('#specialties-form').find('.slds-checkbox--faux').removeClass('has-error');
							}
							displayDemographics();
						});

						clinicSpecialties = clinicSpecialties.add(specialtyTemplate);
					});
					$('#specialties-form').append(clinicSpecialties);
					addOptions('#facility-type', result.facilityType);
			        addOptions('#provider-specialty', result.providerSpecialty);
			        addOptions('#contact-title', result.title);
			        addOptions('#provider-title', result.title);
			        addOptions('.wait-times', result.waitTimes);

			        let states = $();
			        result.state.forEach(state => {
			        	let option = document.createElement('option');
			        	option.text = state;
			        	option.value = state;
			        	states = states.add(option);
			        });
			        $('#billing-state').append(states);

			        $('#reference-number').val(APEX.referenceNumber).change();
				})
				.catch(error => {

				});

		setListeners(signupListeners);
	}
}

let signup = new Signup();