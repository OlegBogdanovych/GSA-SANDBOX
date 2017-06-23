public with sharing class CalendarComponentController {

    public CalendarComponentController() {
    }
  
    public ComponentData componentData {get; set;}
    public String buildingSiteId {get; set;}
    public String dateFrom {get; set;}
    public Date dateFromStr {get; set;}

    public List <Building_Ticket__c> ticketsPerDay {
        get {
            if (ticketsPerDay == null) {
                ticketsPerDay = new List <Building_Ticket__c>();
            }
            return ticketsPerDay;
        } set ;
    }
    public Date dateSelected;
    public Map<String, List <LocationWrap>> locationsForSelect {
        get {
            if (locationsForSelect == null) {
                locationsForSelect = new Map<String, List <LocationWrap>>(); 
            } 
            
            return locationsForSelect;
        } set;
    }
    
    /*public String jsonForCalendar {
        get {

            if (jsonForCalendar == null) {
                return JSON.serialize('[{title: \'All Day Event\',start: \'2015-12-01\'}]');
            } else {
                return jsonForCalendar;
            }
            
        } set;
    }*/
     public Set <Id> leftIds {
        get {
            if (leftIds == null) {
                leftIds = new Set <Id>();
            }
            return leftIds;
        } set;
    }
    
    public List <String> typeNames {
        get {
            if (typeNames == null) {
                typeNames = new List <String>();
            } 
            return typeNames;
        } set ;
    }
    public String getJsonForCalendar () {
        
        
        //System.debug('componentData'+componentData);
        if (componentData != null && componentData.hubSelected != null) {
            buildingSiteId = componentData.hubSelected;
            dateFrom = componentData.dateSelected;
        }
        
        locationsForSelect = new Map<String, List <LocationWrap>>();
        typeNames = new List <String>();
        //System.debug('leftIds '+leftIds.size()+ ' ' + leftIds);
        Map <Id, Location__c> locationsByIds = new Map <Id, Location__c>([select Id, Name, Hub_Building_Site__c , RecordType.Name
                            from Location__c where  Hub_Building_Site__c =: buildingSiteId]);
        //System.debug('locationsByIds'+locationsByIds.size()+ ' ' +locationsByIds );
        Set <String> namesSet = new Set <String>();
        Map <String, RecordTypes__c> recTypes = RecordTypes__c.getAll();
        for (Location__c loc: locationsByIds.values()) {
            if (recTypes.containsKey(loc.RecordType.Name)) {
                namesSet.add(recTypes.get(loc.RecordType.Name).Translation__c);
            } else {
                namesSet.add(loc.RecordType.Name);
            } 
            LocationWrap locWrap = new LocationWrap();
            
            if (leftIds.contains(loc.id)) {
                 locWrap.isChecked = true;
            } else {
                locWrap.isChecked = false;
            }
            locWrap.loc = loc;
            Boolean goaway = true;
            if (recTypes.containsKey(loc.RecordType.Name)){
                if (locationsForSelect.containsKey(recTypes.get(loc.RecordType.Name).Translation__c) ) {
                    goaway = false;
                    locationsForSelect.get(recTypes.get(loc.RecordType.Name).Translation__c).add(locWrap);    
                }else {
                    List <LocationWrap> locsToAdd = new List <LocationWrap>();
                    locsToAdd.add(locWrap);
                    goaway = false;
                    locationsForSelect.put(recTypes.get(loc.RecordType.Name).Translation__c, locsToAdd);
                }
            }
            if (goaway) {
                if (locationsForSelect.containsKey(loc.RecordType.Name) ) {
                    locationsForSelect.get(loc.RecordType.Name).add(locWrap);      
                } else {
                    List <LocationWrap> locsToAdd = new List <LocationWrap>();
                    locsToAdd.add(locWrap);
                    locationsForSelect.put(loc.RecordType.Name, locsToAdd);
                }
            }
            System.debug(LoggingLevel.Error, 'locationsForSelect ' + locationsForSelect);
            
        }
        typeNames.addAll(namesSet);
        //System.debug('locationsForSelect'+locationsForSelect.size()+ ' ' +locationsForSelect );
        //System.debug('typeNames'+typeNames.size()+ ' ' +typeNames );
        if (leftIds.size() == 0) {
            leftIds.addAll(locationsByIds.keySet());
        }
       // System.debug('leftIds '+leftIds.size()+ ' ' + leftIds);
        if (buildingSiteId == null || buildingSiteId == '') {
            ticketsPerDay = [select Id, Name, Location__c, Vertical_Transport__c, Delivery_Date__c, Arrival_Time__c , End_Point__c, 
                            Location__r.Name, Loading_And_Unloading_Time__c, Status__c, Requestor__c, Hub_Building_Site__c, 
                            Content_Delivery__c, Vertical_Transport__r.Name, Gate__c, Account__r.Name, CreatedBy.Name,
                            Hub_Building_Site__r.Name, Description_Of_Delivery__c
                        from Building_Ticket__c 
                        where (Location__c  in : leftIds or Gate__c  in : leftIds or Vertical_Transport__c  in: leftIds) and Status__c !='Rejected' and  Status__c !='Afgewezen' and Status__c != 'Cancelled'];
        } else {
            ticketsPerDay = [select Id, Name, Location__c, Vertical_Transport__c, Delivery_Date__c, Arrival_Time__c , End_Point__c, 
                            Location__r.Name, Loading_And_Unloading_Time__c, Status__c, Hub_Building_Site__c, Content_Delivery__c, 
                            Requestor__c,  Vertical_Transport__r.Name, Gate__c, Account__r.Name, CreatedBy.Name,
                            Hub_Building_Site__r.Name, Description_Of_Delivery__c
                        from Building_Ticket__c 
                        where Hub_Building_Site__c =: buildingSiteId and (Location__c  in : leftIds 
                        or Gate__c  in : leftIds or Vertical_Transport__c  in: leftIds) and Status__c !='Rejected' and  Status__c !='Afgewezen' and Status__c != 'Cancelled'];
        }
        //System.debug('ticketsPerDay '+ticketsPerDay.size()+ ' ' + ticketsPerDay);
        Set <Id> userIds = new Set <Id>();
        for (Building_Ticket__c t : ticketsPerDay) {
            userIds.add(t.Requestor__c);
        }
        Map <Id, User> usersByIds = new Map <Id, User> ([select Id, Name, CompanyName from User where id in: userIds]) ;
        List <Map<String, String>> forJson = new List <Map <String, String>>();       
        
        Map <Id, String> colorsPerTicket = new Map <Id, String>();
        Integer i = 0;
        for (Building_Ticket__c tt : ticketsPerDay) {
            userIds.add(tt.Requestor__c);

            STring color = backColors.get(i) + ' !important';
            if (backColors.size() > i+1) {
                i++;
            } else {
                i = 0;
            }   
            colorsPerTicket.put(tt.id, color);
        }
        for (Building_Ticket__c ticketPerDay : ticketsPerDay) {
            /*System.debug('ticketPerDay '+ ticketPerDay);
            System.debug('ticketPerDay id '+ ticketPerDay.id);
            System.debug('ticketPerDay loc  '+ ticketPerDay.Location__c);
            System.debug('ticketPerDay vt  '+ ticketPerDay.Vertical_Transport__c);
            System.debug('ticketPerDay gate  '+ ticketPerDay.Gate__c);
            System.debug('leftIds '+leftIds.size()+ ' ' + leftIds);*/
            if (leftIds.contains(ticketPerDay.Location__c) || leftIds.contains(ticketPerDay.Vertical_Transport__c) || leftIds.contains(ticketPerDay.Gate__c) ) {
                //System.debug('ticketPerDay id '+ ticketPerDay.id);
                Map<String, String> valueByKey = new Map<String, String>();
                String output = '';
                if (ticketPerDay.Account__c != null ){
                    output += '\n'+ ticketPerDay.Account__r.Name;
                }
                if (ticketPerDay.Requestor__c != null && usersByIds.get(ticketPerDay.Requestor__c).CompanyName != null) {
                    output += '\n' + usersByIds.get(ticketPerDay.Requestor__c).CompanyName;
                }
                if (ticketPerDay.Location__c != null) {
                    output += '\n'+ticketPerDay.Location__r.Name;
                }
                if (ticketPerDay.Vertical_Transport__c != null ){
                    output += '\n'+ ticketPerDay.Vertical_Transport__r.Name;
                }
                
                if (Integer.valueOf(ticketPerDay.Loading_And_Unloading_Time__c) < 120) {
                    output = output.replaceAll('\n', '\t');
                } 
                //valueByKey.put('title', ticketPerDay.Name  + output  );
                valueByKey.put('title', output  );
                valueByKey.put('start', String.valueOf((Datetime)ticketPerDay.Arrival_Time__c) );
                Integer minutes = Integer.valueOf(ticketPerDay.Loading_And_Unloading_Time__c);
                if (minutes == null) {
                    minutes = 0;
                }
                valueByKey.put('end', String.valueOf(ticketPerDay.Arrival_Time__c.addMinutes(minutes)) );
                valueByKey.put('status', ticketPerDay.Status__c );
                valueByKey.put('arrival', String.valueOf(ticketPerDay.Arrival_Time__c) );
                valueByKey.put('createdBy', ticketPerDay.CreatedBy.Name);
                valueByKey.put('loadAndUnload', String.valueOf(ticketPerDay.Loading_And_Unloading_Time__c));
                valueByKey.put('hub', ticketPerDay.Hub_Building_Site__r.Name);
                valueByKey.put('descr', ticketPerDay.Description_Of_Delivery__c );
                valueByKey.put('location', ticketPerDay.Location__r.Name );
                valueByKey.put('endPoint', ticketPerDay.End_Point__c );
                
                String bgcolor = '';
                String textColor='';
                String url = '';
                /*if (ticketPerDay.Vertical_Transport__c != null) {
                    color = '#0000FF !important';
                    //bgcolor = '#6CA6CD !important';
                } else if (ticketPerDay.Location__c != null) {
                    color = '#00FF7F !important';
                    //bgcolor = '#9ACD32  !important';
                }*/
                //System.debug('backColors.size() ' + backColors.size() );
                //System.debug('i ' + i );
                String color = colorsPerTicket.get(ticketPerDay.id);
                textColor = 'black';
                if (ticketPerDay.Status__c == 'Assigned') {
                    //textColor = 'white';
                    bgcolor = '#9ACD32  !important';
                } else {
                    //textColor = 'black';
                    bgcolor = '#FB7D1D  !important';
                }
                valueByKey.put('color', color);
                valueByKey.put('backgroundColor', bgcolor);
                valueByKey.put('textColor', textColor);
                
                valueByKey.put('url', url+'/'+ticketPerDay.id);
                //System.debug('valueByKey' + valueByKey.size() + ' ' + valueByKey);
                forJson.add(valueByKey);
            }
            
        }
        
        
        //jsonForCalendar = JSON.serialize(forJson);
        
        
       
        //System.debug('forJsom' + forJson.size() + ' ' + forJson);
        return JSON.serialize(forJson);//null;
    }
    public Map<String, Colors__c> colorsSR  {
        get {
            if (colorsSR == null) {
                colorsSR = Colors__c.getAll();
            }
            return colorsSR;
        } set;
    }
     public List <String> backColors {
        get {
            if (backColors == null) {
                //backColors = new List <String>{'#6CA6CD', '#9ACD32', '#bbbaca', '#f4bdbd', '#fbf4b1','#6CA6CE', '#9ACD33', '#bbbacf', '#f0ffff', '#ffe4e1', '#e9e6fc'};
                backColors = new List <String>{'#1B48B1', '#32B22B', '#8A8998', '#DC9090', '#E3D553','#0972BD', '#67930F', '#91909C', '#88ECEC', '#D1958F', '#B0AAD1'};
                if (colorsSR.size() > 0) {
                    backColors.addAll(colorsSR.keySet());
                }
                //System.debug('backColors' + backColors.size());
                //System.debug('colorsSR' + colorsSR.size());
            }
            return backColors;
        } set;
    }
    public PageReference change () {
        leftIds = new Set <Id>();
        for (List<LocationWrap> lWs : locationsForSelect.values()) {
            for (LocationWrap lW : lws) {
                if (lW.isChecked) {
                    leftIds.add(lW.loc.id);
                }
            }
        }
        //System.debug('leftIds'+leftIds.size() + ' ' + leftIds);
        
        //getJsonPerDate();
        return null;
    }
   
    public class LocationWrap {
        public Boolean isChecked {
            get {
                if (isChecked == null) {
                    isChecked = false;
                }
                return isChecked;
            } set;
        }
        public Location__c loc {get; set;}
    }
    public String b {get;set;}
    public String getbodyForTable () {
        //System.debug('curentDate' + curentDate);
        Date d = Date.valueOf(curentDate);
        //System.debug('d' + d);

        List <Time> times = new List <Time>();
        Time t = time.newInstance(0, 0, 0, 0);
        Time dead = time.newInstance(23, 45, 0, 0);
        while (t.hour()!=dead.hour() ){
            times.add(t);
            t = t.addMinutes(15);
        }
        times.add(t);
        t = t.addMinutes(15);
        times.add(t);
        t = t.addMinutes(15);
        times.add(t);
        t = t.addMinutes(15);
        times.add(t);
        List <Building_Ticket__c> tickets = new List <Building_Ticket__c>();
        if (buildingSiteId == null || buildingSiteId == '') {
            tickets = [select Id, Name, Location__c, Vertical_Transport__c, Delivery_Date__c, Arrival_Time__c , End_Point__c, 
                            Location__r.Name, Loading_And_Unloading_Time__c, Status__c, Requestor__c, Hub_Building_Site__c, 
                            Content_Delivery__c, Vertical_Transport__r.Name, Gate__c, Account__r.Name
                        from Building_Ticket__c 
                        where (Location__c  in : leftIds or Gate__c  in : leftIds or Vertical_Transport__c  in: leftIds) and Status__c !='Rejected' and  Status__c !='Afgewezen' and Status__c != 'Cancelled' 
                        and Delivery_Date__c =: d order by Location__c desc];
        } else {
            tickets = [select Id, Name, Location__c, Vertical_Transport__c, Delivery_Date__c, Arrival_Time__c , End_Point__c, 
                            Location__r.Name, Loading_And_Unloading_Time__c, Status__c, Hub_Building_Site__c, Content_Delivery__c, 
                            Requestor__c,  Vertical_Transport__r.Name, Gate__c, Account__r.Name
                        from Building_Ticket__c 
                        where Hub_Building_Site__c =: buildingSiteId and (Location__c  in : leftIds 
                        or Gate__c  in : leftIds or Vertical_Transport__c  in: leftIds) and Status__c !='Rejected' and  Status__c !='Afgewezen' and Status__c != 'Cancelled' and Delivery_Date__c =: d order by Location__c desc];
        }
        //System.debug('tickets ' + tickets.size() + ' ' + tickets);
        Set <Id> userIds = new Set <Id>();
        Map <Id, String> colorsPerTicket = new Map <Id, String>();
        Integer i = 0;
        Map <Id, Building_Ticket__c> tickById = new Map <Id, Building_Ticket__c>(tickets);
        for (Building_Ticket__c tt : tickets) {
            userIds.add(tt.Requestor__c);

            STring color = backColors.get(i) + ' !important';
            if (backColors.size() > i+1) {
                i++;
            } else {
                i = 0;
            }   
            colorsPerTicket.put(tt.id, color);
        }
        Set <Id> locsIds= new Set <Id>();

        Map <Id, User> usersByIds = new Map <Id, User> ([select Id, Name, CompanyName from User where id in: userIds]) ;
        Map <Id, Location__c> locationsByIds = new Map <Id, Location__c>([select Id, Name, Hub_Building_Site__c , RecordType.Name
                            from Location__c where  Hub_Building_Site__c =: buildingSiteId]);
        Map <String, List<Building_Ticket__c>> ticketsByLoc = new Map <String, List<Building_Ticket__c>>();
        for (Building_Ticket__c ticket : tickets) {
            if (ticket.Location__c != null) {
                if (ticketsByLoc.containsKey(ticket.Location__c)) {
                    ticketsByLoc.get(ticket.Location__c).add(ticket);
                } else {
                    List <Building_Ticket__c> ticToAdd = new List <Building_Ticket__c>();
                    ticToAdd.add(ticket);
                    ticketsByLoc.put(ticket.Location__c, ticToAdd);
                }
            }
            if (ticket.Gate__c != null) {
                if (ticketsByLoc.containsKey(ticket.Gate__c)) {
                    ticketsByLoc.get(ticket.Gate__c).add(ticket);
                } else {
                    List <Building_Ticket__c> ticToAdd = new List <Building_Ticket__c>();
                    ticToAdd.add(ticket);
                    ticketsByLoc.put(ticket.Gate__c, ticToAdd);
                }
            }
            if (ticket.Vertical_Transport__c != null) {
                if (ticketsByLoc.containsKey(ticket.Vertical_Transport__c)) {
                    ticketsByLoc.get(ticket.Vertical_Transport__c).add(ticket);
                } else {
                    List <Building_Ticket__c> ticToAdd = new List <Building_Ticket__c>();
                    ticToAdd.add(ticket);
                    ticketsByLoc.put(ticket.Vertical_Transport__c, ticToAdd);
                }
            }
            
        }
        Map <Time, Map <Id, Map <Id, Integer>>> ticketsByLocByTime = new Map <Time, Map <Id, Map <Id, Integer>>>();

        //System.debug('ticketsByLoc' + ticketsByLoc.size() + ' ' + ticketsByLoc);
        locationsByIds = new Map <Id, Location__c>([select Id, Name from Location__c where id in: ticketsByLoc.keySet()]);
        String body = '<table class="dayColTable" width="80%" align="center">';
        body+='<caption style="text-align: right;" width="100%">'+
                '<input value="<&nbsp;" onclick="minusDay();" type="button"/>&nbsp;'+
                '<input value="&nbsp;>" onclick="addDay();" type="button"/>'+
            '</caption>';

        body+='<tr><td width="10%"><b>'+String.valueOf(curentDate).substring(0, 10)+'</b></td>';
        for (String loc: ticketsByLoc.keySet()) {
                body += '<td width="'+100/ticketsByLoc.size()+'%"><b><center>';//colspan="'+ticketsByLoc.get(loc).size()+'"
                if  (locationsByIds.containsKey(loc)) {
                    body += locationsByIds.get(loc).name;
                }
                body += '</center></b></td>';
            }
        body+='</tr> ';
        
        for (Time time1: times) {
            ticketsByLocByTime.put(time1, new Map <Id, Map <Id, Integer>>());
            for (String loc: ticketsByLoc.keySet()) {
                ticketsByLocByTime.get(time1).put(loc, new  Map<Id, Integer>());
                    
                    for (Building_Ticket__c tick: ticketsByLoc.get(loc)) {
                        Integer minutes = Integer.valueOf(tick.Loading_And_Unloading_Time__c);
                        if (minutes == null) {
                            minutes = 0;
                        }
                        Time st = time.newInstance(tick.Arrival_Time__c.hour(),
                                                    tick.Arrival_Time__c.minute(), 0, 0 );
                        
                        Time ed = time.newInstance(tick.Arrival_Time__c.addMinutes(minutes).hour(),
                                                    tick.Arrival_Time__c.addMinutes(minutes).minute(), 0, 0 );
                        Time timeLine = time.newInstance(time1.hour(),
                                                    time1.addMinutes(15).minute(), 0, 0 );
                      
                        
                        if (time1>=st &&  time1<ed) {
                            if (ticketsByLocByTime.containsKey(time1)) {
                                if (ticketsByLocByTime.get(time1).containsKey(loc)) {
                                    ticketsByLocByTime.get(time1).get(loc).put(tick.id, ticketsByLocByTime.get(time1).get(loc).size());
                                } else {
                                    Map<Id, Integer> firstInLoc = new Map<Id, Integer>();
                                    firstInLoc.put(tick.id,0);
                                    ticketsByLocByTime.get(time1).put(loc, firstInLoc);
                                }
                            } else {
                                Map <Id, Map<Id, Integer>>tickByLoc = new Map<Id, Map<Id, Integer>>();
                                Map<Id, Integer> firstInLoc = new Map<Id, Integer>();
                                firstInLoc.put( tick.id, 0);
                                tickByLoc.put(loc, firstInLoc);
                                ticketsByLocByTime.put(time1, tickByLoc);
                            }
                        }
                    }
                    
                
            }
        }
        //System.debug('ticketsByLocByTime ' + ticketsByLocByTime.size() +' ' + ticketsByLocByTime );
        Map <Time, Map <Id, Map <Id, Integer>>> idByOrder = new Map <Time, Map <Id, Map <Id, Integer>>>();
        for (Time time1: times) {
            
            //System.debug('ticketsByLocByTime ' +  ticketsByLocByTime.get(time1).size() + ' ' + ticketsByLocByTime.get(time1));
            for (String loc: ticketsByLoc.keySet()) {
                if (ticketsByLoc.containsKey(loc)) {
                    Time timeLine = time.newInstance(time1.hour(),
                                                    time1.addMinutes(-15).minute(), 0, 0 );
                   
                    for (Id tick: ticketsByLocByTime.get(time1).get(loc).keySet()) {
                        Integer minutes = Integer.valueOf(tickById.get(tick).Loading_And_Unloading_Time__c);
                        if (minutes == null) {
                            minutes = 0;
                        }
                        Time st = time.newInstance(tickById.get(tick).Arrival_Time__c.hour(),
                                                    tickById.get(tick).Arrival_Time__c.minute(), 0, 0 );
                        
                        Time ed = time.newInstance(tickById.get(tick).Arrival_Time__c.addMinutes(minutes).hour(),
                                                    tickById.get(tick).Arrival_Time__c.addMinutes(minutes).minute(), 0, 0 );
                        if (ticketsByLocByTime.get(timeLine)!= null && ticketsByLocByTime.get(timeLine).get(loc).containsKey(tick)
                            && st>=time1) {
                            System.debug('Time for change was: ' + tick + ' = ' + ticketsByLocByTime.get(time1).get(loc).get(tick));
                            System.debug('Time for change: ' + tick + ' = ' + ticketsByLocByTime.get(timeLine).get(loc).get(tick));
                            ticketsByLocByTime.get(timeLine).get(loc).put(tick, ticketsByLocByTime.get(timeLine).get(loc).get(tick));
                        }
                    }  
                   
                }
            }
        }
        for (Time time1: times) {
            body +='<tr>';
            String timeStr = String.valueOf(time1);
            timeStr = timeStr.substring(0, 5);
            if (time1.minute() == 0) {
                body += '<td style="background-color:#ddd !important">'+timeStr+'</td>';
            } else {
                body += '<td>'+timeStr+'</td>';
            }
            for (String loc: ticketsByLoc.keySet()) {
                body+='<td><table width="100%" height="100%" style="position:relative"><tr> ';
                Map <Integer, Id> orderedIdMap = new Map<Integer, Id>();
                List <Id> orderedId = new List <Id>();
                Set <Id> orderedIdSet = new Set <Id>();
                for (Id tick: ticketsByLocByTime.get(time1).get(loc).keySet()) {
                    orderedId.add(tick);
                    orderedIdSet.add(tick);
                }
                for (Id tick: ticketsByLocByTime.get(time1).get(loc).keySet()) {
                    System.debug('ALREADY IN' + orderedId);
                    System.debug(tick);
                    System.debug(ticketsByLocByTime.get(time1));
                    System.debug(ticketsByLocByTime.get(time1).get(loc));
                    System.debug(ticketsByLocByTime.get(time1).get(loc).get(tick));
                    If (tick!= null && ticketsByLocByTime.get(time1)!= null 
                            && ticketsByLocByTime.get(time1).get(loc)!= null 
                            && ticketsByLocByTime.get(time1).get(loc).get(tick) != null) {
                        System.debug('TO ADD: ' + ticketsByLocByTime.get(time1).get(loc).get(tick) + ' ' + tick);
                       orderedIdMap.put(ticketsByLocByTime.get(time1).get(loc).get(tick), tick);
                       if (!orderedIdSet.contains(tick)) {
                            orderedId.add(ticketsByLocByTime.get(time1).get(loc).get(tick), tick);
                            
                       }
                    }
                } 
                Integer j=0;
                for (Id tick: orderedId) {
                    
                    System.debug('ALREADY IN LIST' + time1 + ' ' + locationsByIds.get(loc).Name + ' ' + orderedId + ' ' + orderedIdMap);
                    String textColor = 'black';
                    String color = '';
                    //if (tickById.get(tick).Status__c == 'Assigned') {
                    //    textColor = 'white';
                    //} else {
                    //    textColor = 'black';
                    //}
                    if (tickById.get(tick).Status__c == 'Assigned') {
                        color = '#9ACD32  !important';
                    } else {
                        color = '#FB7D1D  !important';
                    }
                 
                    String output = '';
                    if (tickById.get(tick).Requestor__c != null && usersByIds.get(tickById.get(tick).Requestor__c).CompanyName != null) {
                        output +=  usersByIds.get(tickById.get(tick).Requestor__c).CompanyName +  '. ';
                    }
                    if (tickById.get(tick).Location__c != null) {
                        output += tickById.get(tick).Location__r.Name+  '. ';
                    }
                    if (tickById.get(tick).Vertical_Transport__c != null ){
                        output +=tickById.get(tick).Vertical_Transport__r.Name+  '. ';
                    }
                    //String color = colorsPerTicket.get(tickById.get(tick).id);
                    
                    Time st = time.newInstance(tickById.get(tick).Arrival_Time__c.hour(),
                                                    tickById.get(tick).Arrival_Time__c.minute(), 0, 0 );
                    if (orderedId.size()<=1){
                        Integer lastTd = body.lastIndexOf('<td',body.length());
                        String everythingBefore = body.substring(0, lastTd+3);
                        String everythingAfter = body.substring(lastTd+3, body.length());
                        body = everythingBefore + ' class="testClass" style="background-color:'+color+';  border: 1px solid '+color+'" '+ everythingAfter;
                    }
                    String url = '';
                    if (orderedIdMap.get(j)==null) {
                        Integer counter = orderedIdMap.size();
                        if (counter == 0) {
                            counter = 1;
                        }
                        body+='<td width="'+ 100/counter +'%"></td>';
                    } else {
                        Integer counter = orderedIdMap.size();
                        if (counter == 0) {
                            counter = 1;
                        }
                        body+='<td width="'+ 100/counter +'%" style="background-color:'+color+'; color:'+ textColor+'; border: 1px solid '+color+'"><a  href="/'+tick+'" >';
                        System.debug(' time1= ' + time1+ ' st= ' + st);
                        if (time1==st) {
                            body += tickById.get(tick).Name+'. ' + output;
                        }
                        body+='</a></td>';
                    }
                    j++;
                }
                body += '</td></tr></table>';

            }
            
            body +='</tr>';
        }
        
        
        /*for (Time time1: times) {
            //System.debug('Time and time again: ' + time1);
            String timeStr = String.valueOf(time1);
            timeStr = timeStr.substring(0, 5);
            body +='<tr>';
            if (time1.minute() == 0) {
                body += '<td style="background-color:#ddd !important">'+timeStr+'</td>';
            } else {
                body += '<td>'+timeStr+'</td>';
            }
            
           
            for (String loc: ticketsByLoc.keySet()) {
                if (ticketsByLoc.containsKey(loc)) {
                    
                    //System.debug('===loc: ' + loc);
                    body+='<td ';
                
                    //System.debug('ticketsByLoc.containsKey(loc): ' + ticketsByLoc.containsKey(loc));
                    Integer ttt = 0;
                    
                    for (Building_Ticket__c tick: ticketsByLoc.get(loc)) {
                        
                        Integer minutes = Integer.valueOf(tick.Loading_And_Unloading_Time__c);
                        if (minutes == null) {
                            minutes = 0;
                        }
                        Time st = time.newInstance(tick.Arrival_Time__c.hour(),
                                                    tick.Arrival_Time__c.minute(), 0, 0 );
                        
                        Time ed = time.newInstance(tick.Arrival_Time__c.addMinutes(minutes).hour(),
                                                    tick.Arrival_Time__c.addMinutes(minutes).minute(), 0, 0 );
                      
                        
                        if (time1>=st &&  time1<ed) {
                            //System.debug('=====tick ' + tick);
                            String textColor ='';
                            if (tick.Status__c == 'Assigned') {
                                textColor = 'white';
                            } else {
                                textColor = 'black';
                            }
                         
                            String output = '';
                            if (tick.Requestor__c != null && usersByIds.get(tick.Requestor__c).CompanyName != null) {
                                output +=  usersByIds.get(tick.Requestor__c).CompanyName +  '. ';
                            }
                            if (tick.Location__c != null) {
                                output += tick.Location__r.Name+  '. ';
                            }
                            if (tick.Vertical_Transport__c != null ){
                                output +=tick.Vertical_Transport__r.Name+  '. ';
                            }
                            String color = colorsPerTicket.get(tick.id);
                            
                            
                            String url = '';
                           
                            
                            body+=' style="background-color:'+color+'; color:'+ textColor+'; border: 1px solid '+color+'" ><a style="color:'+textColor+'" href="/'+tick.id+'" >';
                            if (time1==st) {
                                body += tick.Name+'. ' + output;
                            }
                            body += '</a>';
                            
                          
                        } else {
                          
                        }

                        ttt++;
                    }
                    
                }
                if (body.endsWith('td ')) {
                    body+='>';

                }
                body+='</td>';
            }
            body+='</tr>';
        }*/
        //System.debug('colorsPerTicket'+colorsPerTicket);
        body += '</table>';
        System.debug('body ' + body);
        b=body;
        return body;
    }
    public Date curentDate {
        get {
            if (curentDate == null) {
                if (dateFrom == '' || dateFrom == null) {
                    dateFrom = ApexPages.currentPage().getparameters().get('dateFrom');
                }
                //System.debug('dateFrom' + dateFrom);
                if (dateFrom !=null) {
                    curentDate = date.newInstance(Integer.valueOf(dateFrom.substring(0,4)), 
                                                    Integer.valueOf(dateFrom.substring(5,7)),
                                                    Integer.valueOf(dateFrom.substring(8,10))
                                    );
                    //System.debug('curentDate' + curentDate);
                } else {
                    curentDate = date.today();
                }
            }
            return curentDate;
        } set;
    }
    public String count {
        get {
            if (count == null) {
                count = '0';
            }
            return count;
        } set;
    }
    public void changeDate () {
        curentDate = curentDate.addDays(1);
        getbodyForTable();
    }
    public void changeDateMinus () {
        curentDate = curentDate.addDays(-1);
        getbodyForTable();
    }
    public void load() {

    }
    public class RecordTypeException extends Exception {}

}