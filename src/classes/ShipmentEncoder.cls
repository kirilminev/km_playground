public with sharing class ShipmentEncoder {


	public static String BuildTrackingRequest( String sCarrier, String sTrackingNumber) {
		String sRequest ='';
		If (sTrackingNumber!=null && sTrackingNumber!=''){
			If (sCarrier == 'UPS') {
				sRequest = BuildTrackingRequestUPS(sTrackingNumber);
			}
		}
		return sRequest;
	}

	public static String BuildTrackingRequestUPS( String TrackingNumber) {

		Xmlstreamwriter xStreamWriter= new Xmlstreamwriter();
			
			xStreamWriter.writeStartDocument('utf-8','1.0');
			    xStreamWriter.writeStartElement(null,'AccessRequest', null);
			        xStreamWriter.writeStartElement(NULL,'AccessLicenseNumber', NULL);
			        xStreamWriter.writeCharacters(EnvironmentUtils.getEnvironmentProperty('REST_UPS_AUTH_LICENSE_NUMBER'));
			        xStreamWriter.writeEndElement();
			        xStreamWriter.writeStartElement(NULL,'UserId', NULL);
			        xStreamWriter.writeCharacters(EnvironmentUtils.getEnvironmentProperty('REST_UPS_AUTH_USERID'));
			        xStreamWriter.writeEndElement();
			        xStreamWriter.writeStartElement(NULL,'Password', NULL);
			        xStreamWriter.writeCharacters(EnvironmentUtils.getEnvironmentProperty('REST_UPS_AUTH_PWD'));
			        xStreamWriter.writeEndElement();
			    xStreamWriter.writeEndElement(); 
			xStreamWriter.writeEndDocument(); 

			xStreamWriter.writeStartDocument('utf-8','1.0');
			    xStreamWriter.writeStartElement(null,'TrackRequest', null);
			       xStreamWriter.writeStartElement(null,'Request', null);
			            xStreamWriter.writeStartElement(null,'TransactionReference', null);
			                xStreamWriter.writeStartElement(null,'CustomerContext', null);
			                    xStreamWriter.writeCharacters('guidlikesubstance');
			                xStreamWriter.writeEndElement(); 
			            xStreamWriter.writeEndElement(); 
			            xStreamWriter.writeStartElement(null,'RequestAction', null);
			                xStreamWriter.writeCharacters('Track');
			            xStreamWriter.writeEndElement(); 
			       xStreamWriter.writeEndElement(); 
			       xStreamWriter.writeStartElement(null,'TrackingNumber', null);
			            xStreamWriter.writeCharacters(TrackingNumber);
			       xStreamWriter.writeEndElement(); 
			    xStreamWriter.writeEndElement();
			xStreamWriter.writeEndDocument(); 
     return xStreamWriter.getXmlString();
    }

}