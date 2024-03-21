/*
INSTALL INSTRUCTIONS

In the target schema:
- create package spec and package body (apex_collections_dml_pkg)
- create view (APEX_COLLECTIONS_DML)
- create instead of trigger (APEX_COLLECTIONS_DML_TRG)

Actually, You can simply execute the following script
*/

CREATE OR REPLACE PACKAGE apex_collections_dml_pkg AS

TYPE t_coll IS TABLE OF apex_collections%ROWTYPE;

FUNCTION get_coll_data RETURN t_coll PIPELINED;

END apex_collections_dml_pkg;
/


CREATE OR REPLACE PACKAGE BODY apex_collections_dml_pkg AS

FUNCTION get_coll_data RETURN t_coll PIPELINED IS

    CURSOR c_data IS
        SELECT *
        FROM apex_collections;

    lrData t_coll;

BEGIN
    OPEN c_data;
    
    LOOP
        FETCH c_data BULK COLLECT INTO lrData LIMIT 50;
        EXIT WHEN lrData.count = 0;

        FOR t IN 1 .. lrData.count LOOP
            PIPE ROW (lrData(t));
        END LOOP;

    END LOOP;
    
    CLOSE c_data;

END;

END apex_collections_dml_pkg;
/


CREATE OR REPLACE VIEW apex_collections_dml AS
SELECT *
FROM table( apex_collections_dml_pkg.get_coll_data )
/



CREATE OR REPLACE TRIGGER apex_collections_dml_trg
INSTEAD OF INSERT OR UPDATE OR DELETE 
ON apex_collections_dml
FOR EACH ROW
BEGIN
    if not apex_collection.collection_exists( nvl(:new.collection_name, :old.collection_name) ) then
        apex_collection.create_collection(nvl(:new.collection_name, :old.collection_name));
    end if;
    
    if inserting then
        apex_collection.add_member (
            p_collection_name => :new.collection_name,
            p_c001 => :new.c001,
            p_c002 => :new.c002,
            p_c003 => :new.c003,
            p_c004 => :new.c004,
            p_c005 => :new.c005,
            p_c006 => :new.c006,
            p_c007 => :new.c007,
            p_c008 => :new.c008,
            p_c009 => :new.c009,
            p_c010 => :new.c010,
            p_c011 => :new.c011,
            p_c012 => :new.c012,
            p_c013 => :new.c013,
            p_c014 => :new.c014,
            p_c015 => :new.c015,
            p_c016 => :new.c016,
            p_c017 => :new.c017,
            p_c018 => :new.c018,
            p_c019 => :new.c019,
            p_c020 => :new.c020,
            p_c021 => :new.c021,
            p_c022 => :new.c022,
            p_c023 => :new.c023,
            p_c024 => :new.c024,
            p_c025 => :new.c025,
            p_c026 => :new.c026,
            p_c027 => :new.c027,
            p_c028 => :new.c028,
            p_c029 => :new.c029,
            p_c030 => :new.c030,
            p_c031 => :new.c031,
            p_c032 => :new.c032,
            p_c033 => :new.c033,
            p_c034 => :new.c034,
            p_c035 => :new.c035,
            p_c036 => :new.c036,
            p_c037 => :new.c037,
            p_c038 => :new.c038,
            p_c039 => :new.c039,
            p_c040 => :new.c040,
            p_c041 => :new.c041,
            p_c042 => :new.c042,
            p_c043 => :new.c043,
            p_c044 => :new.c044,
            p_c045 => :new.c045,
            p_c046 => :new.c046,
            p_c047 => :new.c047,
            p_c048 => :new.c048,
            p_c049 => :new.c049,
            p_c050 => :new.c050,
            p_n001 => :new.n001,
            p_n002 => :new.n002,
            p_n003 => :new.n003,
            p_n004 => :new.n004,
            p_n005 => :new.n005,
            p_d001 => :new.d001,
            p_d002 => :new.d002,
            p_d003 => :new.d003,
            p_d004 => :new.d004,
            p_d005 => :new.d005,
            p_clob001 => :new.clob001,
            p_blob001 => :new.blob001,
            p_xmltype001 => :new.xmltype001
        );

    elsif updating then
        apex_collection.update_member (
            p_seq => :new.seq_id,
            p_collection_name => :new.collection_name,
            p_c001 => :new.c001,
            p_c002 => :new.c002,
            p_c003 => :new.c003,
            p_c004 => :new.c004,
            p_c005 => :new.c005,
            p_c006 => :new.c006,
            p_c007 => :new.c007,
            p_c008 => :new.c008,
            p_c009 => :new.c009,
            p_c010 => :new.c010,
            p_c011 => :new.c011,
            p_c012 => :new.c012,
            p_c013 => :new.c013,
            p_c014 => :new.c014,
            p_c015 => :new.c015,
            p_c016 => :new.c016,
            p_c017 => :new.c017,
            p_c018 => :new.c018,
            p_c019 => :new.c019,
            p_c020 => :new.c020,
            p_c021 => :new.c021,
            p_c022 => :new.c022,
            p_c023 => :new.c023,
            p_c024 => :new.c024,
            p_c025 => :new.c025,
            p_c026 => :new.c026,
            p_c027 => :new.c027,
            p_c028 => :new.c028,
            p_c029 => :new.c029,
            p_c030 => :new.c030,
            p_c031 => :new.c031,
            p_c032 => :new.c032,
            p_c033 => :new.c033,
            p_c034 => :new.c034,
            p_c035 => :new.c035,
            p_c036 => :new.c036,
            p_c037 => :new.c037,
            p_c038 => :new.c038,
            p_c039 => :new.c039,
            p_c040 => :new.c040,
            p_c041 => :new.c041,
            p_c042 => :new.c042,
            p_c043 => :new.c043,
            p_c044 => :new.c044,
            p_c045 => :new.c045,
            p_c046 => :new.c046,
            p_c047 => :new.c047,
            p_c048 => :new.c048,
            p_c049 => :new.c049,
            p_c050 => :new.c050,
            p_n001 => :new.n001,
            p_n002 => :new.n002,
            p_n003 => :new.n003,
            p_n004 => :new.n004,
            p_n005 => :new.n005,
            p_d001 => :new.d001,
            p_d002 => :new.d002,
            p_d003 => :new.d003,
            p_d004 => :new.d004,
            p_d005 => :new.d005,
            p_clob001 => :new.clob001,
            p_blob001 => :new.blob001,
            p_xmltype001 => :new.xmltype001
        );
        
    elsif deleting then
        apex_collection.delete_member (
            p_collection_name => :old.collection_name,
            p_seq => :old.seq_id
        );
        
    end if;

END apex_collections_dml_trg;
/