create or replace semantic view <db>.<schema>.sv_customer_trended_ticket_metrics
	tables (
		DIM_CRM_ACCOUNT as FUNCTIONAL.CONVERGE.DIM_CRM_ACCOUNT primary key (CRM_ACCOUNT_ID),
		DIM_DATE as FUNCTIONAL.CONVERGE.DIM_DATE primary key (MONTH_YEAR),
		DIM_INSTANCE_ACCOUNT as FUNCTIONAL.CONVERGE.DIM_INSTANCE_ACCOUNT primary key (INSTANCE_ACCOUNT_ID),
		FACT_AGENTS_SUMMARY as FUNCTIONAL.CONVERGE.FACT_AGG_INSTANCE_AGENTS_SUMMARY_MONTHLY primary key (INSTANCE_ACCOUNT_ID,MONTH_YEAR),
		FACT_GUIDE as FUNCTIONAL.CONVERGE.FACT_AGG_INSTANCE_GUIDE_METRICS_MONTHLY primary key (INSTANCE_ACCOUNT_ID,MONTH_YEAR),
		FACT_RBA_CHANNEL as FUNCTIONAL.CONVERGE.FACT_AGG_INSTANCE_RBA_CHANNEL_METRICS_MONTHLY primary key (INSTANCE_ACCOUNT_ID,MONTH_YEAR,RBA_CHANNEL_GROUP),
		FACT_RBA_INSTANCE as FUNCTIONAL.CONVERGE.FACT_AGG_INSTANCE_RBA_METRICS_MONTHLY primary key (INSTANCE_ACCOUNT_ID,MONTH_YEAR),
		FACT_TICKETS as FUNCTIONAL.CONVERGE.FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY primary key (INSTANCE_ACCOUNT_ID,MONTH_YEAR,TICKET_CHANNEL_GROUP),
		USERS as FUNCTIONAL.EDA_ML_DATA.EDA_ML_USERS_DAILY_SNAPSHOT_BCV primary key (CRM_USER_ID) comment='Daily snapshot of user data for row-level security filtering.',
		USER_ACCOUNT_MAPPING as FUNCTIONAL.EDA_ML_DATA.EDA_ML_USER_ACCOUNT_MAPPING_BCV primary key (CRM_ACCOUNT_ID,CRM_USER_ID) comment='Mapping table between users and CRM accounts for access control.'
	)
	relationships (
		FACT_AGENTS_SUMMARY_TO_DIM_CRM as FACT_AGENTS_SUMMARY(CRM_ACCOUNT_ID) references DIM_CRM_ACCOUNT(CRM_ACCOUNT_ID),
		FACT_AGENTS_SUMMARY_TO_DIM_DATE as FACT_AGENTS_SUMMARY(MONTH_YEAR) references DIM_DATE(MONTH_YEAR),
		FACT_AGENTS_SUMMARY_TO_DIM_INSTANCE as FACT_AGENTS_SUMMARY(INSTANCE_ACCOUNT_ID) references DIM_INSTANCE_ACCOUNT(INSTANCE_ACCOUNT_ID),
		FACT_GUIDE_TO_DIM_CRM as FACT_GUIDE(CRM_ACCOUNT_ID) references DIM_CRM_ACCOUNT(CRM_ACCOUNT_ID),
		FACT_GUIDE_TO_DIM_DATE as FACT_GUIDE(MONTH_YEAR) references DIM_DATE(MONTH_YEAR),
		FACT_GUIDE_TO_DIM_INSTANCE as FACT_GUIDE(INSTANCE_ACCOUNT_ID) references DIM_INSTANCE_ACCOUNT(INSTANCE_ACCOUNT_ID),
		FACT_RBA_CHANNEL_TO_DIM_CRM as FACT_RBA_CHANNEL(CRM_ACCOUNT_ID) references DIM_CRM_ACCOUNT(CRM_ACCOUNT_ID),
		FACT_RBA_CHANNEL_TO_DIM_DATE as FACT_RBA_CHANNEL(MONTH_YEAR) references DIM_DATE(MONTH_YEAR),
		FACT_RBA_CHANNEL_TO_DIM_INSTANCE as FACT_RBA_CHANNEL(INSTANCE_ACCOUNT_ID) references DIM_INSTANCE_ACCOUNT(INSTANCE_ACCOUNT_ID),
		FACT_RBA_INSTANCE_TO_DIM_CRM as FACT_RBA_INSTANCE(CRM_ACCOUNT_ID) references DIM_CRM_ACCOUNT(CRM_ACCOUNT_ID),
		FACT_RBA_INSTANCE_TO_DIM_DATE as FACT_RBA_INSTANCE(MONTH_YEAR) references DIM_DATE(MONTH_YEAR),
		FACT_RBA_INSTANCE_TO_DIM_INSTANCE as FACT_RBA_INSTANCE(INSTANCE_ACCOUNT_ID) references DIM_INSTANCE_ACCOUNT(INSTANCE_ACCOUNT_ID),
		FACT_TICKETS_TO_DIM_CRM as FACT_TICKETS(CRM_ACCOUNT_ID) references DIM_CRM_ACCOUNT(CRM_ACCOUNT_ID),
		FACT_TICKETS_TO_DIM_DATE as FACT_TICKETS(MONTH_YEAR) references DIM_DATE(MONTH_YEAR),
		FACT_TICKETS_TO_DIM_INSTANCE as FACT_TICKETS(INSTANCE_ACCOUNT_ID) references DIM_INSTANCE_ACCOUNT(INSTANCE_ACCOUNT_ID),
		USER_MAPPING_TO_CRM as USER_ACCOUNT_MAPPING(CRM_ACCOUNT_ID) references DIM_CRM_ACCOUNT(CRM_ACCOUNT_ID),
		USER_MAPPING_TO_USERS as USER_ACCOUNT_MAPPING(CRM_USER_ID) references USERS(CRM_USER_ID)
	)
	dimensions (
		DIM_CRM_ACCOUNT.CRM_ACCOUNT_ID as crm_account_id with synonyms=('account_id','account_identifier','account_key','crm_id','customer_account_id','salesforce_account_id','salesforce_id','sf_account_id','sfdc_id') comment='Salesforce CRM Account ID (18 characters) linking Zendesk instance to CRM customer record.',
		DIM_CRM_ACCOUNT.CRM_ACCOUNT_NAME as crm_account_name with synonyms=('account_name','client_name','company_name','crm_name','customer_account_name','customer_name','organization_name','salesforce_account_name','salesforce_name','sfdc_name') comment='Customer account name from Salesforce CRM.

Matching Strategy (SMART BLEND):
1. PREFER EXACT MATCH FIRST
   - Try case-insensitive exact match before fuzzy search
   - ''Printify'' matches ''printify'' (case-insensitive)
   - ''Uber Freight'' matches ''Uber Freight'' exactly

2. If no exact match → Use fuzzy search
   - Partial matches supported (e.g., ''Printify'' finds ''Printify Inc.'')
   - Typo tolerance: up to 2 character edits
   - Short names match full legal names (e.g., ''Uber'' → ''Uber Technologies Inc.'')

3. ALWAYS explain what matched in the answer
   - Exact: "Showing results for Printify"
   - Fuzzy: "Matched ''Printfy'' to ''Printify Inc.'' (closest match, fixed 1 typo)"
   - Multiple: "Found 3 accounts matching ''Tech'': TechCorp, TechSolutions, TechVision. Please specify which one."

Rationale:
- Exact match avoids false positives (e.g., ''Spring Health'' vs ''Sprinter Health'')
- Fuzzy search handles legitimate typos and variations
- Explaining matches builds user trust and catches errors early

Display:
- When showing results, GROUP BY this dimension to display matched account name
',
		DIM_CRM_ACCOUNT.CRM_MARKET_SEGMENT as crm_market_segment with synonyms=('market_segment') comment='Market segment classification for the CRM account (e.g., Enterprise, Commercial, Digital).',
		DIM_CRM_ACCOUNT.CRM_OWNER_NAME as crm_owner_name with synonyms=('account_executive','account_owner','account_rep','ae owner name','ae_name','crm_ae_owner','sales_owner','sales_rep') comment='Name of the CRM AE account owner (Account Executive assigned to account).',
		DIM_CRM_ACCOUNT.CRM_REGION as crm_region with synonyms=('account_region','geographic_region','region','sales_region','sales_territory','territory') comment='Geographic overarching sales region for the CRM account (e.g., AMER, EMEA, APAC, LATAM).',
		DIM_CRM_ACCOUNT.CRM_SUCCESS_OWNER_NAME as crm_success_owner_name with synonyms=('csm','csm_name','customer_success_manager','customer_success_owner','success_manager','success_owner') comment='Name of the Customer Success Manager assigned to the CRM account. Should reflect the current CSM (not historical) - use for filtering by current success owner.',
		DIM_DATE.MONTH_YEAR as month_year with synonyms=('month','month_start','month_start_date','monthly_period','reporting_month') comment='First day of the reporting month (YYYY-MM-01 format) used as the primary time dimension for all monthly aggregations and time-series analysis.',
		DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_ID as instance_account_id with synonyms=('instance_id','instance_identifier','subdomain_id','zendesk_account_id','zendesk_id','zendesk_instance_id') comment='Unique identifier for a Zendesk instance account.',
		DIM_INSTANCE_ACCOUNT.INSTANCE_ACCOUNT_SUBDOMAIN as instance_account_subdomain with synonyms=('account_subdomain','instance_name','instance_subdomain','subdomain','subdomain_name','zendesk_subdomain') comment='Zendesk subdomain for the instance (e.g., uberfreight, pinterest-business, pinterest2).

Matching Strategy (SMART BLEND):
1. PREFER EXACT MATCH FIRST
   - Try case-insensitive exact match before fuzzy search
   - ''pinterest2'' matches ''pinterest2'' exactly (NOT ''pinterest-business'')
   - ''Uberfreight'' matches ''uberfreight'' (case-insensitive)

2. If no exact match → Use fuzzy search
   - Partial matches supported (e.g., ''pinterest'' finds ''pinterest-business'' if ''pinterest'' doesn''t exist)
   - Common variations: hyphens, underscores, numeric suffixes
   - Example: ''pinterest-bus'' → ''pinterest-business'' (partial match)

3. ALWAYS explain what matched in the answer
   - Exact: "Showing results for subdomain ''pinterest2''"
   - Fuzzy: "Matched ''pinterest'' to ''pinterest-business'' (closest match - exact ''pinterest'' not found)"
   - Multiple: "Found 9 pinterest subdomains. Please specify: pinterest2, pinterest-business, pinterest-enterprise, ..."

Rationale:
- Numeric suffixes distinguish separate instances (''pinterest2'' ≠ ''pinterest-business'')
- Exact match prevents wrong instance data (different customers, different SLAs)
- Fuzzy search handles legitimate variations when exact not found

Display:
- When showing results, include this dimension to show which subdomain was queried

This is a different taxonomy from primary channel and should not be treated as interchangeable.
',
		FACT_RBA_CHANNEL.RBA_CHANNEL_GROUP as rba_channel_group with synonyms=('rba_channel','rba_channel_name','reply_channel') comment='RBA (Reply-Based Analytics) channel classification for ticket analysis.

Matching Strategy (CASE-INSENSITIVE):
- All text matching is case-insensitive
- ''async channels'' = ''Async channels'' = ''ASYNC CHANNELS''
- ''phone'' = ''Phone'' = ''PHONE''
- ALWAYS normalize user input to match stored values case-insensitively
- ALWAYS state matched value in answer: "Showing results for channel ''Async channels'' (matched ''async channels'')"

Rationale:
- Users type channel names casually (''messaging'' vs ''Messaging'')
- Case differences shouldn''t block valid queries
- Stating matched value confirms correct channel was queried

IMPORTANT: This is a DISTINCT taxonomy from TICKET_CHANNEL_GROUP (primary channels).
- RBA channels are based on the channel of the first public reply
- Primary channels are based on ticket creation source
- Do not mix or join these taxonomies unless explicitly requested
',
		FACT_TICKETS.TICKET_CHANNEL_GROUP as ticket_channel_group with synonyms=('channel','channel_group','channel_name','primary_channel','ticket_channel') comment='Primary Zendesk ticket channel classification.

Matching Strategy (CASE-INSENSITIVE):
- All text matching is case-insensitive
- ''messaging'' = ''Messaging'' = ''MESSAGING''
- ''web'' = ''Web'' = ''WEB''
- ALWAYS normalize user input to match stored values case-insensitively
- ALWAYS state matched value in answer: "Showing results for channel ''Messaging'' (matched ''messaging'')"

Rationale:
- Users type channel names casually (''chat'' vs ''Chat'')
- Case differences shouldn''t block valid queries
- Stating matched value confirms correct channel was queried

IMPORTANT: This taxonomy is distinct from RBA_CHANNEL_GROUP (messaging channel classifications).
- TICKET_CHANNEL_GROUP: Based on ticket creation source
- RBA_CHANNEL_GROUP: Based on the channel of the first public reply
- Do not mix these taxonomies unless explicitly requested
',
		USERS.CRM_USER_ID as crm_user_id with synonyms=('crm_user_key','user_id','user_identifier','zendesk_user_id') comment='Unique identifier for the CRM user.',
		USERS.USER_EMAIL as user_email with synonyms=('contact_email','email','email_address','email_id','user_contact_email','user_email_id') comment='The email address of the Zendesk user. Used for filtering data based on user access permissions.'
	)
	metrics (
		FACT_AGENTS_SUMMARY.ACTIVE_AGENTS as SUM(active_agents_for_productivity) with synonyms=('active_agent_count','agents_included_in_productivity','number_of_active_agents','productive_agents') comment='Total number of Admin and Agent agents that have logged into Zendesk in previous 30 days from last day of month.',
		FACT_AGENTS_SUMMARY.AGENTS_ACTIVATED as SUM(total_active_agents) with synonyms=('activated_agents','activated_seats','agent_seats','seats_occupied') comment='Number of occupied agent seats on the instance.',
		FACT_AGENTS_SUMMARY.AGENTS_ADMIN as SUM(num_agents_admin) with synonyms=('admin_role_count','admins','number_of_admin_agents') comment='Total number admins on the instance.',
		FACT_AGENTS_SUMMARY.AGENTS_LIGHT as SUM(num_agents_light) with synonyms=('light_agent_count','light_agents','number_of_light_agents') comment='Total number of Light Agents on the instance.',
		FACT_AGENTS_SUMMARY.AGENTS_REGULAR as SUM(num_agents_regular) with synonyms=('agents','regular_agent_count','regular_agents','standard_agents') comment='Total number of agents with Regular Agent role on the instance.',
		FACT_AGENTS_SUMMARY.AGENTS_REMAINING as SUM(remaining_agents) with synonyms=('available_agent_seats','remaining_seat_count','remaining_seats','seats_remaining','unused_agent_seats') comment='Number of remaining/unused agent seats available on the instance.',
		FACT_AGENTS_SUMMARY.AGENTS_UTILIZATION_RATE as AGENTS_ACTIVATED / NULLIF(AGENTS_ACTIVATED + AGENTS_REMAINING, 0) with synonyms=('agent_seat_occupancy_rate','agent_utilization','seat_utilization_rate') comment='Agent Utilization Rate: Percentage of occupied agent seats out of total available seats (occupied / (occupied + remaining)). Reflects how fully the purchased agent capacity is being utilized.',
		FACT_GUIDE.GUIDE_COMMUNITY_VIEWS as SUM(new_community_post_views) with synonyms=('community_post_views','community_views') comment='Total number of community post views in Zendesk Guide during the month.',
		FACT_GUIDE.GUIDE_KB_CREATED as SUM(new_kb_articles_created) with synonyms=('articles_created','kb_articles_created','new_articles','new_kb_articles') comment='Total number of new knowledge base articles created during the month.',
		FACT_GUIDE.GUIDE_KB_VIEWS as SUM(new_kb_article_views) with synonyms=('article_views','guide_views','help_center_views','kb_article_views','kb_views','knowledge_base_views') comment='Total knowledge base article views during the selected period.

Usage note:
- Requires a time period for meaningful interpretation
',
		FACT_GUIDE.GUIDE_PUBLISHED_ARTICLES as SUM(num_published_articles) with synonyms=('active_articles','live_articles','number_of_published_articles','published_kb_articles','total_published_articles') comment='Total count of published knowledge base articles available at month-end.',
		FACT_RBA_CHANNEL.RBA_FRT_HOURS_BY_CHANNEL as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_channel.rba_frt_median_hours)
        	ELSE NULL
      	END with synonyms=('channel_first_response_time','frt_by_channel','median_frt_by_channel') comment='Median first reply time in calendar hours by RBA channel group for an instance-month-channel.

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID AND RBA_CHANNEL_GROUP in the result set.
Returns NULL if aggregated across multiple instances or channels without proper grouping.

Use case: "What is the FRT for async channels for printifysupport?"
- Requires: Single instance filter OR per-instance grouping
- Requires: Single channel filter OR per-channel grouping

Interpretation:
- Returns median hours from ticket creation to first public agent reply
- Calculated per instance-month-channel
- Calendar hours only (business hours not supported)
',
		FACT_RBA_CHANNEL.RBA_ONE_TOUCH_BY_CHANNEL as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_channel.rba_one_touch_ticket_ratio) / 100
        	ELSE NULL
      	END with synonyms=('channel_one_touch_rate','one_touch_by_channel','one_touch_rate_by_channel') comment='One-Touch Resolution Rate by RBA channel group.

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID AND RBA_CHANNEL_GROUP in the result set.
Returns NULL if aggregated across multiple instances or channels without proper grouping.
',
		FACT_RBA_CHANNEL.RBA_TTC_HOURS_BY_CHANNEL as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_channel.rba_ttc_median_hours)
        	ELSE NULL
      	END with synonyms=('channel_full_resolution_time','channel_resolution_time','channel_ttc','channel_ttr','full_resolution_by_channel','ttc_by_channel','ttr_by_channel') comment='Median time to close in calendar hours by RBA channel group for an instance-month-channel.

CRITICAL: This metric is ONLY valid when queried with BOTH:
1. INSTANCE_ACCOUNT_ID (single instance OR per-instance grouping)
2. RBA_CHANNEL_GROUP (single channel OR per-channel grouping)

Returns NULL if aggregated across multiple instances or channels without proper grouping.

REFUSE if question asks for channel-level TTC without specifying instance.
See module_custom_instructions.question_categorization for full refusal policy.

Use case: "What is TTC for async channels for printifysupport?"
- Requires: Single instance filter OR per-instance grouping
- Requires: Single channel filter OR per-channel grouping

Interpretation:
- Returns median hours from ticket creation to final resolution
- Calculated per instance-month-channel
- Calendar hours only (business hours not supported)
',
		FACT_RBA_CHANNEL.RBA_ZERO_TOUCH_BY_CHANNEL as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_channel.rba_zero_touch_ticket_ratio) / 100
        	ELSE NULL
      	END with synonyms=('channel_zero_touch_rate','zero_touch_by_channel','zero_touch_rate_by_channel') comment='Zero-Touch Resolution Rate by RBA channel group. Expressed as decimal (0.15 = 15%).

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID AND RBA_CHANNEL_GROUP in the result set.
Returns NULL if aggregated across multiple instances or channels without proper grouping.
',
		FACT_RBA_INSTANCE.RBA_FRT_HOURS as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_instance.rba_frt_median_hours)
        	ELSE NULL
      	END with synonyms=('first_reply_time','first_response_time','frt','median_first_reply_time','median_first_response_time','median_frt','time_to_first_response') comment='Median first reply time in calendar hours for an instance-month.

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID in the result set.
Returns NULL if aggregated across multiple instances without per-instance grouping.

Interpretation:
- Returns median hours from ticket creation to first public agent reply
- Calculated per instance-month
- Calendar hours only (business hours not supported)
',
		FACT_RBA_INSTANCE.RBA_ONE_TOUCH_RATIO as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_instance.rba_one_touch_ticket_ratio) / 100
        	ELSE NULL
      	END with synonyms=('fcr_rate','first_contact_resolution_rate','one_and_done_rate','one_touch_rate','one_touch_ticket_ratio','single_response_resolution','single_touch_resolution_rate') comment='One-Touch Resolution Rate: Percentage of solved tickets resolved with exactly one agent reply (Reply-Based Analytics).

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID in the result set.
Returns NULL if aggregated across multiple instances without per-instance grouping.
',
		FACT_RBA_INSTANCE.RBA_TTC_HOURS as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_instance.rba_ttc_median_hours)
        	ELSE NULL
      	END with synonyms=('median_full_resolution_time','median_time_to_resolve','median_ttr','resolution_time','time_to_resolution','ttc','ttr') comment='Median time to close in calendar hours for an instance-month.

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID in the result set.
Returns NULL if aggregated across multiple instances without per-instance grouping.

Interpretation:
- Returns median hours from ticket creation to final resolution
- Calculated per instance-month
- Calendar hours only (business hours not supported)
',
		FACT_RBA_INSTANCE.RBA_ZERO_TOUCH_RATIO as CASE WHEN COUNT(*) = 1
        	THEN AVG(fact_rba_instance.rba_zero_touch_ticket_ratio) / 100
        	ELSE NULL
      	END with synonyms=('zero_touch_rate','zero_touch_ratio') comment='Zero-Touch Resolution Rate: Percentage of solved tickets resolved without any public agent replies (Reply-Based Analytics). Expressed as decimal (0.15 = 15%).

CRITICAL: This metric is ONLY valid when queried with INSTANCE_ACCOUNT_ID in the result set.
Returns NULL if aggregated across multiple instances without per-instance grouping.
',
		FACT_TICKETS.CSAT_GOOD as SUM(count_csat_good) with synonyms=('good_csat_count','good_csat_responses','positive_csat','satisfied_csat_count','top_box_csat') comment='Total number of CSAT responses scored as 5 (very satisfied / good).',
		FACT_TICKETS.CSAT_OFFERED as SUM(count_csat_offered) with synonyms=('csat_offered_count','csat_survey_invites','csat_surveys','csat_surveys_sent','total_csat_offers') comment='Total number of CSAT surveys offered/sent to customers during the month.',
		FACT_TICKETS.CSAT_RESPONSE_RATE as SUM(count_csat_responded) / NULLIF(SUM(count_csat_offered), 0) with synonyms=('csat_completion_rate','csat_participation_rate','csat_survey_response_rate','survey_completion_rate','survey_response_rate') comment='Customer Satisfaction Response Rate: Percentage of CSAT surveys that received a completed response out of total surveys offered. ADDITIVE across instances — safe to aggregate by CRM account.',
		FACT_TICKETS.CSAT_RESPONSES as SUM(count_csat_responded) with synonyms=('completed_csat_surveys','csat_response_count','csat_survey_responses','responded_csat_count','total_csat_responses') comment='Total number of completed CSAT survey responses received during the month.',
		FACT_TICKETS.CSAT_SCORE as fact_tickets.csat_good / NULLIF(SUM(count_csat_responded), 0) with synonyms=('csat','customer_satisfaction_score','satisfaction_score') comment='Customer Satisfaction Score: Percentage of CSAT survey respondents who rated their experience as ''good'' (score of 5). Calculated as good ratings divided by total responses. ADDITIVE across instances — safe to aggregate by CRM account (weighted average via SUM numerator/denominator).',
		FACT_TICKETS.TICKETS_CLOSED as SUM(count_closed_tickets) with synonyms=('closed_ticket_count','closed_tickets','number_of_closed_tickets','resolved_tickets','total_closed_tickets') comment='Total number of tickets closed/resolved during the month.',
		FACT_TICKETS.TICKETS_CREATED as SUM(count_created_tickets) with synonyms=('created_ticket_count','created_tickets','new_ticket_count','new_tickets','number_of_created_tickets','ticket_volume','total_created_tickets') comment='Total number of tickets created during the month.',
		AGENTS_PRODUCTIVITY as fact_tickets.tickets_closed / NULLIF(fact_agents_summary.active_agents, 0) with synonyms=('agent_efficiency','agent_productivity_rate','average_solved_tickets_per_agent','closed_tickets_per_agent','productivity_rate','solved_tickets_per_agent') comment='Agent Productivity: number of tickets closed per active agent (total closed tickets / active agents for productivity).',
		SELF_SERVICE_RATIO as fact_guide.guide_kb_views / NULLIF(fact_tickets.tickets_created, 0) with synonyms=('deflection_ratio','self_help_ratio','self_service_deflection_rate') comment='Self-Service Ratio: Number of knowledge base article views per ticket created (Guide KB views / RBA created tickets). Higher ratio indicates better self-service adoption.'
	)
	comment='Ticket support analytics semantic view for Zendesk operations.

Scope: Ticket volumes, CSAT, agent metrics, KB usage, response times
Grain: Monthly aggregates at instance/channel/account level

Critical architectural constraints:
- RBA median metrics (FRT, TTC, ratios) are NON-ADDITIVE across instances
- Agent metrics (counts, utilization, productivity) are monthly SNAPSHOTS — never SUM across months
- One CRM account may own multiple Zendesk instances with different SLA profiles
- Primary channels and messaging channels are distinct taxonomies (not interchangeable)
- All times in calendar hours (not business hours)

Data architecture:
- FACT_RBA_INSTANCE: Instance-level RBA metrics (instance-month grain)
- FACT_RBA_CHANNEL: Channel-level RBA metrics (instance-month-channel grain)
- USER_ACCOUNT_MAPPING: Bridge table enabling user-level filtering (many-to-many)

Temporal defaults (when no time filter specified):
- Cumulative metrics: Last 24 completed months
- Point-in-time metrics: Last completed month only
- Relative periods: Always anchored to last completed month
- Current month: NEVER included (incomplete data)
'
	ai_sql_generation 'Aggregation has TWO dimensions — understand the difference:
1. Across INSTANCES (same month): ALL metrics are additive. SUM/ratio-of-SUMs across
   instances for one month is always valid (weighted average for ratios).
2. Across MONTHS: depends on whether metric is cumulative or a snapshot.
   - Cumulative (events that happened): tickets created, tickets closed, CSAT counts,
     KB views, community views. These CAN be summed across months.
   - Snapshot (state at month-end): agent counts, utilization, productivity, published articles.
     These CANNOT be summed across months. 100 agents in Jan + 100 agents in Feb ≠ 200 agents.
     For trends: return one row per month. For single value: use last completed month only.

Time handling:
- Completed month: Any month before the current calendar month (current month = incomplete data)
- Anchor: DATE_TRUNC(''''MONTH'''', CURRENT_DATE) = boundary separating complete from incomplete data
- Time ranges: Use DATEADD(MONTH, -N, anchor) with exclusive upper bound (< not <=)

Default windows (when user doesn''''t specify):
- Cumulative metrics (tickets, CSAT counts, views): Last 24 completed months
- Snapshot metrics (agent counts, utilization): Last completed month only

Period comparisons:
- YoY: trailing 12 completed months vs prior 12 (months -12..-1 vs -24..-13 from anchor)
- MoM: last completed month vs month before (month -1 vs -2 from anchor)
- User-specified periods: honor what they ask

Text matching:
- ALWAYS use UPPER() or LOWER() for case-insensitive comparisons
- Example: WHERE LOWER(rba_channel_group) = LOWER(''async channels'')

RBA table selection:
- FACT_RBA_INSTANCE when no channel dimension needed
- FACT_RBA_CHANNEL when question mentions channels

RBA grouping (STRICT):
- ALWAYS include INSTANCE_ACCOUNT_SUBDOMAIN in GROUP BY for RBA queries
- NEVER aggregate RBA medians across instances

Cross-fact metrics (CRITICAL - prevents fan-out bugs):
- Some metrics reference multiple fact tables at different grains (e.g., AGENTS_PRODUCTIVITY, SELF_SERVICE_RATIO)
- NEVER join fact tables directly and SUM both sides — this causes fan-out and double-counting
- CORRECT pattern: Pre-aggregate each fact table to the target grain BEFORE joining
- Each metric component (numerator/denominator) must be computed separately, then joined
- Apply to ANY metric that references multiple fact tables'
	ai_question_categorization 'Text dimension matching (account names, subdomains, channels):
- ALWAYS try exact match (case-insensitive) before fuzzy search
- ALWAYS state what matched in answer: "Matched ''printfy'' → ''Printify Inc'' (typo correction)"
- NEVER fuzzy-match when exact match exists (''pinterest2'' MUST NOT match ''pinterest-business'')

Non-additive metric guardrails (RBA medians and pre-aggregated ratios ONLY):
- Non-additive metrics: RBA_FRT_MEDIAN_HOURS, RBA_TTC_MEDIAN_HOURS,
  RBA_ONE_TOUCH_RATIO, RBA_ZERO_TOUCH_RATIO (and their channel variants)
- REFUSE these metrics by CRM account name (aggregation across instances invalid)
- REFUSE these metrics when NO instance is specified
- ALLOW when instance_account_subdomain IS specified (subdomain = instance filter)
- ALLOW per-instance breakdown: "for each instance of Ticket Master"

Additive metrics (CAN aggregate across instances — do NOT refuse):
- CSAT (SUM-based ratios: good/responded, good/offered) — additive, safe to aggregate
- Ticket counts, KB views — additive
- Agent productivity (closed_tickets/active_agents from same table) — ratio of sums, safe

Instance filter recognition:
- instance_account_subdomain value (e.g., ''printifysupport'') IS a valid instance filter
- CRM account name is NOT an instance filter (one account may own multiple instances)

Unit conversion:
- If user asks for minutes but metric is in hours: ANSWER in hours and state the unit
- NEVER refuse just because unit doesn''t match — convert or clarify

Refusal template:
"Cannot aggregate [metric] across instances. The account may have multiple instances with different values. Specify instance subdomain or request per-instance breakdown."'
	ai_verified_queries (
		"Total tickets created for an account" AS ( 
QUESTION 'How many tickets were created for Uber Freight?' 
ONBOARDING_QUESTION false
SQL 'SELECT SUM(count_created_tickets) AS total_created_tickets FROM FACT_TICKETS AS f JOIN DIM_CRM_ACCOUNT AS a ON f.CRM_ACCOUNT_ID = a.CRM_ACCOUNT_ID WHERE a.CRM_ACCOUNT_NAME = ''Uber Freight'''),
		"Median FRT for a specific instance" AS ( 
QUESTION 'What is the median first response time for zendeskhelp?' 
ONBOARDING_QUESTION false
SQL 'SELECT f.MONTH_YEAR, f.RBA_FRT_MEDIAN_HOURS FROM FACT_RBA_INSTANCE AS f JOIN DIM_INSTANCE_ACCOUNT AS i ON f.INSTANCE_ACCOUNT_ID = i.INSTANCE_ACCOUNT_ID WHERE i.INSTANCE_ACCOUNT_SUBDOMAIN = ''zendeskhelp'' ORDER BY f.MONTH_YEAR'),
		"Median TTC by channel for a specific instance" AS ( 
QUESTION 'What is the ttc for Phone channels in hours for uberfreight?' 
ONBOARDING_QUESTION false
SQL 'SELECT f.MONTH_YEAR, f.RBA_TTC_MEDIAN_HOURS FROM FACT_RBA_CHANNEL AS f JOIN DIM_INSTANCE_ACCOUNT AS i ON f.INSTANCE_ACCOUNT_ID = i.INSTANCE_ACCOUNT_ID WHERE i.INSTANCE_ACCOUNT_SUBDOMAIN = ''uberfreight'' AND f.RBA_CHANNEL_GROUP = ''Phone'' ORDER BY f.MONTH_YEAR'),
		"CSAT score for an account" AS ( 
QUESTION 'What is the CSAT score for Datadog?' 
ONBOARDING_QUESTION false
SQL 'SELECT ROUND(CAST(SUM(count_csat_good) AS DOUBLE) / NULLIF(SUM(count_csat_responded), 0), 4) AS csat_score FROM FACT_TICKETS AS f JOIN DIM_CRM_ACCOUNT AS a ON f.CRM_ACCOUNT_ID = a.CRM_ACCOUNT_ID WHERE a.CRM_ACCOUNT_NAME = ''Datadog''')
	)
	with extension (CA='{"tables":[{"name":"DIM_CRM_ACCOUNT","dimensions":[{"name":"CRM_ACCOUNT_ID"},{"name":"CRM_ACCOUNT_NAME"},{"name":"CRM_MARKET_SEGMENT"},{"name":"CRM_OWNER_NAME"},{"name":"CRM_REGION"},{"name":"CRM_SUCCESS_OWNER_NAME"}]},{"name":"DIM_DATE","dimensions":[{"name":"MONTH_YEAR"}]},{"name":"DIM_INSTANCE_ACCOUNT","dimensions":[{"name":"INSTANCE_ACCOUNT_ID"},{"name":"INSTANCE_ACCOUNT_SUBDOMAIN"}]},{"name":"FACT_AGENTS_SUMMARY","metrics":[{"name":"ACTIVE_AGENTS"},{"name":"AGENTS_ACTIVATED"},{"name":"AGENTS_ADMIN"},{"name":"AGENTS_LIGHT"},{"name":"AGENTS_REGULAR"},{"name":"AGENTS_REMAINING"},{"name":"AGENTS_UTILIZATION_RATE"}]},{"name":"FACT_GUIDE","metrics":[{"name":"GUIDE_COMMUNITY_VIEWS"},{"name":"GUIDE_KB_CREATED"},{"name":"GUIDE_KB_VIEWS"},{"name":"GUIDE_PUBLISHED_ARTICLES"}]},{"name":"FACT_RBA_CHANNEL","dimensions":[{"name":"RBA_CHANNEL_GROUP","sample_values":["Async channels","Phone","Native Chat and Messaging","Social Messaging","API/Web service","other_channel"]}],"metrics":[{"name":"RBA_FRT_HOURS_BY_CHANNEL"},{"name":"RBA_ONE_TOUCH_BY_CHANNEL"},{"name":"RBA_TTC_HOURS_BY_CHANNEL"},{"name":"RBA_ZERO_TOUCH_BY_CHANNEL"}]},{"name":"FACT_RBA_INSTANCE","metrics":[{"name":"RBA_FRT_HOURS"},{"name":"RBA_ONE_TOUCH_RATIO"},{"name":"RBA_TTC_HOURS"},{"name":"RBA_ZERO_TOUCH_RATIO"}]},{"name":"FACT_TICKETS","dimensions":[{"name":"TICKET_CHANNEL_GROUP","sample_values":["API","Chat","Email","Messaging","Mobile SDK","Other","Phone","Web"]}],"metrics":[{"name":"CSAT_GOOD"},{"name":"CSAT_OFFERED"},{"name":"CSAT_RESPONSE_RATE"},{"name":"CSAT_RESPONSES"},{"name":"CSAT_SCORE"},{"name":"TICKETS_CLOSED"},{"name":"TICKETS_CREATED"}]},{"name":"USERS","dimensions":[{"name":"CRM_USER_ID"},{"name":"USER_EMAIL"}]},{"name":"USER_ACCOUNT_MAPPING"}],"relationships":[{"name":"FACT_AGENTS_SUMMARY_TO_DIM_CRM"},{"name":"FACT_AGENTS_SUMMARY_TO_DIM_DATE"},{"name":"FACT_AGENTS_SUMMARY_TO_DIM_INSTANCE"},{"name":"FACT_GUIDE_TO_DIM_CRM"},{"name":"FACT_GUIDE_TO_DIM_DATE"},{"name":"FACT_GUIDE_TO_DIM_INSTANCE"},{"name":"FACT_RBA_CHANNEL_TO_DIM_CRM"},{"name":"FACT_RBA_CHANNEL_TO_DIM_DATE"},{"name":"FACT_RBA_CHANNEL_TO_DIM_INSTANCE"},{"name":"FACT_RBA_INSTANCE_TO_DIM_CRM"},{"name":"FACT_RBA_INSTANCE_TO_DIM_DATE"},{"name":"FACT_RBA_INSTANCE_TO_DIM_INSTANCE"},{"name":"FACT_TICKETS_TO_DIM_CRM"},{"name":"FACT_TICKETS_TO_DIM_DATE"},{"name":"FACT_TICKETS_TO_DIM_INSTANCE"},{"name":"USER_MAPPING_TO_CRM"},{"name":"USER_MAPPING_TO_USERS"}]}');