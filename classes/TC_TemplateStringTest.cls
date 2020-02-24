@IsTest
private class TC_TemplateStringTest {
    @IsTest
    static void testBehavior() {
        Account acc = new Account(
                Name = 'Test Account'
        );
        insert acc;
        Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Credit Application',
                CloseDate = Date.today()
        );
        insert opp;

        String messageTemplateString = 'This is a {!Account.Name}';
        String message2TemplateString = 'This is a {!Account.Name} {!Opportunity.Name}';

        Test.startTest();
        String message = TC_TemplateString.mergeFields(new Set<Id> { acc.Id }, messageTemplateString);
        String message2a = TC_TemplateString.mergeFields(new Set<Id> { acc.Id }, message2TemplateString);
        String message2b = TC_TemplateString.mergeFields(new Set<Id> { acc.Id, opp.Id }, message2TemplateString);
        Test.stopTest();

        System.assertEquals('This is a ' + acc.Name, message);
        System.assertEquals('This is a ' + acc.Name + ' {!Opportunity.Name}', message2a);
        System.assertEquals('This is a ' + acc.Name + ' ' + opp.Name, message2b);
    }
}
