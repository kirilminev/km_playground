export const signupListeners = [
	{
		selector: '#accept-terms-input',
		event: 'change',
		action: function() {
			if ($(this).prop('checked') && $('#accept-terms').find('.slds-checkbox--faux').hasClass('has-error')) {
				$('#accept-terms').find('.slds-checkbox--faux').removeClass('has-error');
			}
		}
	},
	{
		selector: '#add-provider',
		event: 'click',
		action: function() {
			let providerRow = $('#provider-template').clone();
			providerRow.find('.slds-text-heading--label').text('Provider ' + String($('#provider-table-body').children().length + 1));
			providerRow.find('label').each((index, label) => {
				$(label).text('Provider ' + String($('#provider-table-body').children().length + 1) + ' ' + $(label).attr('fieldname'));
			});
			providerRow.find('input').val('');
			providerRow.find('select').val('');
			providerRow.find('#remove-provider').click(function() {
				$(this).parent().parent().remove();
				$('#provider-table-body').children().each((index, element) => {
					$(element).find('.slds-text-heading--label').text('Provider ' + String(index + 1));
					$(element).find('label').each(function(labelIndex, label) {
						$(label).text('Provider ' + String(index + 1) + ' ' + $(label).attr('fieldname'));
					});
				});
			}).show();
			providerRow.find('.has-error').removeClass('has-error');

			$('#provider-table-body').append(providerRow);
		}
	},
	{
		selector: 'input',
		event: 'change',
		action: function() {
			if ($(this).hasClass('has-error') && $(this).val()) {
				$(this).removeClass('has-error');
			}
		}
	},
	{
		selector: '#message-dialog-ok',
		event: 'click',
		action: function() {
			$('#message-dialog').hide('fade');
		}
	},
	{
		selector: '.phone-number',
		event: 'change',
		action: function() {
			formatPhone(this);
		}
	},
	{
		selector: '#reference-number',
		event: 'change',
		action: function() {
	        if ($('#reference-number').val()) {
	            let account = new SObjectModel.Account();
	            account.retrieve({
	                where: {
	                	IdGenerator__c: {
	                		eq: $("#reference-number").val()
	                	}
	                }
	            },   
                (error, accounts) => {
                    if (error) {
                        console.log(error);
                        $('#reference-number').addClass('has-error');
                    }
                    else {
                        if (accounts.length > 0) {
                            accounts.forEach(record => {
                                if (record.get('SignUpFormCompleted__c')) {
                                    $('#reference-number').addClass('has-error');
                                }
                                else {
                                    $('input').each((index, element) => {
                                        if ($(element).attr('sobject') === 'account') {
                                            $(element).val(record.get($(element).attr('fieldname')));
                                            if ($(element).hasClass('has-error')) {
                                            	$(element).removeClass('has-error');
                                            }
                                        }
                                    });
                                    $('select').each((index, element) => {
                                        if ($(element).attr('sobject') === 'account') {
                                            $(element).val(record.get($(element).attr('fieldname')));
                                            if ($(element).hasClass('has-error')) {
                                            	$(element).removeClass('has-error');
                                            }
                                        }
                                    });
                                    if (record.get('Network__c')) {
                                        record.get('Network__c').split(';').forEach(specialty => {
                                            $(specialty).prop('checked', 'true');
                                        });
                                    }
                                    $('#reference-number').data('accountId', record.get('Id'));
                                    $('#reference-number').addClass('has-success');
                                }
                            });
                        }
                        else {
                            if ($('#reference-number').hasClass('has-error')) {
                            	$('#reference-number').removeClass('has-error');
                            }
                            $('#reference-number').addClass('has-error');
                        }
                    }
                });
	        }
	        else {
	            if ($('#reference-number').hasClass('has-error')) {
	            	$('#reference-number').removeClass('has-error');
	            }
	            if ($('#reference-number').hasClass('has-success')) {
	            	$('#reference-number').removeClass('has-success');
	            }
	        }
	    }
	},
	{
		selector: 'select',
		event: 'change',
		action: function() {
			if ($(this).hasClass('has-error') && $(this).val()) {
				$(this).removeClass('has-error');
			}
		}
	},
	{
		selector: '#submit',
		event: 'click',
		action: function() {
			save(false);
		}
	},
	{
		selector: '#submit-and-new',
		event: 'click',
		action: function() {
			save(true);
		}
	}
];