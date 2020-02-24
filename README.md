salesforce-apex-templates
=========================

Inspired by [andrzejchodor/salesforce-apex-templates](https://github.com/andrzejchodor/salesforce-apex-templates)

Apex Templates provide a simple template engine, similar to the standard Salesforce mail merge one. Its aim is to generate messages and emails directly from Apex, for provided SObjects or maps of values.

Basic usage
-----------

The below snippet demonstrates the most basic usage of APEX Templates:

``` java
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

String messageTemplateString = 'This is a {!Account.Name} {!Opportunity.Name}';=
String message = TC_TemplateString.mergeFields(new Set<Id> { acc.Id, opp.Id }, messageTemplateString);
System.debug(message);
// "This is a Test Account Test Opportunity."
```
