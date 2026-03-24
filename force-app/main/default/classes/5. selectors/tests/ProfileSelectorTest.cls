@isTest
private class ProfileSelectorTest {

    @isTest
    static void singleAction() {
        //GIVEN
        List<String> names = new List<String>{ 'Sales' };

        // WHEN
        Test.startTest();
        List<Profile> result = ProfileSelector.selectByNames(names);
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.size());
        System.assertEquals('Sales', result[0].Name);
    }

    @isTest
    static void bulkActions() {
        // GIVEN
        List<String> names = new List<String>{ 'Sales', 'Chatter Free User' };

        // WHEN
        Test.startTest();
        List<Profile> result = ProfileSelector.selectByNames(names);
        Test.stopTest();

        // THEN
        System.assertEquals(2, result.size());
    }

    @isTest
    static void positiveBehaviour() {
        //GIVEN
        List<String> names = new List<String>{ 'Sales' , 'Chatter Free User', 'System Administrator' };

        // WHEN
        Test.startTest();
        List<Profile> result = ProfileSelector.selectByNames(names);
        Test.stopTest();

        List<String> profileNames = new List<String>();
            for (Profile p : result) {
                profileNames.add(p.Name);
            }

        // THEN
        System.assertEquals(3, result.size());
        System.assert(profileNames.contains('Sales'));
        System.assert(profileNames.contains('Chatter Free User'));
        System.assert(profileNames.contains('System Administrator'));
       
    }

    @isTest
    static void negativeBehaviour() {
       // GIVEN
        List<String> names = new List<String>{ 'ProfilQuiNExistePas' };

        // WHEN
        Test.startTest();
        List<Profile> result = ProfileSelector.selectByNames(names);
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size());
    }
}