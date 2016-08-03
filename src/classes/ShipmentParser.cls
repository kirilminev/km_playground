public with sharing class ShipmentParser {
	
	public static String ParseTrackingRequest(HttpResponse HttpResp, string LookUpElement) { 
		
		String sParsedValue = '';
		String sYear = '';
		String sMonth ='';
		String sDay = '';
		String sHour = '';
		String sMinute ='';
		String sSecond ='';


		Dom.Document docx = new Dom.Document();
		docx.load(HttpResp.getbody());
		dom.XmlNode xroot = docx.getRootElement();

		system.debug(HttpResp.getbody());

		//String Response = xroot.getChildElement('Response', null).getText();
		

		if (xroot.getChildElement('Shipment', null) !=null) {

			dom.XmlNode xShipment= xroot.getChildElement('Shipment', null); 

			if (xShipment.getChildElement('Package', null).getChildElement('Activity', null)!=null) { 
				dom.XmlNode xShipActivity = xShipment.getChildElement('Package', null).getChildElement('Activity', null); 
				dom.XmlNode xShipStatusType = xShipActivity.getChildElement('Status', null).getChildElement('StatusType', null);
				
				if (LookUpElement == 'StatusCode') {
					sParsedValue = xShipStatusType.getChildElement('Code', null).getText();
				}

				if  (LookUpElement == 'Status') {	
					sParsedValue = xShipStatusType.getChildElement('Description', null).getText(); 
			    }
			    
			    if  (LookUpElement == 'Message') {	
			    	if  (xShipment.getChildElement('Package', null).getChildElement('Message', null)!=null){
						dom.XmlNode xMessage = xShipment.getChildElement('Package', null).getChildElement('Message', null); 	
						sParsedValue = xMessage.getChildElement('Description', null).getText();
					}
					else
					{
						sParsedValue = xShipStatusType.getChildElement('Description', null).getText(); 
					}
			    }

			    if  (LookUpElement == 'SignedBy') {	
					dom.XmlNode xShipSignedBy = xShipActivity.getChildElement('ActivityLocation', null);	

					if  (xShipSignedBy.getChildElement('SignedForByName', null)!=null){
						sParsedValue = xShipSignedBy.getChildElement('SignedForByName', null).getText();
					}
			    }

			    if  (LookUpElement == 'Location') {	
					dom.XmlNode xShipSignedBy = xShipActivity.getChildElement('ActivityLocation', null);	
					if (xShipSignedBy.getChildElement('Description', null)!=null){
						sParsedValue = xShipSignedBy.getChildElement('Description', null).getText();
					}
			    }

			    if  (LookUpElement == 'Date') {	
					String sDate = xShipActivity.getChildElement('Date', null).getText();
					String sTime = xShipActivity.getChildElement('Time', null).getText();

					 sYear = sDate.substring(0, 4);
					 sMonth = sDate.substring(4, 6);
					 sDay = sDate.substring(6, 8);
					 sHour = sTime.substring(0,2);
					 sMinute = sTime.substring(2,4);
					 sSecond = '00';
					 String StringDate = sYear + '-' + sMonth + '-' + sDay + ' ' + sHour + ':'+ sMinute +  ':' + sSecond;
					 Datetime dt = Datetime.valueOf(stringDate);

					sParsedValue = String.valueOf(dt); 
			    }
			
			    if  (LookUpElement == 'DelDate') {	
			    	if (xShipment.getChildElement('ScheduledDeliveryDate', null)!=null && xShipStatusType.getChildElement('Description', null).getText() !='DESTINATION SCAN'){
						String sDate =  xShipment.getChildElement('ScheduledDeliveryDate', null).getText();
						 sYear = sDate.substring(0, 4);
						 sMonth = sDate.substring(4, 6);
						 sDay = sDate.substring(6, 8);
						 String StringDate = sYear + '-' + sMonth + '-' + sDay ;
						 Date dt = Date.valueOf(stringDate);

						 sParsedValue = String.valueOf(dt); 
					}
			    }
	 		}
	 	}

		return sParsedValue;
	}
}