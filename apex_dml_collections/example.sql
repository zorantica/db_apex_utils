--if needed, create an APEX session
BEGIN
    apex_session.create_session (
        p_app_id => 150,
        p_page_id => 1,
        p_username => 'ZORAN'
    );
END;



--insert new records into the collection
--if collection does not exist it is going to be created automatically -> no need to create it previously
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


