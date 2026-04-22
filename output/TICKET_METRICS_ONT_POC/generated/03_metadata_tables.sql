-- ============================================================================
-- Layer 2: Ontology Metadata Tables for TICKET_METRICS_ONT_POC
-- Generated: 2026-04-15 21:38 UTC
-- ============================================================================

USE SCHEMA _SANDBOX_ONTOLOGY_POC.TICKET_METRICS;

CREATE TABLE IF NOT EXISTS ONT_CLASS (
    CLASS_NAME          STRING NOT NULL PRIMARY KEY,
    PARENT_CLASS_NAME   STRING,
    IS_ABSTRACT         BOOLEAN DEFAULT FALSE,
    DESCRIPTION         STRING,
    ONTOLOGY_NAME       STRING DEFAULT 'TICKET_METRICS_ONT_POC',
    TYPE_CLASS          STRING DEFAULT 'ANALYTICAL',
    CREATED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO ONT_CLASS (CLASS_NAME, PARENT_CLASS_NAME, IS_ABSTRACT, DESCRIPTION, TYPE_CLASS)
SELECT * FROM VALUES
    ('CrmAccount', NULL, FALSE, 'CRM (Salesforce) account dimension. Central entity linking all ticket metrics, agent data, and Gong/UserVoice events. Key attributes: account name, region, market segment, success owner.', 'OPERATIONAL'),
    ('Date', NULL, FALSE, 'Calendar date dimension at monthly grain (MONTH_YEAR). Supports time-based filtering, YoY/MoM comparisons, and quarterly aggregations.', 'OPERATIONAL'),
    ('InstanceAccount', NULL, FALSE, 'Zendesk instance account dimension. Represents a customer''s Zendesk deployment identified by subdomain. Links to CRM account via CRM_ACCOUNT_ID. One CRM account may have multiple instances.', 'OPERATIONAL'),
    ('AggInstanceAgentSummaryMonthly', NULL, FALSE, 'Monthly aggregated agent staffing metrics per Zendesk instance. Includes total active agents, remaining seats, closed tickets, productivity-eligible agents, and role breakdowns (admin/light/regular).', 'OPERATIONAL'),
    ('AggInstanceChannelTicketMonthly', NULL, FALSE, 'Monthly ticket volume metrics by channel group per instance. Additive metrics: created tickets, closed tickets, CSAT counts (good/offered/responded). Supports cross-instance aggregation.', 'OPERATIONAL'),
    ('AggInstanceGuideMetricMonthly', NULL, FALSE, 'Monthly Guide (knowledge base) engagement metrics per instance. Includes KB article views, community post views, published articles, new articles created, comments, and Q&A activity.', 'OPERATIONAL'),
    ('AggInstanceRbaChannelMetricMonthly', NULL, FALSE, 'Monthly RBA (Rules-Based Analysis) ticket metrics broken out by channel. Non-additive metrics (FRT, TTC, ratios) that must NOT be aggregated across instances. Channel dimension: RBA_CHANNEL_GROUP.', 'OPERATIONAL'),
    ('AggInstanceRbaMetricMonthly', NULL, FALSE, 'Monthly RBA ticket metrics at instance level (no channel breakdown). Non-additive metrics: median FRT/TTC in hours, CSAT score, touch ratios, reopened ratio. Must be filtered to single instance.', 'OPERATIONAL'),
    ('ReferenceAccountLookup', NULL, TRUE, 'Simple account ID-to-name lookup reference. Used for Gong and UserVoice event enrichment.', 'ANALYTICAL'),
    ('TransformGongAccountMap', NULL, FALSE, 'Maps Gong conversations to CRM accounts with enriched account attributes (industry, region, segment, health, ARR).', 'OPERATIONAL'),
    ('TransformGongOpportunitieMap', NULL, FALSE, 'Maps Gong conversations to CRM opportunities with opportunity details (type, status, stage, close date, products).', 'OPERATIONAL'),
    ('TransformGongTrackerTaxonomy', NULL, FALSE, 'Hierarchical taxonomy of Gong conversation trackers (up to 4 category levels). Used for topic classification of sales calls.', 'OPERATIONAL'),
    ('UnifiedGongEvent', NULL, FALSE, 'Unified Gong call events with spotlight summaries, key points, next steps, and curated transcripts. Primary key: CONVERSATION_KEY.', 'OPERATIONAL'),
    ('UnifiedUservoiceEvent', NULL, FALSE, 'Unified UserVoice product feedback events combining suggestions and requests. Enriched with CRM account data.', 'OPERATIONAL'),
    ('EdaMlContactActivityDailySnapshot', NULL, FALSE, 'Daily snapshot of Salesforce contact activities (events/tasks). Snapshotted with SOURCE_SNAPSHOT_DATE. Use _BCV view for latest.', 'OPERATIONAL'),
    ('EdaMlContactDailySnapshot', NULL, FALSE, 'Daily snapshot of CRM contacts with engagement scores, web activity, and role information. Use _BCV view for latest snapshot.', 'OPERATIONAL'),
    ('EdaMlCrmAccountDailySnapshot', NULL, FALSE, 'Comprehensive daily CRM account snapshot with 100+ attributes including ARR, health, renewal, territory, engagement metrics. Superset of DIM_CRM_ACCOUNT. Use _BCV for latest.', 'OPERATIONAL'),
    ('EdaMlInstanceAccountDailySnapshot', NULL, FALSE, 'Comprehensive daily Zendesk instance snapshot with 160+ attributes including seat utilization, ticket volumes, CSAT, AR usage, product mix, feature adoption. Use _BCV for latest.', 'OPERATIONAL'),
    ('EdaMlInstanceChannelMonthlySnapshot', NULL, FALSE, 'Monthly channel-level ticket metrics from EDA_ML pipeline. Similar to CONVERGE RBA channel metrics but includes MoM percent changes. Snapshotted.', 'OPERATIONAL'),
    ('EdaMlInstanceProductDailySnapshot', NULL, FALSE, 'Daily product subscription snapshot per instance. Includes product offering, plan, billing, seats, ARR. Use _BCV for latest.', 'OPERATIONAL'),
    ('EdaMlOpportunitieDailySnapshot', NULL, FALSE, 'Daily CRM opportunity snapshot with pipeline details, stage, status, booking ARR by product line. Use _BCV for latest.', 'OPERATIONAL'),
    ('EdaMlUserDailySnapshot', NULL, FALSE, 'Daily CRM user (account executive) snapshot with role, region, segment. Use _BCV for latest. Joins to accounts via EdaMlUserAccountMapping.', 'OPERATIONAL'),
    ('EdaMlUserAccountMapping', NULL, FALSE, 'Maps CRM users (AEs, CSMs) to CRM accounts with role designation. Critical for user-context filtering in benchmark queries. Use _BCV for latest.', 'OPERATIONAL')
AS t(CLASS_NAME, PARENT_CLASS_NAME, IS_ABSTRACT, DESCRIPTION, TYPE_CLASS);

CREATE TABLE IF NOT EXISTS ONT_RELATION_DEF (
    REL_NAME            STRING NOT NULL PRIMARY KEY,
    DOMAIN_CLASS        STRING NOT NULL,
    RANGE_CLASS         STRING NOT NULL,
    CARDINALITY         STRING DEFAULT 'N:N',
    IS_HIERARCHICAL     BOOLEAN DEFAULT FALSE,
    IS_TRANSITIVE       BOOLEAN DEFAULT FALSE,
    INVERSE_REL_NAME    STRING,
    DESCRIPTION         STRING,
    ONTOLOGY_NAME       STRING DEFAULT 'TICKET_METRICS_ONT_POC'
);

INSERT INTO ONT_RELATION_DEF (REL_NAME, DOMAIN_CLASS, RANGE_CLASS, CARDINALITY, IS_HIERARCHICAL, IS_TRANSITIVE, INVERSE_REL_NAME, DESCRIPTION)
SELECT * FROM VALUES
    ('has_crm_account', 'InstanceAccount', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from DIM_INSTANCE_ACCOUNT.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('has_instance_account', 'AggInstanceAgentSummaryMonthly', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_AGENTS_SUMMARY_MONTHLY.INSTANCE_ACCOUNT_ID to DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_ID'),
    ('has_crm_account', 'AggInstanceAgentSummaryMonthly', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_AGENTS_SUMMARY_MONTHLY.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('belongs_to_date', 'AggInstanceAgentSummaryMonthly', 'Date', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_AGENTS_SUMMARY_MONTHLY.MONTH_YEAR to DIM_DATE.MONTH_YEAR'),
    ('has_instance_account', 'AggInstanceChannelTicketMonthly', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY.INSTANCE_ACCOUNT_ID to DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_ID'),
    ('has_crm_account', 'AggInstanceChannelTicketMonthly', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('belongs_to_date', 'AggInstanceChannelTicketMonthly', 'Date', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY.MONTH_YEAR to DIM_DATE.MONTH_YEAR'),
    ('has_instance_account', 'AggInstanceGuideMetricMonthly', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_GUIDE_METRICS_MONTHLY.INSTANCE_ACCOUNT_ID to DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_ID'),
    ('has_crm_account', 'AggInstanceGuideMetricMonthly', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_GUIDE_METRICS_MONTHLY.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('belongs_to_date', 'AggInstanceGuideMetricMonthly', 'Date', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_GUIDE_METRICS_MONTHLY.MONTH_YEAR to DIM_DATE.MONTH_YEAR'),
    ('has_instance_account', 'AggInstanceRbaChannelMetricMonthly', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_RBA_CHANNEL_METRICS_MONTHLY.INSTANCE_ACCOUNT_ID to DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_ID'),
    ('has_crm_account', 'AggInstanceRbaChannelMetricMonthly', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_RBA_CHANNEL_METRICS_MONTHLY.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('belongs_to_date', 'AggInstanceRbaChannelMetricMonthly', 'Date', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_RBA_CHANNEL_METRICS_MONTHLY.MONTH_YEAR to DIM_DATE.MONTH_YEAR'),
    ('has_instance_account', 'AggInstanceRbaMetricMonthly', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_RBA_METRICS_MONTHLY.INSTANCE_ACCOUNT_ID to DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_ID'),
    ('has_crm_account', 'AggInstanceRbaMetricMonthly', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_RBA_METRICS_MONTHLY.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('belongs_to_date', 'AggInstanceRbaMetricMonthly', 'Date', 'N:1', FALSE, FALSE, NULL, 'FK relationship from FACT_AGG_INSTANCE_RBA_METRICS_MONTHLY.MONTH_YEAR to DIM_DATE.MONTH_YEAR'),
    ('has_conversation', 'TransformGongAccountMap', 'UnifiedGongEvent', 'N:1', FALSE, FALSE, NULL, 'FK relationship from TRANSFORM_GONG_ACCOUNTS_MAP.CONVERSATION_KEY to UNIFIED_GONG_EVENTS.CONVERSATION_KEY'),
    ('has_crm_account', 'TransformGongAccountMap', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from TRANSFORM_GONG_ACCOUNTS_MAP.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('has_conversation', 'TransformGongOpportunitieMap', 'UnifiedGongEvent', 'N:1', FALSE, FALSE, NULL, 'FK relationship from TRANSFORM_GONG_OPPORTUNITIES_MAP.CONVERSATION_KEY to UNIFIED_GONG_EVENTS.CONVERSATION_KEY'),
    ('has_crm_account', 'TransformGongOpportunitieMap', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from TRANSFORM_GONG_OPPORTUNITIES_MAP.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('has_crm_account', 'UnifiedUservoiceEvent', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'FK relationship from UNIFIED_USERVOICE_EVENTS.CRM_ACCOUNT_ID to DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID'),
    ('agginstanceagentdetailmonthly', 'InstanceAccount', 'CrmAccount', 'N:N', FALSE, FALSE, NULL, 'Many-to-many relationship via junction table FACT_AGG_INSTANCE_AGENTS_DETAIL_MONTHLY'),
    ('has_crm_account', 'EdaMlContactActivityDailySnapshot', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'EDA_ML Contact Activity links to CRM accounts via CRM_ACCOUNT_ID'),
    ('has_crm_account', 'EdaMlContactDailySnapshot', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'EDA_ML Contact links to CRM accounts via CRM_ACCOUNT_ID'),
    ('maps_user_to_account', 'EdaMlUserAccountMapping', 'CrmAccount', 'N:N', FALSE, FALSE, NULL, 'User-Account mapping links CRM users to CRM accounts. Critical for user-context filtering.'),
    ('maps_user_to_account', 'EdaMlUserAccountMapping', 'EdaMlUserDailySnapshot', 'N:1', FALSE, FALSE, NULL, 'User-Account mapping links to CRM users from daily snapshot'),
    ('has_instance_account', 'EdaMlInstanceProductDailySnapshot', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'EDA_ML Instance Products links to instance accounts via INSTANCE_ACCOUNT_ID'),
    ('snapshot_of_crm_account', 'EdaMlCrmAccountDailySnapshot', 'CrmAccount', 'N:1', FALSE, FALSE, NULL, 'EDA_ML CRM Account Snapshot is a detailed daily version of the CRM Account dimension'),
    ('snapshot_of_instance', 'EdaMlInstanceAccountDailySnapshot', 'InstanceAccount', 'N:1', FALSE, FALSE, NULL, 'EDA_ML Instance Account Snapshot is a detailed daily version of the Instance Account dimension')
AS t(REL_NAME, DOMAIN_CLASS, RANGE_CLASS, CARDINALITY, IS_HIERARCHICAL, IS_TRANSITIVE, INVERSE_REL_NAME, DESCRIPTION);

CREATE TABLE IF NOT EXISTS ONT_CLASS_MAP (
    MAP_ID              STRING DEFAULT UUID_STRING() PRIMARY KEY,
    CLASS_NAME          STRING NOT NULL,
    SOURCE_DATABASE     STRING NOT NULL,
    SOURCE_SCHEMA       STRING NOT NULL,
    SOURCE_TABLE        STRING NOT NULL,
    FILTER_COL          STRING,
    FILTER_VAL          STRING,
    ID_EXPR             STRING NOT NULL,
    NAME_EXPR           STRING,
    SUBTYPE_EXPR        STRING,
    ONTOLOGY_NAME       STRING DEFAULT 'TICKET_METRICS_ONT_POC'
);

INSERT INTO ONT_CLASS_MAP (CLASS_NAME, SOURCE_DATABASE, SOURCE_SCHEMA, SOURCE_TABLE, FILTER_COL, FILTER_VAL, ID_EXPR, NAME_EXPR)
SELECT * FROM VALUES
    ('CrmAccount', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'CrmAccount', 'NODE_ID', 'NAME'),
    ('Date', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'Date', 'NODE_ID', 'NAME'),
    ('InstanceAccount', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'InstanceAccount', 'NODE_ID', 'NAME'),
    ('AggInstanceAgentSummaryMonthly', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'AggInstanceAgentSummaryMonthly', 'NODE_ID', 'NAME'),
    ('AggInstanceChannelTicketMonthly', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'AggInstanceChannelTicketMonthly', 'NODE_ID', 'NAME'),
    ('AggInstanceGuideMetricMonthly', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'AggInstanceGuideMetricMonthly', 'NODE_ID', 'NAME'),
    ('AggInstanceRbaChannelMetricMonthly', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'AggInstanceRbaChannelMetricMonthly', 'NODE_ID', 'NAME'),
    ('AggInstanceRbaMetricMonthly', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'AggInstanceRbaMetricMonthly', 'NODE_ID', 'NAME'),
    ('ReferenceAccountLookup', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'ReferenceAccountLookup', 'NODE_ID', 'NAME'),
    ('TransformGongAccountMap', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'TransformGongAccountMap', 'NODE_ID', 'NAME'),
    ('TransformGongOpportunitieMap', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'TransformGongOpportunitieMap', 'NODE_ID', 'NAME'),
    ('TransformGongTrackerTaxonomy', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'TransformGongTrackerTaxonomy', 'NODE_ID', 'NAME'),
    ('UnifiedGongEvent', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'UnifiedGongEvent', 'NODE_ID', 'NAME'),
    ('UnifiedUservoiceEvent', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'UnifiedUservoiceEvent', 'NODE_ID', 'NAME'),
    ('EdaMlContactActivityDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlContactActivityDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlContactDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlContactDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlCrmAccountDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlCrmAccountDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlInstanceAccountDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlInstanceAccountDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlInstanceChannelMonthlySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlInstanceChannelMonthlySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlInstanceProductDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlInstanceProductDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlOpportunitieDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlOpportunitieDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlUserDailySnapshot', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlUserDailySnapshot', 'NODE_ID', 'NAME'),
    ('EdaMlUserAccountMapping', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_NODE', 'NODE_TYPE', 'EdaMlUserAccountMapping', 'NODE_ID', 'NAME')
AS t(CLASS_NAME, SOURCE_DATABASE, SOURCE_SCHEMA, SOURCE_TABLE, FILTER_COL, FILTER_VAL, ID_EXPR, NAME_EXPR);

CREATE TABLE IF NOT EXISTS ONT_REL_MAP (
    MAP_ID              STRING DEFAULT UUID_STRING() PRIMARY KEY,
    REL_NAME            STRING NOT NULL,
    SOURCE_DATABASE     STRING NOT NULL,
    SOURCE_SCHEMA       STRING NOT NULL,
    SOURCE_TABLE        STRING NOT NULL,
    SRC_ID_EXPR         STRING NOT NULL,
    DST_ID_EXPR         STRING NOT NULL,
    FILTER_COL          STRING,
    FILTER_VAL          STRING,
    ONTOLOGY_NAME       STRING DEFAULT 'TICKET_METRICS_ONT_POC'
);

INSERT INTO ONT_REL_MAP (REL_NAME, SOURCE_DATABASE, SOURCE_SCHEMA, SOURCE_TABLE, SRC_ID_EXPR, DST_ID_EXPR, FILTER_COL, FILTER_VAL)
SELECT * FROM VALUES
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('has_instance_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_instance_account'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('belongs_to_date', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'belongs_to_date'),
    ('has_instance_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_instance_account'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('belongs_to_date', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'belongs_to_date'),
    ('has_instance_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_instance_account'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('belongs_to_date', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'belongs_to_date'),
    ('has_instance_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_instance_account'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('belongs_to_date', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'belongs_to_date'),
    ('has_instance_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_instance_account'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('belongs_to_date', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'belongs_to_date'),
    ('has_conversation', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_conversation'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('has_conversation', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_conversation'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('has_crm_account', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'has_crm_account'),
    ('agginstanceagentdetailmonthly', '_SANDBOX_ONTOLOGY_POC', 'TICKET_METRICS', 'KG_EDGE', 'SRC_ID', 'DST_ID', 'EDGE_TYPE', 'agginstanceagentdetailmonthly')
AS t(REL_NAME, SOURCE_DATABASE, SOURCE_SCHEMA, SOURCE_TABLE, SRC_ID_EXPR, DST_ID_EXPR, FILTER_COL, FILTER_VAL);

-- Ontology Registry
CREATE TABLE IF NOT EXISTS ONT_ONTOLOGY (
    ONTOLOGY_NAME       STRING PRIMARY KEY,
    DESCRIPTION         STRING,
    VERSION             STRING,
    DEFAULT_SCHEMA      STRING,
    CREATED_BY          STRING,
    CREATED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    IS_ACTIVE           BOOLEAN DEFAULT TRUE
);

INSERT INTO ONT_ONTOLOGY (ONTOLOGY_NAME, VERSION, DESCRIPTION, DEFAULT_SCHEMA, CREATED_BY, IS_ACTIVE)
VALUES ('TICKET_METRICS_ONT_POC', '1.0.0', 'TICKET_METRICS_ONT_POC Ontology', 'TICKET_METRICS', 'SYSTEM', TRUE);

-- Object Source Mappings
CREATE TABLE IF NOT EXISTS ONT_OBJECT_SOURCE (
    ONTOLOGY_NAME       STRING,
    OBJ_TYPE            STRING,
    SOURCE_TABLE        STRING,
    FILTER_SQL          STRING,
    MAPPING             VARIANT,
    PRIMARY KEY (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE)
);

INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'CrmAccount', 'KG_NODE', 'NODE_TYPE = ''''CRMACCOUNT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_NAME": "crm_account_name", "PROPS:CRM_OWNER_NAME": "crm_owner_name", "PROPS:CRM_REGION": "crm_region", "PROPS:CRM_MARKET_SEGMENT": "crm_market_segment", "PROPS:CRM_SUCCESS_OWNER_NAME": "crm_success_owner_name"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'Date', 'KG_NODE', 'NODE_TYPE = ''''DATE''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:MONTH_DATE": "month_date", "PROPS:MONTH_YEAR_NUMBER": "month_year_number", "PROPS:CALENDAR_YEAR": "calendar_year", "PROPS:CALENDAR_QUARTER": "calendar_quarter", "PROPS:CALENDAR_MONTH": "calendar_month", "PROPS:MONTH_NAME": "month_name", "PROPS:YEAR_QUARTER": "year_quarter", "PROPS:YEAR_MONTH_LABEL": "year_month_label"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'InstanceAccount', 'KG_NODE', 'NODE_TYPE = ''''INSTANCEACCOUNT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:INSTANCE_ACCOUNT_SUBDOMAIN": "instance_account_subdomain"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'AggInstanceAgentSummaryMonthly', 'KG_NODE', 'NODE_TYPE = ''''AGGINSTANCEAGENTSUMMARYMONTHLY''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:TOTAL_ACTIVE_AGENTS": "total_active_agents", "PROPS:REMAINING_AGENTS": "remaining_agents", "PROPS:TOTAL_CLOSED_TICKETS": "total_closed_tickets", "PROPS:ACTIVE_AGENTS_FOR_PRODUCTIVITY": "active_agents_for_productivity", "PROPS:NUM_AGENTS_ADMIN": "num_agents_admin", "PROPS:NUM_AGENTS_LIGHT": "num_agents_light", "PROPS:NUM_AGENTS_REGULAR": "num_agents_regular"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'AggInstanceChannelTicketMonthly', 'KG_NODE', 'NODE_TYPE = ''''AGGINSTANCECHANNELTICKETMONTHLY''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:COUNT_CREATED_TICKETS": "count_created_tickets", "PROPS:COUNT_CLOSED_TICKETS": "count_closed_tickets", "PROPS:COUNT_CSAT_GOOD": "count_csat_good", "PROPS:COUNT_CSAT_OFFERED": "count_csat_offered", "PROPS:COUNT_CSAT_RESPONDED": "count_csat_responded"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'AggInstanceGuideMetricMonthly', 'KG_NODE', 'NODE_TYPE = ''''AGGINSTANCEGUIDEMETRICMONTHLY''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:NEW_KB_ARTICLE_VIEWS": "new_kb_article_views", "PROPS:NEW_COMMUNITY_POST_VIEWS": "new_community_post_views", "PROPS:NUM_PUBLISHED_ARTICLES": "num_published_articles", "PROPS:NEW_KB_ARTICLES_CREATED": "new_kb_articles_created", "PROPS:NEW_KB_COMMENTS": "new_kb_comments", "PROPS:NEW_COMMUNITY_POST_ANSWERS": "new_community_post_answers", "PROPS:NEW_COMMUNITY_POST_QUESTIONS": "new_community_post_questions"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'AggInstanceRbaChannelMetricMonthly', 'KG_NODE', 'NODE_TYPE = ''''AGGINSTANCERBACHANNELMETRICMONTHLY''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:RBA_CREATED_TICKETS": "rba_created_tickets", "PROPS:RBA_SOLVED_TICKETS": "rba_solved_tickets", "PROPS:RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS": "rba_unique_agents_with_solved_tickets", "PROPS:RBA_SOLVED_TICKETS_PER_AGENT": "rba_solved_tickets_per_agent", "PROPS:RBA_ZERO_TOUCH_TICKET_RATIO": "rba_zero_touch_ticket_ratio", "PROPS:RBA_ONE_TOUCH_TICKET_RATIO": "rba_one_touch_ticket_ratio", "PROPS:RBA_REOPENED_TICKET_RATIO": "rba_reopened_ticket_ratio", "PROPS:RBA_ONE_PLUS_TOUCH_TICKETS": "rba_one_plus_touch_tickets", "PROPS:RBA_FRT_MEDIAN_HOURS": "rba_frt_median_hours", "PROPS:RBA_TTC_MEDIAN_HOURS": "rba_ttc_median_hours", "PROPS:RBA_CSAT_SCORE": "rba_csat_score", "PROPS:RBA_CSAT_RESPONSE_RATE": "rba_csat_response_rate"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'AggInstanceRbaMetricMonthly', 'KG_NODE', 'NODE_TYPE = ''''AGGINSTANCERBAMETRICMONTHLY''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:RBA_CREATED_TICKETS": "rba_created_tickets", "PROPS:RBA_SOLVED_TICKETS": "rba_solved_tickets", "PROPS:RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS": "rba_unique_agents_with_solved_tickets", "PROPS:RBA_SOLVED_TICKETS_PER_AGENT": "rba_solved_tickets_per_agent", "PROPS:RBA_ZERO_TOUCH_TICKET_RATIO": "rba_zero_touch_ticket_ratio", "PROPS:RBA_ONE_TOUCH_TICKET_RATIO": "rba_one_touch_ticket_ratio", "PROPS:RBA_REOPENED_TICKET_RATIO": "rba_reopened_ticket_ratio", "PROPS:RBA_ONE_PLUS_TOUCH_TICKETS": "rba_one_plus_touch_tickets", "PROPS:RBA_FRT_MEDIAN_HOURS": "rba_frt_median_hours", "PROPS:RBA_TTC_MEDIAN_HOURS": "rba_ttc_median_hours", "PROPS:RBA_CSAT_SCORE": "rba_csat_score", "PROPS:RBA_CSAT_RESPONSE_RATE": "rba_csat_response_rate"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'ReferenceAccountLookup', 'KG_NODE', 'NODE_TYPE = ''''REFERENCEACCOUNTLOOKUP''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:ACCOUNT_NAME": "account_name"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'TransformGongAccountMap', 'KG_NODE', 'NODE_TYPE = ''''TRANSFORMGONGACCOUNTMAP''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_NAME": "crm_account_name", "PROPS:PARTNER_LEVEL_C": "partner_level_c", "PROPS:COMPETITOR_C": "competitor_c", "PROPS:TOP_COMPETITOR_C": "top_competitor_c", "PROPS:CRM_NET_ARR_USD": "crm_net_arr_usd", "PROPS:CRM_ACCOUNT_TYPE": "crm_account_type", "PROPS:CRM_HEALTH_STATUS": "crm_health_status", "PROPS:CRM_INDUSTRY": "crm_industry", "PROPS:CRM_SUB_INDUSTRY": "crm_sub_industry", "PROPS:CRM_REGION": "crm_region", "PROPS:CRM_SUB_REGION": "crm_sub_region", "PROPS:CRM_MARKET_SEGMENT": "crm_market_segment", "PROPS:CRM_MARKET_SUPER_SEGMENT": "crm_market_super_segment"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'TransformGongOpportunitieMap', 'KG_NODE', 'NODE_TYPE = ''''TRANSFORMGONGOPPORTUNITIEMAP''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_NAME": "crm_account_name", "PROPS:CRM_OPPORTUNITY_ID": "crm_opportunity_id", "PROPS:OPPORTUNITY_NAME": "opportunity_name", "PROPS:OPPORTUNITY_TYPE": "opportunity_type", "PROPS:OPPORTUNITY_STATUS": "opportunity_status", "PROPS:STAGE_2_PLUS_DATE_C": "stage_2_plus_date_c", "PROPS:CLOSEDATE": "closedate", "PROPS:PRODUCT_LIST": "product_list"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'TransformGongTrackerTaxonomy', 'KG_NODE', 'NODE_TYPE = ''''TRANSFORMGONGTRACKERTAXONOMY''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:TRACKER_ARRAY": "tracker_array", "PROPS:CAT1": "cat1", "PROPS:CAT2": "cat2", "PROPS:CAT3": "cat3", "PROPS:CAT4": "cat4"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'UnifiedGongEvent', 'KG_NODE', 'NODE_TYPE = ''''UNIFIEDGONGEVENT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CALL_ID": "call_id", "PROPS:CALL_DATE": "call_date", "PROPS:TITLE": "title", "PROPS:CALL_SPOTLIGHT_BRIEF": "call_spotlight_brief", "PROPS:CALL_SPOTLIGHT_NEXT_STEPS": "call_spotlight_next_steps", "PROPS:CALL_SPOTLIGHT_KEY_POINTS": "call_spotlight_key_points", "PROPS:CALL_SPOTLIGHT": "call_spotlight", "PROPS:TRANSCRIPT": "transcript", "PROPS:CALL_SPOTLIGHT_OVERVIEW": "call_spotlight_overview", "PROPS:CALL_TRANSCRIPT_CURATED": "call_transcript_curated"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'UnifiedUservoiceEvent', 'KG_NODE', 'NODE_TYPE = ''''UNIFIEDUSERVOICEEVENT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:FORUM_NAME": "forum_name", "PROPS:CATEGORY_NAME": "category_name", "PROPS:SUGGESTION_NAME": "suggestion_name", "PROPS:SUGGESTION_BODY": "suggestion_body", "PROPS:SUGGESTION_CREATED_AT": "suggestion_created_at", "PROPS:SUGGESTION_UPDATED_AT": "suggestion_updated_at", "PROPS:SUGGESTION_STATE": "suggestion_state", "PROPS:REQUEST_BODY": "request_body", "PROPS:REQUEST_CREATED_AT": "request_created_at", "PROPS:REQUEST_UPDATED_AT": "request_updated_at", "PROPS:CRM_ACCOUNT_NAME": "crm_account_name", "PROPS:CRM_NET_ARR_USD": "crm_net_arr_usd", "PROPS:CRM_ACCOUNT_TYPE": "crm_account_type", "PROPS:CRM_HEALTH_STATUS": "crm_health_status", "PROPS:CRM_INDUSTRY": "crm_industry", "PROPS:CRM_SUB_INDUSTRY": "crm_sub_industry", "PROPS:CRM_REGION": "crm_region", "PROPS:CRM_SUB_REGION": "crm_sub_region", "PROPS:CRM_MARKET_SEGMENT": "crm_market_segment", "PROPS:CRM_MARKET_SUPER_SEGMENT": "crm_market_super_segment", "PROPS:REQUEST_OVERVIEW": "request_overview"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlContactActivityDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLCONTACTACTIVITYDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_ID": "crm_account_id", "PROPS:ACTIVITY_SUBJECT": "activity_subject", "PROPS:CONTACT_EMAIL": "contact_email", "PROPS:ACTIVITY_CATEGORY": "activity_category", "PROPS:ACTIVITY_TYPE": "activity_type", "PROPS:ACTIVITY_ZENDESK_DIVISION": "activity_zendesk_division", "PROPS:ACTIVITY_ZENDESK_USER": "activity_zendesk_user"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlContactDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLCONTACTDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_ID": "crm_account_id", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:CONTACT_ID": "contact_id", "PROPS:CONTACT_LAST_HUMAN_TOUCH": "contact_last_human_touch", "PROPS:CONTACT_LAST_SALES_TOUCH_DATE_TIME": "contact_last_sales_touch_date_time", "PROPS:CONTACT_ROLE": "contact_role", "PROPS:CONTACT_JOB_ROLE": "contact_job_role", "PROPS:CONTACT_INTENT_SCORE_6_SENSE": "contact_intent_score_6_sense", "PROPS:CONTACT_TITLE": "contact_title", "PROPS:CONTACT_EMAIL": "contact_email", "PROPS:CONTACT_PHONE_NUMBER": "contact_phone_number", "PROPS:CONTACT_NAME": "contact_name", "PROPS:CONTACT_CREATED_DATE": "contact_created_date", "PROPS:CONTACT_LEAD_SOURCE": "contact_lead_source", "PROPS:NUM_WEB_VISITS_L30D": "num_web_visits_l30d", "PROPS:NUM_WEB_FORMS_L30D": "num_web_forms_l30d", "PROPS:NUM_OPENED_EMAILS_L30D": "num_opened_emails_l30d"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlCrmAccountDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLCRMACCOUNTDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:CRM_ACCOUNT_ID": "crm_account_id", "PROPS:CRM_OWNER_ID": "crm_owner_id", "PROPS:CRM_PRIMARY_OWNER_NAME": "crm_primary_owner_name", "PROPS:CRM_INDUSTRY": "crm_industry", "PROPS:CRM_SUB_INDUSTRY": "crm_sub_industry", "PROPS:CRM_REGION": "crm_region", "PROPS:CRM_SUB_REGION": "crm_sub_region", "PROPS:PRO_FORMA_MARKET_SEGMENT": "pro_forma_market_segment", "PROPS:PRO_FORMA_MARKET_SUBSEGMENT": "pro_forma_market_subsegment", "PROPS:PRO_FORMA_MARKET_SUPER_SEGMENT": "pro_forma_market_super_segment", "PROPS:CRM_ACCOUNT_NAME": "crm_account_name", "PROPS:CRM_HEALTH_STATUS": "crm_health_status", "PROPS:CRM_DATE_BECAME_CUSTOMER": "crm_date_became_customer", "PROPS:CRM_PARENT_ID": "crm_parent_id", "PROPS:CRM_ACCOUNT_TYPE": "crm_account_type", "PROPS:CRM_NET_ARR_USD": "crm_net_arr_usd", "PROPS:CRM_NEXT_RENEWAL_DATE": "crm_next_renewal_date", "PROPS:CRM_NUMBER_OF_EMPLOYEES": "crm_number_of_employees", "PROPS:CRM_REVENUE": "crm_revenue"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlInstanceAccountDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLINSTANCEACCOUNTDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:INSTANCE_ACCOUNT_ID": "instance_account_id", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:CRM_ACCOUNT_ID": "crm_account_id", "PROPS:INSTANCE_ACCOUNT_SUBDOMAIN": "instance_account_subdomain", "PROPS:INSTANCE_ACCOUNT_NAME": "instance_account_name", "PROPS:INSTANCE_ACCOUNT_ARR_USD": "instance_account_arr_usd", "PROPS:SEATS_CAPACITY": "seats_capacity", "PROPS:SEATS_OCCUPIED": "seats_occupied", "PROPS:SEAT_UTILIZATION": "seat_utilization", "PROPS:ACTIVE_AGENTS_L30D": "active_agents_l30d", "PROPS:CSAT_SCORE": "csat_score", "PROPS:NEW_TICKETS_L30D": "new_tickets_l30d", "PROPS:SOLVED_TICKETS_L30D": "solved_tickets_l30d"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlInstanceChannelMonthlySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLINSTANCECHANNELMONTHLYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:MONTH_YEAR": "month_year", "PROPS:INSTANCE_ACCOUNT_ID": "instance_account_id", "PROPS:CHANNEL_GROUP": "channel_group", "PROPS:RBA_CREATED_TICKETS": "rba_created_tickets", "PROPS:RBA_SOLVED_TICKETS": "rba_solved_tickets", "PROPS:RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS": "rba_unique_agents_with_solved_tickets", "PROPS:RBA_SOLVED_TICKETS_PER_AGENT": "rba_solved_tickets_per_agent", "PROPS:RBA_ZERO_TOUCH_TICKET_RATIO": "rba_zero_touch_ticket_ratio", "PROPS:RBA_ONE_TOUCH_TICKET_RATIO": "rba_one_touch_ticket_ratio", "PROPS:RBA_REOPENED_TICKET_RATIO": "rba_reopened_ticket_ratio", "PROPS:RBA_FRT_MEDIAN_HOURS": "rba_frt_median_hours", "PROPS:RBA_TTR_MEDIAN_HOURS": "rba_ttr_median_hours", "PROPS:RBA_CSAT_SCORE": "rba_csat_score", "PROPS:RBA_CSAT_RESPONSE_RATE": "rba_csat_response_rate"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlInstanceProductDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLINSTANCEPRODUCTDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_ID": "crm_account_id", "PROPS:INSTANCE_ACCOUNT_ID": "instance_account_id", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:PRODUCT_OFFERING": "product_offering", "PROPS:PRODUCT_OFFERING_GROUPED": "product_offering_grouped", "PROPS:PRODUCT_PLAN": "product_plan", "PROPS:NET_ARR_USD": "net_arr_usd", "PROPS:SEATS": "seats", "PROPS:QUANTITY": "quantity"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlOpportunitieDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLOPPORTUNITIEDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_ACCOUNT_ID": "crm_account_id", "PROPS:CRM_OPPORTUNITY_ID": "crm_opportunity_id", "PROPS:OPPORTUNITY_NAME": "opportunity_name", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:OPPORTUNITY_CREATED_DATE": "opportunity_created_date", "PROPS:OPPORTUNITY_CLOSE_DATE": "opportunity_close_date", "PROPS:OPPORTUNITY_TYPE": "opportunity_type", "PROPS:OPPORTUNITY_STATUS": "opportunity_status", "PROPS:OPPORTUNITY_STAGE_NAME": "opportunity_stage_name", "PROPS:OPPORTUNITY_BOOKING_ARR_USD": "opportunity_booking_arr_usd"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlUserDailySnapshot', 'KG_NODE', 'NODE_TYPE = ''''EDAMLUSERDAILYSNAPSHOT''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:CRM_USER_ID": "crm_user_id", "PROPS:SOURCE_SNAPSHOT_DATE": "source_snapshot_date", "PROPS:USER_NAME": "user_name", "PROPS:USER_EMAIL": "user_email", "PROPS:USER_MARKET_SEGMENT": "user_market_segment", "PROPS:USER_REGION": "user_region", "PROPS:USER_SUB_REGION": "user_sub_region", "PROPS:MANAGER_1_EMAIL": "manager_1_email"}');
INSERT INTO ONT_OBJECT_SOURCE (ONTOLOGY_NAME, OBJ_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'EdaMlUserAccountMapping', 'KG_NODE', 'NODE_TYPE = ''''EDAMLUSERACCOUNTMAPPING''''', PARSE_JSON('{"NODE_ID": "id", "NAME": "name", "PROPS:USER_NAME": "user_name", "PROPS:USER_EMAIL": "user_email", "PROPS:USER_ROLE_ON_ACCOUNT": "user_role_on_account"}');

-- Link Source Mappings
CREATE TABLE IF NOT EXISTS ONT_LINK_SOURCE (
    ONTOLOGY_NAME       STRING,
    LINK_TYPE           STRING,
    SOURCE_TABLE        STRING,
    FILTER_SQL          STRING,
    MAPPING             VARIANT,
    PRIMARY KEY (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE)
);

INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_instance_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_instance_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'belongs_to_date', 'KG_EDGE', 'EDGE_TYPE = ''''belongs_to_date''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_instance_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_instance_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'belongs_to_date', 'KG_EDGE', 'EDGE_TYPE = ''''belongs_to_date''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_instance_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_instance_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'belongs_to_date', 'KG_EDGE', 'EDGE_TYPE = ''''belongs_to_date''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_instance_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_instance_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'belongs_to_date', 'KG_EDGE', 'EDGE_TYPE = ''''belongs_to_date''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_instance_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_instance_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'belongs_to_date', 'KG_EDGE', 'EDGE_TYPE = ''''belongs_to_date''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_conversation', 'KG_EDGE', 'EDGE_TYPE = ''''has_conversation''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_conversation', 'KG_EDGE', 'EDGE_TYPE = ''''has_conversation''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'has_crm_account', 'KG_EDGE', 'EDGE_TYPE = ''''has_crm_account''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');
INSERT INTO ONT_LINK_SOURCE (ONTOLOGY_NAME, LINK_TYPE, SOURCE_TABLE, FILTER_SQL, MAPPING)
SELECT 'TICKET_METRICS_ONT_POC', 'agginstanceagentdetailmonthly', 'KG_EDGE', 'EDGE_TYPE = ''''agginstanceagentdetailmonthly''''', PARSE_JSON('{"SRC_ID": "src_id", "DST_ID": "dst_id"}');

-- Shared Properties
CREATE TABLE IF NOT EXISTS ONT_SHARED_PROPERTY (
    SHARED_PROP_NAME    STRING PRIMARY KEY,
    BASE_TYPE           STRING,
    DESCRIPTION         STRING,
    DEFAULT_FORMAT      STRING
);

INSERT INTO ONT_SHARED_PROPERTY (SHARED_PROP_NAME, BASE_TYPE, DESCRIPTION) VALUES
    ('crm_account_name', 'STRING', 'Shared property crm_account_name'),
    ('crm_region', 'STRING', 'Shared property crm_region'),
    ('crm_market_segment', 'STRING', 'Shared property crm_market_segment'),
    ('instance_account_subdomain', 'STRING', 'Shared property instance_account_subdomain'),
    ('rba_created_tickets', 'NUMBER', 'Shared property rba_created_tickets'),
    ('rba_solved_tickets', 'NUMBER', 'Shared property rba_solved_tickets'),
    ('rba_unique_agents_with_solved_tickets', 'NUMBER', 'Shared property rba_unique_agents_with_solved_tickets'),
    ('rba_solved_tickets_per_agent', 'NUMBER', 'Shared property rba_solved_tickets_per_agent'),
    ('rba_zero_touch_ticket_ratio', 'NUMBER', 'Shared property rba_zero_touch_ticket_ratio'),
    ('rba_one_touch_ticket_ratio', 'NUMBER', 'Shared property rba_one_touch_ticket_ratio'),
    ('rba_reopened_ticket_ratio', 'NUMBER', 'Shared property rba_reopened_ticket_ratio'),
    ('rba_one_plus_touch_tickets', 'NUMBER', 'Shared property rba_one_plus_touch_tickets'),
    ('rba_frt_median_hours', 'NUMBER', 'Shared property rba_frt_median_hours'),
    ('rba_ttc_median_hours', 'NUMBER', 'Shared property rba_ttc_median_hours'),
    ('rba_csat_score', 'NUMBER', 'Shared property rba_csat_score'),
    ('rba_csat_response_rate', 'NUMBER', 'Shared property rba_csat_response_rate'),
    ('crm_net_arr_usd', 'NUMBER', 'Shared property crm_net_arr_usd'),
    ('crm_account_type', 'STRING', 'Shared property crm_account_type'),
    ('crm_health_status', 'STRING', 'Shared property crm_health_status'),
    ('crm_industry', 'STRING', 'Shared property crm_industry'),
    ('crm_sub_industry', 'STRING', 'Shared property crm_sub_industry'),
    ('crm_sub_region', 'STRING', 'Shared property crm_sub_region'),
    ('crm_market_super_segment', 'STRING', 'Shared property crm_market_super_segment'),
    ('crm_opportunity_id', 'STRING', 'Shared property crm_opportunity_id'),
    ('opportunity_name', 'STRING', 'Shared property opportunity_name'),
    ('opportunity_type', 'STRING', 'Shared property opportunity_type'),
    ('opportunity_status', 'STRING', 'Shared property opportunity_status'),
    ('crm_account_id', 'STRING', 'Shared property crm_account_id'),
    ('contact_email', 'STRING', 'Shared property contact_email'),
    ('source_snapshot_date', 'DATE', 'Shared property source_snapshot_date'),
    ('instance_account_id', 'NUMBER', 'Shared property instance_account_id'),
    ('user_name', 'STRING', 'Shared property user_name'),
    ('user_email', 'STRING', 'Shared property user_email');

-- Property Definitions
CREATE TABLE IF NOT EXISTS ONT_PROPERTY (
    CLASS_NAME          STRING,
    PROP_NAME           STRING,
    DATA_TYPE           STRING,
    SHARED_PROP_NAME    STRING,
    IS_REQUIRED         BOOLEAN DEFAULT FALSE,
    IS_INDEXED          BOOLEAN DEFAULT FALSE,
    DESCRIPTION         STRING,
    PRIMARY KEY (CLASS_NAME, PROP_NAME)
);

INSERT INTO ONT_PROPERTY (CLASS_NAME, PROP_NAME, DATA_TYPE, SHARED_PROP_NAME, IS_REQUIRED, IS_INDEXED, DESCRIPTION) VALUES
    ('CrmAccount', 'crm_account_name', 'STRING', 'crm_account_name', FALSE, FALSE, 'CRM_ACCOUNT_NAME of CrmAccount'),
    ('CrmAccount', 'crm_owner_name', 'STRING', NULL, FALSE, FALSE, 'CRM_OWNER_NAME of CrmAccount'),
    ('CrmAccount', 'crm_region', 'STRING', 'crm_region', FALSE, FALSE, 'CRM_REGION of CrmAccount'),
    ('CrmAccount', 'crm_market_segment', 'STRING', 'crm_market_segment', FALSE, FALSE, 'CRM_MARKET_SEGMENT of CrmAccount'),
    ('CrmAccount', 'crm_success_owner_name', 'STRING', NULL, FALSE, FALSE, 'CRM_SUCCESS_OWNER_NAME of CrmAccount'),
    ('Date', 'month_date', 'DATE', NULL, FALSE, FALSE, 'MONTH_DATE of Date'),
    ('Date', 'month_year_number', 'NUMBER', NULL, FALSE, FALSE, 'MONTH_YEAR_NUMBER of Date'),
    ('Date', 'calendar_year', 'NUMBER', NULL, FALSE, FALSE, 'CALENDAR_YEAR of Date'),
    ('Date', 'calendar_quarter', 'NUMBER', NULL, FALSE, FALSE, 'CALENDAR_QUARTER of Date'),
    ('Date', 'calendar_month', 'NUMBER', NULL, FALSE, FALSE, 'CALENDAR_MONTH of Date'),
    ('Date', 'month_name', 'STRING', NULL, FALSE, FALSE, 'MONTH_NAME of Date'),
    ('Date', 'year_quarter', 'STRING', NULL, FALSE, FALSE, 'YEAR_QUARTER of Date'),
    ('Date', 'year_month_label', 'STRING', NULL, FALSE, FALSE, 'YEAR_MONTH_LABEL of Date'),
    ('InstanceAccount', 'instance_account_subdomain', 'STRING', 'instance_account_subdomain', FALSE, FALSE, 'INSTANCE_ACCOUNT_SUBDOMAIN of InstanceAccount'),
    ('AggInstanceAgentSummaryMonthly', 'total_active_agents', 'NUMBER', NULL, FALSE, FALSE, 'TOTAL_ACTIVE_AGENTS of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceAgentSummaryMonthly', 'remaining_agents', 'NUMBER', NULL, FALSE, FALSE, 'REMAINING_AGENTS of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceAgentSummaryMonthly', 'total_closed_tickets', 'NUMBER', NULL, FALSE, FALSE, 'TOTAL_CLOSED_TICKETS of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceAgentSummaryMonthly', 'active_agents_for_productivity', 'NUMBER', NULL, FALSE, FALSE, 'ACTIVE_AGENTS_FOR_PRODUCTIVITY of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceAgentSummaryMonthly', 'num_agents_admin', 'NUMBER', NULL, FALSE, FALSE, 'NUM_AGENTS_ADMIN of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceAgentSummaryMonthly', 'num_agents_light', 'NUMBER', NULL, FALSE, FALSE, 'NUM_AGENTS_LIGHT of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceAgentSummaryMonthly', 'num_agents_regular', 'NUMBER', NULL, FALSE, FALSE, 'NUM_AGENTS_REGULAR of AggInstanceAgentSummaryMonthly'),
    ('AggInstanceChannelTicketMonthly', 'count_created_tickets', 'NUMBER', NULL, FALSE, FALSE, 'COUNT_CREATED_TICKETS of AggInstanceChannelTicketMonthly'),
    ('AggInstanceChannelTicketMonthly', 'count_closed_tickets', 'NUMBER', NULL, FALSE, FALSE, 'COUNT_CLOSED_TICKETS of AggInstanceChannelTicketMonthly'),
    ('AggInstanceChannelTicketMonthly', 'count_csat_good', 'NUMBER', NULL, FALSE, FALSE, 'COUNT_CSAT_GOOD of AggInstanceChannelTicketMonthly'),
    ('AggInstanceChannelTicketMonthly', 'count_csat_offered', 'NUMBER', NULL, FALSE, FALSE, 'COUNT_CSAT_OFFERED of AggInstanceChannelTicketMonthly'),
    ('AggInstanceChannelTicketMonthly', 'count_csat_responded', 'NUMBER', NULL, FALSE, FALSE, 'COUNT_CSAT_RESPONDED of AggInstanceChannelTicketMonthly'),
    ('AggInstanceGuideMetricMonthly', 'new_kb_article_views', 'NUMBER', NULL, FALSE, FALSE, 'NEW_KB_ARTICLE_VIEWS of AggInstanceGuideMetricMonthly'),
    ('AggInstanceGuideMetricMonthly', 'new_community_post_views', 'NUMBER', NULL, FALSE, FALSE, 'NEW_COMMUNITY_POST_VIEWS of AggInstanceGuideMetricMonthly'),
    ('AggInstanceGuideMetricMonthly', 'num_published_articles', 'NUMBER', NULL, FALSE, FALSE, 'NUM_PUBLISHED_ARTICLES of AggInstanceGuideMetricMonthly'),
    ('AggInstanceGuideMetricMonthly', 'new_kb_articles_created', 'NUMBER', NULL, FALSE, FALSE, 'NEW_KB_ARTICLES_CREATED of AggInstanceGuideMetricMonthly'),
    ('AggInstanceGuideMetricMonthly', 'new_kb_comments', 'NUMBER', NULL, FALSE, FALSE, 'NEW_KB_COMMENTS of AggInstanceGuideMetricMonthly'),
    ('AggInstanceGuideMetricMonthly', 'new_community_post_answers', 'NUMBER', NULL, FALSE, FALSE, 'NEW_COMMUNITY_POST_ANSWERS of AggInstanceGuideMetricMonthly'),
    ('AggInstanceGuideMetricMonthly', 'new_community_post_questions', 'NUMBER', NULL, FALSE, FALSE, 'NEW_COMMUNITY_POST_QUESTIONS of AggInstanceGuideMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_created_tickets', 'NUMBER', 'rba_created_tickets', FALSE, FALSE, 'RBA_CREATED_TICKETS of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_solved_tickets', 'NUMBER', 'rba_solved_tickets', FALSE, FALSE, 'RBA_SOLVED_TICKETS of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_unique_agents_with_solved_tickets', 'NUMBER', 'rba_unique_agents_with_solved_tickets', FALSE, FALSE, 'RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_solved_tickets_per_agent', 'NUMBER', 'rba_solved_tickets_per_agent', FALSE, FALSE, 'RBA_SOLVED_TICKETS_PER_AGENT of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_zero_touch_ticket_ratio', 'NUMBER', 'rba_zero_touch_ticket_ratio', FALSE, FALSE, 'RBA_ZERO_TOUCH_TICKET_RATIO of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_one_touch_ticket_ratio', 'NUMBER', 'rba_one_touch_ticket_ratio', FALSE, FALSE, 'RBA_ONE_TOUCH_TICKET_RATIO of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_reopened_ticket_ratio', 'NUMBER', 'rba_reopened_ticket_ratio', FALSE, FALSE, 'RBA_REOPENED_TICKET_RATIO of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_one_plus_touch_tickets', 'NUMBER', 'rba_one_plus_touch_tickets', FALSE, FALSE, 'RBA_ONE_PLUS_TOUCH_TICKETS of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_frt_median_hours', 'NUMBER', 'rba_frt_median_hours', FALSE, FALSE, 'RBA_FRT_MEDIAN_HOURS of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_ttc_median_hours', 'NUMBER', 'rba_ttc_median_hours', FALSE, FALSE, 'RBA_TTC_MEDIAN_HOURS of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_csat_score', 'NUMBER', 'rba_csat_score', FALSE, FALSE, 'RBA_CSAT_SCORE of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaChannelMetricMonthly', 'rba_csat_response_rate', 'NUMBER', 'rba_csat_response_rate', FALSE, FALSE, 'RBA_CSAT_RESPONSE_RATE of AggInstanceRbaChannelMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_created_tickets', 'NUMBER', 'rba_created_tickets', FALSE, FALSE, 'RBA_CREATED_TICKETS of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_solved_tickets', 'NUMBER', 'rba_solved_tickets', FALSE, FALSE, 'RBA_SOLVED_TICKETS of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_unique_agents_with_solved_tickets', 'NUMBER', 'rba_unique_agents_with_solved_tickets', FALSE, FALSE, 'RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_solved_tickets_per_agent', 'NUMBER', 'rba_solved_tickets_per_agent', FALSE, FALSE, 'RBA_SOLVED_TICKETS_PER_AGENT of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_zero_touch_ticket_ratio', 'NUMBER', 'rba_zero_touch_ticket_ratio', FALSE, FALSE, 'RBA_ZERO_TOUCH_TICKET_RATIO of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_one_touch_ticket_ratio', 'NUMBER', 'rba_one_touch_ticket_ratio', FALSE, FALSE, 'RBA_ONE_TOUCH_TICKET_RATIO of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_reopened_ticket_ratio', 'NUMBER', 'rba_reopened_ticket_ratio', FALSE, FALSE, 'RBA_REOPENED_TICKET_RATIO of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_one_plus_touch_tickets', 'NUMBER', 'rba_one_plus_touch_tickets', FALSE, FALSE, 'RBA_ONE_PLUS_TOUCH_TICKETS of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_frt_median_hours', 'NUMBER', 'rba_frt_median_hours', FALSE, FALSE, 'RBA_FRT_MEDIAN_HOURS of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_ttc_median_hours', 'NUMBER', 'rba_ttc_median_hours', FALSE, FALSE, 'RBA_TTC_MEDIAN_HOURS of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_csat_score', 'NUMBER', 'rba_csat_score', FALSE, FALSE, 'RBA_CSAT_SCORE of AggInstanceRbaMetricMonthly'),
    ('AggInstanceRbaMetricMonthly', 'rba_csat_response_rate', 'NUMBER', 'rba_csat_response_rate', FALSE, FALSE, 'RBA_CSAT_RESPONSE_RATE of AggInstanceRbaMetricMonthly'),
    ('ReferenceAccountLookup', 'account_name', 'STRING', NULL, FALSE, FALSE, 'ACCOUNT_NAME of ReferenceAccountLookup'),
    ('TransformGongAccountMap', 'crm_account_name', 'STRING', 'crm_account_name', FALSE, FALSE, 'CRM_ACCOUNT_NAME of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'partner_level_c', 'STRING', NULL, FALSE, FALSE, 'PARTNER_LEVEL_C of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'competitor_c', 'STRING', NULL, FALSE, FALSE, 'COMPETITOR_C of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'top_competitor_c', 'STRING', NULL, FALSE, FALSE, 'TOP_COMPETITOR_C of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_net_arr_usd', 'NUMBER', 'crm_net_arr_usd', FALSE, FALSE, 'CRM_NET_ARR_USD of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_account_type', 'STRING', 'crm_account_type', FALSE, FALSE, 'CRM_ACCOUNT_TYPE of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_health_status', 'STRING', 'crm_health_status', FALSE, FALSE, 'CRM_HEALTH_STATUS of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_industry', 'STRING', 'crm_industry', FALSE, FALSE, 'CRM_INDUSTRY of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_sub_industry', 'STRING', 'crm_sub_industry', FALSE, FALSE, 'CRM_SUB_INDUSTRY of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_region', 'STRING', 'crm_region', FALSE, FALSE, 'CRM_REGION of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_sub_region', 'STRING', 'crm_sub_region', FALSE, FALSE, 'CRM_SUB_REGION of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_market_segment', 'STRING', 'crm_market_segment', FALSE, FALSE, 'CRM_MARKET_SEGMENT of TransformGongAccountMap'),
    ('TransformGongAccountMap', 'crm_market_super_segment', 'STRING', 'crm_market_super_segment', FALSE, FALSE, 'CRM_MARKET_SUPER_SEGMENT of TransformGongAccountMap'),
    ('TransformGongOpportunitieMap', 'crm_account_name', 'STRING', 'crm_account_name', FALSE, FALSE, 'CRM_ACCOUNT_NAME of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'crm_opportunity_id', 'STRING', 'crm_opportunity_id', FALSE, FALSE, 'CRM_OPPORTUNITY_ID of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'opportunity_name', 'STRING', 'opportunity_name', FALSE, FALSE, 'OPPORTUNITY_NAME of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'opportunity_type', 'STRING', 'opportunity_type', FALSE, FALSE, 'OPPORTUNITY_TYPE of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'opportunity_status', 'STRING', 'opportunity_status', FALSE, FALSE, 'OPPORTUNITY_STATUS of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'stage_2_plus_date_c', 'DATE', NULL, FALSE, FALSE, 'STAGE_2_PLUS_DATE_C of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'closedate', 'DATE', NULL, FALSE, FALSE, 'CLOSEDATE of TransformGongOpportunitieMap'),
    ('TransformGongOpportunitieMap', 'product_list', 'STRING', NULL, FALSE, FALSE, 'PRODUCT_LIST of TransformGongOpportunitieMap'),
    ('TransformGongTrackerTaxonomy', 'tracker_array', 'VARIANT', NULL, FALSE, FALSE, 'TRACKER_ARRAY of TransformGongTrackerTaxonomy'),
    ('TransformGongTrackerTaxonomy', 'cat1', 'STRING', NULL, FALSE, FALSE, 'CAT1 of TransformGongTrackerTaxonomy'),
    ('TransformGongTrackerTaxonomy', 'cat2', 'STRING', NULL, FALSE, FALSE, 'CAT2 of TransformGongTrackerTaxonomy'),
    ('TransformGongTrackerTaxonomy', 'cat3', 'STRING', NULL, FALSE, FALSE, 'CAT3 of TransformGongTrackerTaxonomy'),
    ('TransformGongTrackerTaxonomy', 'cat4', 'STRING', NULL, FALSE, FALSE, 'CAT4 of TransformGongTrackerTaxonomy'),
    ('UnifiedGongEvent', 'call_id', 'STRING', NULL, FALSE, FALSE, 'CALL_ID of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_date', 'DATE', NULL, FALSE, FALSE, 'CALL_DATE of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'title', 'STRING', NULL, FALSE, FALSE, 'TITLE of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_spotlight_brief', 'STRING', NULL, FALSE, FALSE, 'CALL_SPOTLIGHT_BRIEF of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_spotlight_next_steps', 'STRING', NULL, FALSE, FALSE, 'CALL_SPOTLIGHT_NEXT_STEPS of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_spotlight_key_points', 'VARIANT', NULL, FALSE, FALSE, 'CALL_SPOTLIGHT_KEY_POINTS of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_spotlight', 'VARIANT', NULL, FALSE, FALSE, 'CALL_SPOTLIGHT of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'transcript', 'VARIANT', NULL, FALSE, FALSE, 'TRANSCRIPT of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_spotlight_overview', 'STRING', NULL, FALSE, FALSE, 'CALL_SPOTLIGHT_OVERVIEW of UnifiedGongEvent'),
    ('UnifiedGongEvent', 'call_transcript_curated', 'STRING', NULL, FALSE, FALSE, 'CALL_TRANSCRIPT_CURATED of UnifiedGongEvent'),
    ('UnifiedUservoiceEvent', 'forum_name', 'STRING', NULL, FALSE, FALSE, 'FORUM_NAME of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'category_name', 'STRING', NULL, FALSE, FALSE, 'CATEGORY_NAME of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'suggestion_name', 'STRING', NULL, FALSE, FALSE, 'SUGGESTION_NAME of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'suggestion_body', 'STRING', NULL, FALSE, FALSE, 'SUGGESTION_BODY of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'suggestion_created_at', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'SUGGESTION_CREATED_AT of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'suggestion_updated_at', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'SUGGESTION_UPDATED_AT of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'suggestion_state', 'STRING', NULL, FALSE, FALSE, 'SUGGESTION_STATE of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'request_body', 'STRING', NULL, FALSE, FALSE, 'REQUEST_BODY of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'request_created_at', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'REQUEST_CREATED_AT of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'request_updated_at', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'REQUEST_UPDATED_AT of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_account_name', 'STRING', 'crm_account_name', FALSE, FALSE, 'CRM_ACCOUNT_NAME of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_net_arr_usd', 'NUMBER', 'crm_net_arr_usd', FALSE, FALSE, 'CRM_NET_ARR_USD of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_account_type', 'STRING', 'crm_account_type', FALSE, FALSE, 'CRM_ACCOUNT_TYPE of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_health_status', 'STRING', 'crm_health_status', FALSE, FALSE, 'CRM_HEALTH_STATUS of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_industry', 'STRING', 'crm_industry', FALSE, FALSE, 'CRM_INDUSTRY of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_sub_industry', 'STRING', 'crm_sub_industry', FALSE, FALSE, 'CRM_SUB_INDUSTRY of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_region', 'STRING', 'crm_region', FALSE, FALSE, 'CRM_REGION of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_sub_region', 'STRING', 'crm_sub_region', FALSE, FALSE, 'CRM_SUB_REGION of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_market_segment', 'STRING', 'crm_market_segment', FALSE, FALSE, 'CRM_MARKET_SEGMENT of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'crm_market_super_segment', 'STRING', 'crm_market_super_segment', FALSE, FALSE, 'CRM_MARKET_SUPER_SEGMENT of UnifiedUservoiceEvent'),
    ('UnifiedUservoiceEvent', 'request_overview', 'STRING', NULL, FALSE, FALSE, 'REQUEST_OVERVIEW of UnifiedUservoiceEvent'),
    ('EdaMlContactActivityDailySnapshot', 'crm_account_id', 'STRING', 'crm_account_id', FALSE, FALSE, 'CRM_ACCOUNT_ID of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactActivityDailySnapshot', 'activity_subject', 'STRING', NULL, FALSE, FALSE, 'ACTIVITY_SUBJECT of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactActivityDailySnapshot', 'contact_email', 'STRING', 'contact_email', FALSE, FALSE, 'CONTACT_EMAIL of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactActivityDailySnapshot', 'activity_category', 'STRING', NULL, FALSE, FALSE, 'ACTIVITY_CATEGORY of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactActivityDailySnapshot', 'activity_type', 'STRING', NULL, FALSE, FALSE, 'ACTIVITY_TYPE of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactActivityDailySnapshot', 'activity_zendesk_division', 'STRING', NULL, FALSE, FALSE, 'ACTIVITY_ZENDESK_DIVISION of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactActivityDailySnapshot', 'activity_zendesk_user', 'STRING', NULL, FALSE, FALSE, 'ACTIVITY_ZENDESK_USER of EdaMlContactActivityDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'crm_account_id', 'STRING', 'crm_account_id', FALSE, FALSE, 'CRM_ACCOUNT_ID of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_id', 'STRING', NULL, FALSE, FALSE, 'CONTACT_ID of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_last_human_touch', 'DATE', NULL, FALSE, FALSE, 'CONTACT_LAST_HUMAN_TOUCH of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_last_sales_touch_date_time', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'CONTACT_LAST_SALES_TOUCH_DATE_TIME of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_role', 'STRING', NULL, FALSE, FALSE, 'CONTACT_ROLE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_job_role', 'STRING', NULL, FALSE, FALSE, 'CONTACT_JOB_ROLE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_intent_score_6_sense', 'FLOAT', NULL, FALSE, FALSE, 'CONTACT_INTENT_SCORE_6_SENSE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_title', 'STRING', NULL, FALSE, FALSE, 'CONTACT_TITLE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_email', 'STRING', 'contact_email', FALSE, FALSE, 'CONTACT_EMAIL of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_phone_number', 'STRING', NULL, FALSE, FALSE, 'CONTACT_PHONE_NUMBER of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_name', 'STRING', NULL, FALSE, FALSE, 'CONTACT_NAME of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_created_date', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'CONTACT_CREATED_DATE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'contact_lead_source', 'STRING', NULL, FALSE, FALSE, 'CONTACT_LEAD_SOURCE of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'num_web_visits_l30d', 'NUMBER', NULL, FALSE, FALSE, 'NUM_WEB_VISITS_L30D of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'num_web_forms_l30d', 'NUMBER', NULL, FALSE, FALSE, 'NUM_WEB_FORMS_L30D of EdaMlContactDailySnapshot'),
    ('EdaMlContactDailySnapshot', 'num_opened_emails_l30d', 'NUMBER', NULL, FALSE, FALSE, 'NUM_OPENED_EMAILS_L30D of EdaMlContactDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_account_id', 'STRING', 'crm_account_id', FALSE, FALSE, 'CRM_ACCOUNT_ID of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_owner_id', 'STRING', NULL, FALSE, FALSE, 'CRM_OWNER_ID of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_primary_owner_name', 'STRING', NULL, FALSE, FALSE, 'CRM_PRIMARY_OWNER_NAME of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_industry', 'STRING', 'crm_industry', FALSE, FALSE, 'CRM_INDUSTRY of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_sub_industry', 'STRING', 'crm_sub_industry', FALSE, FALSE, 'CRM_SUB_INDUSTRY of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_region', 'STRING', 'crm_region', FALSE, FALSE, 'CRM_REGION of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_sub_region', 'STRING', 'crm_sub_region', FALSE, FALSE, 'CRM_SUB_REGION of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'pro_forma_market_segment', 'STRING', NULL, FALSE, FALSE, 'PRO_FORMA_MARKET_SEGMENT of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'pro_forma_market_subsegment', 'STRING', NULL, FALSE, FALSE, 'PRO_FORMA_MARKET_SUBSEGMENT of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'pro_forma_market_super_segment', 'STRING', NULL, FALSE, FALSE, 'PRO_FORMA_MARKET_SUPER_SEGMENT of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_account_name', 'STRING', 'crm_account_name', FALSE, FALSE, 'CRM_ACCOUNT_NAME of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_health_status', 'STRING', 'crm_health_status', FALSE, FALSE, 'CRM_HEALTH_STATUS of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_date_became_customer', 'DATE', NULL, FALSE, FALSE, 'CRM_DATE_BECAME_CUSTOMER of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_parent_id', 'STRING', NULL, FALSE, FALSE, 'CRM_PARENT_ID of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_account_type', 'STRING', 'crm_account_type', FALSE, FALSE, 'CRM_ACCOUNT_TYPE of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_net_arr_usd', 'NUMBER', 'crm_net_arr_usd', FALSE, FALSE, 'CRM_NET_ARR_USD of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_next_renewal_date', 'DATE', NULL, FALSE, FALSE, 'CRM_NEXT_RENEWAL_DATE of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_number_of_employees', 'NUMBER', NULL, FALSE, FALSE, 'CRM_NUMBER_OF_EMPLOYEES of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlCrmAccountDailySnapshot', 'crm_revenue', 'NUMBER', NULL, FALSE, FALSE, 'CRM_REVENUE of EdaMlCrmAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'instance_account_id', 'NUMBER', 'instance_account_id', FALSE, FALSE, 'INSTANCE_ACCOUNT_ID of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'crm_account_id', 'STRING', 'crm_account_id', FALSE, FALSE, 'CRM_ACCOUNT_ID of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'instance_account_subdomain', 'STRING', 'instance_account_subdomain', FALSE, FALSE, 'INSTANCE_ACCOUNT_SUBDOMAIN of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'instance_account_name', 'STRING', NULL, FALSE, FALSE, 'INSTANCE_ACCOUNT_NAME of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'instance_account_arr_usd', 'NUMBER', NULL, FALSE, FALSE, 'INSTANCE_ACCOUNT_ARR_USD of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'seats_capacity', 'NUMBER', NULL, FALSE, FALSE, 'SEATS_CAPACITY of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'seats_occupied', 'NUMBER', NULL, FALSE, FALSE, 'SEATS_OCCUPIED of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'seat_utilization', 'NUMBER', NULL, FALSE, FALSE, 'SEAT_UTILIZATION of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'active_agents_l30d', 'NUMBER', NULL, FALSE, FALSE, 'ACTIVE_AGENTS_L30D of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'csat_score', 'NUMBER', NULL, FALSE, FALSE, 'CSAT_SCORE of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'new_tickets_l30d', 'NUMBER', NULL, FALSE, FALSE, 'NEW_TICKETS_L30D of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceAccountDailySnapshot', 'solved_tickets_l30d', 'NUMBER', NULL, FALSE, FALSE, 'SOLVED_TICKETS_L30D of EdaMlInstanceAccountDailySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'month_year', 'DATE', NULL, FALSE, FALSE, 'MONTH_YEAR of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'instance_account_id', 'NUMBER', 'instance_account_id', FALSE, FALSE, 'INSTANCE_ACCOUNT_ID of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'channel_group', 'STRING', NULL, FALSE, FALSE, 'CHANNEL_GROUP of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_created_tickets', 'NUMBER', 'rba_created_tickets', FALSE, FALSE, 'RBA_CREATED_TICKETS of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_solved_tickets', 'NUMBER', 'rba_solved_tickets', FALSE, FALSE, 'RBA_SOLVED_TICKETS of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_unique_agents_with_solved_tickets', 'NUMBER', 'rba_unique_agents_with_solved_tickets', FALSE, FALSE, 'RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_solved_tickets_per_agent', 'NUMBER', 'rba_solved_tickets_per_agent', FALSE, FALSE, 'RBA_SOLVED_TICKETS_PER_AGENT of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_zero_touch_ticket_ratio', 'NUMBER', 'rba_zero_touch_ticket_ratio', FALSE, FALSE, 'RBA_ZERO_TOUCH_TICKET_RATIO of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_one_touch_ticket_ratio', 'NUMBER', 'rba_one_touch_ticket_ratio', FALSE, FALSE, 'RBA_ONE_TOUCH_TICKET_RATIO of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_reopened_ticket_ratio', 'NUMBER', 'rba_reopened_ticket_ratio', FALSE, FALSE, 'RBA_REOPENED_TICKET_RATIO of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_frt_median_hours', 'NUMBER', 'rba_frt_median_hours', FALSE, FALSE, 'RBA_FRT_MEDIAN_HOURS of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_ttr_median_hours', 'NUMBER', NULL, FALSE, FALSE, 'RBA_TTR_MEDIAN_HOURS of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_csat_score', 'NUMBER', 'rba_csat_score', FALSE, FALSE, 'RBA_CSAT_SCORE of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceChannelMonthlySnapshot', 'rba_csat_response_rate', 'NUMBER', 'rba_csat_response_rate', FALSE, FALSE, 'RBA_CSAT_RESPONSE_RATE of EdaMlInstanceChannelMonthlySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'crm_account_id', 'STRING', 'crm_account_id', FALSE, FALSE, 'CRM_ACCOUNT_ID of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'instance_account_id', 'NUMBER', 'instance_account_id', FALSE, FALSE, 'INSTANCE_ACCOUNT_ID of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'product_offering', 'STRING', NULL, FALSE, FALSE, 'PRODUCT_OFFERING of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'product_offering_grouped', 'STRING', NULL, FALSE, FALSE, 'PRODUCT_OFFERING_GROUPED of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'product_plan', 'STRING', NULL, FALSE, FALSE, 'PRODUCT_PLAN of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'net_arr_usd', 'NUMBER', NULL, FALSE, FALSE, 'NET_ARR_USD of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'seats', 'NUMBER', NULL, FALSE, FALSE, 'SEATS of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlInstanceProductDailySnapshot', 'quantity', 'NUMBER', NULL, FALSE, FALSE, 'QUANTITY of EdaMlInstanceProductDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'crm_account_id', 'STRING', 'crm_account_id', FALSE, FALSE, 'CRM_ACCOUNT_ID of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'crm_opportunity_id', 'STRING', 'crm_opportunity_id', FALSE, FALSE, 'CRM_OPPORTUNITY_ID of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_name', 'STRING', 'opportunity_name', FALSE, FALSE, 'OPPORTUNITY_NAME of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_created_date', 'TIMESTAMP_NTZ', NULL, FALSE, FALSE, 'OPPORTUNITY_CREATED_DATE of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_close_date', 'DATE', NULL, FALSE, FALSE, 'OPPORTUNITY_CLOSE_DATE of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_type', 'STRING', 'opportunity_type', FALSE, FALSE, 'OPPORTUNITY_TYPE of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_status', 'STRING', 'opportunity_status', FALSE, FALSE, 'OPPORTUNITY_STATUS of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_stage_name', 'STRING', NULL, FALSE, FALSE, 'OPPORTUNITY_STAGE_NAME of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlOpportunitieDailySnapshot', 'opportunity_booking_arr_usd', 'NUMBER', NULL, FALSE, FALSE, 'OPPORTUNITY_BOOKING_ARR_USD of EdaMlOpportunitieDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'crm_user_id', 'STRING', NULL, FALSE, FALSE, 'CRM_USER_ID of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'source_snapshot_date', 'DATE', 'source_snapshot_date', FALSE, FALSE, 'SOURCE_SNAPSHOT_DATE of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'user_name', 'STRING', 'user_name', FALSE, FALSE, 'USER_NAME of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'user_email', 'STRING', 'user_email', FALSE, FALSE, 'USER_EMAIL of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'user_market_segment', 'STRING', NULL, FALSE, FALSE, 'USER_MARKET_SEGMENT of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'user_region', 'STRING', NULL, FALSE, FALSE, 'USER_REGION of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'user_sub_region', 'STRING', NULL, FALSE, FALSE, 'USER_SUB_REGION of EdaMlUserDailySnapshot'),
    ('EdaMlUserDailySnapshot', 'manager_1_email', 'STRING', NULL, FALSE, FALSE, 'MANAGER_1_EMAIL of EdaMlUserDailySnapshot'),
    ('EdaMlUserAccountMapping', 'user_name', 'STRING', 'user_name', FALSE, FALSE, 'USER_NAME of EdaMlUserAccountMapping'),
    ('EdaMlUserAccountMapping', 'user_email', 'STRING', 'user_email', FALSE, FALSE, 'USER_EMAIL of EdaMlUserAccountMapping'),
    ('EdaMlUserAccountMapping', 'user_role_on_account', 'STRING', NULL, FALSE, FALSE, 'USER_ROLE_ON_ACCOUNT of EdaMlUserAccountMapping');

-- Derived Properties
CREATE TABLE IF NOT EXISTS ONT_DERIVED_PROPERTY (
    CLASS_NAME          STRING,
    PROP_NAME           STRING,
    DEFINITION_KIND     STRING,
    SQL_EXPR            STRING,
    FUNCTION_NAME       STRING,
    DESCRIPTION         STRING,
    PRIMARY KEY (CLASS_NAME, PROP_NAME)
);

-- Interfaces (Polymorphism)
CREATE TABLE IF NOT EXISTS ONT_INTERFACE (
    INTERFACE_NAME      STRING PRIMARY KEY,
    DESCRIPTION         STRING
);

CREATE TABLE IF NOT EXISTS ONT_INTERFACE_PROPERTY (
    INTERFACE_NAME      STRING,
    PROP_NAME           STRING,
    SHARED_PROP_NAME    STRING,
    PRIMARY KEY (INTERFACE_NAME, PROP_NAME)
);

CREATE TABLE IF NOT EXISTS ONT_INTERFACE_IMPL (
    INTERFACE_NAME      STRING,
    CLASS_NAME          STRING,
    PRIMARY KEY (INTERFACE_NAME, CLASS_NAME)
);

INSERT INTO ONT_INTERFACE (INTERFACE_NAME, DESCRIPTION) VALUES
    ('HasCrmAccountName', 'Entities with crm_account_name property'),
    ('HasCrmRegion', 'Entities with crm_region property'),
    ('HasCrmMarketSegment', 'Entities with crm_market_segment property'),
    ('HasInstanceAccountSubdomain', 'Entities with instance_account_subdomain property'),
    ('HasRbaCreatedTickets', 'Entities with rba_created_tickets property'),
    ('HasRbaSolvedTickets', 'Entities with rba_solved_tickets property'),
    ('HasRbaUniqueAgentsWithSolvedTickets', 'Entities with rba_unique_agents_with_solved_tickets property'),
    ('HasRbaSolvedTicketsPerAgent', 'Entities with rba_solved_tickets_per_agent property'),
    ('HasRbaZeroTouchTicketRatio', 'Entities with rba_zero_touch_ticket_ratio property'),
    ('HasRbaOneTouchTicketRatio', 'Entities with rba_one_touch_ticket_ratio property'),
    ('HasRbaReopenedTicketRatio', 'Entities with rba_reopened_ticket_ratio property'),
    ('HasRbaOnePlusTouchTickets', 'Entities with rba_one_plus_touch_tickets property'),
    ('HasRbaFrtMedianHours', 'Entities with rba_frt_median_hours property'),
    ('HasRbaTtcMedianHours', 'Entities with rba_ttc_median_hours property'),
    ('HasRbaCsatScore', 'Entities with rba_csat_score property'),
    ('HasRbaCsatResponseRate', 'Entities with rba_csat_response_rate property'),
    ('HasCrmNetArrUsd', 'Entities with crm_net_arr_usd property'),
    ('HasCrmAccountType', 'Entities with crm_account_type property'),
    ('HasCrmHealthStatus', 'Entities with crm_health_status property'),
    ('HasCrmIndustry', 'Entities with crm_industry property'),
    ('HasCrmSubIndustry', 'Entities with crm_sub_industry property'),
    ('HasCrmSubRegion', 'Entities with crm_sub_region property'),
    ('HasCrmMarketSuperSegment', 'Entities with crm_market_super_segment property'),
    ('HasCrmOpportunityId', 'Entities with crm_opportunity_id property'),
    ('HasOpportunityName', 'Entities with opportunity_name property'),
    ('HasOpportunityType', 'Entities with opportunity_type property'),
    ('HasOpportunityStatus', 'Entities with opportunity_status property'),
    ('HasCrmAccountId', 'Entities with crm_account_id property'),
    ('HasContactEmail', 'Entities with contact_email property'),
    ('HasSourceSnapshotDate', 'Entities with source_snapshot_date property'),
    ('HasInstanceAccountId', 'Entities with instance_account_id property'),
    ('HasUserName', 'Entities with user_name property'),
    ('HasUserEmail', 'Entities with user_email property');

INSERT INTO ONT_INTERFACE_PROPERTY (INTERFACE_NAME, PROP_NAME, SHARED_PROP_NAME) VALUES
    ('HasCrmAccountName', 'crm_account_name', 'crm_account_name'),
    ('HasCrmRegion', 'crm_region', 'crm_region'),
    ('HasCrmMarketSegment', 'crm_market_segment', 'crm_market_segment'),
    ('HasInstanceAccountSubdomain', 'instance_account_subdomain', 'instance_account_subdomain'),
    ('HasRbaCreatedTickets', 'rba_created_tickets', 'rba_created_tickets'),
    ('HasRbaSolvedTickets', 'rba_solved_tickets', 'rba_solved_tickets'),
    ('HasRbaUniqueAgentsWithSolvedTickets', 'rba_unique_agents_with_solved_tickets', 'rba_unique_agents_with_solved_tickets'),
    ('HasRbaSolvedTicketsPerAgent', 'rba_solved_tickets_per_agent', 'rba_solved_tickets_per_agent'),
    ('HasRbaZeroTouchTicketRatio', 'rba_zero_touch_ticket_ratio', 'rba_zero_touch_ticket_ratio'),
    ('HasRbaOneTouchTicketRatio', 'rba_one_touch_ticket_ratio', 'rba_one_touch_ticket_ratio'),
    ('HasRbaReopenedTicketRatio', 'rba_reopened_ticket_ratio', 'rba_reopened_ticket_ratio'),
    ('HasRbaOnePlusTouchTickets', 'rba_one_plus_touch_tickets', 'rba_one_plus_touch_tickets'),
    ('HasRbaFrtMedianHours', 'rba_frt_median_hours', 'rba_frt_median_hours'),
    ('HasRbaTtcMedianHours', 'rba_ttc_median_hours', 'rba_ttc_median_hours'),
    ('HasRbaCsatScore', 'rba_csat_score', 'rba_csat_score'),
    ('HasRbaCsatResponseRate', 'rba_csat_response_rate', 'rba_csat_response_rate'),
    ('HasCrmNetArrUsd', 'crm_net_arr_usd', 'crm_net_arr_usd'),
    ('HasCrmAccountType', 'crm_account_type', 'crm_account_type'),
    ('HasCrmHealthStatus', 'crm_health_status', 'crm_health_status'),
    ('HasCrmIndustry', 'crm_industry', 'crm_industry'),
    ('HasCrmSubIndustry', 'crm_sub_industry', 'crm_sub_industry'),
    ('HasCrmSubRegion', 'crm_sub_region', 'crm_sub_region'),
    ('HasCrmMarketSuperSegment', 'crm_market_super_segment', 'crm_market_super_segment'),
    ('HasCrmOpportunityId', 'crm_opportunity_id', 'crm_opportunity_id'),
    ('HasOpportunityName', 'opportunity_name', 'opportunity_name'),
    ('HasOpportunityType', 'opportunity_type', 'opportunity_type'),
    ('HasOpportunityStatus', 'opportunity_status', 'opportunity_status'),
    ('HasCrmAccountId', 'crm_account_id', 'crm_account_id'),
    ('HasContactEmail', 'contact_email', 'contact_email'),
    ('HasSourceSnapshotDate', 'source_snapshot_date', 'source_snapshot_date'),
    ('HasInstanceAccountId', 'instance_account_id', 'instance_account_id'),
    ('HasUserName', 'user_name', 'user_name'),
    ('HasUserEmail', 'user_email', 'user_email');

INSERT INTO ONT_INTERFACE_IMPL (INTERFACE_NAME, CLASS_NAME) VALUES
    ('HasCrmAccountName', 'CrmAccount'),
    ('HasCrmAccountName', 'TransformGongAccountMap'),
    ('HasCrmAccountName', 'TransformGongOpportunitieMap'),
    ('HasCrmAccountName', 'UnifiedUservoiceEvent'),
    ('HasCrmAccountName', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmRegion', 'CrmAccount'),
    ('HasCrmRegion', 'TransformGongAccountMap'),
    ('HasCrmRegion', 'UnifiedUservoiceEvent'),
    ('HasCrmRegion', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmMarketSegment', 'CrmAccount'),
    ('HasCrmMarketSegment', 'TransformGongAccountMap'),
    ('HasCrmMarketSegment', 'UnifiedUservoiceEvent'),
    ('HasInstanceAccountSubdomain', 'InstanceAccount'),
    ('HasInstanceAccountSubdomain', 'EdaMlInstanceAccountDailySnapshot'),
    ('HasRbaCreatedTickets', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaCreatedTickets', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaCreatedTickets', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaSolvedTickets', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaSolvedTickets', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaSolvedTickets', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaUniqueAgentsWithSolvedTickets', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaUniqueAgentsWithSolvedTickets', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaUniqueAgentsWithSolvedTickets', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaSolvedTicketsPerAgent', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaSolvedTicketsPerAgent', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaSolvedTicketsPerAgent', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaZeroTouchTicketRatio', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaZeroTouchTicketRatio', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaZeroTouchTicketRatio', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaOneTouchTicketRatio', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaOneTouchTicketRatio', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaOneTouchTicketRatio', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaReopenedTicketRatio', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaReopenedTicketRatio', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaReopenedTicketRatio', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaOnePlusTouchTickets', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaOnePlusTouchTickets', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaFrtMedianHours', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaFrtMedianHours', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaFrtMedianHours', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaTtcMedianHours', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaTtcMedianHours', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaCsatScore', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaCsatScore', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaCsatScore', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasRbaCsatResponseRate', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasRbaCsatResponseRate', 'AggInstanceRbaMetricMonthly'),
    ('HasRbaCsatResponseRate', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasCrmNetArrUsd', 'TransformGongAccountMap'),
    ('HasCrmNetArrUsd', 'UnifiedUservoiceEvent'),
    ('HasCrmNetArrUsd', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmAccountType', 'TransformGongAccountMap'),
    ('HasCrmAccountType', 'UnifiedUservoiceEvent'),
    ('HasCrmAccountType', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmHealthStatus', 'TransformGongAccountMap'),
    ('HasCrmHealthStatus', 'UnifiedUservoiceEvent'),
    ('HasCrmHealthStatus', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmIndustry', 'TransformGongAccountMap'),
    ('HasCrmIndustry', 'UnifiedUservoiceEvent'),
    ('HasCrmIndustry', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmSubIndustry', 'TransformGongAccountMap'),
    ('HasCrmSubIndustry', 'UnifiedUservoiceEvent'),
    ('HasCrmSubIndustry', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmSubRegion', 'TransformGongAccountMap'),
    ('HasCrmSubRegion', 'UnifiedUservoiceEvent'),
    ('HasCrmSubRegion', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmMarketSuperSegment', 'TransformGongAccountMap'),
    ('HasCrmMarketSuperSegment', 'UnifiedUservoiceEvent'),
    ('HasCrmOpportunityId', 'TransformGongOpportunitieMap'),
    ('HasCrmOpportunityId', 'EdaMlOpportunitieDailySnapshot'),
    ('HasOpportunityName', 'TransformGongOpportunitieMap'),
    ('HasOpportunityName', 'EdaMlOpportunitieDailySnapshot'),
    ('HasOpportunityType', 'TransformGongOpportunitieMap'),
    ('HasOpportunityType', 'EdaMlOpportunitieDailySnapshot'),
    ('HasOpportunityStatus', 'TransformGongOpportunitieMap'),
    ('HasOpportunityStatus', 'EdaMlOpportunitieDailySnapshot'),
    ('HasCrmAccountId', 'CrmAccount'),
    ('HasCrmAccountId', 'InstanceAccount'),
    ('HasCrmAccountId', 'AggInstanceAgentSummaryMonthly'),
    ('HasCrmAccountId', 'AggInstanceChannelTicketMonthly'),
    ('HasCrmAccountId', 'AggInstanceGuideMetricMonthly'),
    ('HasCrmAccountId', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasCrmAccountId', 'AggInstanceRbaMetricMonthly'),
    ('HasCrmAccountId', 'TransformGongAccountMap'),
    ('HasCrmAccountId', 'TransformGongOpportunitieMap'),
    ('HasCrmAccountId', 'UnifiedUservoiceEvent'),
    ('HasCrmAccountId', 'EdaMlContactActivityDailySnapshot'),
    ('HasCrmAccountId', 'EdaMlContactDailySnapshot'),
    ('HasCrmAccountId', 'EdaMlCrmAccountDailySnapshot'),
    ('HasCrmAccountId', 'EdaMlInstanceAccountDailySnapshot'),
    ('HasCrmAccountId', 'EdaMlInstanceProductDailySnapshot'),
    ('HasCrmAccountId', 'EdaMlOpportunitieDailySnapshot'),
    ('HasCrmAccountId', 'EdaMlUserAccountMapping'),
    ('HasContactEmail', 'EdaMlContactActivityDailySnapshot'),
    ('HasContactEmail', 'EdaMlContactDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlContactActivityDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlContactDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlCrmAccountDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlInstanceAccountDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlInstanceProductDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlOpportunitieDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlUserDailySnapshot'),
    ('HasSourceSnapshotDate', 'EdaMlUserAccountMapping'),
    ('HasInstanceAccountId', 'InstanceAccount'),
    ('HasInstanceAccountId', 'AggInstanceAgentSummaryMonthly'),
    ('HasInstanceAccountId', 'AggInstanceChannelTicketMonthly'),
    ('HasInstanceAccountId', 'AggInstanceGuideMetricMonthly'),
    ('HasInstanceAccountId', 'AggInstanceRbaChannelMetricMonthly'),
    ('HasInstanceAccountId', 'AggInstanceRbaMetricMonthly'),
    ('HasInstanceAccountId', 'EdaMlInstanceAccountDailySnapshot'),
    ('HasInstanceAccountId', 'EdaMlInstanceChannelMonthlySnapshot'),
    ('HasInstanceAccountId', 'EdaMlInstanceProductDailySnapshot'),
    ('HasUserName', 'EdaMlUserDailySnapshot'),
    ('HasUserName', 'EdaMlUserAccountMapping'),
    ('HasUserEmail', 'EdaMlUserDailySnapshot'),
    ('HasUserEmail', 'EdaMlUserAccountMapping');

-- Inference Rules
CREATE TABLE IF NOT EXISTS ONT_RULE (
    RULE_ID             STRING PRIMARY KEY,
    RULE_KIND           STRING,
    TARGET_REL          STRING,
    SOURCE_REL_1        STRING,
    SOURCE_REL_2        STRING,
    INVERSE_OF          STRING,
    DESCRIPTION         STRING,
    IS_ENABLED          BOOLEAN DEFAULT TRUE,
    TS_CREATED          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Inferred Edges
CREATE TABLE IF NOT EXISTS REL_EDGE_INFERRED (
    REL_NAME            STRING NOT NULL,
    SRC_ID              STRING NOT NULL,
    DST_ID              STRING NOT NULL,
    INFERENCE_KIND      STRING,
    RULE_ID             STRING,
    WEIGHT              FLOAT DEFAULT 1.0,
    EFFECTIVE_START     DATE,
    EFFECTIVE_END       DATE,
    COMPUTED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (REL_NAME, SRC_ID, DST_ID, RULE_ID)
);

-- Data Quality Constraints
CREATE TABLE IF NOT EXISTS ONT_CONSTRAINT_VIOLATION (
    VIOLATION_ID        STRING DEFAULT UUID_STRING(),
    CHECK_NAME          STRING,
    SCOPE               STRING,
    REL_OR_CLASS        STRING,
    SRC_ID              STRING,
    DST_ID              STRING,
    DETAILS             STRING,
    OBSERVED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (VIOLATION_ID)
);

-- Action Types
CREATE TABLE IF NOT EXISTS ACT_TYPE (
    ACTION_TYPE_ID      STRING PRIMARY KEY,
    ACTION_NAME         STRING NOT NULL,
    DESCRIPTION         STRING,
    ONTOLOGY_NAME       STRING,
    TARGET_CLASS        STRING,
    HANDLER_PROC        STRING,
    IS_ENABLED          BOOLEAN DEFAULT TRUE,
    TS_CREATED          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Action Parameter Definitions
CREATE TABLE IF NOT EXISTS ACT_DEF (
    ACTION_TYPE_ID      STRING,
    PARAM_NAME          STRING,
    PARAM_TYPE          STRING,
    IS_REQUIRED         BOOLEAN DEFAULT FALSE,
    DESCRIPTION         STRING,
    PRIMARY KEY (ACTION_TYPE_ID, PARAM_NAME)
);

-- Action Invocation Log
CREATE TABLE IF NOT EXISTS ACT_INVOCATION (
    INVOCATION_ID       STRING PRIMARY KEY,
    ACTION_TYPE_ID      STRING NOT NULL,
    TARGET_OBJECT_ID    STRING,
    PARAMS              VARIANT,
    STATUS              STRING,
    RESULT_MSG          STRING,
    INVOKED_BY          STRING,
    INVOKED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    COMPLETED_AT        TIMESTAMP_NTZ
);

-- Function Catalog
CREATE TABLE IF NOT EXISTS ONT_FUNCTION (
    FUNCTION_NAME       STRING,
    VERSION             STRING,
    LANGUAGE            STRING,
    SNOWFLAKE_REF       STRING,
    DESCRIPTION         STRING,
    INPUT_SCHEMA        VARIANT,
    OUTPUT_SCHEMA       VARIANT,
    ONTOLOGY_NAME       STRING,
    PRIMARY KEY (ONTOLOGY_NAME, FUNCTION_NAME, VERSION)
);

-- Function Bindings
CREATE TABLE IF NOT EXISTS ONT_FUNCTION_BINDING (
    ONTOLOGY_NAME       STRING,
    FUNCTION_NAME       STRING,
    VERSION             STRING,
    BOUND_TO_KIND       STRING,
    BOUND_TO_NAME       STRING
);

-- Object View Definitions (UI/Governance)
CREATE TABLE IF NOT EXISTS OBJ_VIEW_DEF (
    OBJ_TYPE            STRING,
    VIEW_NAME           STRING,
    CREATED_BY          STRING,
    DESCRIPTION         STRING,
    DISPLAY_COLS        VARIANT,
    VERSION             STRING DEFAULT '1.0',
    STATUS              STRING DEFAULT 'ACTIVE',
    TS_CREATED          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (OBJ_TYPE, VIEW_NAME)
);

INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'CrmAccount', 'V_CRMACCOUNT', 'SYSTEM', 'Standard CrmAccount view', ARRAY_CONSTRUCT('CRM_ACCOUNT_NAME', 'CRM_OWNER_NAME', 'CRM_REGION', 'CRM_MARKET_SEGMENT', 'CRM_SUCCESS_OWNER_NAME');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'Date', 'V_DATE', 'SYSTEM', 'Standard Date view', ARRAY_CONSTRUCT('MONTH_DATE', 'MONTH_YEAR_NUMBER', 'CALENDAR_YEAR', 'CALENDAR_QUARTER', 'CALENDAR_MONTH');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'InstanceAccount', 'V_INSTANCEACCOUNT', 'SYSTEM', 'Standard InstanceAccount view', ARRAY_CONSTRUCT('INSTANCE_ACCOUNT_SUBDOMAIN');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'AggInstanceAgentSummaryMonthly', 'V_AGGINSTANCEAGENTSUMMARYMONTHLY', 'SYSTEM', 'Standard AggInstanceAgentSummaryMonthly view', ARRAY_CONSTRUCT('TOTAL_ACTIVE_AGENTS', 'REMAINING_AGENTS', 'TOTAL_CLOSED_TICKETS', 'ACTIVE_AGENTS_FOR_PRODUCTIVITY', 'NUM_AGENTS_ADMIN');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'AggInstanceChannelTicketMonthly', 'V_AGGINSTANCECHANNELTICKETMONTHLY', 'SYSTEM', 'Standard AggInstanceChannelTicketMonthly view', ARRAY_CONSTRUCT('COUNT_CREATED_TICKETS', 'COUNT_CLOSED_TICKETS', 'COUNT_CSAT_GOOD', 'COUNT_CSAT_OFFERED', 'COUNT_CSAT_RESPONDED');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'AggInstanceGuideMetricMonthly', 'V_AGGINSTANCEGUIDEMETRICMONTHLY', 'SYSTEM', 'Standard AggInstanceGuideMetricMonthly view', ARRAY_CONSTRUCT('NEW_KB_ARTICLE_VIEWS', 'NEW_COMMUNITY_POST_VIEWS', 'NUM_PUBLISHED_ARTICLES', 'NEW_KB_ARTICLES_CREATED', 'NEW_KB_COMMENTS');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'AggInstanceRbaChannelMetricMonthly', 'V_AGGINSTANCERBACHANNELMETRICMONTHLY', 'SYSTEM', 'Standard AggInstanceRbaChannelMetricMonthly view', ARRAY_CONSTRUCT('RBA_CREATED_TICKETS', 'RBA_SOLVED_TICKETS', 'RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS', 'RBA_SOLVED_TICKETS_PER_AGENT', 'RBA_ZERO_TOUCH_TICKET_RATIO');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'AggInstanceRbaMetricMonthly', 'V_AGGINSTANCERBAMETRICMONTHLY', 'SYSTEM', 'Standard AggInstanceRbaMetricMonthly view', ARRAY_CONSTRUCT('RBA_CREATED_TICKETS', 'RBA_SOLVED_TICKETS', 'RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS', 'RBA_SOLVED_TICKETS_PER_AGENT', 'RBA_ZERO_TOUCH_TICKET_RATIO');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'ReferenceAccountLookup', 'V_REFERENCEACCOUNTLOOKUP', 'SYSTEM', 'Standard ReferenceAccountLookup view', ARRAY_CONSTRUCT('ACCOUNT_NAME');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'TransformGongAccountMap', 'V_TRANSFORMGONGACCOUNTMAP', 'SYSTEM', 'Standard TransformGongAccountMap view', ARRAY_CONSTRUCT('CRM_ACCOUNT_NAME', 'PARTNER_LEVEL_C', 'COMPETITOR_C', 'TOP_COMPETITOR_C', 'CRM_NET_ARR_USD');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'TransformGongOpportunitieMap', 'V_TRANSFORMGONGOPPORTUNITIEMAP', 'SYSTEM', 'Standard TransformGongOpportunitieMap view', ARRAY_CONSTRUCT('CRM_ACCOUNT_NAME', 'CRM_OPPORTUNITY_ID', 'OPPORTUNITY_NAME', 'OPPORTUNITY_TYPE', 'OPPORTUNITY_STATUS');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'TransformGongTrackerTaxonomy', 'V_TRANSFORMGONGTRACKERTAXONOMY', 'SYSTEM', 'Standard TransformGongTrackerTaxonomy view', ARRAY_CONSTRUCT('NAME', 'TRACKER_ARRAY', 'CAT1', 'CAT2', 'CAT3');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'UnifiedGongEvent', 'V_UNIFIEDGONGEVENT', 'SYSTEM', 'Standard UnifiedGongEvent view', ARRAY_CONSTRUCT('CALL_ID', 'CALL_DATE', 'TITLE', 'CALL_SPOTLIGHT_BRIEF', 'CALL_SPOTLIGHT_NEXT_STEPS');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'UnifiedUservoiceEvent', 'V_UNIFIEDUSERVOICEEVENT', 'SYSTEM', 'Standard UnifiedUservoiceEvent view', ARRAY_CONSTRUCT('FORUM_NAME', 'CATEGORY_NAME', 'SUGGESTION_NAME', 'SUGGESTION_BODY', 'SUGGESTION_CREATED_AT');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlContactActivityDailySnapshot', 'V_EDAMLCONTACTACTIVITYDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlContactActivityDailySnapshot view', ARRAY_CONSTRUCT('CRM_ACCOUNT_ID', 'ACTIVITY_SUBJECT', 'CONTACT_EMAIL', 'ACTIVITY_CATEGORY', 'ACTIVITY_TYPE');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlContactDailySnapshot', 'V_EDAMLCONTACTDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlContactDailySnapshot view', ARRAY_CONSTRUCT('CRM_ACCOUNT_ID', 'SOURCE_SNAPSHOT_DATE', 'CONTACT_ID', 'CONTACT_LAST_HUMAN_TOUCH', 'CONTACT_LAST_SALES_TOUCH_DATE_TIME');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlCrmAccountDailySnapshot', 'V_EDAMLCRMACCOUNTDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlCrmAccountDailySnapshot view', ARRAY_CONSTRUCT('SOURCE_SNAPSHOT_DATE', 'CRM_ACCOUNT_ID', 'CRM_OWNER_ID', 'CRM_PRIMARY_OWNER_NAME', 'CRM_INDUSTRY');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlInstanceAccountDailySnapshot', 'V_EDAMLINSTANCEACCOUNTDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlInstanceAccountDailySnapshot view', ARRAY_CONSTRUCT('INSTANCE_ACCOUNT_ID', 'SOURCE_SNAPSHOT_DATE', 'CRM_ACCOUNT_ID', 'INSTANCE_ACCOUNT_SUBDOMAIN', 'INSTANCE_ACCOUNT_NAME');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlInstanceChannelMonthlySnapshot', 'V_EDAMLINSTANCECHANNELMONTHLYSNAPSHOT', 'SYSTEM', 'Standard EdaMlInstanceChannelMonthlySnapshot view', ARRAY_CONSTRUCT('SOURCE_SNAPSHOT_DATE', 'MONTH_YEAR', 'INSTANCE_ACCOUNT_ID', 'CHANNEL_GROUP', 'RBA_CREATED_TICKETS');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlInstanceProductDailySnapshot', 'V_EDAMLINSTANCEPRODUCTDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlInstanceProductDailySnapshot view', ARRAY_CONSTRUCT('CRM_ACCOUNT_ID', 'INSTANCE_ACCOUNT_ID', 'SOURCE_SNAPSHOT_DATE', 'PRODUCT_OFFERING', 'PRODUCT_OFFERING_GROUPED');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlOpportunitieDailySnapshot', 'V_EDAMLOPPORTUNITIEDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlOpportunitieDailySnapshot view', ARRAY_CONSTRUCT('CRM_ACCOUNT_ID', 'CRM_OPPORTUNITY_ID', 'OPPORTUNITY_NAME', 'SOURCE_SNAPSHOT_DATE', 'OPPORTUNITY_CREATED_DATE');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlUserDailySnapshot', 'V_EDAMLUSERDAILYSNAPSHOT', 'SYSTEM', 'Standard EdaMlUserDailySnapshot view', ARRAY_CONSTRUCT('CRM_USER_ID', 'SOURCE_SNAPSHOT_DATE', 'USER_NAME', 'USER_EMAIL', 'USER_MARKET_SEGMENT');
INSERT INTO OBJ_VIEW_DEF (OBJ_TYPE, VIEW_NAME, CREATED_BY, DESCRIPTION, DISPLAY_COLS)
SELECT 'EdaMlUserAccountMapping', 'V_EDAMLUSERACCOUNTMAPPING', 'SYSTEM', 'Standard EdaMlUserAccountMapping view', ARRAY_CONSTRUCT('USER_NAME', 'USER_EMAIL', 'USER_ROLE_ON_ACCOUNT');

-- Object View Fields
CREATE TABLE IF NOT EXISTS OBJ_VIEW_FIELD (
    OBJ_TYPE            STRING,
    VIEW_NAME           STRING,
    VERSION             STRING DEFAULT '1.0',
    FIELD_ORDER         NUMBER,
    PROP_NAME           STRING,
    RENDER_HINT         STRING,
    PRIMARY KEY (OBJ_TYPE, VIEW_NAME, VERSION, PROP_NAME)
);

-- Roles and Permissions
CREATE TABLE IF NOT EXISTS ONT_ROLE (
    ONTOLOGY_NAME       STRING,
    ONT_ROLE_NAME       STRING,
    DESCRIPTION         STRING,
    PRIMARY KEY (ONTOLOGY_NAME, ONT_ROLE_NAME)
);

INSERT INTO ONT_ROLE (ONTOLOGY_NAME, ONT_ROLE_NAME, DESCRIPTION) VALUES
    ('TICKET_METRICS_ONT_POC', 'viewer', 'Read-only access to all entities'),
    ('TICKET_METRICS_ONT_POC', 'analyst', 'Read access plus analytics functions'),
    ('TICKET_METRICS_ONT_POC', 'editor', 'Read and write access to entities'),
    ('TICKET_METRICS_ONT_POC', 'admin', 'Full administrative access');

CREATE TABLE IF NOT EXISTS ONT_ROLE_BINDING (
    ONTOLOGY_NAME       STRING,
    ONT_ROLE_NAME       STRING,
    SNOWFLAKE_ROLE      STRING,
    PRIMARY KEY (ONTOLOGY_NAME, ONT_ROLE_NAME, SNOWFLAKE_ROLE)
);

CREATE TABLE IF NOT EXISTS ONT_PERMISSION (
    ONTOLOGY_NAME       STRING,
    SUBJECT_KIND        STRING,
    SUBJECT_NAME        STRING,
    ONT_ROLE_NAME       STRING,
    PRIVILEGE           STRING,
    PRIMARY KEY (ONTOLOGY_NAME, SUBJECT_KIND, SUBJECT_NAME, ONT_ROLE_NAME, PRIVILEGE)
);

INSERT INTO ONT_PERMISSION (ONTOLOGY_NAME, SUBJECT_KIND, SUBJECT_NAME, ONT_ROLE_NAME, PRIVILEGE) VALUES
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'CrmAccount', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'CrmAccount', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'Date', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'Date', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'InstanceAccount', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'InstanceAccount', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceAgentSummaryMonthly', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceAgentSummaryMonthly', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceChannelTicketMonthly', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceChannelTicketMonthly', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceGuideMetricMonthly', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceGuideMetricMonthly', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceRbaChannelMetricMonthly', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceRbaChannelMetricMonthly', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceRbaMetricMonthly', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'AggInstanceRbaMetricMonthly', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'ReferenceAccountLookup', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'ReferenceAccountLookup', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'TransformGongAccountMap', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'TransformGongAccountMap', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'TransformGongOpportunitieMap', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'TransformGongOpportunitieMap', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'TransformGongTrackerTaxonomy', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'TransformGongTrackerTaxonomy', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'UnifiedGongEvent', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'UnifiedGongEvent', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'UnifiedUservoiceEvent', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'UnifiedUservoiceEvent', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlContactActivityDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlContactActivityDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlContactDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlContactDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlCrmAccountDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlCrmAccountDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlInstanceAccountDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlInstanceAccountDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlInstanceChannelMonthlySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlInstanceChannelMonthlySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlInstanceProductDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlInstanceProductDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlOpportunitieDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlOpportunitieDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlUserDailySnapshot', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlUserDailySnapshot', 'admin', 'ADMIN'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlUserAccountMapping', 'viewer', 'READ'),
    ('TICKET_METRICS_ONT_POC', 'OBJECT_TYPE', 'EdaMlUserAccountMapping', 'admin', 'ADMIN');
