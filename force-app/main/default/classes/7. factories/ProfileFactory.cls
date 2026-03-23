public with sharing class ProfileFactory {

    public static List<Profile> assemble(List<String> names) {

        return ProfileSelector.selectByNames(names);
    }
}

    