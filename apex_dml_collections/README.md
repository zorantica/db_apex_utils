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