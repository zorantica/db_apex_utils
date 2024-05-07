CREATE OR REPLACE PACKAGE lob_2_script IS

--utility program units
FUNCTION f_clob_to_blob(
    c clob,
    plEncoding IN NUMBER default 0
) RETURN blob;



FUNCTION f_lob_type (
    p_table varchar2,
    p_column varchar2
) RETURN varchar2;


/*
Function returns a CLOB value containg a SQL script, 
which can be included in the patch or executed in the target environment.

Parameters:
@ p_table - target table, in which the LOB contect is going to be stored  
@ p_column - target table column (CLOB or BLOB), in which the LOB contect is going to be stored
@ p_column_type - C for CLOB or B for BLOB
@ p_where - where condition for the target table, which determines one record, in which the LOB content is going to be stored; the combination of column and where condition is determining one table cell to store LOB content 
@ p_lob_source - LOB content source; values are: "PARAM" (content is read from function input parameter p_file), "APEX_VIEW" (a single file from APEX_APPLICATION_TEMP_FILES view - used for APEX UI), "TABLE" (read from the database table - the cell containing the content is deteremined by function parameters p_table, p_column and p_where)
@ p_file - a blob content, if the p_lob_source is "PARAM"

@return - CLOB value containg a SQL script
*/
FUNCTION f_generate_script(
    p_table varchar2,
    p_column varchar2,
    p_column_type varchar2,
    p_where varchar2,
    p_lob_source varchar2,
    p_file_blob blob default null
) RETURN clob;


--
PROCEDURE p_generate_script_and_download (
    p_table varchar2,
    p_column varchar2,
    p_column_type varchar2,
    p_where varchar2,
    p_lob_source varchar2,
    p_file_blob blob default null
);

END lob_2_script;
/

