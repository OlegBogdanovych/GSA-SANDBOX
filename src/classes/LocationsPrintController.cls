public with sharing class LocationsPrintController {

    public static final Integer LIMITINT = 999;

    public static List <Location__c > locations {
    	get {
    		if (locations == null) {
    			locations = new List <Location__c>();
    		}
    		return locations;
    	} set;
    }

    public static Integer offsetNumb {get;set;}
    public static Integer offsetNumbSet {get;set;}

    public static String hubSelected {get;set;}

	public LocationsPrintController() {

	}

	public void init() {}

	public static void loadData() {
        offsetNumb = 0;
        if (offsetNumbSet < 0) {
            offsetNumbSet = 0;
        }

        if (offsetNumbSet != null) {
            offsetNumb = offsetNumbSet * LIMITINT;
        }

        System.debug('offsetNumb'+offsetNumb);
        System.debug('offsetNumbSet'+offsetNumbSet);

		if (hubSelected != null && hubSelected != 'All') {
			locations = [select Id, Name from Location__c where Hub_Building_Site__c =: hubSelected  limit : LIMITINT offset:offsetNumb];
		} else {
			locations = [select Id, Name from Location__c limit: LIMITINT offset:offsetNumb];
		}
        System.debug('locations'+locations);
	}

    public static List<SelectOption> getHubs() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));

        List<Hub_Building_Site__c> hubs = [Select Id, Name from Hub_Building_Site__c ];
        for (Hub_Building_Site__c hub : hubs) {
            options.add(new SelectOption(hub.id, hub.Name));
        }

        return options;
    }
}