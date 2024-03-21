# Various Oracle Database and Oracle APEX utilities
In this repository You may find various Oracle Database and Oracle APEX utilities

- [Oracle APEX - DML on Collections ](#oracle-apex-dml-on-collections)
- [Oracle APEX - apex_lang_utils package ](#oracle-apex---apex_lang_utils-package)

### History of changes:
- 1.0 - created "Oracle APEX - DML On Collections" utility
- 1.1 - created "apex_lang_utils" package

## Oracle APEX - DML on Collections
This utility provides You the functionality to execute DML statements directly on APEX collections from pure SQL. No need for using PL/SQL APEX_COLLECTION API. This may come handy in various scenarios like using Interactive Grid for data editing or manipulating temporary data.

Installation and examples scripts with instructions can be found in the folder [apex_dml_collections](https://github.com/zorantica/db_apex_utils/tree/main/apex_dml_collections). But simply... just create the package, view and trigger in the target schema and You're ready to go.

Quick peek - if You want for example to populate the APEX collection with data from DEMO_CUSTOMERS table, You may execute the following INSERT statement:

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

## Oracle APEX - apex_lang_utils package

Compatible with the Oracle APEX vesrion 23.1 

Package installation scripts can be found in the folder [apex_lang_utils](https://github.com/zorantica/db_apex_utils/tree/main/apex_lang_utils).

The package contains following program units:
- a function get_xliff_per_page to export multiple XLIFF files for selected pages 
- a procedure apply_xliff_files to apply multiple XLIFF translation files stored in a single ZIP file