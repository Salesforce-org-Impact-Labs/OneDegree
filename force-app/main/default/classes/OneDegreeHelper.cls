public class OneDegreeHelper {

    public OneDegreeHelper() {

    }
    
    public static string checkNull(String value) {
        if(value == null) {
            return '';
        }else {
            return value;
        }
    }

    public static string getTags(List<string> tags) {
        String result;
        integer counter = 0;
        for(string s : tags) {
            if(counter == 0) {
                result = 'Tags - ' + s;
            }else {
                result += ',' + s;
            }
            counter++;
        }
        return result;

    }

    public static List<refrec__Open_Hours__c> oneDegreeGetOpenHours(OneDegreeDataWrapper.Schedule sched, string service_external_id) {
        List<refrec__Open_Hours__c> ohs = new List<refrec__Open_Hours__c>();
        refrec__Service__c  serviceReference = new refrec__Service__c(refrec__External_ID__c = String.valueOf(service_external_id));
        // all 7 days of the week.
        //monday
        if((sched.monday_start != null && sched.monday_end != null) && 
                            (sched.monday_start.length() > 0 && sched.monday_end.length() > 0)) {
            refrec__Open_Hours__c oh1 = new refrec__Open_Hours__c();                                     
            oh1.refrec__Day__c = 'Monday';
            String[] strTimeSplitStart = sched.monday_start.split(':');
            String[] strTimeSplitEnd = sched.monday_end.split(':');
            oh1.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh1.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh1.refrec__Service__r = serviceReference;
            ohs.add(oh1);                                                                
        }

        //tuesday
        if((sched.tuesday_start != null && sched.tuesday_end != null) && 
                            (sched.tuesday_start.length() > 0 && sched.tuesday_end.length() > 0)) {
            refrec__Open_Hours__c oh2 = new refrec__Open_Hours__c();                                     
            oh2.refrec__Day__c = 'Tuesday';
            String[] strTimeSplitStart = sched.tuesday_start.split(':');
            String[] strTimeSplitEnd = sched.tuesday_end.split(':');
            oh2.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh2.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh2.refrec__Service__r = serviceReference;
            ohs.add(oh2);                                                                
        }        

        //wednesday
        if((sched.wednesday_start != null && sched.wednesday_end != null) && 
                            (sched.wednesday_start.length() > 0 && sched.wednesday_end.length() > 0)) {
            refrec__Open_Hours__c oh3 = new refrec__Open_Hours__c();                                     
            oh3.refrec__Day__c = 'Wednesday';
            String[] strTimeSplitStart = sched.wednesday_start.split(':');
            String[] strTimeSplitEnd = sched.wednesday_end.split(':');
            oh3.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh3.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh3.refrec__Service__r = serviceReference;
            ohs.add(oh3);                                                                
        }        

        //thursday
        if((sched.thursday_start != null && sched.thursday_end != null) && 
                            (sched.thursday_start.length() > 0 && sched.thursday_end.length() > 0)) {
            refrec__Open_Hours__c oh4 = new refrec__Open_Hours__c();                                     
            oh4.refrec__Day__c = 'Thursday';
            String[] strTimeSplitStart = sched.thursday_start.split(':');
            String[] strTimeSplitEnd = sched.thursday_end.split(':');
            oh4.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh4.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh4.refrec__Service__r = serviceReference;
            ohs.add(oh4);                                                                
        }        
        //friday
        if((sched.friday_start != null && sched.friday_end != null) && 
                            (sched.friday_start.length() > 0 && sched.friday_end.length() > 0)) {
            refrec__Open_Hours__c oh5 = new refrec__Open_Hours__c();                                     
            oh5.refrec__Day__c = 'Friday';
            String[] strTimeSplitStart = sched.friday_start.split(':');
            String[] strTimeSplitEnd = sched.friday_end.split(':');
            oh5.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh5.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh5.refrec__Service__r = serviceReference;
            ohs.add(oh5);                                                                
        }        
        //saturday
        if((sched.saturday_start != null && sched.saturday_end != null) && 
                            (sched.saturday_start.length() > 0 && sched.saturday_end.length() > 0)) {
            refrec__Open_Hours__c oh6 = new refrec__Open_Hours__c();                                     
            oh6.refrec__Day__c = 'Saturday';
            String[] strTimeSplitStart = sched.saturday_start.split(':');
            String[] strTimeSplitEnd = sched.saturday_end.split(':');
            oh6.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh6.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh6.refrec__Service__r = serviceReference;
            ohs.add(oh6);                                                                
        }        
        //sunday
        if((sched.sunday_start != null && sched.sunday_end != null) && 
                            (sched.sunday_start.length() > 0 && sched.sunday_end.length() > 0)) {
            refrec__Open_Hours__c oh7 = new refrec__Open_Hours__c();                                     
            oh7.refrec__Day__c = 'Sunday';
            String[] strTimeSplitStart = sched.sunday_start.split(':');
            String[] strTimeSplitEnd = sched.sunday_end.split(':');
            oh7.refrec__Start_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitStart[0]), 
                                                            Integer.valueOf(strTimeSplitStart[1]), 0, 0);
            oh7.refrec__End_Time__c = Time.newInstance(Integer.valueOf(strTimeSplitEnd[0]), 
                                                                Integer.valueOf(strTimeSplitEnd[1]), 0, 0);                
            oh7.refrec__Service__r = serviceReference;
            ohs.add(oh7);                                                                
        }       


        return ohs;
    }


}