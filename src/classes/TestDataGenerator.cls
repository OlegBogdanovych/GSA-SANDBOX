public with sharing class TestDataGenerator {
	public TestDataGenerator() {

	}

	public static void fillTriggerSwitcherValues() {
		Set<String> triggerNames = new Set<String>();
		triggerNames.add('AccountHubUtil');
		triggerNames.add('BuildingTicketUtil');
		triggerNames.add('HubUtil');
		triggerNames.add('LocationUtil');
		triggerNames.add('ProductUtil');
		triggerNames.add('ProjectUtil');
		triggerNames.add('SubLocationDetailUtil');
		triggerNames.add('UserUtil');
		triggerNames.add('WWWDetailUtil');

		List<ActiveTrigger__c> toInsert = new List<ActiveTrigger__c>();

		for (String str : triggerNames) {
			ActiveTrigger__c activeTrigger = new ActiveTrigger__c();
		    activeTrigger.Name = str;
		    activeTrigger.IsActive__c = true;

		    toInsert.add(activeTrigger);
		}

		insert toInsert;
	}

	public static void createTestWwwDetailOntvangen(WWW__c www, Location__c location, Decimal numberOfItems) {
		RecordType rcTp = [Select Id from RecordType where sObjectType = 'WWW_Detail__c' AND DeveloperName = 'Delivered_2_Hub' limit 1];

		WWW_Detail__c detail = new WWW_Detail__c();
		detail.WWW__c = www.Id;
		detail.RecordTypeId = rcTp.Id;
		detail.Number_Of_Items__c = numberOfItems;
		detail.Location__c = location.Id;
		detail.Damage_Package__c = 'No';
		detail.Arrival_Truck_On_Hub__c = DateTime.newInstance(2017, 4, 25, 8, 0, 0);
		detail.Einddatum_opslag__c = DateTime.newInstance(2017, 4, 30, 8, 0, 0);
		detail.WWWD_sublocations__c = location.Name + ' ABCD';

		insert detail;

		List<Location__c> subLocs = [select Id, Name from Location__c where Parent_Location__c = :location.Id];

		List<SubLocationDetail__c> sublocsToInsert = new List<SubLocationDetail__c>();
		for (Location__c loc : subLocs) {
			sublocsToInsert.add(new SubLocationDetail__c(WWW_detail__c = detail.id, Location__c = loc.Id));
		}

		insert sublocsToInsert;
	}

	public static User createTestBouwticketUser(Account acc) {
		Profile profile = [select Id from Profile where Name = 'Bouwticket account'];

        User user = new User();
        user.Username = 'contact@ukr.net';
        user.Email = 'contact@ukr.net';
        user.FirstName = 'contact';
        user.CommunityNickname = 'test65454';
        user.LastName = 'contact';
        user.ProfileId = profile.Id;
        user.isActive = true;
        user.Alias = 'contact' ;
        user.EmailEncodingKey='UTF-8';
        user.languageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.isActive = true;
        user.AccountId__c = acc.id;
        user.TimeZoneSidKey='Europe/Amsterdam';

        insert user;

        return user;
	}

	public static Account createBouwticketAccount(String accName) {
		RecordType accRT = [select Id, Name from RecordType where Name = 'Client'];

        Account acc = new Account (RecordTypeId = accRT.id, Name = accName);
        insert acc;

        return acc;
	}

	public static Item__c createTestItem(String itemName, Decimal itemsPerPackage) {
		Item__c item = new Item__c();
		item.Name = itemName;
		item.Kind_Of_Packages__c = 'Balen';
		item.Number_Of_Units_Per_Package__c = itemsPerPackage;

		insert item;

		return item;
	}

	public static Contact createTestContact(Account acc) {
		Contact cont = new Contact(AccountId = acc.id, LastName = 'Test');
        insert cont;

        return cont;
	}

	public static Projecten__c createTestProject(Account acc, String name) {
		Projecten__c pr = new Projecten__c(Account__c = acc.id, Name = name);
        insert pr;

		return pr;
	}

	public static Projectmember__c createTestProjectMember(Projecten__c proj, Contact cont) {
		Projectmember__c member = new Projectmember__c (Project__c = proj.id, Contact__c = cont.id);
        insert member;

        return member;
	}

	public static Hub_Building_Site__c createTestHub(String name, Projecten__c proj) {
		RecordType hRT = [select Id, Name from RecordType where Name = 'Hub'];

		Hub_Building_Site__c buldingSite;
		if (proj == null) {
			buldingSite = new Hub_Building_Site__c(RecordTypeId = hRT.id, Name = name);
		} else {
			buldingSite = new Hub_Building_Site__c(RecordTypeId = hRT.id, Name = name, Project__c = proj.id );
		}

        insert buldingSite;

        return buldingSite;
	}

	public static Hub_Building_Site__c createTestHubBuildingSite(String name, Projecten__c proj) {
		RecordType bsRT = [select Id, Name from RecordType where Name = 'Building Site'];

		Hub_Building_Site__c buldingSite;
		if (proj == null) {
			buldingSite = new Hub_Building_Site__c(RecordTypeId = bsRT.id, Name = name);
		} else {
			buldingSite = new Hub_Building_Site__c(RecordTypeId = bsRT.id, Name = name, Project__c = proj.id );
		}

        insert buldingSite;

        return buldingSite;
	}

	public static WWW__c createTestWww(Projecten__c project, Item__c item, Hub_Building_Site__c hub) {
		WWW__c www = new WWW__c();

		www.Project__c = project.Id;
		www.Item__c = item.Id;
		www.Hub_Building_Site__c = hub.Id;

		insert www;

		return www;
	}

	public static Location__c createTestGateLocation(String name) {
		RecordType gateRT = [select Id, Name from RecordType where Name = 'Gate'];

        Location__c gate = new Location__c(RecordTypeId = gateRT.id, Name = name );
        insert gate;

        return gate;
	}

	public static Location__c createTestHublocationParent(String name, Hub_Building_Site__c hub) {
		RecordType hublRT = [select Id, Name from RecordType where Name = 'Hublocation'];

		Location__c hubl = new Location__c(RecordTypeId = hublRT.id, Name = name, Hub_Building_Site__c = hub.id);
        insert hubl;

        return hubl;
	}

	public static List<Location__c> createTestHublocationChildren(Hub_Building_Site__c hub, Location__c parent) {
		List<String> sublocsNames = new List<String>{'A', 'B', 'C', 'D'};
		RecordType hublRT = [select Id, Name from RecordType where Name = 'Hublocation'];

		List<Location__c> toReturn = new List<Location__c>();
		for (String str : sublocsNames) {
			Location__c loc = new Location__c();
			loc.Name = parent.Name + str;
			loc.Parent_Location__c = parent.Id;
			loc.Hub_Building_Site__c = hub.Id;
			loc.RecordTypeId = hublRT.id;

			toReturn.add(loc);
		}

		insert toReturn;

		return toReturn;
	}

	public static List<Location__c> createTestMassGateLocationWithHub(String name, Integer count, Hub_Building_Site__c hub) {
		RecordType gateRT = [select Id, Name from RecordType where Name = 'Gate'];

        List<Location__c> locs = new List<Location__c>();
		for (Integer i=0; i< count; i++) {
			Location__c gate = new Location__c(RecordTypeId = gateRT.id, Name = name + String.valueOf(i), Hub_Building_Site__c = hub.id );
			locs.add(gate);
		}
		insert locs;

        return locs;
	}

	public static Location__c createTestSiteLocation(Hub_Building_Site__c buldingSite, String name) {
		RecordType siteRT = [select Id, Name from RecordType where Name = 'Site Location'];

        Location__c siteL = new Location__c(RecordTypeId = siteRT.id, Hub_Building_Site__c = buldingSite.id, Name = name);
        insert siteL;

        return siteL;
	}

	public static List<Location__c> createTestMassSiteLocationWithHub(String name, Integer count, Hub_Building_Site__c hub) {
		RecordType siteRT = [select Id, Name from RecordType where Name = 'Site Location'];

        List<Location__c> locs = new List<Location__c>();
		for (Integer i=0; i< count; i++) {
			Location__c gate = new Location__c(RecordTypeId = siteRT.id, Name = name + String.valueOf(i), Hub_Building_Site__c = hub.id );
			locs.add(gate);
		}
		insert locs;

        return locs;
	}

	public static Location__c createTestVerticalTransport(String name) {
		RecordType verRT = [select Id, Name from RecordType where Name = 'Vertical Transport'];

        Location__c verTr = new Location__c(RecordTypeId = verRT.id, Name = name);
        insert verTr;

        return verTr;
	}

	public static List<Location__c> createTestMassVerticalTransportWithHub(String name, Integer count, Hub_Building_Site__c hub) {
		RecordType verRT = [select Id, Name from RecordType where Name = 'Vertical Transport'];

        List<Location__c> locs = new List<Location__c>();
		for (Integer i=0; i< count; i++) {
			Location__c gate = new Location__c(RecordTypeId = verRT.id, Name = name + String.valueOf(i), Hub_Building_Site__c = hub.id );
			locs.add(gate);
		}
		insert locs;

        return locs;
	}
}