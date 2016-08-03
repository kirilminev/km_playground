import $ from 'jquery';
import 'jquery-ui/effect-fade';

import {RegEx} from '../lib/constants';
import {RemoteAction} from '../lib/remoting-helpers';

window.addOptions = (selector, values) => {
	let options = $();
	values.forEach(value => {
		let option = document.createElement('option');
		option.text = value;
		option.value = value;
		options = options.add(option);
	});
	$(selector).append(options);
}

window.addProvider = () => {
	let errors = [];
	$(document.forms['provider-form'].elements).each((index, element) => {
		if ($(element).prop('required') && ($(element).val() === '' || $(element).val() === '--')) {
			errors.push(element);
		}
	});
	if (errors.length > 0) {
		$(errors).addClass('has-error');
	}
	else {
		let provider = {
			firstName: $('#provider-first-name').val(),
			lastName: $('#provider-last-name').val(),
			title: $('#provider-title').val(),
			specialty: $('provider-specialty').val()
		};
		let providerRow = $('#provider-template').clone();
		providerRow.data('provider', provider);

		$(providerRow).children().each((index, child) => {
			switch ($(child).attr('data-label')) {
				case 'Name':
					$(child).text(provider.firstName + ' ' + provider.lastName);
					break;
				case 'Title':
					$(child).text(provider.title);
					break;
				case 'Specialty':
					$(child).text(provider.specialty);
					break;
			}
		});
		$(providerRow).find('button').click(function() {
			$(providerRow).hide('fade', () => {
				$(providerRow).remove();
				if ($('#provider-table-body').children().length === 1) {
					$('#provider-table').slideUp();
				}
			});
		});
		$('#provider-table-body').append(providerRow);
        if ($('#provider-table').css('display') === 'none') {
        	$('#provider-table').show('fade');
        }
        $(providerRow).show('fade');

        $('#provider-dialog').hide('fade');
        document.forms['provider-form'].reset();
        $('#add-provider').focus();
	}
}

window.buildDemographics = (specialty, demographics) => {
	if (demographics) {
		demographics.forEach((demographic) => {
			let demographicTemplate = $('#demographic-template').clone();
			demographicTemplate.attr('specialty', specialty);
			demographicTemplate.find('label').text(demographic.label);
			demographicTemplate.find('select').attr('fieldname', demographic.name);
			$('#demographics').append(demographicTemplate);
			addOptions(demographicTemplate.find('select'), demographic.options);
		});
	}
}

window.displayDemographics = () => {
	let selectedSpecialties = [];
	$('#specialties-form').find('input').each((index, element) => {
		if ($(element).prop('checked')) {
			$("[specialty='" + element.id + "']").show('fade');
            selectedSpecialties.push(element.id);
		}
		else {
			$("[specialty='" + element.id + "']").hide('fade', function() {
				$(this).remove();
			});
		}
	});

	if (selectedSpecialties.length > 0) {
		$("[specialty='All']").show('fade');
	}
	else {
		$("[specialty='All']").hide('fade', function(){
			$(this).remove();
		});
	}
}

window.formatPhone = a => {
	a.value = a.value.trim();
	let b = a.value,
	c = '',
	d = -1;
	if (0 < b.length && '+' != b.charAt(0)) {
		let e = 0;
		if ('1' == b.charAt(0)) {
			b = b.substring(1, b.length);
		}
		for (let i = 0; i < b.length; i++) {
			let f = b.charAt(i);
			if (f >= '0' && f <= '9') {
				if (e == 0) c += '(';
				else if (e == 3) c += ') ';
				else if(e == 6) c += '-';
				c += f;
				e++;
			}
			if (!(f >= '0' && f <= '9') && f != ' ' && f != '-' && f != '.' && f != '(' && f != ')') {
				d = i;
				break;
			}
		}
		if (d >= 0) c += ' ' + b.substring(d, b.length);
		if (e == 10 && c.length <= 40) a.value = c;
	}
	return true;
}

window.save = andNew => {
	let account = new SObjectModel.Account();
	let contact = new SObjectModel.Contact();
	let errors = [];
	let providers = [];
	let selectedSpecialties = [];

	$(document.forms['clinic-form'].elements).each((index, element) => {
		console.log(element);
		if (!element.checkValidity()) {
			$(element).addClass('has-error');
			errors.push($(element).siblings('label').text() + ': ' + element.validationMessage);
		}
		
		if ($(element).attr('fieldname') === 'Email' && $(element).val() && !RegEx.Email.test($(element).val())) {
			$(element).addClass('has-error');
			errors.push($(element).siblings('label').text() + ': Please enter a valid email address.');
		}
	});

    $('#provider-table-body').children().each((index, providerRow) => {
        providers.push({
        	firstName: $(providerRow).find('#provider-first-name').val(),
        	lastName: $(providerRow).find('#provider-last-name').val(),
        	specialty: $(providerRow).find('#provider-specialty').val(),
        	title: $(providerRow).find('#provider-title').val()
        });
    });
    if (providers.length === 0){
        errors.push('Please add at least one provider in the Providers section.');
    }
    $('#specialties-form').find('input').each((index, element) => {
        if ($(element).prop("checked")) {
        	selectedSpecialties.push(element.id);
        }
    });
    if (selectedSpecialties.length === 0) {
        $('#specialties-form').find('.slds-checkbox--faux').addClass('has-error');
        errors.push('Please select at least one specialty in the Specialties Treated section.');
    }
    if (!$('#accept-terms-input').prop('checked')) {
    	$('#accept-terms').find('.slds-checkbox--faux').addClass('has-error');
    	errors.push('Please accept the terms and conditions.');
    }

    if (errors.length > 0) {
        let messageBody = $('#error-messages');
        messageBody.empty();
        errors.forEach(error => {
        	messageBody.append($('<li>' + error + '</li>'));
        });
        $('#message-dialog').show();
    }
    else {
        account.set('SignUpFormCompleted__c', true);
        if ($('#reference-number').data('accountId')) {
        	account.set('Id', $('#reference-number').data('accountId'));
        }
        $(document.forms['clinic-form'].elements).each((index, element) => {
            if ($(element).attr('sobject') === 'account' && $(element).attr('fieldname')) {
                if (element.type === 'checkbox') {
                	account.set($(element).attr('fieldname'), $(element).prop('checked'));
                }
                else {
                    if ($(element).attr('fieldname') === 'BillingStreet') {
                    	account.set($(element).attr('fieldname'), $(element).val() + ' \r\n ' + $('#billing-street-2').val());
                    }
                    else {
                    	account.set($(element).attr('fieldname'), $(element).val());
                    }
                }
            }
            else if ($(element).attr('sobject') === 'contact' && $(element).attr('fieldname')) {
                if (element.type === 'checkbox') {
                	contact.set($(element).attr('fieldname'), $(element).prop('checked'));
                }
                else {
                	contact.set($(element).attr('fieldname'), $(element).val());
                }
            }
        });
        let contentRequested = '';
        selectedSpecialties.forEach(specialty => {
            if (!contentRequested) {
            	contentRequested = specialty;
            }
            else {
            	contentRequested += ';' + specialty;
            }
        });
        account.set('Network__c', contentRequested);

        $("[id$=save-status]").find("span").show();
        new RemoteAction(SignupController.save, account._props, contact._props, providers)
        	.invoke()
        	.then(result => {
        		if (result === 'Success!') {
        			if (andNew) {
        				window.location.reload();
        			}
        			else {
        				window.location.href = 'http://www.contextmediahealth.com/congratulations/';
        			}
        		}
        		else {
        			$('#error-messages').html('There was an error submitting this form. Please contact your Healthcare Sales Executive and reference the following error message: ' + result);
                	$('#message-dialog').show();
                	$("[id$=save-status]").find("span").hide();
        		}
        	})
        	.catch(error => {
        		$('#error-messages').html('There was an error submitting this form. Please contact your Healthcare Sales Executive and reference the following error message: ' + error);
                $('#message-dialog').show();
                $("[id$=save-status]").find("span").hide();
        	});
    }
}