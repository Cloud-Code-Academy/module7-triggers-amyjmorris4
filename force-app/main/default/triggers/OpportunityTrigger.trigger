 /* Opportunity trigger should do the following:
    * 1. Validate that the amount is greater than 5000. - before update
    * 2. Prevent the deletion of a closed won opportunity for a banking account. - before delete
    * 3. Set the primary contact on the opportunity to the contact with the title of CEO. - after update

     Question 5
    * Opportunity Trigger
    * When an opportunity is updated validate that the amount is greater than 5000.
    * Error Message: 'Opportunity amount must be greater than 5000'
    * Trigger should only fire on update.

     * Question 6
	 * Opportunity Trigger
	 * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
	 * Error Message: 'Cannot delete closed opportunity for a banking account that is won'
	 * Trigger should only fire on delete.
    
      * Question 7
    * Opportunity Trigger
    * When an opportunity is updated set the primary contact on the opportunity to the contact on the same account with the title of 'CEO'.
    * Trigger should only fire on update. 123
    */

trigger OpportunityTrigger on Opportunity (before update, before delete) {

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            for (Opportunity opportunity : Trigger.new) {
                if (opportunity.Amount != null && opportunity.Amount < 5000) {
                    opportunity.addError('Opportunity amount must be greater than 5000');
                }
            }
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opportunity : Trigger.new) {
                if (opportunity.AccountId!= null) {
                    accountIds.add(opportunity.AccountId);
                }
            }

            if (accountIds.size() > 0) {
                Map<Id, Account> accountsMap = new Map<Id, Account>([
                    SELECT Id, (SELECT Id, Title, AccountId FROM Contacts WHERE Title = 'CEO')
                    FROM Account
                    WHERE Id IN :accountIds
                ]);

                for (Opportunity opportunity : Trigger.new) {
                    if (opportunity.AccountId!= null) {
                        Account parentAccount = accountsMap.get(opportunity.AccountId);
                        if (parentAccount!= null) {
                            for (Contact contact : parentAccount.Contacts) {
                                if (contact.Title == 'CEO') {
                                    opportunity.Primary_Contact__c = contact.Id;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

        if (Trigger.isDelete) {
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opportunity : Trigger.old) {
                if (opportunity.AccountId != null) {
                    accountIds.add(opportunity.AccountId);
                }
            }

            Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);

            for (Opportunity opportunity : Trigger.old) {
                if (opportunity.StageName == 'Closed Won' && accountsMap.containsKey(opportunity.AccountId) 
                     && accountsMap.get(opportunity.AccountId).Industry == 'Banking') {
                    opportunity.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }    

        

            

