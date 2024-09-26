/* Account trigger should do the following:
* 1. Set the account type to prospect.
* 2. Copy the shipping address to the billing address.
* 3. Set the account rating to hot.
* 4. Create a contact for each account inserted.  
Question 1
    * Account Trigger
    * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
    * Trigger should only fire on insert.
Question 2
    * Account Trigger
    * When an account is inserted copy the shipping address to the billing address.
    * BONUS: Check if the shipping fields are empty before copying.
    * Trigger should only fire on insert.
Question 3
    * Account Trigger
	* When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
    * Trigger should only fire on insert.
Question 4
    * Account Trigger
    * When an account is inserted create a contact related to the account with the following default values:
    * LastName = 'DefaultContact'
    * Email = 'default@email.com'
    * Trigger should only fire on insert. 123
*/


trigger AccountTrigger on Account (before insert, after insert) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            // Set the account type to prospect.
            
            for (Account acc : Trigger.new) {
                if (acc.Type == null) {
                    acc.Type = 'Prospect';

                    acc.BillingStreet = acc.ShippingStreet;
                    acc.BillingCity = acc.ShippingCity;
                    acc.BillingState = acc.ShippingState;
                    acc.BillingPostalCode = acc.ShippingPostalCode;
                    acc.BillingCountry = acc.ShippingCountry;

                    if (acc.Phone != null && acc.Phone != '' && acc.Website != null && acc.Website != '' && acc.Fax != null && acc.Fax != '') {
                        acc.Rating = 'Hot';
                    }
                }   
            }
        }
        if (Trigger.isAfter) {
            // Create a contact for each account inserted. 
            List<Contact> contacts = new List<Contact>();
            for (Account acc2 : Trigger.new) {
                //Ensure that the account has been successfully inserted (has an Id).
                if (acc2.Id != null) {
                    Contact contact = new Contact();
                    contact.LastName = 'DefaultContact';
                    contact.Email = 'default@email.com';
                    contact.AccountId = acc2.Id;
                    contacts.add(contact);
                }
            }
            if (!contacts.isEmpty()) {
                insert contacts;
            }
        }
    }
}