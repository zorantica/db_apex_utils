CREATE OR REPLACE PACKAGE BODY lob_2_script IS



FUNCTION f_lob_type (
    p_table varchar2,
    p_column varchar2
) RETURN varchar2 IS

    lcLobType varchar2(1);

BEGIN
    SELECT
        CASE 
            WHEN data_type = 'CLOB' THEN 'C'
            ELSE 'B'
        END
    INTO
        lcLobType
    FROM 
        all_tab_columns
    WHERE
        owner || '.' || table_name = p_table
    AND column_name = p_column
    ;

    RETURN lcLobType;

EXCEPTION WHEN others THEN 
    RETURN 'B';
    
END f_lob_type;



FUNCTION f_generate_script(
    p_table varchar2,
    p_column varchar2,
    p_column_type varchar2,  --"C" for CLOB; "B" for BLOB
    p_where varchar2,
    p_lob_source varchar2,  --"PARAM" as p_file_blob parameter, "APEX_VIEW" as single file from apex_application_temp_file_blobs view, "READ_FROM_TABLE" read from source table
    p_file_blob blob default null
) RETURN clob IS

    lbBlob blob;
    lcClob clob;
    lrPieces apex_t_varchar2;
    
    PROCEDURE p_add(p_text varchar2 default null) IS
    BEGIN
        lcClob := lcClob || p_text || chr(10);
    END p_add;
    
BEGIN
    --get document
    if p_lob_source = 'TABLE' then
        EXECUTE IMMEDIATE 
            'SELECT ' || 
            CASE WHEN p_column_type = 'C' THEN 'lob_2_script.f_clob_to_blob(' || p_column || ')' ELSE p_column END || 
            ' FROM ' || p_table || 
            ' WHERE ' || p_where
        INTO lbBlob;
        
    elsif p_lob_source = 'APEX_VIEW' then
        SELECT blob_content
        INTO lbBlob
        FROM apex_application_temp_files
        WHERE rownum = 1;
        
    elsif p_lob_source = 'PARAM' then
        lbBlob := p_file_blob;
    
    else
        RAISE_APPLICATION_ERROR(-20001, 'Selected source option is not valid. It must be TABLE, APEX_VIEW or PARAM.');
        
    end if;
    
    
    --encode to base64 and split into rows
    lcClob := replace( apex_web_service.blob2clobbase64(p_blob => lbBlob), chr(13) || chr(10), chr(10) );
    lrPieces := apex_string.split(lcClob);
    
    
    --P R E P A R E   S C R I P T
    --header
    lcClob := null;
    p_add('DECLARE');
    p_add;
    p_add('    lcClob clob;');
    p_add('    lbBlob blob;');
    p_add;
    
    p_add(q'[  function decode_base64(p_clob_in in clob) return blob is
    v_blob blob;
    v_result blob;
    v_offset integer;
    v_buffer_size binary_integer := 48;
    v_buffer_varchar varchar2(48);
    v_buffer_raw raw(48);
  begin
    if p_clob_in is null then
      return null;
    end if;
    dbms_lob.createtemporary(v_blob, true);
    v_offset := 1;
    for i in 1 .. ceil(dbms_lob.getlength(p_clob_in) / v_buffer_size) loop
      dbms_lob.read(p_clob_in, v_buffer_size, v_offset, v_buffer_varchar);
      v_buffer_raw := utl_raw.cast_to_raw(v_buffer_varchar);
      v_buffer_raw := utl_encode.base64_decode(v_buffer_raw);
      dbms_lob.writeappend(v_blob, utl_raw.length(v_buffer_raw), v_buffer_raw);
      v_offset := v_offset + v_buffer_size;
    end loop;
    v_result := v_blob;
    dbms_lob.freetemporary(v_blob);
    return v_result;
  end decode_base64;]');
    p_add;

    if p_column_type = 'C' then
        p_add(q'[  FUNCTION f_blob_to_clob(
    blob_in IN blob,
    plEncoding IN NUMBER default 0) RETURN clob IS

    v_clob Clob;
    v_in Pls_Integer := 1;
    v_out Pls_Integer := 1;
    v_lang Pls_Integer := 0;
    v_warning Pls_Integer := 0;
    v_id number(10);

BEGIN
    if blob_in is null then
        return null;
    end if;

    v_in:=1;
    v_out:=1;
    dbms_lob.createtemporary(v_clob,TRUE);
    DBMS_LOB.convertToClob(v_clob,
                           blob_in,
                           DBMS_lob.getlength(blob_in),
                           v_in,
                           v_out,
                           plEncoding,
                           v_lang,
                           v_warning);

    RETURN v_clob;

END f_blob_to_clob;]');
        p_add;
    end if;


    p_add('BEGIN');

    --lines
    FOR t in 1 .. lrPieces.count LOOP
        p_add('    lcClob := lcClob || ''' || lrPieces(t) || ''';');
    END LOOP;
    p_add;

    --convert back to blob
    p_add('    lbBlob := decode_base64(lcClob);');
    p_add;
    
    --update desired record
    p_add(
        '    UPDATE ' || p_table || 
        ' SET ' ||  p_column || ' = ' || 
        CASE p_column_type WHEN 'B' THEN 'lbBlob' ELSE 'f_blob_to_clob(lbBlob)' END || 
        ' WHERE ' || p_where || 
        ';'
    );
    p_add;

    --finish
    p_add('    COMMIT;');
    p_add;
    p_add('END;');
    p_add('/');

    DELETE FROM apex_application_temp_files;
    COMMIT;

    
    RETURN lcClob;
    
END f_generate_script;


FUNCTION f_clob_to_blob(
    c clob,
    plEncoding IN NUMBER default 0) RETURN blob IS

    v_blob Blob;
    v_in Pls_Integer := 1;
    v_out Pls_Integer := 1;
    v_lang Pls_Integer := 0;
    v_warning Pls_Integer := 0;
    v_id number(10);

BEGIN
    if c is null then
        return null;
    end if;

    v_in:=1;
    v_out:=1;
    dbms_lob.createtemporary(v_blob,TRUE);
    
    DBMS_LOB.convertToBlob(
        v_blob,
        c,
        DBMS_lob.getlength(c),
        v_in,
        v_out,
        plEncoding,
        v_lang,
        v_warning
    );

    RETURN v_blob;

END f_clob_to_blob; 


PROCEDURE p_download_document (
    p_doc IN OUT blob,
    p_file_blob_name varchar2,
    p_disposition varchar2 default 'attachment'  --values "attachment" and "inline"
    ) IS
BEGIN
    htp.init;
    OWA_UTIL.MIME_HEADER('application/pdf', FALSE);
    htp.p('Content-length: ' || dbms_lob.getlength(p_doc) ); 
    htp.p('Content-Disposition: ' || p_disposition || '; filename="' || p_file_blob_name || '"' );
    OWA_UTIL.HTTP_HEADER_CLOSE;
    
    WPG_DOCLOAD.DOWNLOAD_FILE(p_doc);
    DBMS_LOB.FREETEMPORARY(p_doc);
    
    apex_application.stop_apex_engine;
END p_download_document;  


PROCEDURE p_download_document(
    p_text IN OUT clob,
    p_file_blob_name varchar2,
    p_disposition varchar2 default 'attachment'  --values "attachment" and "inline"
    ) IS
    
    lbBlob blob;
    
BEGIN
    lbBlob := f_clob_to_blob(p_text);
    
    p_download_document(
        p_doc => lbBlob,
        p_file_blob_name => p_file_blob_name,
        p_disposition => p_disposition
    );
    
END p_download_document;



PROCEDURE p_generate_script_and_download (
    p_table varchar2,
    p_column varchar2,
    p_column_type varchar2,  --"C" for CLOB; "B" for BLOB
    p_where varchar2,
    p_lob_source varchar2,  --"PARAM" as p_file_blob parameter, "APEX_VIEW" as single file from apex_application_temp_file_blobs view, "READ_FROM_TABLE" read from source table
    p_file_blob blob default null
) IS

    lcClob clob;

BEGIN
    lcClob := f_generate_script (
        p_table => p_table,
        p_column => p_column,
        p_column_type => p_column_type,
        p_where => p_where,
        p_lob_source => p_lob_source,
        p_file_blob => p_file_blob
    );

    --convert script to blob and download
    p_download_document(
        p_text => lcClob,
        p_file_blob_name => 'lob_doc.sql'
    );

END p_generate_script_and_download;

END lob_2_script;
/

