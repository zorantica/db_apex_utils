CREATE OR REPLACE PACKAGE BODY apex_zip_utils AS


FUNCTION unzip (
    p_zipped_blob IN blob,
    p_include varchar2 default null,
    p_exclude varchar2 default null,
    p_separator varchar2 default ':'
) RETURN t_files PIPELINED IS

    $IF wwv_flow_api.c_current >= apex_zip_utils.c_apex_21_2 $THEN
    l_files apex_zip.t_dir_entries;
    $ELSE
    l_files apex_zip.t_files;
    $END
    
    l_file blob;
    l_counter pls_integer := 1;
    l_index varchar2(32767);
    l_filter apex_t_varchar2;
    
    l_filename varchar2(4000);
    l_filename_and_directory varchar2(4000);

    l_row r_file;
    
    l_match_found boolean;

BEGIN
    --get a file list from the zip file
    $IF wwv_flow_api.c_current >= apex_zip_utils.c_apex_21_2 $THEN
    l_files := apex_zip.get_dir_entries (
        p_zipped_blob => p_zipped_blob,
        p_only_files => true
    );
    $ELSE
    l_files := apex_zip.get_files (
        p_zipped_blob => p_zipped_blob
    );
    $END
    

    --unzipping files and populating the output collection
    l_index := l_files.first;
    
    LOOP
        EXIT WHEN l_index is null;

        --get filename
        
        $IF wwv_flow_api.c_current >= apex_zip_utils.c_apex_21_2 $THEN
        l_filename := l_files( l_index ).file_name;
        l_row.file_name_and_directory := l_index;
        $ELSE
        l_filename := l_files( l_index );
        l_row.file_name_and_directory := l_files( l_index );
        $END
        
        l_row.file_name := 
            CASE 
                WHEN instr(l_filename, '/') = 0 THEN l_filename
                ELSE substr(l_filename, instr(l_filename, '/', -1) + 1 )
            END
        ;
        
        --include files
        if p_include is null then  --no filters -> extract all files
            l_match_found := true;
        
        else  --check filters
        
            l_match_found := false;
            
            l_filter := apex_string.split (
                p_str => p_include,
                p_sep => p_separator
            );
            
            FOR t IN 1 .. l_filter.count LOOP
                if l_row.file_name_and_directory like replace(l_filter(t), '*', '%') then
                    l_match_found := true;
                    EXIT;
                end if;
            END LOOP;

        end if;

        --exclude files
        if p_include is not null and l_match_found then  --exclude
            l_filter := apex_string.split (
                p_str => p_exclude,
                p_sep => p_separator
            );
            
            FOR t IN 1 .. l_filter.count LOOP
                if l_row.file_name_and_directory like replace(l_filter(t), '*', '%') then
                    l_match_found := false;
                    EXIT;
                end if;
            END LOOP;

        end if;

        
        if l_match_found then
        
            --get file content
            $IF wwv_flow_api.c_current >= apex_zip_utils.c_apex_21_2 $THEN
            l_row.file_content := apex_zip.get_file_content (
                p_zipped_blob => p_zipped_blob,
                p_dir_entry => l_files( l_index ) 
            );
            $ELSE
            l_row.file_content := apex_zip.get_file_content (
                p_zipped_blob => p_zipped_blob,
                p_file_name   => l_files( l_index ) 
            );
            $END
            
            --get file size
            $IF wwv_flow_api.c_current >= apex_zip_utils.c_apex_21_2 $THEN
            l_row.file_size := l_files( l_index ).uncompressed_length;
            $ELSE
            l_row.file_size := dbms_lob.getLength(l_row.file_content);
            $END
            
            pipe row (l_row);
            
        end if;
        
        --next file index
        l_index := l_files.next(l_index);
        l_counter := l_counter + 1;
    END LOOP;    

    RETURN;
END unzip;


FUNCTION unzip_nt (
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
            apex_zip_utils.unzip (
                p_zipped_blob => p_zipped_blob,
                p_include => p_include,
                p_exclude => p_exclude,
                p_separator => p_separator
            )
        )
    ;
    
    RETURN l_output;
    
END unzip_nt;



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
            apex_zip_utils.unzip (
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