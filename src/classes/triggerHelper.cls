public with sharing class triggerHelper {


public static boolean entryHasStartedAfterInUp=false;


//A boolean that is set and then checked at the beginning of update triggers to be sure they only execute once

    public static  void  recursiveHelperAfterInUp (Boolean tempBool){
        entryHasStartedAfterInUp=tempBool;
    }
}