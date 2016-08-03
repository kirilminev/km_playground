import React, {Component} from 'react';
import {APEX} from '../lib/constants';

import {connect} from 'react-redux';
import {
	addMessage
} from '../ducks/general/actions';
import {
	addProvider,
	getOptions,
	removeProvider,
	save,
	setAccount,
	setStep,
	updateModel,
	updateProvider
} from '../ducks/slingshot/actions';

import {Button} from './button';
import {Card} from './card';
import PageMessages from './page-messages';
import {Process} from './process';
import {RecordHome} from './record-home';

import {
	CONFIRM,
	INSTALLATION,
	PRACTICE,
	PRODUCTS,
	PROVIDERS,
	SCHEDULING,
	STEPS,
	getValidityMessage
} from '../helpers/slingshot-helpers';

class Slingshot extends Component {
	constructor(props, context) {
		super(props, context);

		props.dispatch(getOptions(props.dispatch));

		this.handleAccountChange = this.handleAccountChange.bind(this);
		this.handleAddProvider = this.handleAddProvider.bind(this);
		this.handleChangeStep = this.handleChangeStep.bind(this);
		this.handleSave = this.handleSave.bind(this);
		this.renderClinicOption = this.renderClinicOption.bind(this);
		this.renderDay = this.renderDay.bind(this);
		this.renderOption = this.renderOption.bind(this);
		this.renderProvider = this.renderProvider.bind(this);
		this.renderSpecialty = this.renderSpecialty.bind(this);
	}
	handleAccountChange(event) {
		let {
			dispatch,
			options
		} = this.props;
		options.clinics.forEach(clinic => {
			if (clinic.Name === event.target.value) {
				if (!clinic.of_Waiting_Rooms__c) {
					clinic.of_Waiting_Rooms__c = 1;
				}
				dispatch(setAccount(clinic));
				if (clinic.Contacts && clinic.Contacts.length > 0) {
					clinic.Contacts.forEach(contact => dispatch(addProvider(contact)));
				}
				else {
					dispatch(addProvider());
				}
			}
		});
	}
	handleAddProvider() {
		this.props.dispatch(addProvider());
	}
	handleChangeStep(step) {
		let {
			currentStep,
			dispatch
		} = this.props;
		if (currentStep) {
			if (STEPS.indexOf(currentStep) > STEPS.indexOf(step)) {
				dispatch(setStep(step));
			}
			else if (STEPS.indexOf(currentStep) < STEPS.indexOf(step)) {
				for (let i = STEPS.indexOf(currentStep); i < STEPS.indexOf(step); i++) {
					if (!getValidityMessage(STEPS[i], this.props)) {
						//no message means we can move ahead.
						if (i === STEPS.indexOf(step) - 1) {
							dispatch(setStep(step));
						}
					}
					else {
						//there is a message so display it before moving on.
						dispatch(addMessage(getValidityMessage(STEPS[i], this.props), 4000));
						if (STEPS[i] !== currentStep) {
							dispatch(setStep(STEPS[i]));
						}
						break;
					}
				}
			}
		}
		else {
			dispatch(setStep(step));
		}
	}
	handleCheckboxClick(type, event) {
		let model = {}, changed = {};
		changed[event.target.id] = event.target.checked;
		model[type] = Object.assign({}, this.props[type], changed);
		this.props.dispatch(updateModel(model));
	}
	handleInputChange(type, event) {
		let model = {}, changed = {};
		changed[event.target.id] = event.target.value;
		model[type] = Object.assign({}, this.props[type], changed);
		this.props.dispatch(updateModel(model));
	}
	handleProviderChange(key, event) {
		let changed = {key};
		changed[event.target.id] = event.target.value;
		this.props.dispatch(updateProvider(changed));
	}
	handleRemoveProvider(id) {
		this.props.dispatch(removeProvider(id));
	}
	handleSave() {
		let {
			account,
			alternateContact,
			contact,
			dispatch,
			itapproval,
			options,
			providers,
			scheduleddays,
			specialties,
			workorder
		} = this.props;
		let finalProviders = [...providers];
		if (!options.ShipToPracticeManager) {
			alternateContact.Title__c = 'Shipping Contact';
			finalProviders.push(alternateContact);
		}
		finalProviders.forEach(finalProvider => {delete finalProvider.key});
		delete account.Contacts;
		dispatch(save([account, contact, itapproval, workorder, finalProviders, specialties, scheduleddays], dispatch));
	}
	renderClinicOption(clinic) {
		return clinic.SignUpFormCompleted__c ? undefined : this.renderOption(clinic.Name);
	}
	renderDay(day) {
		let {
			currentStep,
			schedulabledays,
			scheduleddays
		} = this.props;
		return (
			<div className="slds-grid slds-p-top--medium">
				<div className="slds-col--padded slds-size--1-of-2">
					<div className="slds-form-element">
						<label className="slds-checkbox slds-form-element__label">
							<input id={day} type="checkbox" value={schedulabledays[day]} checked={schedulabledays[day]} onChange={this.handleCheckboxClick.bind(this, 'schedulabledays')} disabled={currentStep === CONFIRM}/>
							<span className="slds-checkbox--faux"/>
							<span>{day}</span>
						</label>
					</div>
				</div>
				<div className="slds-col--padded slds-size--1-of-2">
					{currentStep === CONFIRM
					? (scheduleddays ? scheduleddays[day] : undefined)
					: <select id={day} className="slds-select slds-form-element__control" value={scheduleddays ? scheduleddays[day] : ''} onChange={this.handleInputChange.bind(this, 'scheduleddays')} disabled={!schedulabledays[day]}>
						<option value="">Select install times...</option>
						<option value="6am-12pm">6am-12pm</option>
						<option value="12pm-6pm">12pm-6pm</option>
						<option value="3pm-9pm">3pm-9pm</option>
					  </select>}
				</div>
			</div>
		);
	}
	renderOption(option) {
		return (
			<option value={option}>{option}</option>
		);
	}
	renderProvider(provider) {
		let {
			currentStep,
			options,
			providers
		} = this.props;
		let {
			FirstName,
			Id,
			key,
			LastName,
			Specialty__c,
			Title__c
		} = provider;
		let label = 'Provider ' + (providers.indexOf(provider) + 1);
		return (
			<tr key={label} className="slds-hint-parent">
				<td>
					<div className="slds-text-heading--label">{label}</div>
				</td>
				<td>
					{currentStep === CONFIRM
					? FirstName
					: <input id="FirstName" className="slds-input" value={FirstName} onChange={this.handleProviderChange.bind(this, key)}/>}
				</td>
				<td>
					{currentStep === CONFIRM
					? LastName
					: <input id="LastName" className="slds-input" value={LastName} onChange={this.handleProviderChange.bind(this, key)}/>}
				</td>
				<td>
					{currentStep === CONFIRM
					? Title__c
					: <select id="Title__c" className="slds-select" required="true" value={Title__c || ''} onChange={this.handleProviderChange.bind(this, key)}>
						 <option value="">Select a title...</option>
						 {options.titles
							 ? options.titles.map(this.renderOption)
							 : undefined}
					  </select>}
				</td>
				<td>
					{currentStep === CONFIRM
					? Specialty__c
					: <select id="Specialty__c" className="slds-select" value={Specialty__c || ''} onChange={this.handleProviderChange.bind(this, key)}>
						 <option value="">Select a specialty...</option>
						 {options.providerSpecialties
							 ? options.providerSpecialties.map(this.renderOption)
							 : undefined}
					  </select>}
				</td>
				<td>
					{currentStep !== CONFIRM
					? <Button type="destructive" label="Remove" disabled={(providers.indexOf(provider) === 0 && providers.length === 1) || provider.Id !== undefined} onClick={this.handleRemoveProvider.bind(this, key)}/>
					: undefined}
				</td>
			</tr>
		);
	}
	renderSpecialty(specialty) {
		let {specialties} = this.props;
		return (
			<div className="slds-form-element">
				<label className="slds-checkbox">
					<input id={specialty} type="checkbox" value={specialties[specialty]} checked={specialties[specialty]} onChange={this.handleCheckboxClick.bind(this, 'specialties')} disabled={this.props.currentStep === CONFIRM}/>
					<span className="slds-checkbox--faux"/>
					<span className="slds-form-element__label">{specialty}</span>
				</label>
			</div>
		);
	}
	render() {
		let {
			account,
			alternateContact,
			contact,
			currentStep,
			dispatch,
			loading,
			itapproval,
			options,
			providers,
			workorder
		} = this.props;
		return (
			<div className="slds">
				<PageMessages />
				{loading
				? 	<div>
						<div className="popup-background"/>
						<div className="popup-panel">
							<img src={APEX.progressBar}/>
						</div>
					</div>
				: 	undefined}
				<div style={{width: '100%', backgroundColor: 'rgb(110,41,141)'}}>
					<img style={{height: '100px'}} src={APEX.banner}></img>
				</div>
				{currentStep === undefined
				? 	<Card text="">
						<div className="slds-grid slds-grid--align-center">
							<div className="slds-col slds-size--1-of-3">
								<select className="slds-select slds-form-element__control" disabled={options.clinics === undefined} onChange={this.handleAccountChange}>
									<option value="">Select your practice...</option>
									{options.clinics
										? options.clinics.map(this.renderClinicOption)
										: undefined}
								</select>
							</div>
						</div>
						<div className="slds-grid slds-grid--align-center slds-p-top--large">
							<Button label="Get Started" type="brand" disabled={account === undefined} onClick={this.handleChangeStep.bind(this, PRACTICE)}/>
						</div>
					</Card>
				: 	<div>
						<RecordHome title={account ? account.Name + (account.COID__c ? (' (COID: ' + account.COID__c + ')'): '') : undefined} info={account && account.Parent ? account.Parent.Name : undefined} icon="/assets/icons/standard-sprite/svg/symbols.svg#account"/>
						{currentStep !== CONFIRM
						? 	<Process currentStep={currentStep} steps={STEPS} onChangeStep={this.handleChangeStep} />
						: 	undefined}
						{currentStep === PRACTICE || currentStep === CONFIRM
						? 	<Card text="Practice Manager">
								<div className="slds-container--medium">
									<div className="slds-grid">
										<div className="slds-col--padded slds-size--1-of-2">
											<div>
												<label className="slds-form-element__label">First Name</label>
												{currentStep === CONFIRM
												? contact.FirstName
												: <input id="FirstName" className="slds-input slds-form-element__control" value={contact.FirstName} onChange={this.handleInputChange.bind(this, 'contact')}/>}
											</div>
											<div className="is-required">
												<label className="slds-form-element__label">Last Name</label>
												{currentStep === CONFIRM
												? contact.LastName
												: <input id="LastName" className="slds-input slds-form-element__control" value={contact.LastName} onChange={this.handleInputChange.bind(this, 'contact')}/>}
											</div>
											<div>
												<label className="slds-form-element__label">Title</label>
												{currentStep === CONFIRM
												? contact.Title__c
												: <select id="Title__c" className="slds-select slds-form-element__control" value={contact.Title__c} onChange={this.handleInputChange.bind(this, 'contact')}>
													 <option value="">Select a title...</option>
													 {options.titles
														 ? options.titles.map(this.renderOption)
														 : undefined}
												  </select>}
											</div>
										</div>
										<div className="slds-col--padded slds-size--1-of-2">
											<div>
												<label className="slds-form-element__label">Email Address</label>
												{currentStep === CONFIRM
												? contact.Email
												: <input id="Email" className="slds-input slds-form-element__control" value={contact.Email} onChange={this.handleInputChange.bind(this, 'contact')}/>}
											</div>
											<div>
												<label className="slds-form-element__label">Phone</label>
												{currentStep === CONFIRM
												? contact.Phone
												: <input id="Phone" className="slds-input slds-form-element__control" value={contact.Phone} onChange={this.handleInputChange.bind(this, 'contact')}/>}
											</div>
											<div>
												<label className="slds-form-element__label">Practice COID</label>
												{currentStep === CONFIRM
												? account.COID__c
												: <input id="COID__c" className="slds-input slds-form-element__control" value={account.COID__c} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
										</div>
									</div>
								</div>
							</Card>
						: 	undefined}
						{currentStep === PRACTICE || currentStep === CONFIRM
						? 	<Card text="Practice Location">
								<div className="slds-container--large">
									<div className="slds-grid">
										<div className="slds-col--padded slds-size--1-of-3">
											<div>
												<label className="slds-form-element__label">Street Address</label>
												{currentStep === CONFIRM
												? account.BillingStreet
												: <input id="BillingStreet" className="slds-input slds-form-element__control" value={account.BillingStreet} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
											<div>
												<label className="slds-form-element__label">City</label>
												{currentStep === CONFIRM
												? account.BillingCity
												: <input id="BillingCity" className="slds-input slds-form-element__control" value={account.BillingCity} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
											<div>
												<label className="slds-form-element__label">State</label>
												{currentStep === CONFIRM
												? account.BillingState
												: <select id="BillingState" className="slds-select slds-form-element__control" value={account.BillingState} onChange={this.handleInputChange.bind(this, 'account')}>
													 <option value="">Select a state...</option>
													 {options.states
														 ? options.states.map(this.renderOption)
														 : undefined}
												  </select>}
											</div>
											<div>
												<label className="slds-form-element__label">Zip</label>
												{currentStep === CONFIRM
												? account.BillingPostalCode
												: <input id="BillingPostalCode" className="slds-input slds-form-element__control" value={account.BillingPostalCode} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
										</div>
										<div className="slds-col--padded slds-size--1-of-3">
											<div>
												<label className="slds-form-element__label">Hours of Operation</label>
												{currentStep === CONFIRM
												? account.Clinic_Office_Hours__c
												: <input id="Clinic_Office_Hours__c" className="slds-input slds-form-element__control" value={account.Clinic_Office_Hours__c} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
											<div>
												<label className="slds-form-element__label"># of Waiting Rooms</label>
												{currentStep === CONFIRM
												? account.of_Waiting_Rooms__c
												: <input id="of_Waiting_Rooms__c" type="number" className="slds-input slds-form-element__control" value={account.of_Waiting_Rooms__c} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
											<div>
												<label className="slds-form-element__label"># of Exam Rooms</label>
												{currentStep === CONFIRM
												? account.NumberOfExamRooms__c
												: <input id="NumberOfExamRooms__c" type="number" className="slds-input slds-form-element__control" value={account.NumberOfExamRooms__c} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
										</div>
										<div className="slds-col--padded slds-size--1-of-3">
											<div>
												<label className="slds-form-element__label"># of TVs currently in your waiting room</label>
												{currentStep === CONFIRM
												? itapproval.NumberofTVRemovedRelocated__c
												: <input id="NumberofTVRemovedRelocated__c" type="number" className="slds-input slds-form-element__control" value={itapproval.NumberofTVRemovedRelocated__c} onChange={this.handleInputChange.bind(this, 'itapproval')}/>}
											</div>
											<div className="slds-form-element slds-p-top--large">
												<label className="slds-checkbox slds-form-element__label">
													<input id="SharedWaitingRoom__c" type="checkbox" value={account.SharedWaitingRoom__c} checked={account.SharedWaitingRoom__c} onChange={this.handleCheckboxClick.bind(this, 'account')} disabled={currentStep === CONFIRM}/>
													<span className="slds-checkbox--faux"/>
													<span>Shared Waiting Room</span>
												</label>
											</div>
										</div>
									</div>
								</div>
							</Card>
						: 	undefined}
						{currentStep === PROVIDERS || currentStep === CONFIRM
						? 	<Card text="Specialties">
								<div className="slds-p-left--large">
									{options.clinicSpecialties.map(this.renderSpecialty)}
								</div>
							</Card>
						: 	undefined}
						{currentStep === PROVIDERS || currentStep === CONFIRM
						? 	<Card text="Providers" button={currentStep !== CONFIRM ? <Button type="neutral" label={providers && providers.length > 0 ? '+ Add Another' : '+ Add Provider'} onClick={this.handleAddProvider}/> : undefined}>
								{providers && providers.length > 0
								? 	<table className="slds-table slds-table--bordered slds-max-medium-table--stacked-horizontal slds-no-row-hover">
										<thead>
											<tr>
												<th scope="col"></th>
												<th className="slds-text-heading--label" scope="col">First Name</th>
												<th className="slds-text-heading--label is-required-header" scope="col">Last Name</th>
												<th className="slds-text-heading--label" scope="col">Title</th>
												<th className="slds-text-heading--label" scope="col">Specialty</th>
												<th scope="col"></th>
											</tr>
										</thead>
										<tbody>
											{providers.map(this.renderProvider)}
										</tbody>
									</table>
								: undefined}
							</Card>
						: 	undefined}
						{currentStep === PRODUCTS || currentStep === CONFIRM
						?	<Card text="Quantity of Products your Practice Needs">
								<table className="slds-table slds-table--bordered slds-max-medium-table--stacked-horizontal slds-no-row-hover">
									<thead>
										<tr>
											<th className="slds-text-heading--label" scope="col">Product Name</th>
											<th className="slds-text-heading--label" scope="col">Quantity</th>
										</tr>
									</thead>
									<tbody>
										<tr>
											<td>Waiting Room TV</td>
											<td>
												{currentStep === CONFIRM
												? workorder.TVs_Being_Installed__c
												: <select id="TVs_Being_Installed__c" className="slds-select" value={workorder.TVs_Being_Installed__c} onChange={this.handleInputChange.bind(this, 'workorder')}>
												  {options.quantities
														? options.quantities.map(this.renderOption)
														: undefined}
												  </select>}
											</td>
										</tr>
										<tr>
											<td>Exam Room Tablet</td>
											<td>
												{currentStep === CONFIRM
												? workorder.Tablets_Being_Installed__c
												: <select id="Tablets_Being_Installed__c" className="slds-select" value={workorder.Tablets_Being_Installed__c} onChange={this.handleInputChange.bind(this, 'workorder')}>
												  {options.quantities
														? options.quantities.map(this.renderOption)
														: undefined}
												  </select>}
											</td>
										</tr>
										<tr>
											<td>Exam Room Wallboard</td>
											<td>
												{currentStep === CONFIRM
												? workorder.Wallboards_Being_Installed__c
												: <select id="Wallboards_Being_Installed__c" className="slds-select" value={workorder.Wallboards_Being_Installed__c} onChange={this.handleInputChange.bind(this, 'workorder')}>
												  	<option value="0">0</option>
												  	<option value="1">1</option>
												  </select>}
											</td>
										</tr>
									</tbody>
								</table>
								<p className="slds-p-top--medium slds-p-left--small">
									You may find that your designated wallboard number is lower than desired. We've had a fantastic amount of interest in our wallboards, and due to this, have depleted our short term supply.  Please email hca@contextmediainc.com with requests for additional wallboards, and our team will accommodate as soon as additional product is available.
								</p>
							</Card>
						: 	undefined}
						{currentStep === INSTALLATION || currentStep === CONFIRM
						? 	<Card text="Installation">
								<div className="slds-container--medium">
									<div className="slds-grid">
										<div className="slds-col--padded slds-size--1-of-2">
											<div className="slds-form-element">
												<label className="slds-form-element__label">Special requests regarding content or product numbers: (i.e. Spanish, Pediatrics)</label>
												{currentStep === CONFIRM
												? account.SpecialContentRequest__c
												: <input id="SpecialContentRequest__c" className="slds-input slds-form-element__control" value={account.SpecialContentRequest__c} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
											<div className="slds-form-element slds-p-top--medium slds-p-bottom--medium">
												<label className="slds-checkbox slds-form-element__label">
													<input id="HasWifi__c" type="checkbox" value={itapproval.HasWifi__c} checked={itapproval.HasWifi__c} onChange={this.handleCheckboxClick.bind(this, 'itapproval')} disabled={currentStep === CONFIRM}/>
													<span className="slds-checkbox--faux"/>
													<span>Our practice has WiFi.</span>
												</label>
											</div>
											<div className="slds-form-element">
												<label className="slds-form-element__label">Electrical Outlet Near TV Location</label>
												{currentStep === CONFIRM
												? itapproval.Electrical_Outlet_near_requested_TV_loca__c
												: <select id="Electrical_Outlet_near_requested_TV_loca__c" className="slds-select" value={itapproval.Electrical_Outlet_near_requested_TV_loca__c} onChange={this.handleInputChange.bind(this, 'itapproval')}>
													<option value="">Select an option...</option>
													<option value="less than 5 feet">less than 5 feet</option>
													<option value="6 to 10 feet">6 to 10 feet</option>
													<option value="greater than 10 feet">greater than 10 feet</option>
													<option value="Not all TVs have an outlet nearby">Not all TVs have an outlet nearby</option>
													<option value="Additional TVs are all within parameters">Additional TVs are all within parameters</option>
												  </select>}
											</div>
											<div className="slds-form-element slds-p-top--medium">
												<label className="slds-checkbox slds-form-element__label">
													<input id="eCW__c" type="checkbox" value={account.eCW__c} checked={account.eCW__c} onChange={this.handleCheckboxClick.bind(this, 'account')} disabled={currentStep === CONFIRM}/>
													<span className="slds-checkbox--faux"/>
													<span>This practice is using the HCA hosted version of eCW.</span>
												</label>
											</div>
											<div className="slds-form-element slds-p-top--medium">
												<label className="slds-checkbox slds-form-element__label">
													<input id="CompetitorRemoval__c" type="checkbox" value={account.CompetitorRemoval__c} checked={account.CompetitorRemoval__c} onChange={this.handleCheckboxClick.bind(this, 'account')} disabled={currentStep === CONFIRM}/>
													<span className="slds-checkbox--faux"/>
													<span>Are the TVs running anything aside from cable?</span>
												</label>
											</div>
											<div className="slds-form-element">
												<label className="slds-form-element__label">If yes, please explain - e.g. Accent Health, Patient Point</label>
												{currentStep === CONFIRM
												? account.CompetitorRemovalNotes__c
												: <input id="CompetitorRemovalNotes__c" className="slds-input slds-form-element__control" value={account.CompetitorRemovalNotes__c} onChange={this.handleInputChange.bind(this, 'account')}/>}
											</div>
										</div>
										<div className="slds-col slds-size--1-of-2" />
									</div>
								</div>
							</Card>
						: 	undefined}
						{currentStep === SCHEDULING || currentStep === CONFIRM
						? 	<Card text="Available Installation Times">
								<div className="slds-container--small">
									{options.schedulableDays
										? options.schedulableDays.map(this.renderDay)
										: undefined}
								</div>
							</Card>
						: 	undefined}
						{currentStep === SCHEDULING || currentStep === CONFIRM
						? 	<Card text="Ship Devices To">
								<div className="slds-grid slds-container--medium">
									<div className="slds-col--padded slds-size--1-of-2">
										<div className="slds-form-element slds-p-top--medium">
											<label className="slds-checkbox slds-form-element__label">
												<input id="ShipToPracticeManager" type="checkbox" checked={options.ShipToPracticeManager} value={options.ShipToPracticeManager} onChange={this.handleCheckboxClick.bind(this, 'options')} disabled={currentStep === CONFIRM}/>
												<span className="slds-checkbox--faux"/>
												<span>This is the Practice Manager</span>
											</label>
										</div>
										<div>
											<label className="slds-form-element__label">First Name</label>
											{currentStep === CONFIRM || options.ShipToPracticeManager
											? (options.ShipToPracticeManager ? contact.FirstName : alternateContact.FirstName)
											: <input id="FirstName" className="slds-input slds-form-element__control" value={alternateContact.FirstName} onChange={this.handleInputChange.bind(this, 'alternateContact')}/>}
										</div>
										<div>
											<label className="slds-form-element__label">Last Name</label>
											{currentStep === CONFIRM || options.ShipToPracticeManager
											? (options.ShipToPracticeManager ? contact.LastName : alternateContact.LastName)
											: <input id="LastName" className="slds-input slds-form-element__control" value={alternateContact.LastName} onChange={this.handleInputChange.bind(this, 'alternateContact')}/>}
										</div>
										<div>
											<label className="slds-form-element__label">Email Address</label>
											{currentStep === CONFIRM || options.ShipToPracticeManager
											? (options.ShipToPracticeManager ? contact.Email : alternateContact.Email)
											: <input id="Email" className="slds-input slds-form-element__control" value={alternateContact.Email} onChange={this.handleInputChange.bind(this, 'alternateContact')}/>}
										</div>
										<div>
											<label className="slds-form-element__label">Phone</label>
											{currentStep === CONFIRM || options.ShipToPracticeManager
											? (options.ShipToPracticeManager ? contact.Phone : alternateContact.Phone)
											: <input id="Phone" className="slds-input slds-form-element__control" value={alternateContact.Phone} onChange={this.handleInputChange.bind(this, 'alternateContact')}/>}
										</div>
									</div>
									<div className="slds-col slds-size--1-of-2" />
								</div>
								{currentStep !== CONFIRM
								? <div className="slds-grid slds-grid--align-center slds-p-top--medium">
									<Button label="Continue to Confirmation" type="brand" disabled={account === undefined} onClick={this.handleChangeStep.bind(this, CONFIRM)}/>
								  </div>
								: <div className="slds-grid slds-grid--align-center slds-p-top--medium">
									<Button label="Back" type="neutral" onClick={this.handleChangeStep.bind(this, SCHEDULING)} />
									<div className="slds-p-left--medium">
										<Button label="Confirm and Submit" type="brand" onClick={this.handleSave}/>
									</div>
								  </div>}
							</Card>
						: 	undefined}
					</div>}
			</div>
		);
	}
}

export default connect(state => ({
	account: state.account,
	alternateContact: state.alternateContact,
	contact: state.contact,
	currentStep: state.currentStep,
	itapproval: state.itapproval,
	loading: state.loading,
	options: state.options,
	providers: state.providers,
	schedulabledays: state.schedulabledays,
	scheduleddays: state.scheduleddays,
	specialties: state.specialties,
	workorder: state.workorder
}))(Slingshot);