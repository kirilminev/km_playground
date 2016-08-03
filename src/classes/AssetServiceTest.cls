@isTest
public with sharing class AssetServiceTest {
	
	private static testMethod void testGetByAccountId() {
		List<Asset> assets = new List<Asset>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Asset asset = new Asset();
		asset.Name = 'Asset Name';
		asset.AccountId = account.Id;
		insert asset;
		assets.add(asset);
		List<Asset> result = AssetService.getByAccountId(account.Id, new List<String> {'AccountId',
																					   'Name'});
		system.assert(result == assets);		
	}

	private static testMethod void testGetById() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = 'Asset Name';
		insert asset;
		Asset result = AssetService.getById(asset.Id, new List<String> {'AccountId',
																		'Name'});
		system.assert(result == asset);
	}

	private static testMethod void testGetByNames() {
		List<String> assetNames = new List<String>();
		List<Asset> assets = new List<Asset>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = 'Asset  Name';
		insert asset;
		assetNames.add(asset.Name);
		assets.add(asset);
		List<Asset> result = AssetService.getByNames(assetNames, new List<String> {'AccountId',
																				   'Name'});
		system.assert(result == assets);
	}

	private static testMethod void testGetByName() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = 'Asset Name';
		insert asset;
		Asset result = AssetService.getByName(asset.Name, new List<String> {'AccountId',
																			'Name'});

		system.assert(result == asset);
	}
}