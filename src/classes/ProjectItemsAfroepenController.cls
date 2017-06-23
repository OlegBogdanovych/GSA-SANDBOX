public with sharing class ProjectItemsAfroepenController {
	public List<Projecten__c> projectsFound {
		get {
			if (projectsFound == null) {
				projectsFound = new List<Projecten__c>();
			}
			return projectsFound;
		} set;
	}

	public Boolean showItems {
		get {
			if (showItems == null) {
				showItems = false;
			}
			return showItems;
		} set;
	}

	public Boolean showItemsForAfroepen {
		get {
			if (showItemsForAfroepen == null) {
				showItemsForAfroepen = false;
			}
			return showItemsForAfroepen;
		} set;
	}

	public Date deliveryDate {
		get {
			if (deliveryDate == null) {
				//deliveryDate = Date.today();
			}
			return deliveryDate;
		} set;
	}

	public String selectedTime {
        get {
            if(selectedTime == null)
            {
                selectedTime = '8:00';
            }
            return selectedTime;
        } set;
    }

	public List<ItemsList> listOfItems {get; set;}
	public List<ItemsList> listForAfroepen {get; set;}

	public String searchline {get; set;}
	public String projectId {get; set;}
	public String extraRemark {get; set;}
	public String sortDirection {get;set;}
    public String sortField {get;set;}

    /* Filters */
    public String seacrhByItemName {get; set;}
    public String selectedStaat {get; set;}
    public String seacrhByItemSize {get; set;}
    public String seacrhByItemDiameter {get; set;}
    public String seacrhByItemMerk {get; set;}
    public String selectedMaterial {get; set;}
    public String selectedKleur {get; set;}
    public String selectedKindOfPackages {get; set;}
    public String seacrhByHub {get; set;}

	public Boolean showSuccessPopup {get; set;}

	public Map<Id, Projecten__c> projectsById {get; set;}

	@TestVisible String fieldsValidationError = '';

	public ProjectItemsAfroepenController() {
		showSuccessPopup = false;
	}

	public void searchProjects() {
		projectsFound = new List<Projecten__c>();

		String searchString = '%' + searchline + '%';
		projectsById = new Map<Id, Projecten__c>([Select Id, Name from Projecten__c WHERE Name LIKE :searchString LIMIT 5]);

		projectsFound.addAll(projectsById.values());
	}

	public void selectItems() {
		showItems = true;
		showItemsForAfroepen = false;
		showSuccessPopup = false;

		fieldsValidationError = '';

		listForAfroepen = new List<ItemsList>();
		listOfItems = new List<ItemsList>();

		List<WWW__c> wwws = [SELECT Id, Name, Project__c, Hub_Building_Site__c, Hub_Building_Site__r.Name, Curr_Items_To_Invoke__c, Item__c, Item__r.Name, Item__r.Staat__c, Item__r.Sizes__c,
										Item__r.Diameter__c, Item__r.Merk__c, Item__r.Materiaal__c, Item__r.Kleur__c, Item__r.Kind_Of_Packages__c
								FROM WWW__c
								WHERE Project__c = :projectId];

		if (wwws != null && !wwws.isEmpty()) {
			for (WWW__c www : wwws) {
				if (www.Curr_Items_To_Invoke__c > 0) {
					listOfItems.add(new ItemsList(www, true));
				}
			}
		}

		System.debug(listOfItems);
	}

	public void afroepenItems() {
		showItemsForAfroepen = true;
		listForAfroepen = new List<ItemsList>();
		fieldsValidationError = '';

		for (ItemsList il : listOfItems) {
			if (il.isSelected == true) {
				listForAfroepen.add(il);
			}
		}
	}

	public PageReference finishAfroepenItems() {
		System.debug('deliveryDate -->> ' + deliveryDate);

		fieldsValidationError = validateDateField();
		for (ItemsList il : listForAfroepen) {
			if (il.itemsToInvoke > il.wwwRecord.Curr_Items_To_Invoke__c) {
				fieldsValidationError += 'Max aantal items for ' + il.wwwRecord.Item__r.Name + ' item is ' + il.wwwRecord.Curr_Items_To_Invoke__c + ' <br/>';
			} else if (il.itemsToInvoke == null || il.itemsToInvoke == 0 || il.itemsToInvoke < 0) {
				fieldsValidationError += 'Aantal items for ' + il.wwwRecord.Item__r.Name + ' item should be > 0 <br/>';
			}
		}

		if (fieldsValidationError != '' && fieldsValidationError.length() > 0) {
            System.debug('ERROR -->> ' + fieldsValidationError);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, fieldsValidationError, '');
            ApexPages.addMessage(myMsg);
            return null;
        } else {
        	List<WWW_Detail__c> toInsert = new List<WWW_Detail__c>();

        	RecordType recType = [Select Id, Name from RecordType where sObjectType = 'WWW_Detail__c' and DeveloperName = 'Invoked' limit 1];

        	Datetime dateOfDelivery = makeDatetime(deliveryDate, selectedTime);
        	System.debug('dateOfDelivery -->> ' + dateOfDelivery);

        	String itemsAfroepen = '';
            String itemsAfroepenLinks = '';

            String fullURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

        	for (ItemsList il : listForAfroepen) {
        		WWW_Detail__c det = new WWW_Detail__c();
        		det.WWW__c = il.wwwRecord.Id;
        		det.RecordTypeId = recType.Id;
        		det.Number_Of_Items__c = il.itemsToInvoke;
        		det.Extra_Remarks__c = extraRemark;
        		det.Preferred_Delivery_Time__c = dateOfDelivery;

                insert det;

        		itemsAfroepen += il.wwwRecord.Item__r.Name + ' ( ' +  il.itemsToInvoke + ' ) \n';
                itemsAfroepenLinks += '<a href="' + fullURL + det.Id + '" >' + il.wwwRecord.Item__r.Name + ' ( ' +  il.itemsToInvoke + ' ) </a> <br />';
                System.debug('itemsAfroepenLinks -->> ' + itemsAfroepenLinks);
        		//System.debug('OBDEB DETAIL FOR ' + il.wwwRecord.Item__r.Name2 + ' -->> ' + det);
        		//toInsert.add(det);
        	}

        	//insert toInsert;

        	AfroepenAgenda__c afroepenAgenda = new AfroepenAgenda__c();
        	afroepenAgenda.Extra_Remarks__c = extraRemark;
        	afroepenAgenda.Preferred_Delivery_Time__c = dateOfDelivery;
        	//afroepenAgenda.End_Delivery_Time__c = makeDatetime(deliveryDate, '23:59');
        	afroepenAgenda.ItemsAfroepen__c = itemsAfroepen;
            afroepenAgenda.ItemsList__c = itemsAfroepenLinks;
        	afroepenAgenda.Project__c = projectId;

        	insert afroepenAgenda;

        	selectItems();
        	showItemsForAfroepen = false;

        	showSuccessPopup = true;
        }

		return null;
	}

	private String validateDateField() {
		String toReturn = '';

		if (deliveryDate == null) {
			//toReturn = 'Voorkeur afleverdatum is required field <br/>';
			toReturn = System.Label.Preferred_Delivery_Time + ' ' + System.Label.is_required_field + ' <br/>';
		}

		return toReturn;
	}

	private Datetime makeDatetime (Date dateVal, String timeStr) {
		Datetime toReturn = null;

		if (dateVal != null && timeStr != null) {
			Integer hours  = Integer.valueOf(timeStr.substring(0, timeStr.indexOf(':')));
	        Integer min = Integer.valueOf(timeStr.substring(timeStr.indexOf(':') + 1, timeStr.length()));

	        String dateStr = String.valueOf(dateVal);

			toReturn = Datetime.newInstance(Integer.valueOf(dateStr.substring(0,4)),
	                                    Integer.valueOf(dateStr.substring(5,7)), Integer.valueOf(dateStr.substring(8,10)), hours, min, 0);
		}

		return toReturn;
	}

	public List<SelectOption> getTimes() {
        List<SelectOption> options = WWWDetailHelper.fillTimesSelectList();

        return options;
    }

    public PageReference sortByFiledItem() {
        if (sortDirection == null || sortDirection == '') {
            sortDirection  = 'ASCENDING';
            sortField = 'Name';
        }

        ItemsList.SortDirection = sortDirection;
        ItemsList.SortField = sortField;
        this.listOfItems.sort();

        return null;
    }

    public void addFiltersToItems() {
    	if (seacrhByItemName == null) {
            seacrhByItemName = '';
        }

        if (selectedStaat == null) {
            selectedStaat = '';
        }

        if (seacrhByItemSize == null) {
            seacrhByItemSize = '';
        }

        if (seacrhByItemDiameter == null) {
            seacrhByItemDiameter = '';
        }

        if (seacrhByItemMerk == null) {
            seacrhByItemMerk = '';
        }

        if (selectedMaterial == null) {
        	selectedMaterial = '';
        }

        if (selectedKleur == null) {
        	selectedKleur = '';
        }

		if (selectedKindOfPackages == null) {
        	selectedKindOfPackages = '';
        }

		if (seacrhByHub == null) {
        	seacrhByHub = '';
        }
        for (ItemsList il : listOfItems) {
        	String diameterString = il.wwwRecord.Item__r.Diameter__c == null ? '' : String.valueOf(il.wwwRecord.Item__r.Diameter__c);
        	String merkString = il.wwwRecord.Item__r.Merk__c == null ? '' : String.valueOf(il.wwwRecord.Item__r.Merk__c);
        	String hubString = il.wwwRecord.Hub_Building_Site__r.Name == null ? '' : String.valueOf(il.wwwRecord.Hub_Building_Site__r.Name);

        	if (il.wwwRecord.Item__r.Name.containsIgnoreCase(seacrhByItemName)
        			&& (il.wwwRecord.Item__r.Staat__c != null && (il.wwwRecord.Item__r.Staat__c).contains(selectedStaat) || selectedStaat == 'Alle' || selectedStaat == '')
        			&& (il.wwwRecord.Item__r.Sizes__c.containsIgnoreCase(seacrhByItemSize))
        			&& (diameterString.containsIgnoreCase(seacrhByItemDiameter))
        			&& (merkString.containsIgnoreCase(seacrhByItemMerk))
        			&& (il.wwwRecord.Item__r.Materiaal__c != null && (il.wwwRecord.Item__r.Materiaal__c).contains(selectedMaterial) || selectedMaterial == 'Alle' || selectedMaterial == '')
        			&& (il.wwwRecord.Item__r.Kleur__c != null && (il.wwwRecord.Item__r.Kleur__c).contains(selectedKleur) || selectedKleur == 'Alle' || selectedKleur == '')
        			&& (il.wwwRecord.Item__r.Kind_Of_Packages__c != null && (il.wwwRecord.Item__r.Kind_Of_Packages__c).contains(selectedKindOfPackages) || selectedKindOfPackages == 'Alle' || selectedKindOfPackages == '')
        			&& (hubString.containsIgnoreCase(seacrhByHub))
        		) {
                il.show = true;
            } else {
                il.show = false;
            }

            if (seacrhByItemName == ''
            		&& (selectedStaat == 'Alle' || selectedStaat == '')
            		&& (seacrhByItemSize == '')
            		&& (seacrhByItemDiameter == '')
            		&& (seacrhByItemMerk == '')
            		&& (selectedMaterial == 'Alle' || selectedMaterial == '')
            		&& (selectedKleur == 'Alle' || selectedKleur == '')
            		&& (selectedKindOfPackages == 'Alle' || selectedKindOfPackages == '')
            		&& (seacrhByHub == '')
            	) {
                il.show = true;
            }
		}
    }

    public List<SelectOption> getStaatPicklistValues() {
    	List<SelectOption> options = new List<SelectOption>();

    	options.add(new SelectOption('Alle', 'Alle'));

    	Schema.DescribeFieldResult fieldResult = Item__c.Staat__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

    	for (Schema.PicklistEntry f : ple) {
    		options.add(new SelectOption(f.getLabel(), f.getValue()));
    	}

    	return options;
    }

    public List<SelectOption> getMaterialPicklistValues() {
    	List<SelectOption> options = new List<SelectOption>();

    	options.add(new SelectOption('Alle', 'Alle'));

    	Schema.DescribeFieldResult fieldResult = Item__c.Materiaal__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

    	for (Schema.PicklistEntry f : ple) {
    		options.add(new SelectOption(f.getLabel(), f.getValue()));
    	}

    	return options;
    }

    public List<SelectOption> getKleurPicklistValues() {
    	List<SelectOption> options = new List<SelectOption>();

    	options.add(new SelectOption('Alle', 'Alle'));

    	Schema.DescribeFieldResult fieldResult = Item__c.Kleur__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

    	for (Schema.PicklistEntry f : ple) {
    		options.add(new SelectOption(f.getLabel(), f.getValue()));
    	}

    	return options;
    }

    public List<SelectOption> getKindOfPackagesPicklistValues() {
    	List<SelectOption> options = new List<SelectOption>();

    	options.add(new SelectOption('Alle', 'Alle'));

    	Schema.DescribeFieldResult fieldResult = Item__c.Kind_Of_Packages__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

    	for (Schema.PicklistEntry f : ple) {
    		options.add(new SelectOption(f.getLabel(), f.getValue()));
    	}

    	return options;
    }
}