/*******************************************************************************************************
* @description Test coveraage for ShipmentDelegate
* 
*/
@isTest (seeAlldata=false)
public with sharing class ShipmentDelegateTest {
    
    private static String orderNumber = '1234567890';

    @testSetup
    private static void setupData() {
        TestDataService.setupRestEnvironmentProperties();
        TestDataService.setupSlackCustomSettings();
        TestDataService.setupLoggingCustomSettings();
    }

    @isTest static void testHTTPResponse() { 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ShipmentUpsMockHttpResponseGenerator(200, ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE.GET_SHIPMENT_TRACKING_INFO));
        ShipmentPackage__c p = ShipmentDelegate.GetShipmentTrackingInfo('UPS','1z2345678901');
        System.AssertEquals(p.Status__c, 'DELIVERED');
        Test.stopTest();
    }

    @isTest static void testCancelOrderUnknownStatusCode() {
   
        Test.startTest();
        String invalidResponseStatus= 'INVALID RESULT TEST 12345';

        Test.setMock(HttpCalloutMock.class, 
            new ShipmentUpsMockHttpResponseGenerator(200, 
                ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE.CANCEL_ORDER,
                '[{"Status" : "'+ invalidResponseStatus + '"}, {"OrderId" : "' + orderNumber + '"}]'));
        
        System.assertEquals(0, [SELECT Id FROM Exception_Log__c].size());

        HttpRequestResult requestResult = ShipmentDelegate.cancelOrder(orderNumber);
        
        System.assertEquals(false, requestResult.success, 'cancelOrder expected to fail.');

        Exception_Log__c exceptionLog = [SELECT Id, Message__c FROM Exception_Log__c limit 1][0];
        System.assertNotEquals(null, exceptionLog, 'Expected to have Exception_Log__c object inserted.');

        String exceptionMessage = (new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_STATUS_CODE + '{Status=' + invalidResponseStatus + '}');
        System.assertEquals(exceptionMessage, exceptionLog.Message__c);
        
        Test.stopTest();
    }

    @isTest static void handleCancelOrderManualProcessTest () {

        Account account1 = new Account(Name = 'Test Account 123');
        insert account1;

        Shipment__c shipment1 = new Shipment__c(OrderId__c = orderNumber,
                                               Account__c = account1.Id,
                                               ShippingStreet__c = 'No Name Street 123',
                                               ShippingCity__c = 'Chicago',
                                               ShippingPostalCode__c = '60610',
                                               ShippingState__c = 'IL',
                                               EstimatedShipDate__c = Date.today()
                                            );
        insert shipment1;

        Test.startTest();

        String invalidResponseStatus= '';

        Test.setMock(HttpCalloutMock.class, 
            new ShipmentUpsMockHttpResponseGenerator(200, 
                ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE.CANCEL_ORDER,
                '[{"Status" : ""}, {"OrderId" : "' + orderNumber + '"}]'));
        
        System.assertEquals(0, [SELECT Id FROM Exception_Log__c].size());

        HttpRequestResult requestResult = ShipmentDelegate.cancelOrder(orderNumber);
        
        System.assertEquals(true, requestResult.success, 'cancelOrder expected to succeed.');

        Exception_Log__c exceptionLog = [SELECT Id, Message__c FROM Exception_Log__c limit 1][0];
        System.assertNotEquals(null, exceptionLog, 'Expected to have Exception_Log__c object inserted.');

        String exceptionMessage = (new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_STATUS_CODE + ' OrderId: '+ orderNumber + ' canceled, but Status code return was blank!');
        System.assertEquals(exceptionMessage, exceptionLog.Message__c);
        
        Test.stopTest();
    }

    @isTest static void testCancelOrderNotFound() {

        Test.startTest();
        helperTestCancelOrderFailStatuses(ShipmentDelegate.NOT_FOUND, false);
        Test.stopTest();
    }

    @isTest static void testCancelOrderAlreadyProcessed() {

        Test.startTest();
        helperTestCancelOrderFailStatuses(ShipmentDelegate.ALREADY_PROCESSED, false);
        Test.stopTest();
    }

    @isTest static void testCancelOrderSuccesful() {

        Test.startTest();
        helperTestCancelOrderSuccessfulStatuses(ShipmentDelegate.CANCELLED, true);
        Test.stopTest();
    }

    @isTest static void testCancelOrderAlreadyCanceled() {

        Test.startTest();
        helperTestCancelOrderSuccessfulStatuses(ShipmentDelegate.ALREADY_CANCELED, true);
        Test.stopTest();
    }

    @isTest static void testCancelOrderStatusCode401() {
        Test.startTest();
        helperTestCancelOrderStatusCodes(401, false);
        Test.stopTest();
    }

    @isTest static void testCancelOrderStatusCode404() {
        Test.startTest();
        helperTestCancelOrderStatusCodes(404, false);
        Test.stopTest();
    }

    @isTest static void testCancelOrderStatusCode409() {
        Test.startTest();
        helperTestCancelOrderStatusCodes(409, false);
        Test.stopTest();
    }

    @isTest static void testCancelOrderStatusCode500() {
        Test.startTest();
        helperTestCancelOrderStatusCodes(500, false);
        Test.stopTest();
    }

    @isTest static void testCancelOrderStatusCode600() {
        Test.startTest();
        helperTestCancelOrderStatusCodes(600, false);
        Test.stopTest();
    }

    /*----------  Helper Methods Below this Line  ----------*/
    

    /*******************************************************************************************************
    * @description      Helper method to help test cover each status code in cancelOrder method
    * @param 
    * @param 
    * @return           void
    * 
    */
    static void helperTestCancelOrderStatusCodes(Integer statusCode, Boolean expectedToSucceed) {

        Test.setMock(HttpCalloutMock.class, 
            new ShipmentUpsMockHttpResponseGenerator(statusCode, 
                ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE.CANCEL_ORDER,
                '[{"Status" : "someStatus"}, {"OrderId" : "' + orderNumber + '"}]'));

        HttpRequestResult requestResult = ShipmentDelegate.cancelOrder(orderNumber);
        System.assertEquals(expectedToSucceed, requestResult.success);
    }

    /*******************************************************************************************************
    * @description     Helper test method to help with code duplicacy
    * 
    */
    static void helperTestCancelOrderSuccessfulStatuses(String shipmentDelegateStatus, Boolean expectedToSucceed) {

        Test.setMock(HttpCalloutMock.class, 
            new ShipmentUpsMockHttpResponseGenerator(200, 
                ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE.CANCEL_ORDER,
                '[{"Status" : "' + shipmentDelegateStatus + '"}, {"OrderId" : "' + orderNumber + '"}]'));

        HttpRequestResult requestResult = ShipmentDelegate.cancelOrder(orderNumber);
        System.assertEquals(true, requestResult.success);
    }

    /*******************************************************************************************************
    * @description     Helper test method to help with code duplicacy
    * 
    */
    static void helperTestCancelOrderFailStatuses(String shipmentDelegateStatus, Boolean expectedToSucceed) {

        Test.setMock(HttpCalloutMock.class, 
            new ShipmentUpsMockHttpResponseGenerator(200, 
                ShipmentUpsMockHttpResponseGenerator.REQUEST_TYPE.CANCEL_ORDER,
                '[{"Status" : "' + shipmentDelegateStatus + '"}, {"OrderId" : "' + orderNumber + '"}]'));
        
        System.assertEquals(0, [SELECT Id FROM Exception_Log__c].size());       
        HttpRequestResult requestResult = ShipmentDelegate.cancelOrder(orderNumber);   
        System.assertEquals(expectedToSucceed, requestResult.success);
        Exception_Log__c exceptionLog = [SELECT Id, Message__c FROM Exception_Log__c limit 1][0];
        System.assertNotEquals(null, exceptionLog, 'Expected to have Exception_Log__c object inserted.');
    }
}