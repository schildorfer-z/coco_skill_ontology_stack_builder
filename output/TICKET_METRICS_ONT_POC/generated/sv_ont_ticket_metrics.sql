CREATE OR REPLACE SEMANTIC VIEW _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.SV_ONT_TICKET_METRICS
  COMMENT = 'Ontology abstract layer semantic view exposing VW_ONT_* views for entity-type browsing and ontology-aware queries.'
  tables (
    -- Unified entity view
    ALL_ENTITIES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_ALL_ENTITIES
      primary key (ENTITY_ID)
      comment = 'Unified view of all ontology entities across all 23 classes. Use for type-agnostic entity lookups and cross-class searches.',

    -- Dimension abstract views
    ONT_CRM_ACCOUNT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_CRMACCOUNT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for CRM Account entities. Includes ENTITY_TYPE and PROPS variant column with all properties.',
    ONT_INSTANCE_ACCOUNT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_INSTANCEACCOUNT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Instance Account (Zendesk subdomain) entities.',
    ONT_DATE as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_DATE
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Date dimension entities.',

    -- Fact abstract views
    ONT_AGG_AGENTS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_AGGINSTANCEAGENTSUMMARYMONTHLY
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for monthly agent summary fact entities.',
    ONT_AGG_TICKETS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_AGGINSTANCECHANNELTICKETMONTHLY
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for monthly channel ticket fact entities.',
    ONT_AGG_GUIDE as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_AGGINSTANCEGUIDEMETRICMONTHLY
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for monthly Guide (help center) metric fact entities.',
    ONT_AGG_RBA_CHANNEL as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_AGGINSTANCERBACHANNELMETRICMONTHLY
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for monthly RBA channel metric fact entities. Non-additive metrics.',
    ONT_AGG_RBA_INSTANCE as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_AGGINSTANCERBAMETRICMONTHLY
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for monthly RBA instance metric fact entities. Non-additive metrics.',

    -- Reference/lookup abstract views
    ONT_REFERENCE_LOOKUP as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_REFERENCEACCOUNTLOOKUP
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Reference Account Lookup entities.',
    ONT_GONG_ACCOUNT_MAP as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_TRANSFORMGONGACCOUNTMAP
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Gong Account Map entities.',
    ONT_GONG_OPPORTUNITY_MAP as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_TRANSFORMGONGOPPORTUNITIEMAP
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Gong Opportunity Map entities.',
    ONT_GONG_TAXONOMY as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_TRANSFORMGONGTRACKERTAXONOMY
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Gong Tracker Taxonomy entities.',
    ONT_GONG_EVENT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_UNIFIEDGONGEVENT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Unified Gong Event entities.',
    ONT_USERVOICE_EVENT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_UNIFIEDUSERVOICEEVENT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for Unified Uservoice Event entities.',

    -- EDA ML abstract views
    ONT_CONTACT_ACTIVITY as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLCONTACTACTIVITYDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML Contact Activity Daily Snapshot entities (0 rows — empty source).',
    ONT_CONTACT_SNAPSHOT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLCONTACTDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML Contact Daily Snapshot entities.',
    ONT_CRM_ACCOUNT_SNAPSHOT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLCRMACCOUNTDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML CRM Account Daily Snapshot entities.',
    ONT_INSTANCE_SNAPSHOT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLINSTANCEACCOUNTDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML Instance Account Daily Snapshot entities.',
    ONT_INSTANCE_CHANNEL as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLINSTANCECHANNELMONTHLYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML Instance Channel Monthly Snapshot entities.',
    ONT_INSTANCE_PRODUCT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLINSTANCEPRODUCTDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML Instance Product Daily Snapshot entities.',
    ONT_OPPORTUNITY as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLOPPORTUNITIEDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML Opportunity Daily Snapshot entities.',
    ONT_USER_SNAPSHOT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLUSERDAILYSNAPSHOT
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML User Daily Snapshot entities.',
    ONT_USER_ACCOUNT_MAP as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.VW_ONT_EDAMLUSERACCOUNTMAPPING
      primary key (ENTITY_ID)
      comment = 'Abstract ontology view for EDA ML User Account Mapping entities.',

    -- Resolved relationships
    RELATIONSHIPS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.REL_RESOLVED
      primary key (SRC_ID, DST_ID, REL_NAME)
      comment = 'Resolved relationship view for connecting ontology entities. Join ENTITY_ID from any VW_ONT_* view to SRC_ID or DST_ID here.'
  )
  relationships (
    -- All entities → individual type views (for filtering by type)
    ALL_TO_CRM as ALL_ENTITIES(ENTITY_ID) references ONT_CRM_ACCOUNT(ENTITY_ID),
    ALL_TO_INSTANCE as ALL_ENTITIES(ENTITY_ID) references ONT_INSTANCE_ACCOUNT(ENTITY_ID),
    ALL_TO_DATE as ALL_ENTITIES(ENTITY_ID) references ONT_DATE(ENTITY_ID),
    ALL_TO_AGENTS as ALL_ENTITIES(ENTITY_ID) references ONT_AGG_AGENTS(ENTITY_ID),
    ALL_TO_TICKETS as ALL_ENTITIES(ENTITY_ID) references ONT_AGG_TICKETS(ENTITY_ID),
    ALL_TO_GUIDE as ALL_ENTITIES(ENTITY_ID) references ONT_AGG_GUIDE(ENTITY_ID),
    ALL_TO_RBA_CHANNEL as ALL_ENTITIES(ENTITY_ID) references ONT_AGG_RBA_CHANNEL(ENTITY_ID),
    ALL_TO_RBA_INSTANCE as ALL_ENTITIES(ENTITY_ID) references ONT_AGG_RBA_INSTANCE(ENTITY_ID),

    -- Relationships → entities via SRC_ID / DST_ID
    REL_TO_SRC_CRM as RELATIONSHIPS(SRC_ID) references ONT_CRM_ACCOUNT(ENTITY_ID),
    REL_TO_SRC_INSTANCE as RELATIONSHIPS(SRC_ID) references ONT_INSTANCE_ACCOUNT(ENTITY_ID),
    REL_TO_SRC_AGENTS as RELATIONSHIPS(SRC_ID) references ONT_AGG_AGENTS(ENTITY_ID),
    REL_TO_SRC_TICKETS as RELATIONSHIPS(SRC_ID) references ONT_AGG_TICKETS(ENTITY_ID),
    REL_TO_SRC_GUIDE as RELATIONSHIPS(SRC_ID) references ONT_AGG_GUIDE(ENTITY_ID),
    REL_TO_SRC_RBA_CHANNEL as RELATIONSHIPS(SRC_ID) references ONT_AGG_RBA_CHANNEL(ENTITY_ID),
    REL_TO_SRC_RBA_INSTANCE as RELATIONSHIPS(SRC_ID) references ONT_AGG_RBA_INSTANCE(ENTITY_ID),
    REL_TO_DST_CRM as RELATIONSHIPS(DST_ID) references ONT_CRM_ACCOUNT(ENTITY_ID),
    REL_TO_DST_INSTANCE as RELATIONSHIPS(DST_ID) references ONT_INSTANCE_ACCOUNT(ENTITY_ID),
    REL_TO_DST_DATE as RELATIONSHIPS(DST_ID) references ONT_DATE(ENTITY_ID)
  )
  dimensions (
    -- Universal entity dimensions (all VW_ONT_* views share this schema)
    ALL_ENTITIES.ENTITY_ID as entity_id
      with synonyms = ('node_id', 'id')
      comment = 'Unique entity identifier across all ontology classes.',
    ALL_ENTITIES.ENTITY_TYPE as entity_type
      with synonyms = ('node_type', 'class', 'class_name', 'type')
      comment = 'Ontology class name for the entity (e.g. CrmAccount, InstanceAccount, AggInstanceRbaMetricMonthly). Use to filter by entity type.',
    ALL_ENTITIES.ENTITY_NAME as entity_name
      with synonyms = ('name', 'node_name', 'label')
      comment = 'Human-readable name of the entity.',

    -- Relationship dimensions
    RELATIONSHIPS.REL_NAME as relationship_type
      with synonyms = ('edge_type', 'relation')
      comment = 'Relationship type name (has_crm_account, has_instance_account, belongs_to_date, has_conversation, agginstanceagentdetailmonthly).',
    RELATIONSHIPS.SRC_TYPE as source_type
      comment = 'Entity type of relationship source.',
    RELATIONSHIPS.DST_TYPE as target_type
      comment = 'Entity type of relationship target.',
    RELATIONSHIPS.SRC_NAME as source_name
      comment = 'Name of relationship source entity.',
    RELATIONSHIPS.DST_NAME as target_name
      comment = 'Name of relationship target entity.',
    RELATIONSHIPS.SRC_ID as source_id
      comment = 'ID of relationship source entity.',
    RELATIONSHIPS.DST_ID as target_id
      comment = 'ID of relationship target entity.',

    -- Type-specific entity names for direct access
    ONT_CRM_ACCOUNT.ENTITY_NAME as crm_account_entity_name
      with synonyms = ('crm_name', 'account_name')
      comment = 'CRM Account entity name from ontology view.',
    ONT_INSTANCE_ACCOUNT.ENTITY_NAME as instance_account_entity_name
      with synonyms = ('instance_name', 'subdomain')
      comment = 'Instance Account entity name from ontology view.',
    ONT_DATE.ENTITY_NAME as date_entity_name
      with synonyms = ('date_label', 'month_label')
      comment = 'Date entity name from ontology view.'
  )
  metrics (
    RELATIONSHIPS.WEIGHT as relationship_weight
      comment = 'Edge weight in the relationship (1.0 for standard edges).'
  )
  ai_instructions (
    sql_generation = '
RULES FOR ONTOLOGY SEMANTIC VIEW QUERIES:
1. All VW_ONT_* views share the same schema: ENTITY_ID, ENTITY_TYPE, ENTITY_NAME, PROPS (VARIANT).
2. Use ALL_ENTITIES for cross-class searches. Filter by ENTITY_TYPE to narrow to a specific class.
3. To access detailed properties beyond the base columns, use PROPS:field_name::TYPE syntax on the PROPS variant column.
4. To find relationships between entities, join any VW_ONT_* view ENTITY_ID to RELATIONSHIPS.SRC_ID or DST_ID.
5. Common patterns:
   - "How many CrmAccount entities exist?" → SELECT COUNT(*) FROM ONT_CRM_ACCOUNT
   - "List all entity types" → SELECT DISTINCT ENTITY_TYPE, COUNT(*) FROM ALL_ENTITIES GROUP BY 1
   - "What is connected to entity X?" → SELECT * FROM RELATIONSHIPS WHERE SRC_NAME = X OR DST_NAME = X
   - "Show all facts for CRM account Y" → Join RELATIONSHIPS where DST_NAME = Y AND REL_NAME = has_crm_account
6. Entity counts by type: CrmAccount=181K, InstanceAccount=199K, Date=79, AggInstanceAgentSummaryMonthly=3.8M, AggInstanceChannelTicketMonthly=6.2M, AggInstanceGuideMetricMonthly=2.1M, AggInstanceRbaChannelMetricMonthly=3.6M, AggInstanceRbaMetricMonthly=2.0M, plus 14 more types.
7. The PROPS column contains all source columns as a VARIANT. Access individual fields with PROPS:column_name::data_type.
'
  )
;
