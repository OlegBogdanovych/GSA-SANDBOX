public class ProductUtil {
    public static void entry(TriggerParams triggerParams) {
        List<Product2> triggerNew = (List<Product2>)triggerParams.triggerNew;
        List<Product2> triggerOld = (List<Product2>)triggerParams.triggerOld;
        Map<Id, Product2> oldMap = (Map<Id, Product2>)triggerParams.oldMap;
        Map<Id, Product2> newMap = (Map<Id, Product2>)triggerParams.newMap;


        if (triggerParams.isBefore){
          if (triggerParams.isUpdate || triggerParams.isInsert) {
            checkName(triggerNew);
          }
        }
    }
    public static void checkName(List <Product2> projects) {
        Set <String> names = new Set <String>();
        for (Product2 p: projects) {
            names.add(p.Name);
        }
        List <Product2> oldprojects = [select Name from Product2 where Name in: names];
        Map<string, Product2> byName = new Map <String, Product2>();
        for (Product2 pr: oldprojects ) {
            byName.put(pr.Name, pr);
        }
        for (Product2 p: projects) {
           if (byName.containsKey(p.Name) ) {
                p.addError(Label.Unique);
            }
        }
        
    }
}