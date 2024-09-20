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
    * Trigger should only fire on update.
    */
    trigger OpportunityTrigger on Opportunity (before update, after update, before delete){

        if (Trigger.isBefore){
            if(Trigger.isUpdate){
                for (Opportunity opportunity : Trigger.new){
                    if (opportunity.Amount < 5000){
                        opportunity.addError('Opportunity amount must be greater than 5000');
                    }
                }
    }
            if(Trigger.isDelete){
                for (Opportunity opportunity : Trigger.old){
                    if (opportunity.StageName == 'Closed Won' && opportunity.Account.Industry == 'Banking'){
                            opportunity.addError('Cannot delete closed won opportunity for a banking account');
                    }
                }
            } }

        if (Trigger.isAfter){
            if(Trigger.isUpdate){
               Set<Id> accountIds = new Set<Id>();
               for (Opportunity opp : Trigger.new){
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
               }
               //Query Contacts with title "CEO" related to accounts
               Map<Id, Contact> ceoContactsMap = new Map<Id, Contact>();
               for (Contact contact : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']){
                ceoContactsMap.put(contact.AccountId, contact);
               }
               // Iterate over the Opportunities and update OpportunityContactRole
            List<OpportunityContactRole> newOcrs = new List<OpportunityContactRole>();
            for (Opportunity opp : Trigger.new) {
                if (opp.AccountId != null && ceoContactsMap.containsKey(opp.AccountId)) {
                    Contact ceoContact = ceoContactsMap.get(opp.AccountId);

                    // Create a new OpportunityContactRole to associate the CEO contact
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = opp.Id;
                    ocr.ContactId = ceoContact.Id;
                    ocr.Role = 'CEO'; 
                    ocr.IsPrimary = true;
                    newOcrs.add(ocr);
                }
            }

            if (!newOcrs.isEmpty()) {
                insert newOcrs;
            }
        }
    }
}
