CREATE OR REPLACE PACKAGE BODY apex_lang_utils AS


PROCEDURE p_download_document(
    p_doc IN OUT blob,
    p_file_name varchar2,
    p_disposition varchar2 default 'attachment'  --values "attachment" and "inline"
    ) IS
BEGIN
    htp.init;
    OWA_UTIL.MIME_HEADER('application/pdf', FALSE);
    htp.p('Content-length: ' || dbms_lob.getlength(p_doc) ); 
    htp.p('Content-Disposition: ' || p_disposition || '; filename="' || p_file_name || '"' );
    OWA_UTIL.HTTP_HEADER_CLOSE;
    
    WPG_DOCLOAD.DOWNLOAD_FILE(p_doc);

    --free temporary lob IF it is temporary
    if dbms_lob.istemporary(p_doc) = 1 then
        DBMS_LOB.FREETEMPORARY(p_doc);
    end if;
    
    apex_application.stop_apex_engine;
END p_download_document;  



PROCEDURE create_session_if_needed (
    p_app_id number
) IS
BEGIN
    if nvl(v('APP_ID'), 0) <> p_app_id then

        dbms_output.put_line('Creating a session for APP id ' || p_app_id);
            
        --please provide an appropriate username and page in order to create a session
        apex_session.create_session (
            p_app_id => p_app_id,
            p_page_id => 1,
            p_username => 'zoran'
        );
    
    else
        dbms_output.put_line('Session ' || v('APP_SESSION') || ' already created');
    
    end if;

END create_session_if_needed;

FUNCTION get_xliff_per_page (
    p_app_id number,
    p_pages varchar2 default 'all',
    p_languages varchar2 default 'all',
    p_folder_per_group_yn varchar2 default 'Y',
    p_only_modified_elements_yn varchar2 default 'N'

) RETURN blob IS

    CURSOR c_data IS
        SELECT
            tm.translated_app_language,
            p.page_id,
            p_app_id || '/' ||
            tm.translated_app_language || '/' ||
            CASE p_folder_per_group_yn WHEN 'Y' THEN nvl(p.page_group, '(unassigned)') || '/' ELSE null END ||
            to_char(p.page_id, 'fm00000') || ' - ' || 
            replace( replace(p.page_name, '/', '_'), '\', '_') || ' (' ||
            tm.translated_app_language || ').xlf' as filename
        FROM 
            apex_application_trans_map tm
            JOIN apex_application_pages p ON tm.primary_application_id = p.application_id
        WHERE
            tm.primary_application_id = p_app_id
        AND (
                p_languages = 'all'
            OR  tm.translated_app_language in 
                    (
                    SELECT column_value as translated_app_language 
                    FROM table( apex_string.split(p_languages, ','))
                    )
            )
        AND (
                p_pages = 'all'
            OR  p.page_id in 
                    (
                    SELECT column_value as page_id 
                    FROM table( apex_string.split(p_pages, ','))
                    )
            )
        --AND rownum <= 10  --for testing purposes
    ;
    
    TYPE t_data IS TABLE OF c_data%ROWTYPE;
    l_data t_data;
    
    l_xliff clob;
    l_zip blob;

BEGIN
    --fetch data
    OPEN c_data;
    FETCH c_data BULK COLLECT INTO l_data;
    CLOSE c_data;
    
    --create APEX session (if needed)
    create_session_if_needed (
        p_app_id => p_app_id
    );

    --loop through all pages and languages, prepare XLIFF files and zip them
    FOR t IN 1 .. l_data.count LOOP

        dbms_output.put_line('Exporting file for page ' || l_data(t).page_id || ' and language ' || l_data(t).translated_app_language || '...');

        l_xliff := apex_lang.get_xliff_document (
            p_application_id => p_app_id,
            p_page_id => l_data(t).page_id,
            p_language => l_data(t).translated_app_language,
            p_only_modified_elements => CASE p_only_modified_elements_yn WHEN 'Y' THEN true ELSE false END
        );
        
        apex_zip.add_file (
            p_zipped_blob => l_zip,
            p_file_name => l_data(t).filename,
            p_content => apex_util.clob_to_blob(l_xliff)
        );
        
    END LOOP;

    apex_zip.finish(l_zip);
    
    RETURN l_zip;

END get_xliff_per_page;



PROCEDURE apply_xliff_files (
    p_zip blob,
    p_app_id number,
    p_seed_yn varchar2 default 'Y',
    p_publish_yn varchar2 default 'Y'
) IS
    
    l_files apex_zip.t_files;
    l_file blob;
    l_xliff clob;
    l_lang varchar2(10);

    CURSOR c_languages IS
        SELECT amp.translated_app_language as lang
        FROM apex_application_trans_map amp 
        WHERE amp.primary_application_id = p_app_id
    ;


    PROCEDURE p_seed IS
    BEGIN
        FOR t IN c_languages LOOP
            dbms_output.put_line('Seeding ' || t.lang);
            apex_lang.seed_translations(
                p_application_id => p_app_id,
                p_language => t.lang
            );
            dbms_output.put_line('Seed finished ' || t.lang);
        END LOOP;

        COMMIT;
        
    END p_seed;

    PROCEDURE p_publish IS
    BEGIN
        FOR t IN c_languages LOOP
            dbms_output.put_line('Publishing '  || t.lang);
            apex_lang.publish_application(
                p_application_id => p_app_id,
                p_language => t.lang
            );
            dbms_output.put_line('Publish finished ' || t.lang);

        END LOOP;

        COMMIT;
        
    END p_publish;
        
BEGIN
    --create APEX session (if needed)
    create_session_if_needed (
        p_app_id => p_app_id
    );

    --seed (if needed)
    if p_seed_yn = 'Y' then
        p_seed;
    end if;


    --get a list of files from the ZIP file
    l_files := apex_zip.get_files ( p_zipped_blob => p_zip );
    
    --loop through files and apply them if possible
    FOR t IN 1 .. l_files.count LOOP

        --check file extension (ignore MAC subfolder)
        if lower( substr( l_files(t), -4 ) ) = '.xlf' and not instr(l_files(t), '__MACOSX') > 0 then
        
            dbms_output.put_line( 'Processing ' || l_files(t) );
            
            --get a single file content and convert it from blob to clob
            l_file := apex_zip.get_file_content (
                p_zipped_blob => p_zip,
                p_file_name => l_files(t)
            );
            
            l_xliff := apex_util.blob_to_clob(l_file);
            
            --determine the target language from the file 
            SELECT 
                XMLCast (
                    xmlquery(
                        '(: :) /xliff/file/@target-language' 
                        passing xmlType(l_xliff)
                        RETURNING CONTENT
                    ) 
                    as varchar2(10)
                ) as lang
            INTO l_lang
            FROM dual;
            
            dbms_output.put_line('Detected language ' || l_lang);
            dbms_output.put_line('File size: ' || length(l_xliff) );
            
            if l_lang is null then
                RAISE_APPLICATION_ERROR(-20001, 'Language can not be determined for a file ' || l_files(t));
            end if;
            
            
            --apply translation to the repository
            apex_lang.apply_xliff_document (
                p_application_id => p_app_id,
                p_language => l_lang,
                p_document => l_xliff 
            );

            dbms_output.put_line( 'File applied ' || l_files(t) );
            
        else
            dbms_output.put_line( 'Skipping ' || l_files(t) );
            
        end if;
        
    END LOOP;

    --publish (if needed)
    if p_publish_yn = 'Y' then
        p_publish;
    end if;


END apply_xliff_files;


PROCEDURE p_export_from_apex (
    p_app_id number,
    p_folder_per_group_yn varchar2 default 'Y',
    p_only_modified_elements_yn varchar2 default 'N'
) IS

    l_languages varchar2(4000);
    l_pages varchar2(4000);
    l_zip blob;

BEGIN
    SELECT listagg(column_value, ',') as languages
    INTO l_languages
    FROM table( apex_application.g_f01);

    SELECT listagg(column_value, ',') as pages
    INTO l_pages
    FROM table( apex_application.g_f02);

    l_zip := apex_lang_utils.get_xliff_per_page (
        p_app_id => p_app_id,
        p_pages => l_pages,
        p_languages => l_languages,
        p_folder_per_group_yn => p_folder_per_group_yn,
        p_only_modified_elements_yn => p_only_modified_elements_yn
    );

    p_download_document (
        p_doc => l_zip,
        p_file_name => 'translations for app ' || p_app_id || '.zip'
    );
END p_export_from_apex;


PROCEDURE p_import (
    p_app_id number,
    p_seed_yn varchar2 default 'Y',
    p_publish_yn varchar2 default 'Y'
) IS

    CURSOR c_files IS 
        SELECT *
        FROM apex_application_temp_files;

BEGIN
    FOR t IN c_files LOOP

        zt_log.p_zabelezi_komentar('FILENAME: ' || t.filename);
        zt_log.p_zabelezi_komentar('Size: ' || dbms_lob.getLength(t.blob_content) );

        apex_lang_utils.apply_xliff_files (
            p_zip => t.blob_content,
            p_app_id => p_app_id,
            p_seed_yn => p_seed_yn,
            p_publish_yn => p_publish_yn
        );
        
    END LOOP;
    
EXCEPTION WHEN others THEN

    zt_log.p_zabelezi_komentar(sqlerrm || ' ' || dbms_utility.format_error_backtrace);
    RAISE;

END p_import;


END apex_lang_utils;