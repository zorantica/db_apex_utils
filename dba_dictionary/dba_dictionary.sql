CREATE OR REPLACE VIEW DBA_DICTIONARY AS
SELECT 
    d.table_name as view_name,
    atc.column_id,
    atc.column_name,
    com.comments as comments,
    'Column' as comment_type,
    null as parent_view
FROM 
    all_tab_columns atc
    JOIN dictionary d ON atc.table_name = d.table_name AND atc.owner = 'SYS'
    LEFT JOIN all_col_comments com ON atc.table_name = com.table_name AND atc.column_name = com.column_name AND atc.owner = 'SYS'
UNION ALL 
SELECT 
    d.table_name,
    0 as column_id,
    null as column_name,
    com.comments as comments,
    'View' as comment_type,
    null as parent_view
FROM 
    dictionary d
    LEFT JOIN all_tab_comments com ON d.table_name = com.table_name AND com.owner = 'SYS'
ORDER BY 
    view_name,
    column_id
;