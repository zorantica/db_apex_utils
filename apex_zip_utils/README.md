# Oracle APEX - "apex_zip_utils" package

History of changes:
- 1.0 - initial version

## Install instructions

Create the package specification and the package body in the target database schema.

## Program unit specs

### Function unzip_pl

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

```sql
SELECT *
FROM 
    table(
        apex_zip_utils.unzip_pl (
            p_zipped_blob => (SELECT blob_content FROM import_zip WHERE id = 1)
        )
    )
;
```

```text
Result:
FILE_NAME                    FILE_NAME_AND_DIRECTORY            FILE_SIZE   FILE_CONTENT
00000000000000130429.jpeg    00000000000000130429.jpeg          11900       (blob)
00000000000000130430.jpeg    00000000000000130430.jpeg          9340        (blob)
00000000000000130431.jpeg    00000000000000130431.jpeg          17634       (blob)
ajax-loading.gif             ajax-loading.gif                   72232       (blob)
apexrnd-555x311.png	      apexrnd-555x311.png	            31480       (blob)
test.txt                     test.txt                           4           (blob)
00000000000000130407.jpeg    tiles/00000000000000130407.jpeg    9270        (blob)
00000000000000130408.jpeg    tiles/00000000000000130408.jpeg    11206       (blob)
```


Code example (with include filters):

SELECT *
FROM 
    table(
        apex_zip_utils.unzip_pl (
            p_zipped_blob => (SELECT blob_content FROM import_zip WHERE id = 1),
            p_include => '*.gif:*.jpeg'
        )
    )
;

Result:
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
        apex_zip_utils.unzip_pl (
            p_zipped_blob => (SELECT blob_content FROM import_zip WHERE id = 1),
            p_include => '*.gif:*.jpeg',
            p_exclude => 'tiles/*'
        )
    )
;

Result:
FILE_NAME                   FILE_NAME_AND_DIRECTORY           FILE_SIZE   FILE_CONTENT
00000000000000130429.jpeg	00000000000000130429.jpeg	        11900       (blob)
00000000000000130430.jpeg	00000000000000130430.jpeg	        9340        (blob)
00000000000000130431.jpeg	00000000000000130431.jpeg	        17634       (blob)
ajax-loading.gif            ajax-loading.gif                    72232       (blob)


### Procedure apply_xliff_files

Procedure receives a ZIP file with XLIFF translations and applies them to a selected application.
Compatible with APEX 23.1 or newer.

Parameters:
- p_zip - a ZIP file containing XLIFF files  
- p_app_id - main application ID in primary language
- p_seed_yn - if the seed action should be executed BEFORE applying XLIFF files
- p_publish_yn - if the publish action should be executed AFTER applying XLIFF files

## Usage

### Export multiple XLIFF files in a single ZIP file

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

### Apply multiple XLIFF files from a single ZIP file

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