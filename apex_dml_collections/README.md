# Oracle APEX - DML Collections

History of changes:
- 1.0 - initial version

## Install instructions

In the target schema create following objects. 

- create package spec and package body (apex_collections_dml_pkg)
- create view (apex_collections_dml)
- create instead of trigger (apex_collections_dml_trg)

The objects definition can be found in the following script [install.sql](https://github.com/zorantica/db_apex_utils/blob/main/apex_dml_collections/install.sql) 

The script works for the Oracle database version 12c or newer.

## Examples

Examples can be found in the script [examples.sql](https://github.com/zorantica/db_apex_utils/blob/main/apex_dml_collections/examples.sql)

## How it works

The database package APEX_COLLECTIONS_DML_PKG contains pipelined function, which returns data from the APEX_COLLECTIONS view for the current session.

The view APEX_COLLECTIONS_DML is just a wrapper around the pipelined function.

The "instead of" trigger APEX_COLLECTIONS_DML_TRG, created on the view APEX_COLLECTIONS_DML, is executing DML operations on APEX collections via APEX_COLLECTION API.

So, all DML operations executed on the APEX_COLLECTIONS_DML view are reflected on the APEX collections and data can be accessed either from APEX_COLLECTIONS or APEX_COLLECTIONS_DML view.

## Why this approach with pipelined function?

Well... first option was to create a trigger directly on the APEX_COLLECTIONS view. But I have no privileges to do so. Plus, this also means messing up with APEX objects, which is never a good option.

Second option was to create a local view APEX_COLLECTIONS_DML, which read data directly from APEX_COLLECTIONS view. And to create a trigger on the view. But the problem was that the database is checking privileges on underlying objects BEFORE executing the trigger and therefore I ended up with "ORA-01031: insufficient privileges" error.

In order to avoid this ORA error I needed to somehow separate APEX_COLLECTIONS view from my local DML view... and pipelined function was just right. 