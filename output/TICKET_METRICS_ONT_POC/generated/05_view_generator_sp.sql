-- ============================================================================
-- View Generator Stored Procedure
-- Reads ONT_CLASS_MAP and regenerates VW_ONT_* views dynamically
-- ============================================================================

USE SCHEMA _SANDBOX_ONTOLOGY_POC.TICKET_METRICS;

CREATE OR REPLACE PROCEDURE SP_GENERATE_ONTOLOGY_VIEWS()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.12'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'generate_views'
AS
$$
def generate_views(session):
    import json

    # Read class mappings
    maps_df = session.sql("SELECT * FROM ONT_CLASS_MAP").collect()
    
    views_created = []
    union_parts = []
    
    for row in maps_df:
        cls_name = row['CLASS_NAME']
        src_db = row['SOURCE_DATABASE']
        src_schema = row['SOURCE_SCHEMA']
        src_table = row['SOURCE_TABLE']
        filter_col = row.get('FILTER_COL')
        filter_val = row.get('FILTER_VAL')
        id_expr = row['ID_EXPR']
        name_expr = row.get('NAME_EXPR') or id_expr
        
        view_name = f"VW_ONT_{cls_name.upper()}"
        fqn_src = f"{src_db}.{src_schema}.{src_table}"
        
        where_clause = ""
        if filter_col and filter_val:
            where_clause = f"WHERE {filter_col} = '{filter_val}'"
        
        view_sql = f"""
CREATE OR REPLACE VIEW {view_name} AS
SELECT
    {id_expr}::STRING AS ENTITY_ID,
    '{cls_name}' AS ENTITY_TYPE,
    {name_expr}::STRING AS ENTITY_NAME,
    OBJECT_CONSTRUCT(*) AS PROPS
FROM {fqn_src}
{where_clause}
"""
        session.sql(view_sql.strip()).collect()
        views_created.append(view_name)
        
        union_parts.append(
            f"SELECT ENTITY_ID, ENTITY_TYPE, ENTITY_NAME, PROPS FROM {view_name}"
        )
    
    # Create unified view
    if len(union_parts) > 1:
        union_sql = "CREATE OR REPLACE VIEW VW_ONT_ALL_ENTITIES AS\n" + "\nUNION ALL\n".join(union_parts)
        session.sql(union_sql).collect()
        views_created.append("VW_ONT_ALL_ENTITIES")
    
    return json.dumps({"views_created": views_created, "count": len(views_created)})
$$;

-- Run it once to generate initial views
CALL SP_GENERATE_ONTOLOGY_VIEWS();
