# Various Oracle Database and Oracle APEX utilities
In this repository You may find various Oracle Database and Oracle APEX utilities:

- Oracle APEX Collections DML

## Oracle APEX Collections DML
This utility provides You the functionality to execute DML operations directly on APEX collections from pure SQL. No need for using PL/SQL APEX_COLLECTION API.

Installation script and examples script can be found in the folder "apex_dml_collections". Just create the package, view and trigger in the target schema and You're good to go.

So, for example, if You want to populate the APEX collection with data from DEMO_CUSTOMERS table, You may do it in the following way:

```sql
INSERT INTO apex_collections_dml (
    collection_name, 
    n001,  --customer_id 
    c001,  --cust_first_name 
    c002,  --cust_last_name 
    c003,  --cust_street_address1 
    c004,  --cust_street_address2 
    c005,  --cust_city 
    c006,  --cust_state
    c007,  --cust_postal_code
    c008,  --cust_email
    c009,  --phone_number1
    c010,  --phone_number2
    c011,  --url
    c012,  --tag
    n002   --credit_limit
)
SELECT
    'DEMO_CUSTOMERS',
    customer_id, 
    cust_first_name, 
    cust_last_name, 
    cust_street_address1, 
    cust_street_address2, 
    cust_city, 
    cust_state, 
    cust_postal_code, 
    cust_email, 
    phone_number1, 
    phone_number2, 
    url, 
    tags,
    credit_limit
FROM 
    demo_customers 
;
```

Or You may update the collection and change the credit limit for repeat customers by 10% like this:

```sql
UPDATE apex_collections_dml
SET 
    n002 = n002 + (10 * n002 / 100)
WHERE
    c012 = 'REPEAT CUSTOMER'
AND collection_name = 'DEMO_CUSTOMERS'
;
```

Co not forget to commit the changes :)