public with sharing class AfleverenSublocs {
	public String locsLabel {get; set;}
    public List<Location__c> locations {get; set;}
    public Boolean isChecked {get;set;}

    public AfleverenSublocs (String locsLabel, List<Location__c> locations, Boolean isChecked){
        this.locsLabel = locsLabel;
        this.locations = locations;
        this.isChecked = isChecked;
    }
}