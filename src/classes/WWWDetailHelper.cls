public with sharing class WWWDetailHelper {
	public WWWDetailHelper() {
	}

	public static WWW__c getWwwRecordById(Id recordId) {
		WWW__c www = [SELECT Id, Project__c, Curr_Items_To_Invoke__c, Item__c, Item__r.Name, Actueel_aantal_palletplaatsenworkflow__c,
								Can_be_delivered__c, Ticket_Number_ILIPS__c, Filecardnumber__c, Projectmember__c, Hub_Building_Site__c,
								Actueel_aantal_palletplaatsen__c,  Supplier__c , Name
						FROM WWW__c
						WHERE Id = :recordId];

		return www;
	}

	public static List<RecordType> getRecordTypesBySobjectName(String sObjName) {
		List<RecordType> recordTypes = [select Id, DeveloperName  from RecordType where sObjectType = :sObjName];

		return recordTypes;
	}

	public static List<SelectOption> fillRecordTypesSelectListBySobject(String sObjName) {
		List<SelectOption> options = new List<SelectOption>();
        Map<Id, RecordType> recTypesById = new Map<Id, RecordType>([select Id, Name, DeveloperName from RecordType where sObjectType = :sObjName]);

        for (RecordType rec : recTypesById.values()) {
            options.add(new SelectOption(rec.Id, rec.Name));
        }

        return options;
	}

	//public static List<SelectOption> getProjectsForVerwatchen() {
	//	List<SelectOption> options = new List<SelectOption>();

	//	Map<Id, Projecten__c> prById = new Map<Id, Projecten__c>([select Id, Name from Projecten__c order by CreatedDate desc]);

 //       for (Projecten__c rec: prById.values()) {
 //           options.add(new SelectOption(rec.Id, rec.Name));
 //       }

	//	return options;
	//}

	public static Map<Id, WWW__c> fillMapWwwRecordsById() {
		Map<Id, WWW__c> toReturn = new Map<Id, WWW__c>([select Id, Project__c, Curr_Items_To_Invoke__c, Item__c, Can_be_delivered__c, Actueel_aantal_palletplaatsenworkflow__c, Ticket_Number_ILIPS__c, Filecardnumber__c, Projectmember__c, Hub_Building_Site__c, Actueel_aantal_palletplaatsen__c, Supplier__c, Name from WWW__c order by CreatedDate desc]);

		return toReturn;
	}

	public static String cutErrorMessage(String m) {
		String toReturn = '';

		if (m.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1 && m.indexOf('Class.') != -1) {
            toReturn = m.substring(m.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION'), m.indexOf('Class.'));
        } else if (m.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1){
             toReturn = m.substring(m.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+34, m.length());
        }

        return toReturn;
	}

	public static List<SubLocation> getSublocations(String locationId) {
		List<SubLocation> options = new List<SubLocation>();

        if (locationId != null) {
        	if (locationId.length() == 18) {
            	locationId = locationId.left(locationId.length()-3);
            }

            for (Location__c loc: [select Id, Name from Location__c where Parent_Location__c =: locationId] ) {
                options.add(new SubLocation(false, loc));
            }
        }

        return options;
	}

	public static Datetime madeDateFromNewDatepicker(String dateStr, String timeStr) {
		Datetime toReturn = null;

		if (dateStr != null && dateStr != '' && timeStr != null) {
			Integer hours  = Integer.valueOf(timeStr.substring(0, timeStr.indexOf(':')));
	        Integer min = Integer.valueOf(timeStr.substring(timeStr.indexOf(':') + 1, timeStr.length()));

			toReturn = Datetime.newInstance(Integer.valueOf(dateStr.substring(6,10)),
	                                    Integer.valueOf(dateStr.substring(3,5)), Integer.valueOf(dateStr.substring(0,2)), hours, min, 0);
		}

		return toReturn;
	}

	public static List<SelectOption> fillTimesSelectList() {
		List<SelectOption> options = new List<SelectOption>();

		for (integer i= 0; i <= 23; i++) {
            for (integer j = 0; j <= 30; j = j + 30) {
                If (j == 0) {
                   options.add(new SelectOption(String.valueOf(i)+':0'+String.valueOf(j), String.valueOf(i)+':0'+String.valueOf(j)));
                } else {
                    options.add(new SelectOption(String.valueOf(i)+':'+String.valueOf(j), String.valueOf(i)+':'+String.valueOf(j)));
                }
            }
        }

        return options;
	}

	public static List<SelectOption> getLocationsForAfleveren(Id wwwId) {
		List<SelectOption> options = new List<SelectOption>();

		if (wwwId != null) {
			List<WWW_detail__c> detailsDelToHub = [select Id, Location__c, Location__r.Name, Number_Of_Items__c from WWW_detail__c
                            where WWW__c = :wwwId and RecordType.DeveloperName =: 'Delivered_2_Hub' ];

	        List<WWW_detail__c> detailsDelTo = [select Id, Location__c, Location__r.Name, Number_Of_Items__c, RecordType.DeveloperName from WWW_detail__c
	                            where WWW__c = :wwwId and (RecordType.DeveloperName =: 'Delivered_2_Project' or RecordType.DeveloperName =:'Delivered_2_Hub')];

	        Map<Id, Decimal> valueByLocId = new Map<Id, Decimal>();
	        for (WWW_detail__c det: detailsDelTo) {
	            if (valueByLocId.get(det.Location__c) == null) {
	                valueByLocId.put(det.Location__c, 0);
	            }
	            if (det.RecordType.DeveloperName == 'Delivered_2_Hub') {
	                Decimal currVal = valueByLocId.get(det.Location__c);
	                currVal += det.Number_of_items__c;
	                valueByLocId.put(det.Location__c, currVal);
	            } else if(det.RecordType.DeveloperName == 'Delivered_2_Project') {
	                Decimal currVal = valueByLocId.get(det.Location__c);
	                currVal -= det.Number_of_items__c;
	                valueByLocId.put(det.Location__c, currVal);
	            }
	        }

	        Map<String, String> locationsMap = new Map<String, String>();
	        for (WWW_detail__c det: detailsDelToHub) {
	            if (det.Location__c != null && valueByLocId.get(det.Location__c) > 0) {
	                locationsMap.put(det.Location__c, det.Location__r.Name);
	            }
	        }

	        options.add(new SelectOption('', ''));
	        for (String lcId : locationsMap.keySet()) {
	            options.add(new SelectOption(lcId, locationsMap.get(lcId)));
	        }
		}

        return options;
	}

	public static List<AfleverenSublocs> getSublocationsForAfleveren(Id locationId, Id wwRecordId) {
		List<AfleverenSublocs> occupiedSublocs = new List<AfleverenSublocs>();

        if (locationId != null ) {
            String wwwId = wwRecordId;
            if (wwwId.length() == 18) {
            	wwwId = wwwId.left(wwwId.length()-3);
            }

            List<WWW_Detail__c> wwwDs = [Select Id, Name, Number_Of_Items__c, Location__c, WWWD_sublocations__c
                                            from WWW_Detail__c
                                            where WWW__c = :wwwId and RecordType.DeveloperName = 'Delivered_2_Hub'
                                                                    and Location__c = :locationId];
            Set<Id> wwwdIds = new Set<Id>();
            Map<Id, WWW_Detail__c> wwwdById = new Map<Id, WWW_Detail__c>();
            Map<String, List<WWW_Detail__c>> wwwdsByLocations = new Map<String, List<WWW_Detail__c>>();

            for (WWW_Detail__c wd : wwwDs) {
                wwwdIds.add(wd.Id);
                wwwdById.put(wd.Id, wd);

                if (wwwdsByLocations.get(wd.WWWD_sublocations__c) == null) {
                    wwwdsByLocations.put(wd.WWWD_sublocations__c, new List<WWW_Detail__c>());
                }
                wwwdsByLocations.get(wd.WWWD_sublocations__c).add(wd);
            }

            List<SublocationDetail__c> sublocsToCheck = [SELECT Id, Location__c, WWW_Detail__c, WWW_Detail_r_RecordType_DeveloperName__c,  WWWid__c, Number_of_items__c
                                FROM SublocationDetail__c
                                where WWWid__c = :wwwId];

            Map<Id, List<SublocationDetail__c>> subLocDetsByWwwdId = new Map<Id, List<SublocationDetail__c>>();
            Map<Id, Decimal> locationAmountByLocationId = new Map<Id, Decimal>();

            for (SublocationDetail__c sd : sublocsToCheck) {
                if (subLocDetsByWWWdId.get(sd.WWW_Detail__c) == null) {
                    subLocDetsByWWWdId.put(sd.WWW_Detail__c, new List<SublocationDetail__c>());
                }
                subLocDetsByWWWdId.get(sd.WWW_Detail__c).add(sd);

                if (locationAmountByLocationId.get(sd.Location__c) == null) {
                    locationAmountByLocationId.put(sd.Location__c, 0);
                }

                if (sd.WWW_Detail_r_RecordType_DeveloperName__c == 'Delivered_2_Hub') {
                    Decimal currVal = locationAmountByLocationId.get(sd.Location__c);
                    currVal += sd.Number_of_items__c;
                    locationAmountByLocationId.put(sd.Location__c, currVal);
                } else if(sd.WWW_Detail_r_RecordType_DeveloperName__c == 'Delivered_2_Project') {
                    Decimal currVal = locationAmountByLocationId.get(sd.Location__c);
                    currVal -= sd.Number_of_items__c;
                    locationAmountByLocationId.put(sd.Location__c, currVal);
                }
            }

            Map<Id, Location__c> locationById = new Map<Id, Location__c>([select Name, Id, Current_amount__c from Location__c where Parent_Location__c =: locationId and Occupied__c = true and difference__c > 0]);

            Map<String, List<Location__c>> locationsByAbbr = new Map<String, List<Location__c>>();
            for(String locAbbr: wwwdsByLocations.keySet()) {
                Set<Id> locsIdToAdd = new Set<Id>();

                for (WWW_Detail__c wd : wwwdsByLocations.get(locAbbr)) {
                    for (SublocationDetail__c sd : subLocDetsByWwwdId.get(wd.Id)) {
                        if (locationById.get(sd.Location__c) != null && locationAmountByLocationId.get(sd.Location__c) > 0) {
                            locsIdToAdd.add(sd.Location__c);
                        }
                    }
                }

                String subStr = locAbbr.substringAfterLast(' ');
                if (subStr.length() == locsIdToAdd.size()) {
                    List<Location__c> ls = new List<Location__c>();
                    for (Id i : locsIdToAdd) {
                        ls.add(locationById.get(i));
                    }
                    locationsByAbbr.put(locAbbr, ls);
                }
            }

            for (String lAbbr: locationsByAbbr.keySet()) {
                occupiedSublocs.add(new AfleverenSublocs(lAbbr,  locationsByAbbr.get(lAbbr), false));
            }
        }

		return occupiedSublocs;
	}

	public static String makeSublocationStringForDelToHub(List<SubLocation> subLocations, List<AfleverenSublocs> occupiedSublocs) {
		String toReturn = '';

		if (subLocations.size() > 0) {
	        for (SubLocation subLocation: subLocations) {
	            if (subLocation.isChecked) {
	                if (toReturn == '') {
	                    toReturn = (String.valueOf(subLocation.sub.Name)).substring(0, (String.valueOf(subLocation.sub.Name)).length()-1);
	                    toReturn = toReturn + ' ' + (String.valueOf(subLocation.sub.Name)).right(1);
	                } else {
	                    toReturn = toReturn + (String.valueOf(subLocation.sub.Name)).right(1);
	                }
	            }
	        }
	    } else if (occupiedSublocs.size() > 0) {
	    	for (AfleverenSublocs aflSubLoc : occupiedSublocs) {
	    		if (aflSubLoc.isChecked) {
	    			toReturn = aflSubLoc.locsLabel;
	    		}
	    	}
	    }

        return toReturn;
	}

	public static List<SubLocationDetail__c> generateSublocationDetailsToInsert(WWW_Detail__c detail, Boolean delToProj, List<AfleverenSublocs> occupiedSublocs, List<SubLocation> subLocations) {
		List<SubLocationDetail__c> toReturn = new List<SubLocationDetail__c>();

		if(delToProj) {
            for (AfleverenSublocs subLocation: occupiedSublocs) {
                if (subLocation.isChecked) {
                    for(Location__c loc : subLocation.locations) {
                        toReturn.add(new SubLocationDetail__c(WWW_detail__c = detail.id, Location__c = loc.Id));
                    }
                }
            }
        } else {
            for (SubLocation subLocation: sublocations) {
                if (subLocation.isChecked){
                    toReturn.add(new SubLocationDetail__c(WWW_detail__c = detail.id, Location__c = subLocation.sub.Id));
                }
            }
        }

        return toReturn;
	}

	public static String customValidation(WWW_Detail__c detail, List<SubLocation> subLocations, List<AfleverenSublocs> occupiedSublocs, WWW__c www, Boolean delToHub, Boolean delToProj, Boolean invoked, Boolean reserved) {
		String errorMessage = '';

		if (reserved) {
			if (detail.Grootte_verpakking__c == null || detail.Date_Of_Delivery__c == null
					|| detail.Opslagduur__c == null || detail.Afroepeenheid__c == null) {
                errorMessage = 'PLease fill all required fields <br/>';
                //return errorMessage;
            }

            errorMessage += validateNumberOfItemsFilled(detail);
            errorMessage += validateNumberOfItemsInvoked(detail, www);
        }

        if (delToHub) {
        	errorMessage += validateWwwSelected(detail);
        	errorMessage += validateNumberOfItemsFilled(detail);
        	errorMessage += validateLocationFilled(detail);
        	errorMessage += validateArrivalTruckOnHub(detail);
        	errorMessage += validateDamagePackage(detail);
        	errorMessage += validateSublocationSelectedForDelToHub(subLocations);
        	errorMessage += validateOpmerkingenOnOntvangen(detail);
        }

        if (delToProj) {
        	errorMessage += validateWwwSelected(detail);
        	errorMessage += validateNumberOfItemsFilled(detail);
        	errorMessage += validateNumberOfItemsDeliveredToProject(detail, www);
        	errorMessage += validateAfleverenDateHigerOntvangen(detail, www);
        	errorMessage += validateSublocationSelectedForDelToProj(occupiedSublocs);
        	errorMessage += validateEnteredAmountForSubLOcationOnDelToProj(detail, occupiedSublocs, www);
        	errorMessage += validateLocationFilled(detail);
        	errorMessage += validateCompleetKlaargezet(detail);
        	errorMessage += validateOpmerkingen(detail);
        }

        if (invoked) {
        	errorMessage += validateWwwSelected(detail);
        	errorMessage += validateNumberOfItemsFilled(detail);
        	errorMessage += validateNumberOfItemsInvoked(detail, www);
        }

        return errorMessage;
	}

	public static String validateSublocationSelectedForDelToProj(List<AfleverenSublocs> occupiedSublocs) {
		String toReturn = '';
		Boolean selectedSubs = false;
        for (AfleverenSublocs subLocation: occupiedSublocs) {
            if (subLocation.isChecked) {
                selectedSubs = true;
            }
        }

        if (selectedSubs == false) {
        	toReturn = 'Sublocatie is required <br/>';
        }

		return toReturn;
	}

	public static String validateEnteredAmountForSubLOcationOnDelToProj(WWW_Detail__c detail, List<AfleverenSublocs> occupiedSublocs, WWW__c www) {
		String toReturn = '';

		if (www == null || www.Id == null) {
			return toReturn;
		}

		String wwwId = www.id;
        if (wwwId.length() == 18) {
        	wwwId = wwwId.left(wwwId.length()-3);
        }

        List<SublocationDetail__c> sublocsToCheck = [SELECT Id, Location__c, WWW_Detail__c, WWW_Detail_r_RecordType_DeveloperName__c,  WWWid__c, Number_of_items__c
                        FROM SublocationDetail__c
                        where WWWid__c = :wwwId];

        Map<Id, Decimal> locationAmountByLocationId = new Map<Id, Decimal>();
        for(SublocationDetail__c sld : sublocsToCheck) {
            if( locationAmountByLocationId.get(sld.Location__c) == null ) {
                locationAmountByLocationId.put(sld.Location__c, 0);
            }
            if(sld.WWW_Detail_r_RecordType_DeveloperName__c == 'Delivered_2_Hub') {
                Decimal currVal = locationAmountByLocationId.get(sld.Location__c);
                currVal += sld.Number_of_items__c;
                locationAmountByLocationId.put(sld.Location__c, currVal);
            } else if(sld.WWW_Detail_r_RecordType_DeveloperName__c == 'Delivered_2_Project') {
                Decimal currVal = locationAmountByLocationId.get(sld.Location__c);
                currVal -= sld.Number_of_items__c;
                locationAmountByLocationId.put(sld.Location__c, currVal);
            }
        }

        for (AfleverenSublocs subLocation: occupiedSublocs) {
            if (subLocation.isChecked) {
                for(Location__c loc : subLocation.locations) {
                    if(detail.Number_Of_Items__c > locationAmountByLocationId.get(loc.Id)) {
                        toReturn += 'Max aantal on sublocatie ' + loc.Name + ' is ' + locationAmountByLocationId.get(loc.Id) + '<br/>';
                    }
                }
            }
        }

		return toReturn;
	}

	public static String validateSublocationSelectedForDelToHub(List<SubLocation> subLocations) {
		String toReturn = '';

		Boolean isSelected = false;
		for (SubLocation subLocation: subLocations) {
            if (subLocation.isChecked) {
            	isSelected = true;
            }
        }

        if (isSelected == false) {
        	toReturn = 'Sublocatie is required <br/>';
        }

        return toReturn;
	}

	public static String validateWwwSelected(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.WWW__c == null) {
			toReturn = 'WWW is required <br/>';
		}

		return toReturn;
	}

	public static String validateNumberOfItemsFilled(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.Number_Of_Items__c == null || detail.Number_Of_Items__c <= 0) {
            toReturn = 'Aantal items is required field and should be > 0 <br/>';
        }

        return toReturn;
	}

	public static String validateNumberOfItemsInvoked(WWW_Detail__c detail, WWW__c www) {
		String toReturn = '';

		if (detail.Number_Of_Items__c != null && detail.Number_Of_Items__c > 0) {
			if ((www.Curr_Items_To_Invoke__c < detail.Number_Of_Items__c) && www.Curr_Items_To_Invoke__c != 0) {
                toReturn = 'Max Aantal items is ' + String.valueOf(www.Curr_Items_To_Invoke__c) + ' <br/>';
            }
		}

		return toReturn;
	}

	public static String validateAfleverenDateHigerOntvangen(WWW_Detail__c detail, WWW__c www) {
		String toReturn = '';

		List<WWW_Detail__c> ontvangenDetails = [Select Id, Name, Arrival_Truck_On_Hub__c from WWW_Detail__c where WWW__c = :www.Id and RecordType.DeveloperName = 'Delivered_2_Hub'];

		if (ontvangenDetails != null && !ontvangenDetails.isEmpty()) {
			Datetime lowerDate;

			for (WWW_Detail__c det : ontvangenDetails) {
				if (lowerDate == null) {
					lowerDate = det.Arrival_Truck_On_Hub__c;
				} else {
					if (lowerDate > det.Arrival_Truck_On_Hub__c) {
						lowerDate = det.Arrival_Truck_On_Hub__c;
					}
				}
			}

			if (detail.Arrival_Truck_On_Project__c < lowerDate && lowerDate != null) {
				toReturn = 'Datum en tijd klaargezet should be grater than ' + lowerDate + ' <br/>';
			}
		}

		return toReturn;
	}

	public static String validateNumberOfItemsDeliveredToProject(WWW_Detail__c detail, WWW__c www) {
		String toReturn = '';

		if (detail.Number_Of_Items__c != null && detail.Number_Of_Items__c > 0) {
			if ((www.Can_be_delivered__c < detail.Number_Of_Items__c) && www.Can_be_delivered__c != 0) {
                toReturn = 'Max Aantal items is ' + String.valueOf(www.Can_be_delivered__c) + ' <br/>';
            }
		}

		return toReturn;
	}

	public static string validateLocationFilled(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.Location__c == null) {
            toReturn = 'Locatie is required field <br/>';
        }

		return toReturn;
	}

	public static String validateArrivalTruckOnHub(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.Arrival_Truck_On_Hub__c == null) {
            toReturn = 'Datum en tijd klaargezet is required field <br/>';
        }

        return toReturn;
	}

	public static String validateDamagePackage(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.Damage_Package__c == null) {
        	toReturn = 'Beschadigd is required field <br/>';
        }

        return toReturn;
	}

	public static String validateCompleetKlaargezet(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.Compleet_klaargezet__c == null) {
            toReturn = 'Compleet klaargezet is required field <br/>';
        }

        return toReturn;
	}

	public static String validateOpmerkingen(WWW_Detail__c detail) {
		String toReturn = '';

		if (detail.Compleet_klaargezet__c == 'Nee') {
            if (detail.Toelichting__c == null) {
                toReturn = 'Opmerkingen is required field <br/>';
            }
        }

        return toReturn;
	}

	public static String validateOpmerkingenOnOntvangen(WWW_Detail__c detail) {
		String toReturn = '';

		if(detail.Damage_Package__c == 'Yes') {
			if(detail.Extra_Remarks__c == null) {
				toReturn = 'Opmerkingen is required field <br/>';
			}
		}

		return toReturn;
	}
}