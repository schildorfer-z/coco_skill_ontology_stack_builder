CREATE OR REPLACE SEMANTIC VIEW _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.SV_KG_TICKET_METRICS
  COMMENT = 'Knowledge Graph semantic view exposing KG_NODE entity views and KG_EDGE relationship views for graph-oriented queries.'
  tables (
    -- Dimension entity views (from KG_NODE)
    CRM_ACCOUNT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_CRMACCOUNT
      primary key (NODE_ID)
      comment = 'CRM Account dimension nodes from KG_NODE. Central hub entity — all fact entities connect here via has_crm_account edges.',
    INSTANCE_ACCOUNT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_INSTANCEACCOUNT
      primary key (NODE_ID)
      comment = 'Instance Account (Zendesk subdomain) dimension nodes from KG_NODE. Child of CRM Account in the two-level hierarchy.',
    DATE_DIM as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_DATE
      primary key (NODE_ID)
      comment = 'Date dimension nodes from KG_NODE. Monthly grain calendar with year/quarter/month breakdowns.',

    -- Fact entity views (from KG_NODE)
    AGG_AGENTS_SUMMARY as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_AGGINSTANCEAGENTSUMMARYMONTHLY
      primary key (NODE_ID)
      comment = 'Monthly agent summary metrics per instance from KG_NODE. Contains active agent counts, ticket volumes, agent types.',
    AGG_CHANNEL_TICKETS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_AGGINSTANCECHANNELTICKETMONTHLY
      primary key (NODE_ID)
      comment = 'Monthly ticket counts per instance by channel from KG_NODE. Contains created, closed, and CSAT ticket counts.',
    AGG_GUIDE_METRICS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_AGGINSTANCEGUIDEMETRICMONTHLY
      primary key (NODE_ID)
      comment = 'Monthly Guide (help center) metrics per instance from KG_NODE. KB article views, community posts, published articles.',
    AGG_RBA_CHANNEL as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_AGGINSTANCERBACHANNELMETRICMONTHLY
      primary key (NODE_ID)
      comment = 'Monthly RBA metrics per instance per channel from KG_NODE. Non-additive: contains median FRT/TTC and ratios that cannot be summed across instances.',
    AGG_RBA_INSTANCE as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_AGGINSTANCERBAMETRICMONTHLY
      primary key (NODE_ID)
      comment = 'Monthly RBA metrics per instance (all channels combined) from KG_NODE. Non-additive: contains median FRT/TTC and ratios.',

    -- Relationship views (from KG_EDGE)
    REL_HAS_CRM_ACCOUNT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_HAS_CRM_ACCOUNT
      primary key (SRC_ID, DST_ID)
      comment = 'KG edges linking fact/instance entities to their CRM Account. The most common edge type (35.9M edges).',
    REL_HAS_INSTANCE_ACCOUNT as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_HAS_INSTANCE_ACCOUNT
      primary key (SRC_ID, DST_ID)
      comment = 'KG edges linking fact entities to their Instance Account (Zendesk subdomain).',
    REL_BELONGS_TO_DATE as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.V_BELONGS_TO_DATE
      primary key (SRC_ID, DST_ID)
      comment = 'KG edges linking fact entities to their Date dimension node for temporal queries.',

    -- Resolved relationships (enriched join of edges + node names)
    RELATIONSHIPS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.REL_RESOLVED
      primary key (SRC_ID, DST_ID, REL_NAME)
      comment = 'Resolved relationship view joining KG_EDGE with KG_NODE names. Contains source/destination IDs, names, types, and edge metadata. Use this for graph traversal questions.'
  )
  relationships (
    -- Entity → CRM Account edges
    AGG_AGENTS_SUMMARY_HAS_CRM as REL_HAS_CRM_ACCOUNT(SRC_ID) references AGG_AGENTS_SUMMARY(NODE_ID),
    AGG_CHANNEL_TICKETS_HAS_CRM as REL_HAS_CRM_ACCOUNT(SRC_ID) references AGG_CHANNEL_TICKETS(NODE_ID),
    AGG_GUIDE_METRICS_HAS_CRM as REL_HAS_CRM_ACCOUNT(SRC_ID) references AGG_GUIDE_METRICS(NODE_ID),
    AGG_RBA_CHANNEL_HAS_CRM as REL_HAS_CRM_ACCOUNT(SRC_ID) references AGG_RBA_CHANNEL(NODE_ID),
    AGG_RBA_INSTANCE_HAS_CRM as REL_HAS_CRM_ACCOUNT(SRC_ID) references AGG_RBA_INSTANCE(NODE_ID),
    INSTANCE_HAS_CRM as REL_HAS_CRM_ACCOUNT(SRC_ID) references INSTANCE_ACCOUNT(NODE_ID),
    CRM_IS_TARGET as REL_HAS_CRM_ACCOUNT(DST_ID) references CRM_ACCOUNT(NODE_ID),

    -- Entity → Instance Account edges
    AGG_AGENTS_SUMMARY_HAS_INST as REL_HAS_INSTANCE_ACCOUNT(SRC_ID) references AGG_AGENTS_SUMMARY(NODE_ID),
    AGG_CHANNEL_TICKETS_HAS_INST as REL_HAS_INSTANCE_ACCOUNT(SRC_ID) references AGG_CHANNEL_TICKETS(NODE_ID),
    AGG_GUIDE_METRICS_HAS_INST as REL_HAS_INSTANCE_ACCOUNT(SRC_ID) references AGG_GUIDE_METRICS(NODE_ID),
    AGG_RBA_CHANNEL_HAS_INST as REL_HAS_INSTANCE_ACCOUNT(SRC_ID) references AGG_RBA_CHANNEL(NODE_ID),
    AGG_RBA_INSTANCE_HAS_INST as REL_HAS_INSTANCE_ACCOUNT(SRC_ID) references AGG_RBA_INSTANCE(NODE_ID),
    INSTANCE_IS_TARGET as REL_HAS_INSTANCE_ACCOUNT(DST_ID) references INSTANCE_ACCOUNT(NODE_ID),

    -- Entity → Date edges
    AGG_AGENTS_SUMMARY_HAS_DATE as REL_BELONGS_TO_DATE(SRC_ID) references AGG_AGENTS_SUMMARY(NODE_ID),
    AGG_CHANNEL_TICKETS_HAS_DATE as REL_BELONGS_TO_DATE(SRC_ID) references AGG_CHANNEL_TICKETS(NODE_ID),
    AGG_GUIDE_METRICS_HAS_DATE as REL_BELONGS_TO_DATE(SRC_ID) references AGG_GUIDE_METRICS(NODE_ID),
    AGG_RBA_CHANNEL_HAS_DATE as REL_BELONGS_TO_DATE(SRC_ID) references AGG_RBA_CHANNEL(NODE_ID),
    AGG_RBA_INSTANCE_HAS_DATE as REL_BELONGS_TO_DATE(SRC_ID) references AGG_RBA_INSTANCE(NODE_ID),
    DATE_IS_TARGET as REL_BELONGS_TO_DATE(DST_ID) references DATE_DIM(NODE_ID),

    -- Resolved relationships → all entities
    REL_SRC_CRM as RELATIONSHIPS(SRC_ID) references CRM_ACCOUNT(NODE_ID),
    REL_SRC_INST as RELATIONSHIPS(SRC_ID) references INSTANCE_ACCOUNT(NODE_ID),
    REL_DST_CRM as RELATIONSHIPS(DST_ID) references CRM_ACCOUNT(NODE_ID),
    REL_DST_INST as RELATIONSHIPS(DST_ID) references INSTANCE_ACCOUNT(NODE_ID),
    REL_DST_DATE as RELATIONSHIPS(DST_ID) references DATE_DIM(NODE_ID)
  )
  dimensions (
    -- CRM Account dimensions
    CRM_ACCOUNT.NODE_ID as crm_node_id
      with synonyms = ('crm_account_id', 'crm_id', 'account_id')
      comment = 'KG node ID for CRM Account entity.',
    CRM_ACCOUNT.NAME as crm_account_name
      with synonyms = ('account_name', 'customer_name', 'company_name')
      comment = 'CRM Account name from Salesforce.',
    CRM_ACCOUNT.CRM_ACCOUNT_NAME as crm_display_name
      comment = 'Display name for CRM Account (may differ from node NAME).',
    CRM_ACCOUNT.CRM_OWNER_NAME as crm_owner
      with synonyms = ('account_owner', 'sales_rep')
      comment = 'Salesforce account owner name.',
    CRM_ACCOUNT.CRM_REGION as crm_region
      with synonyms = ('region', 'sales_region')
      comment = 'CRM Account region (Americas, EMEA, APJ, etc.).',
    CRM_ACCOUNT.CRM_MARKET_SEGMENT as crm_market_segment
      with synonyms = ('market_segment', 'segment')
      comment = 'CRM Account market segment (Enterprise, Mid-Market, SMB, etc.).',
    CRM_ACCOUNT.CRM_SUCCESS_OWNER_NAME as crm_success_owner
      with synonyms = ('success_owner', 'csm')
      comment = 'Customer success manager name.',

    -- Instance Account dimensions
    INSTANCE_ACCOUNT.NODE_ID as instance_node_id
      with synonyms = ('instance_id', 'instance_account_id')
      comment = 'KG node ID for Instance Account entity.',
    INSTANCE_ACCOUNT.NAME as instance_name
      comment = 'Instance Account name (typically the Zendesk subdomain).',
    INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_SUBDOMAIN as instance_subdomain
      with synonyms = ('subdomain', 'zendesk_subdomain', 'zendesk_instance')
      comment = 'Zendesk subdomain identifier for the instance account.',

    -- Date dimensions
    DATE_DIM.NODE_ID as date_node_id
      comment = 'KG node ID for Date dimension entity.',
    DATE_DIM.NAME as date_name
      comment = 'Date name label (e.g. "2024-03").',
    DATE_DIM.MONTH_DATE as month_date
      with synonyms = ('date', 'month')
      comment = 'Calendar month date.',
    DATE_DIM.CALENDAR_YEAR as calendar_year
      with synonyms = ('year')
      comment = 'Calendar year number.',
    DATE_DIM.CALENDAR_QUARTER as calendar_quarter
      with synonyms = ('quarter')
      comment = 'Calendar quarter (1-4).',
    DATE_DIM.CALENDAR_MONTH as calendar_month
      comment = 'Calendar month number (1-12).',
    DATE_DIM.MONTH_NAME as month_name
      comment = 'Month name (January, February, etc.).',
    DATE_DIM.YEAR_QUARTER as year_quarter
      comment = 'Year-quarter label (e.g. "2024-Q1").',
    DATE_DIM.YEAR_MONTH_LABEL as year_month_label
      comment = 'Year-month label (e.g. "2024-03").',

    -- Relationship dimensions
    RELATIONSHIPS.REL_NAME as relationship_type
      with synonyms = ('edge_type', 'relation', 'rel_type')
      comment = 'Type of KG relationship (has_crm_account, has_instance_account, belongs_to_date, has_conversation, agginstanceagentdetailmonthly).',
    RELATIONSHIPS.SRC_TYPE as source_entity_type
      with synonyms = ('src_type', 'source_type')
      comment = 'Entity type of the source node in the relationship.',
    RELATIONSHIPS.DST_TYPE as target_entity_type
      with synonyms = ('dst_type', 'destination_type', 'target_type')
      comment = 'Entity type of the destination node in the relationship.',
    RELATIONSHIPS.SRC_NAME as source_entity_name
      with synonyms = ('src_name', 'source_name')
      comment = 'Name of the source node in the relationship.',
    RELATIONSHIPS.DST_NAME as target_entity_name
      with synonyms = ('dst_name', 'destination_name', 'target_name')
      comment = 'Name of the destination node in the relationship.',

    -- Edge view dimensions
    REL_HAS_CRM_ACCOUNT.EDGE_TYPE as has_crm_edge_type
      comment = 'Edge type for has_crm_account relationships.',
    REL_HAS_INSTANCE_ACCOUNT.EDGE_TYPE as has_instance_edge_type
      comment = 'Edge type for has_instance_account relationships.',
    REL_BELONGS_TO_DATE.EDGE_TYPE as belongs_to_date_edge_type
      comment = 'Edge type for belongs_to_date relationships.',

    -- RBA Channel dimension from channel-level view
    AGG_RBA_CHANNEL.NAME as rba_channel_entity_name
      comment = 'Entity name for RBA channel-level metric node.'
  )
  metrics (
    -- Agent Summary metrics (additive)
    AGG_AGENTS_SUMMARY.TOTAL_ACTIVE_AGENTS as total_active_agents
      with synonyms = ('active_agents', 'agent_count')
      comment = 'Total active agents for the instance in the month. Additive across instances.',
    AGG_AGENTS_SUMMARY.REMAINING_AGENTS as remaining_agents
      comment = 'Remaining agent seats available.',
    AGG_AGENTS_SUMMARY.TOTAL_CLOSED_TICKETS as total_closed_tickets_agents
      with synonyms = ('closed_tickets')
      comment = 'Total tickets closed by agents in the month.',
    AGG_AGENTS_SUMMARY.ACTIVE_AGENTS_FOR_PRODUCTIVITY as active_agents_for_productivity
      comment = 'Active agents counted for productivity calculation.',
    AGG_AGENTS_SUMMARY.NUM_AGENTS_ADMIN as num_agents_admin
      comment = 'Number of admin agents.',
    AGG_AGENTS_SUMMARY.NUM_AGENTS_LIGHT as num_agents_light
      comment = 'Number of light agents.',
    AGG_AGENTS_SUMMARY.NUM_AGENTS_REGULAR as num_agents_regular
      comment = 'Number of regular agents.',

    -- Channel Ticket metrics (additive)
    AGG_CHANNEL_TICKETS.COUNT_CREATED_TICKETS as count_created_tickets
      with synonyms = ('tickets_created', 'new_tickets', 'created_tickets')
      comment = 'Number of tickets created in the month. Additive across instances.',
    AGG_CHANNEL_TICKETS.COUNT_CLOSED_TICKETS as count_closed_tickets
      with synonyms = ('tickets_closed', 'resolved_tickets')
      comment = 'Number of tickets closed in the month. Additive across instances.',
    AGG_CHANNEL_TICKETS.COUNT_CSAT_GOOD as count_csat_good
      comment = 'Number of good CSAT ratings received.',
    AGG_CHANNEL_TICKETS.COUNT_CSAT_OFFERED as count_csat_offered
      comment = 'Number of CSAT surveys offered.',
    AGG_CHANNEL_TICKETS.COUNT_CSAT_RESPONDED as count_csat_responded
      comment = 'Number of CSAT surveys responded to.',

    -- Guide metrics (additive)
    AGG_GUIDE_METRICS.NEW_KB_ARTICLE_VIEWS as new_kb_article_views
      with synonyms = ('article_views', 'kb_views')
      comment = 'New knowledge base article views in the month.',
    AGG_GUIDE_METRICS.NEW_COMMUNITY_POST_VIEWS as new_community_post_views
      comment = 'New community post views in the month.',
    AGG_GUIDE_METRICS.NUM_PUBLISHED_ARTICLES as num_published_articles
      comment = 'Number of published KB articles.',
    AGG_GUIDE_METRICS.NEW_KB_ARTICLES_CREATED as new_kb_articles_created
      comment = 'New KB articles created in the month.',
    AGG_GUIDE_METRICS.NEW_KB_COMMENTS as new_kb_comments
      comment = 'New KB article comments in the month.',
    AGG_GUIDE_METRICS.NEW_COMMUNITY_POST_ANSWERS as new_community_post_answers
      comment = 'New community post answers in the month.',
    AGG_GUIDE_METRICS.NEW_COMMUNITY_POST_QUESTIONS as new_community_post_questions
      comment = 'New community post questions in the month.',

    -- RBA Channel metrics (NON-ADDITIVE — per-instance medians and ratios)
    AGG_RBA_CHANNEL.RBA_CREATED_TICKETS as rba_channel_created_tickets
      comment = 'RBA created tickets per channel. NON-ADDITIVE: do not SUM across instances. Use only when filtering to a single instance.',
    AGG_RBA_CHANNEL.RBA_SOLVED_TICKETS as rba_channel_solved_tickets
      comment = 'RBA solved tickets per channel. NON-ADDITIVE: do not SUM across instances.',
    AGG_RBA_CHANNEL.RBA_FRT_MEDIAN_HOURS as rba_channel_frt_median_hours
      with synonyms = ('channel_first_reply_time', 'channel_frt')
      comment = 'Median first reply time in hours per channel. NON-ADDITIVE: this is a median — do not SUM or AVG across instances.',
    AGG_RBA_CHANNEL.RBA_TTC_MEDIAN_HOURS as rba_channel_ttc_median_hours
      with synonyms = ('channel_time_to_close', 'channel_ttc')
      comment = 'Median time to close in hours per channel. NON-ADDITIVE: this is a median — do not SUM or AVG across instances.',
    AGG_RBA_CHANNEL.RBA_CSAT_SCORE as rba_channel_csat_score
      comment = 'CSAT score per channel. NON-ADDITIVE: do not SUM across instances.',
    AGG_RBA_CHANNEL.RBA_CSAT_RESPONSE_RATE as rba_channel_csat_response_rate
      comment = 'CSAT response rate per channel. NON-ADDITIVE ratio.',

    -- RBA Instance metrics (NON-ADDITIVE — per-instance medians and ratios)
    AGG_RBA_INSTANCE.RBA_CREATED_TICKETS as rba_instance_created_tickets
      comment = 'RBA created tickets for all channels combined. NON-ADDITIVE: do not SUM across instances.',
    AGG_RBA_INSTANCE.RBA_SOLVED_TICKETS as rba_instance_solved_tickets
      comment = 'RBA solved tickets for all channels combined. NON-ADDITIVE.',
    AGG_RBA_INSTANCE.RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS as rba_unique_agents_solved
      comment = 'Unique agents who solved at least one ticket. NON-ADDITIVE.',
    AGG_RBA_INSTANCE.RBA_SOLVED_TICKETS_PER_AGENT as rba_solved_per_agent
      comment = 'Solved tickets per agent ratio. NON-ADDITIVE.',
    AGG_RBA_INSTANCE.RBA_ZERO_TOUCH_TICKET_RATIO as rba_zero_touch_ratio
      comment = 'Fraction of tickets resolved with zero agent touches. NON-ADDITIVE ratio.',
    AGG_RBA_INSTANCE.RBA_ONE_TOUCH_TICKET_RATIO as rba_one_touch_ratio
      comment = 'Fraction of tickets resolved with one agent touch. NON-ADDITIVE ratio.',
    AGG_RBA_INSTANCE.RBA_REOPENED_TICKET_RATIO as rba_reopened_ratio
      comment = 'Fraction of tickets that were reopened. NON-ADDITIVE ratio.',
    AGG_RBA_INSTANCE.RBA_ONE_PLUS_TOUCH_TICKETS as rba_one_plus_touch_tickets
      comment = 'Tickets requiring one or more agent touches. NON-ADDITIVE.',
    AGG_RBA_INSTANCE.RBA_FRT_MEDIAN_HOURS as rba_instance_frt_median_hours
      with synonyms = ('first_reply_time', 'frt', 'median_frt')
      comment = 'Median first reply time in hours (all channels). NON-ADDITIVE: this is a median — do not SUM or AVG across instances.',
    AGG_RBA_INSTANCE.RBA_TTC_MEDIAN_HOURS as rba_instance_ttc_median_hours
      with synonyms = ('time_to_close', 'ttc', 'median_ttc')
      comment = 'Median time to close in hours (all channels). NON-ADDITIVE: this is a median — do not SUM or AVG across instances.',
    AGG_RBA_INSTANCE.RBA_CSAT_SCORE as rba_instance_csat_score
      with synonyms = ('csat', 'csat_score', 'customer_satisfaction')
      comment = 'CSAT score (all channels). NON-ADDITIVE.',
    AGG_RBA_INSTANCE.RBA_CSAT_RESPONSE_RATE as rba_instance_csat_response_rate
      comment = 'CSAT response rate (all channels). NON-ADDITIVE ratio.',

    -- Relationship edge counts
    RELATIONSHIPS.WEIGHT as edge_weight
      comment = 'Weight of the KG edge (1.0 for standard edges).',

    -- Edge-level metrics from V_BELONGS_TO_DATE (carries RBA data)
    REL_BELONGS_TO_DATE.WEIGHT as date_edge_weight
      comment = 'Weight of belongs_to_date edge.'
  )
  ai_instructions (
    sql_generation = '
RULES FOR KG SEMANTIC VIEW QUERIES:
1. NODE_ID is the primary key for all entity views. Use it to join entities to edge views.
2. Edge views have SRC_ID and DST_ID — SRC_ID is the source entity NODE_ID, DST_ID is the target.
3. To find which CRM account a fact belongs to: JOIN fact entity ON fact.NODE_ID = REL_HAS_CRM_ACCOUNT.SRC_ID, then JOIN CRM_ACCOUNT ON REL_HAS_CRM_ACCOUNT.DST_ID = CRM_ACCOUNT.NODE_ID.
4. NON-ADDITIVE METRICS: RBA metrics (median FRT/TTC, ratios) are per-instance values. Never SUM or AVG them across instances. When the question asks about a single instance, return the value directly. When aggregating across multiple instances, use CASE WHEN COUNT(*) = 1 THEN MAX(value) ELSE NULL END and explain why.
5. For graph traversal questions (descendants, ancestors, paths), use the EXPAND_DESCENDANTS_TOOL, GET_ANCESTORS_TOOL, GET_HIERARCHY_PATH_TOOL, or GET_DIRECT_CHILDREN_TOOL UDFs.
6. The RELATIONSHIPS (REL_RESOLVED) table is the most convenient for ad-hoc graph queries — it already joins edge data with source and destination node names and types.
7. Date filtering: join via REL_BELONGS_TO_DATE to DATE_DIM, then filter on DATE_DIM.MONTH_DATE, CALENDAR_YEAR, CALENDAR_QUARTER, etc.
'
  )
;
