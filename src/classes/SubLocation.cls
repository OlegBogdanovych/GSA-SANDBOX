public with sharing class SubLocation {
	public Boolean isChecked {get;set;}
    public Location__c sub {get;set;}
    public SubLocation  ( Boolean isChecked, Location__c sub){
        this.isChecked = isChecked;
        this.sub = sub;
    }
}