/**
 * Wrapper class for Items to Afroepen with comperable methods
 *
 * @version     1.01 11 June 2017
 * @author      Oleg Bogdanovych
 */

global with sharing class ItemsList implements Comparable {
	public Boolean isSelected {get; set;}
	public WWW__c wwwRecord {get; set;}
	public Decimal itemsToInvoke {get; set;}
	public Boolean show {get; set;}

	public ItemsList(WWW__c www, Boolean show) {
		this.wwwRecord = www;
		this.isSelected = false;
		this.show = show;
	}

	public static final String ASCENDING = 'ASCENDING';
    public static String SortDirection;
    public static String SortField;

	global Integer compareTo(Object compareTo) {
		ItemsList compateToItem = (ItemsList) compareTo;

		if (SortField == 'Name') {
            return compareToName(compareTo);
        }

        if (SortField == 'Staat') {
            return compareToStaat(compareTo);
        }

        if (SortField == 'Maten') {
            return compareToMaten(compareTo);
        }

        if (SortField == 'Diameter') {
            return compareToDiameter(compareTo);
        }

        if (SortField == 'Merk') {
            return compareToMerk(compareTo);
        }

        if (SortField == 'Material') {
            return compareToMaterial(compareTo);
        }

        if (SortField == 'Kleur') {
            return compareToKleur(compareTo);
        }

        if (SortField == 'Type_verpakking') {
            return compareToTypeVerpakking(compareTo);
        }

        if (SortField == 'wat_nog_op_te_roepen_is') {
            return compareToItemsLeft(compareTo);
        }

        if (SortField == 'Loods/HUB') {
            return compareToHub(compareTo);
        }

        return 0;
    }

    public Integer compareToName(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Name > item.wwwRecord.Item__r.Name) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Name == item.wwwRecord.Item__r.Name) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToStaat(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Staat__c > item.wwwRecord.Item__r.Staat__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Staat__c == item.wwwRecord.Item__r.Staat__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToMaten(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Sizes__c > item.wwwRecord.Item__r.Sizes__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Sizes__c == item.wwwRecord.Item__r.Sizes__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToDiameter(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Diameter__c > item.wwwRecord.Item__r.Diameter__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Diameter__c == item.wwwRecord.Item__r.Diameter__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToMerk(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Merk__c > item.wwwRecord.Item__r.Merk__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Merk__c == item.wwwRecord.Item__r.Merk__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToMaterial(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Materiaal__c > item.wwwRecord.Item__r.Materiaal__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Materiaal__c == item.wwwRecord.Item__r.Materiaal__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToKleur(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Kleur__c > item.wwwRecord.Item__r.Kleur__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Kleur__c == item.wwwRecord.Item__r.Kleur__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToTypeVerpakking(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Item__r.Kind_Of_Packages__c > item.wwwRecord.Item__r.Kind_Of_Packages__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Item__r.Kind_Of_Packages__c == item.wwwRecord.Item__r.Kind_Of_Packages__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToItemsLeft(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Curr_Items_To_Invoke__c > item.wwwRecord.Curr_Items_To_Invoke__c) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Curr_Items_To_Invoke__c == item.wwwRecord.Curr_Items_To_Invoke__c) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }

    public Integer compareToHub(Object obj) {
    	ItemsList item = (ItemsList)(obj);

        if (this.wwwRecord.Hub_Building_Site__r.Name > item.wwwRecord.Hub_Building_Site__r.Name) {
            if (SortDirection == ASCENDING) {
            	return 1;
            } else {
                return -1;
            }
        }

        if (this.wwwRecord.Hub_Building_Site__r.Name == item.wwwRecord.Hub_Building_Site__r.Name) {
            return 0;
        }

        if (SortDirection == ASCENDING) {
            return -1;
        } else {
            return 1;
        }
    }
}