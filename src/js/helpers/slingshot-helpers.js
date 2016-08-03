export const CONFIRM = 'Confirm';
export const INSTALLATION = 'Installation';
export const PRACTICE = 'Practice';
export const PRODUCTS = 'Products';
export const PROVIDERS = 'Providers';
export const SCHEDULING = 'Scheduling';
export const STEPS = [PRACTICE, PROVIDERS, PRODUCTS, INSTALLATION, SCHEDULING, CONFIRM];


export function getValidityMessage(step, data) {
	switch (step) {
		case PRACTICE:
			return data.contact.LastName
					? undefined
					: 'Practice manager last name is required.';
		case PROVIDERS:
			let message;
			data.providers.forEach(provider => {
				if (provider.LastName === undefined || provider.LastName === '') {
					message = 'Provider last name is required.';	
				}
			});
			return message;
		case SCHEDULING:
			return data.scheduleddays
					? undefined
					: 'Please select at least one available day for scheduling your installation.';
		default:
			return undefined;
	}
}
