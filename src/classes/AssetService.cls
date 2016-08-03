public class AssetService {
    private static final String ASSETx = 'Asset';

    public static List<Asset> getByAccountId(Id accountId, List<String> fields) {
        String soql = new SoqlBuilder()
                          .selectx(fields)
                          .fromx(ASSETx)
                          .wherex(new FieldCondition('AccountId').equals(accountId))
                          .toSoql();
        return Database.query(soql);
    }

    public static Asset getById(Id assetId, List<String> fields) {
        String soql = new SoqlBuilder()
                          .selectx(fields)
                          .fromx(ASSETx)
                          .wherex(new FieldCondition('Id').equals(assetId))
                          .toSoql();
        return Database.query(soql);
    }

    public static List<Asset> getByIds(List<Id> assetIds, List<String> fields) {
        String soql = new SoqlBuilder()
                          .selectx(fields)
                          .fromx(ASSETx)
                          .wherex(new SetCondition('Id').inx(assetIds))
                          .toSoql();
        return Database.query(soql);
    }

    public static List<Asset> getByNames(List<String> assetNames, List<String> fields) {
        String soql = new SoqlBuilder()
                          .selectx(fields)
                          .fromx(ASSETx)
                          .wherex(new SetCondition('Name').inx(assetNames))
                          .toSoql();
        return Database.query(soql);
    }

    public static Asset getByName(String assetName, List<String> fields) {
        String soql = new SoqlBuilder()
                          .selectx(fields)
                          .fromx(ASSETx)
                          .wherex(new FieldCondition('Name').equals(assetName))
                          .limitx(1)
                          .toSoql();
        return Database.query(soql);
    }

    public static List<Asset> getByRelatedWorkOrderId(Id caseId, List<String> fields) {
        String soql = new SoqlBuilder()
                          .selectx(fields)
                          .fromx(ASSETx)
                          .wherex(new FieldCondition('RelatedWorkOrder__c').equals(caseId))
                          .toSoql();
        return Database.query(soql);
    }

}