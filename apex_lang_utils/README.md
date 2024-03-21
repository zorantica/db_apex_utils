# Oracle APEX - "apex_lang_utils" package

History of changes:
- 1.0 - initial version

## Install instructions

In the target schema create the package specification and the package body.

## Program unit specs

### Function get_xliff_per_page

Function returns a ZIP file with exported XLIFF files for selected pages and selected languages.
Compatible with APEX 23.1 or newer.

Parameters:
- p_app_id - main application ID in primary language  
- p_pages - a comma separated list of desired pages OR "all" value for all pages
- p_languages - a comma separated list of desired languages OR "all" value for all languages
- p_folder_per_group_yn - if files are going to be stored in separate folders named by page groups; values Y/N 
- p_only_modified_elements_yn - if only modified elements are going to be exported; values Y/N

### Procedure apply_xliff_files

Procedure receives a ZIP file with XLIFF translations and applies them to a selected application.
Compatible with APEX 23.1 or newer.

Parameters:
- p_zip - a ZIP file containing XLIFF files  
- p_app_id - main application ID in primary language
- p_seed_yn - if the seed action should be executed BEFORE applying XLIFF files
- p_publish_yn - if the publish action should be executed AFTER applying XLIFF files

## Usage

Export multiple XLIFF files in a single ZIP file:

```sql
DECLARE
    l_zip blob;
    
BEGIN
    --create a ZIP file
    l_zip := apex_lang_utils.get_xliff_per_page (
        p_app_id => 140,
        p_pages => '1,2,3',
        p_languages => 'nl-be,fr-be',
        p_folder_per_group_yn => 'Y',
        p_only_modified_elements_yn => 'N'
    );
    
    --store the ZIP file into the TEST table
    DELETE test;
    INSERT INTO test (id, blob_doc)
    VALUES (1, l_zip);
    
    COMMIT;

END;
```

Apply multiple XLIFF files from a single ZIP file:

```sql
DECLARE
    l_zip blob;
    
BEGIN
    --fetch a ZIP file with XLIFF translations from the TEST table
    SELECT blob_doc
    INTO l_zip
    FROM test
    WHERE id = 2;
    
    --apply translations
    apex_lang_utils.apply_xliff_files (
        p_zip => l_zip,
        p_app_id => 140,
        p_seed_yn => 'Y',
        p_publish_yn => 'N'
    );

END;
```