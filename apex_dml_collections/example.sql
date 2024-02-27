-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--EXAMPLE 01

--if needed, create an APEX session
BEGIN
    apex_session.create_session (
        p_app_id => 150,
        p_page_id => 1,
        p_username => 'ZORAN'
    );
END;



--insert new records into the collection
--if collection does not exist no problem - it is going to be created automatically - no need to create it previously
INSERT INTO apex_collections_dml (
    collection_name, 
    n001, 
    c001
)
SELECT
    'MY_COLL' as collection_name,
    level as counter,
    'my record ' || level as my_text
FROM dual
CONNECT BY level <= 100
;

COMMIT;

SELECT *
FROM apex_collections
WHERE collection_name = 'MY_COLL'
;

SELECT *
FROM apex_collections_dml
WHERE collection_name = 'MY_COLL'
;


--update records in the collection
UPDATE apex_collections_dml
SET 
    c002 = c001,
    n002 = n001 * 2,
    d001 = trunc(sysdate) + n001
WHERE 
    collection_name = 'MY_COLL'
;

COMMIT;

SELECT *
FROM apex_collections
WHERE collection_name = 'MY_COLL'
;

SELECT *
FROM apex_collections_dml
WHERE collection_name = 'MY_COLL'
;


--delete records from the collection
DELETE apex_collections_dml
WHERE 
    collection_name = 'MY_COLL'
AND n002 <= 50;

COMMIT;

SELECT *
FROM apex_collections
WHERE collection_name = 'MY_COLL'
;

SELECT *
FROM apex_collections_dml
WHERE collection_name = 'MY_COLL'
;



-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--EXAMPLE 02 - use data from DEMO_CUSTOMERS table (table needs to be installed first with the APEX demo app)


--clear the collection
DELETE apex_collections_dml
WHERE collection_name = 'DEMO_CUSTOMERS'
;

commit;

--populate the collection from DEMO_CUSTOMERS table
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

commit;


--check data
SELECT *
FROM apex_collections
WHERE collection_name = 'DEMO_CUSTOMERS'
;

SELECT *
FROM apex_collections_dml
WHERE collection_name = 'DEMO_CUSTOMERS'
;



--update credit limit for repeat customers by 10%
UPDATE apex_collections_dml
SET 
    n002 = n002 + (10 * n002 / 100)
WHERE
    c012 = 'REPEAT CUSTOMER'
AND collection_name = 'DEMO_CUSTOMERS'
;

commit;



--check data
SELECT *
FROM apex_collections
WHERE collection_name = 'DEMO_CUSTOMERS'
;

SELECT *
FROM apex_collections_dml
WHERE collection_name = 'DEMO_CUSTOMERS'
;



--remove customers from the state "VA"
DELETE apex_collections_dml
WHERE 
    collection_name = 'DEMO_CUSTOMERS'
AND c006 = 'VA'
;

commit;
