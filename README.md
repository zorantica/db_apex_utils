# Various Oracle Database and Oracle APEX utilities
In this repository You may find various Oracle Database and Oracle APEX utilities:

- [Oracle APEX - DML Collections ](#oracle-apex-dml-collections)

## Oracle APEX - DML Collections
This utility provides You the functionality to execute DML operations directly on APEX collections from pure SQL. No need for using PL/SQL APEX_COLLECTION API. This may come handy in various scenarios like using Interactive Grid for data editing or manipulating temporary data.

Installation script and examples script can be found in the folder "apex_dml_collections". Just create the package, view and trigger in the target schema and You're good to go.

So, if You want for example to populate the APEX collection with data from DEMO_CUSTOMERS table, You may execute the following INSERT statement:

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

Or delete all customers from "VA" state:

```sql
DELETE apex_collections_dml
WHERE 
    collection_name = 'DEMO_CUSTOMERS'
AND c006 = 'VA'
;
```

Do not forget to commit the changes :blush: