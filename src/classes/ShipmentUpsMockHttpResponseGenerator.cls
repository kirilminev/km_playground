/*******************************************************************************************************
* @description Http Mock for ShipmentDelegate inbound integration with iD
*
*/
@isTest
global class ShipmentUpsMockHttpResponseGenerator implements HttpCalloutMock {

  /* 
  *   Based on these types of request the response will be changed 
  *   Add new request types as needed and change accordingly the response logic below as well
  */
  public enum REQUEST_TYPE {CANCEL_ORDER, GET_SHIPMENT_TRACKING_INFO}

  private Integer statusCode;
  private REQUEST_TYPE requestType;
  private String responseBody;

  public ShipmentUpsMockHttpResponseGenerator(Integer statusCode, 
                                              ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE requestType) {
    this.statusCode = statusCode;
    this.requestType = requestType;
  }

  public ShipmentUpsMockHttpResponseGenerator(Integer statusCode, 
                                              ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE requestType,
                                              String responseBody) {
    this.statusCode = statusCode;
    this.requestType = requestType;
    this.responseBody = responseBody;
  }

  global HTTPResponse respond(HTTPRequest request) {

    HttpResponse response = new HttpResponse();

    if (requestType == REQUEST_TYPE.GET_SHIPMENT_TRACKING_INFO) {
      response.setHeader('Content-Type', 'text/xml');
      response.setBody(getShipmentTrackingInfoResponse());
    } else if (requestType == REQUEST_TYPE.CANCEL_ORDER) {
      response.setHeader('Content-Type', 'application/json');
      response.setBody(cancelOrderResponse());
    }

    response.setStatusCode(statusCode);
    return response;
  }

  private String cancelOrderResponse() {
    return this.responseBody;
  }

  private String getShipmentTrackingInfoResponse() {
    Xmlstreamwriter xmlReq = new Xmlstreamwriter();

    xmlReq.writeStartElement(null, 'TrackResponse', null);
    xmlReq.writeStartElement(null, 'Response', null);
    xmlReq.writeCharacters('Success');
    xmlReq.writeEndElement();

    xmlReq.writeStartElement(null, 'Shipment', null);
    xmlReq.writeStartElement(null, 'Package', null);
    xmlReq.writeStartElement(null, 'Activity', null);
    xmlReq.writeStartElement(null, 'Date', null);
    xmlReq.writeCharacters('20150612');
    xmlReq.writeEndElement();
    xmlReq.writeStartElement(null, 'Time', null);
    xmlReq.writeCharacters('124400');
    xmlReq.writeEndElement();
    xmlReq.writeStartElement(null, 'Status', null);
    xmlReq.writeStartElement(null, 'StatusType', null);
    xmlReq.writeStartElement(null, 'Code', null);
    xmlReq.writeCharacters('D');
    xmlReq.writeEndElement();
    xmlReq.writeStartElement(null, 'Description', null);
    xmlReq.writeCharacters('DELIVERED');
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();
    xmlReq.writeStartElement(null, 'ActivityLocation', null);
    xmlReq.writeStartElement(null, 'SignedForByName', null);
    xmlReq.writeCharacters('TestSignedForName');
    xmlReq.writeEndElement();
    xmlReq.writeStartElement(null, 'Description', null);
    xmlReq.writeCharacters('TestLocation');
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();
    xmlReq.writeEndElement();

    return xmlReq.getXmlString();
  }
}