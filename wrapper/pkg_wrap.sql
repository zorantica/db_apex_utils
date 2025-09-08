create or replace PACKAGE     pkg_wrap AS
/******************************************************************************
   NAME:        pkg_wrap
   PURPOSE:     Utility for wrapping a source code

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08.06.2021  zoran            1. Created this package.
******************************************************************************/

FUNCTION f_wrap (
    p_sql_source clob,
    p_add_slash_yn varchar2 default 'N'
) RETURN clob;

PROCEDURE p_decode_and_wrap (
    p_source blob
);

END pkg_wrap;
/

create or replace PACKAGE BODY     pkg_wrap AS


FUNCTION f_blob_to_clob (
	p_blob IN BLOB
) RETURN CLOB
AS
	v_clob    CLOB;
	v_varchar VARCHAR2(32767);
	v_start   PLS_INTEGER := 1;
	v_buffer  PLS_INTEGER := 32767;
BEGIN
	dbms_lob.createtemporary(
	                        v_clob,
	                        true
	);
	FOR i IN 1..ceil(dbms_lob.getlength(p_blob) / v_buffer) LOOP
		v_varchar := utl_raw.cast_to_varchar2(dbms_lob.substr(
		                                                     p_blob,
		                                                     v_buffer,
		                                                     v_start
		                                      ));
		dbms_lob.writeappend(
		                    v_clob,
		                    length(v_varchar),
		                    v_varchar
		);
		v_start   := v_start
		           + v_buffer;
	END LOOP;
	RETURN v_clob;
END f_blob_to_clob;


  procedure print_htp_clob (
    p_clob in clob
  ) is
    l_read_amount  integer := 32000;
    l_read_offset  number := 1;
    l_buffer       varchar2(32767);
  begin
    if length(p_clob) > l_read_amount then
      loop
        dbms_lob.read(
          p_clob,
          l_read_amount,
                      l_read_offset,
                      l_buffer
        );
        sys.htp.prn(l_buffer);
        l_read_offset := l_read_offset + l_read_amount;
        exit when l_read_offset > length(p_clob);
      end loop;

    else
      sys.htp.prn(p_clob);
    end if;

  end print_htp_clob;


FUNCTION f_wrap(
    p_sql_source clob,
    p_add_slash_yn varchar2 default 'N'
) RETURN clob IS

    lrSource dbms_sql.varchar2a;
    lrWrapped dbms_sql.varchar2a;
    
    lnPos pls_integer := 1;
    lnIndex pls_integer := 1;
    
    lcClob clob;
    
    l_parts apex_t_varchar2;
    l_last_line varchar2(100);

BEGIN
    --remove EDITIONABLE word because it rises an error
    lcClob := replace(p_sql_source, 'CREATE OR REPLACE EDITIONABLE', 'CREATE OR REPLACE');
    
    --remove "/" from end of script - wrapped script gets invalid
    lcClob := rtrim(lcClob, '/');
    

    --break clob in varchar2 chunks
    WHILE lnPos <= dbms_lob.getLength( lcClob) LOOP
        lrSource(lnIndex) := substr(lcClob, lnPos, 30000);
        
        lnPos := lnPos + 30000;
        lnIndex := lnIndex + 1;
    END LOOP; 

    --wrap chunks
    lrWrapped := dbms_ddl.wrap(
        ddl => lrSource,
        lb => 1,
        ub => lrSource.count
    );

    --concat wrapped chunks into CLOB
    lcClob := null;
    FOR t IN 1 .. lrWrapped.count LOOP
        lcClob := lcClob || lrWrapped(t); 
    END LOOP;
    
    
    --check if the last line is 72 characters long and split if needed
    l_parts := apex_string.split(lcClob, chr(10) );

    WHILE l_parts(l_parts.count) is null and l_parts.count > 0 LOOP
        l_parts.delete(l_parts.count);
    END LOOP;

    if length(l_parts(l_parts.count)) = 72 then
        l_last_line := l_parts(l_parts.count);

        l_parts(l_parts.count) := substr(l_last_line, 1, 30);
        l_parts(l_parts.count + 1) := substr(l_last_line, 31);
    end if;

    lcClob := apex_string.join_clob(l_parts, chr(10) );

    --if requested add slash at the end
    if p_add_slash_yn = 'Y' then
        lcClob := lcClob || chr(10) || '/';
    end if;

    RETURN lcClob;

END f_wrap;


PROCEDURE p_decode_and_wrap (
    p_source blob
) IS

    l_source clob;

BEGIN
    l_source := f_wrap( f_blob_to_clob(p_source), 'Y' );

    print_htp_clob(l_source);
END p_decode_and_wrap;


END pkg_wrap;
/