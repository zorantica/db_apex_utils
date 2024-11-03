CREATE OR REPLACE PACKAGE BODY apex_zip_utils AS


FUNCTION unzip_pl (
    p_zipped_blob IN blob,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':'
) RETURN t_files PIPELINED IS

    l_files apex_zip.t_dir_entries;
    l_file blob;
    l_counter pls_integer := 1;
    l_index varchar2(32767);
    l_include apex_t_varchar2;

    l_row r_file;
    
    l_match_found boolean;

BEGIN
    --get a file list from the zip file
    l_files := apex_zip.get_dir_entries (
        p_zipped_blob => p_zipped_blob,
        p_only_files => true
    );
    

    --unzipping files and populating the output collection
    l_index := l_files.first;
    
    LOOP
        EXIT WHEN l_index is null;

        --get filename
        l_row.file_name_and_directory := l_index;
        l_row.file_name := 
            CASE 
                WHEN instr(l_files( l_index ).file_name, '/') = 0 THEN l_files( l_index ).file_name
                ELSE substr(l_files( l_index ).file_name, instr(l_files( l_index ).file_name, '/', -1) + 1 )
            END
        ;
        
        --check filename for filters
        if p_include is null then  --no filters -> extract all files
            l_match_found := true;
        
        else  --check filters
        
            l_match_found := false;
            
            l_include := apex_string.split (
                p_str => p_include,
                p_sep => p_separator
            );
            
            FOR t IN 1 .. l_include.count LOOP
                if l_row.file_name_and_directory like replace(l_include(t), '*', '%') then
                    l_match_found := true;
                    EXIT;
                end if;
            END LOOP;

        end if;
        
        if l_match_found then
        
            --get file content
            l_row.file_content := apex_zip.get_file_content (
                p_zipped_blob => p_zipped_blob,
                p_dir_entry => l_files( l_index ) 
            );
            
            --get file size
            l_row.file_size := l_files( l_index ).uncompressed_length;
            
            pipe row (l_row);
            
        end if;
        
        --next file index
        l_index := l_files.next(l_index);
        l_counter := l_counter + 1;
    END LOOP;    

    RETURN;
END unzip_pl;


FUNCTION unzip (
    p_zipped_blob blob,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':'
) RETURN t_files IS

    l_output t_files;

BEGIN
    SELECT *
    BULK COLLECT INTO l_output
    FROM
        table(
            apex_zip_utils.unzip_pl (
                p_zipped_blob => p_zipped_blob,
                p_include => p_include,
                p_exclude => p_exclude,
                p_separator => p_separator
            )
        )
    ;
    
    RETURN l_output;
    
END unzip;



FUNCTION unzip_ar (
    p_zipped_blob blob,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':' 
) RETURN t_files_ar IS

    l_output_nt t_files;
    l_output t_files_ar;

BEGIN
    SELECT *
    BULK COLLECT INTO l_output_nt
    FROM
        table(
            apex_zip_utils.unzip_pl (
                p_zipped_blob => p_zipped_blob,
                p_include => p_include,
                p_exclude => p_exclude,
                p_separator => p_separator
            )
        )
    ;
    
    FOR t IN 1 .. l_output_nt.count LOOP
        l_output( l_output_nt(t).file_name_and_directory ) := l_output_nt(t);
    END LOOP;
    
    RETURN l_output;
    
END unzip_ar;



END apex_zip_utils;