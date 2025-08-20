CREATE OR REPLACE PACKAGE apex_lang_utils AS


PROCEDURE p_download_document(
    p_doc IN OUT blob,
    p_file_name varchar2,
    p_disposition varchar2 default 'attachment'  --values "attachment" and "inline"
);


/*
Function returns a ZIP file with exported XLIFF files for selected pages and selected languages.
Compatible with APEX 23.1 or newer.

Parameters:
@p_app_id - main application ID in primary language  
@p_pages - a comma separated list of desired pages OR "all" value for all pages
@p_languages - a comma separated list of desired languages OR "all" value for all languages
@p_folder_per_group_yn - if files are going to be stored in separate folders named by page groups; values Y/N 
@p_only_modified_elements_yn - if only modified elements are going to be exported; values Y/N

usage:
DECLARE
    l_zip blob;
BEGIN
    l_zip := apex_lang_utils.get_xliff_per_page (
        p_app_id => 140,
        p_pages => '1,2,3',
        p_languages => 'nl-be,fr-be',
        p_folder_per_group_yn => 'Y',
        p_only_modified_elements_yn => 'N'
    );
    
    DELETE test;
    INSERT INTO test (id, blob_doc)
    VALUES (1, l_zip);
    
    COMMIT;

END;
*/
FUNCTION get_xliff_per_page (
    p_app_id number,
    p_pages varchar2 default 'all',
    p_languages varchar2 default 'all',
    p_folder_per_group_yn varchar2 default 'Y',
    p_only_modified_elements_yn varchar2 default 'N'
) RETURN blob;



/*
Procedure receives a ZIP file with XLIFF translations and applies them to a selected application.
Compatible with APEX 23.1 or newer.

Parameters:
@p_zip - a ZIP file containing XLIFF files  
@p_app_id - main application ID in primary language
@p_seed_yn - if the seed action should be executed BEFORE applying XLIFF files
@p_publish_yn - if the publish action should be executed AFTER applying XLIFF files
*/

PROCEDURE apply_xliff_files (
    p_zip blob,
    p_app_id number,
    p_seed_yn varchar2 default 'Y',
    p_publish_yn varchar2 default 'Y'
);


PROCEDURE p_export_from_apex (
    p_app_id number,
    p_folder_per_group_yn varchar2 default 'Y',
    p_only_modified_elements_yn varchar2 default 'N'
);

PROCEDURE p_import (
    p_app_id number,
    p_seed_yn varchar2 default 'Y',
    p_publish_yn varchar2 default 'Y'
);


END apex_lang_utils;