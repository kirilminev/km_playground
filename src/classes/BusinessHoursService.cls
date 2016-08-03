public with sharing class BusinessHoursService {
	private static final String BUSINESSHOURSx = 'BusinessHours';

	public static BusinessHours getByName(String businessHoursName, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(BUSINESSHOURSx)
						  .wherex(new FieldCondition('Name').equals(businessHoursName))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<String> getAvailableShippingDays(Integer numberOfDays) {
		BusinessHours shippingDays = getByName('Shipping Days', new List<String> {'Id','TimeZoneSidKey'});
		List<String> availableDays = new List<String>();
		for (Integer i = 1; i < numberOfDays; i++) {
			Datetime theDate = Datetime.newInstance(System.today(), Time.newInstance(7,0,0,0));
			theDate = theDate.addDays(i);
			if (BusinessHours.isWithin(shippingDays.Id, theDate)) {
				String availableDay = '';
				if (theDate.month() < 10) { availableDay = '0'; }
				availableDay += String.valueOf(theDate.month()) + '-';
				if (theDate.day() < 10) { availableDay += '0'; }
				availableDay += String.valueOf(theDate.day()) + '-' + String.valueOf(theDate.year());
				availableDays.add(availableDay);
			}
		}
		if (!BusinessHours.isWithin(shippingDays.Id, system.now())){ 
		availableDays.remove(0);}

		return availableDays;
	}

	public static Date getEstimatedShipDate(Shipment__c shipment, Integer leadTimeInDays) {
		Integer count = 1;
		Integer totalNumberOfDays = 0;
		BusinessHours shippingDays = getByName('Shipping Days', new List<String> {'Id'});
		if (shipment.isExpedited__c) {
			return shipment.CreatedDate == null ? System.today() : Date.valueOf(shipment.CreatedDate);
		}
		else {
			do {
				if (BusinessHours.isWithin(shippingDays.Id, Datetime.newInstance(shipment.RequestedDateOfArrival__c - count, Time.newInstance(1,2,3,4)))) {
					totalNumberOfDays++;
					system.debug('count: ' + count + ' totalNumberOfDays: ' + totalNumberOfDays + ' date: ' + String.valueOf(shipment.RequestedDateOfArrival__c - count));
				}
				else {
					system.debug(String.valueOf(shipment.RequestedDateOfArrival__c - count) + ' is not within.');
				}
				if (totalNumberOfDays == leadTimeInDays) {
					return shipment.RequestedDateOfArrival__c - count;
				}
				count++;
			} while(totalNumberOfDays < leadTimeInDays);
		}
		return null;
	}
}