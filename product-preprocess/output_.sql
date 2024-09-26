-- General analysis query
EXEC sp_fkeys @pktable_name = 'Product', @pktable_owner = 'Production'

SELECT    
OBJECT_NAME(fkeys.constraint_object_id) foreign_key_name
,OBJECT_NAME(fkeys.parent_object_id) referencing_table_name
,COL_NAME(fkeys.parent_object_id, fkeys.parent_column_id) referencing_column_name
,OBJECT_SCHEMA_NAME(fkeys.parent_object_id) referencing_schema_name
,OBJECT_NAME (fkeys.referenced_object_id) referenced_table_name
,COL_NAME(fkeys.referenced_object_id, fkeys.referenced_column_id) 
referenced_column_name
,OBJECT_SCHEMA_NAME(fkeys.referenced_object_id) referenced_schema_name
FROM sys.foreign_key_columns AS fkeys
