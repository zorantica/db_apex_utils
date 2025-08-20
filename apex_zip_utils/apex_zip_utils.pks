CREATE OR REPLACE PACKAGE apex_zip_utils AS

TYPE r_file IS RECORD (
    zip_file_name varchar2(1000),
    file_name varchar2(1000),
    file_name_and_directory varchar2(4000),
    file_size number,
    file_content blob
);

TYPE t_files IS TABLE OF r_file;
TYPE t_files_ar IS TABLE OF r_file INDEX BY varchar2(4000);

--copied from wwv_flow_api package
c_apex_21_2 constant number := 20211015;


/*
The pipelined function unzips all files from the passed ZIP file and returns a dataset with list of unziped files containing:
- file name
- file directory and name
- file size 
- file content

Parameters:
- p_zipped_blob - a blob value containing a ZIP file
- p_include - a separated string containing file and directory name criterias to include in a result set, like "*.jpg" or "tile*.gif"; separator is defined in a parameter p_separator (default value ":")
- p_exclude - a separated string containing file and directory name criterias to exclude from a result set, like "tiles/*"; separator is defined in a parameter p_separator (default value ":")
- p_separator - include and exclude string separator
 

Code example (without any include/exclude filters):

SELECT *
FROM 
    table(
        apex_zip_utils.unzip (
            p_zipped_blob => (SELECT blob_content FROM import_zip WHERE id = 1)
        )
    )
;

Result;
FILE_NAME                   FILE_NAME_AND_DIRECTORY             FILE_SIZE   FILE_CONTENT
00000000000000130429.jpeg	00000000000000130429.jpeg	        11900       (blob)
00000000000000130430.jpeg	00000000000000130430.jpeg	        9340        (blob)
00000000000000130431.jpeg	00000000000000130431.jpeg	        17634       (blob)
ajax-loading.gif            ajax-loading.gif                    72232       (blob)
apexrnd-555x311.png	        apexrnd-555x311.png	                31480       (blob)
test.txt                    test.txt                            4           (blob)
00000000000000130407.jpeg   tiles/00000000000000130407.jpeg     9270        (blob)
00000000000000130408.jpeg   tiles/00000000000000130408.jpeg     11206       (blob)


Code example (with include filters):

SELECT *
FROM 
    table(
        apex_zip_utils.unzip (
            p_zipped_blob => (SELECT blob_content FROM import_zip WHERE id = 1),
            p_include => '*.gif:*.jpeg'
        )
    )
;

Result;
Result;
FILE_NAME                   FILE_NAME_AND_DIRECTORY           FILE_SIZE   FILE_CONTENT
00000000000000130429.jpeg	00000000000000130429.jpeg	        11900       (blob)
00000000000000130430.jpeg	00000000000000130430.jpeg	        9340        (blob)
00000000000000130431.jpeg	00000000000000130431.jpeg	        17634       (blob)
ajax-loading.gif            ajax-loading.gif                    72232       (blob)
00000000000000130407.jpeg   tiles/00000000000000130407.jpeg     9270        (blob)
00000000000000130408.jpeg   tiles/00000000000000130408.jpeg     11206       (blob)


Code example (with include filters and excluding a folder "tiles"):

SELECT *
FROM 
    table(
        apex_zip_utils.unzip (
            p_zipped_blob => (SELECT blob_content FROM import_zip WHERE id = 1),
            p_include => '*.gif:*.jpeg',
            p_exclude => 'tiles/*'
        )
    )
;

Result;
Result;
FILE_NAME                   FILE_NAME_AND_DIRECTORY           FILE_SIZE   FILE_CONTENT
00000000000000130429.jpeg	00000000000000130429.jpeg	        11900       (blob)
00000000000000130430.jpeg	00000000000000130430.jpeg	        9340        (blob)
00000000000000130431.jpeg	00000000000000130431.jpeg	        17634       (blob)
ajax-loading.gif            ajax-loading.gif                    72232       (blob)
*/


FUNCTION unzip (
    p_zipped_blob blob,
    p_zip_filename IN varchar2,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':'
) RETURN t_files PIPELINED;


/*
The function unzips all files from the passed ZIP file and retuns a nested table collection of files containing:
- file name
- file directory and name
- file size 
- file content
 
Code example:

DECLARE
    
    l_zipped_blob blob;
    l_files apex_zip_utils.t_files;
    
BEGIN
    --get zip file from the table
    SELECT blob_content 
    INTO l_zipped_blob
    FROM import_zip 
    WHERE id = 1;

    l_files := apex_zip_utils.unzip_nt (
        p_zipped_blob => l_zipped_blob
    );
    
    FOR t IN 1 .. l_files.count LOOP
        dbms_output.put_line(l_files(t).file_name_and_directory);
        dbms_output.put_line(l_files(t).file_name || ' (' || l_files(t).file_size || ' bytes)');
    END LOOP;
END;
*/

FUNCTION unzip_nt (
    p_zipped_blob blob,
    p_zip_filename IN varchar2,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':' 
) RETURN t_files;


/*
The function unzips all files from the passed ZIP file and returns an associative array collection of files containing:
- file name
- file directory and name
- file size 
- file content data

The collection index is the file directory and name, for example 'my/folder/file.xml'

Example of usage:

DECLARE
    
    l_zipped_blob blob;
    l_files apex_zip_utils.t_files_ar;
    l_index varchar2(32000);
    
BEGIN
    --get zip file from the table
    SELECT blob_content 
    INTO l_zipped_blob
    FROM import_zip 
    WHERE id = 1;

    l_files := apex_zip_utils.unzip_ar (
        p_zipped_blob => l_zipped_blob
    );
    
    l_index := 'tiles/00000000000000130407.jpeg';
    dbms_output.put_line(
        l_files(l_index).file_name || ' (' || 
        l_files(l_index).file_size || ' bytes)'
    );
END;

*/

FUNCTION unzip_ar (
    p_zipped_blob blob,
    p_zip_filename IN varchar2,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':' 
) RETURN t_files_ar;

END apex_zip_utils;
