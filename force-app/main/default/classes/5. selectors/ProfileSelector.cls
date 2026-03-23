public with sharing class ProfileSelector {
   
    public static List<Profile> selectByNames(List<String> names) {
        return [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN :names
        ];
    }
}

