-- ============================================================================
-- Concrete Entity & Relationship Views
-- Typed views over KG_NODE/KG_EDGE (KG path) or source tables (direct path)
-- Generated: 2026-04-15 21:38 UTC
-- ============================================================================

USE SCHEMA _SANDBOX_ONTOLOGY_POC.TICKET_METRICS;

-- V_CRMACCOUNT: Typed view for CrmAccount (KG path)
CREATE OR REPLACE VIEW V_CRMACCOUNT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_owner_name::STRING AS CRM_OWNER_NAME,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_market_segment::STRING AS CRM_MARKET_SEGMENT,
    PROPS:crm_success_owner_name::STRING AS CRM_SUCCESS_OWNER_NAME,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'CrmAccount';

-- V_DATE: Typed view for Date (KG path)
CREATE OR REPLACE VIEW V_DATE AS
SELECT
    NODE_ID,
    NAME,
    PROPS:month_date::DATE AS MONTH_DATE,
    PROPS:month_year_number::NUMBER AS MONTH_YEAR_NUMBER,
    PROPS:calendar_year::NUMBER AS CALENDAR_YEAR,
    PROPS:calendar_quarter::NUMBER AS CALENDAR_QUARTER,
    PROPS:calendar_month::NUMBER AS CALENDAR_MONTH,
    PROPS:month_name::STRING AS MONTH_NAME,
    PROPS:year_quarter::STRING AS YEAR_QUARTER,
    PROPS:year_month_label::STRING AS YEAR_MONTH_LABEL,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'Date';

-- V_INSTANCEACCOUNT: Typed view for InstanceAccount (KG path)
CREATE OR REPLACE VIEW V_INSTANCEACCOUNT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:instance_account_subdomain::STRING AS INSTANCE_ACCOUNT_SUBDOMAIN,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'InstanceAccount';

-- V_AGGINSTANCEAGENTSUMMARYMONTHLY: Typed view for AggInstanceAgentSummaryMonthly (KG path)
CREATE OR REPLACE VIEW V_AGGINSTANCEAGENTSUMMARYMONTHLY AS
SELECT
    NODE_ID,
    NAME,
    PROPS:total_active_agents::NUMBER AS TOTAL_ACTIVE_AGENTS,
    PROPS:remaining_agents::NUMBER AS REMAINING_AGENTS,
    PROPS:total_closed_tickets::NUMBER AS TOTAL_CLOSED_TICKETS,
    PROPS:active_agents_for_productivity::NUMBER AS ACTIVE_AGENTS_FOR_PRODUCTIVITY,
    PROPS:num_agents_admin::NUMBER AS NUM_AGENTS_ADMIN,
    PROPS:num_agents_light::NUMBER AS NUM_AGENTS_LIGHT,
    PROPS:num_agents_regular::NUMBER AS NUM_AGENTS_REGULAR,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'AggInstanceAgentSummaryMonthly';

-- V_AGGINSTANCECHANNELTICKETMONTHLY: Typed view for AggInstanceChannelTicketMonthly (KG path)
CREATE OR REPLACE VIEW V_AGGINSTANCECHANNELTICKETMONTHLY AS
SELECT
    NODE_ID,
    NAME,
    PROPS:count_created_tickets::NUMBER AS COUNT_CREATED_TICKETS,
    PROPS:count_closed_tickets::NUMBER AS COUNT_CLOSED_TICKETS,
    PROPS:count_csat_good::NUMBER AS COUNT_CSAT_GOOD,
    PROPS:count_csat_offered::NUMBER AS COUNT_CSAT_OFFERED,
    PROPS:count_csat_responded::NUMBER AS COUNT_CSAT_RESPONDED,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'AggInstanceChannelTicketMonthly';

-- V_AGGINSTANCEGUIDEMETRICMONTHLY: Typed view for AggInstanceGuideMetricMonthly (KG path)
CREATE OR REPLACE VIEW V_AGGINSTANCEGUIDEMETRICMONTHLY AS
SELECT
    NODE_ID,
    NAME,
    PROPS:new_kb_article_views::NUMBER AS NEW_KB_ARTICLE_VIEWS,
    PROPS:new_community_post_views::NUMBER AS NEW_COMMUNITY_POST_VIEWS,
    PROPS:num_published_articles::NUMBER AS NUM_PUBLISHED_ARTICLES,
    PROPS:new_kb_articles_created::NUMBER AS NEW_KB_ARTICLES_CREATED,
    PROPS:new_kb_comments::NUMBER AS NEW_KB_COMMENTS,
    PROPS:new_community_post_answers::NUMBER AS NEW_COMMUNITY_POST_ANSWERS,
    PROPS:new_community_post_questions::NUMBER AS NEW_COMMUNITY_POST_QUESTIONS,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'AggInstanceGuideMetricMonthly';

-- V_AGGINSTANCERBACHANNELMETRICMONTHLY: Typed view for AggInstanceRbaChannelMetricMonthly (KG path)
CREATE OR REPLACE VIEW V_AGGINSTANCERBACHANNELMETRICMONTHLY AS
SELECT
    NODE_ID,
    NAME,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'AggInstanceRbaChannelMetricMonthly';

-- V_AGGINSTANCERBAMETRICMONTHLY: Typed view for AggInstanceRbaMetricMonthly (KG path)
CREATE OR REPLACE VIEW V_AGGINSTANCERBAMETRICMONTHLY AS
SELECT
    NODE_ID,
    NAME,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'AggInstanceRbaMetricMonthly';

-- V_REFERENCEACCOUNTLOOKUP: Typed view for ReferenceAccountLookup (KG path)
CREATE OR REPLACE VIEW V_REFERENCEACCOUNTLOOKUP AS
SELECT
    NODE_ID,
    NAME,
    PROPS:account_name::STRING AS ACCOUNT_NAME,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'ReferenceAccountLookup';

-- V_TRANSFORMGONGACCOUNTMAP: Typed view for TransformGongAccountMap (KG path)
CREATE OR REPLACE VIEW V_TRANSFORMGONGACCOUNTMAP AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:partner_level_c::STRING AS PARTNER_LEVEL_C,
    PROPS:competitor_c::STRING AS COMPETITOR_C,
    PROPS:top_competitor_c::STRING AS TOP_COMPETITOR_C,
    PROPS:crm_net_arr_usd::NUMBER AS CRM_NET_ARR_USD,
    PROPS:crm_account_type::STRING AS CRM_ACCOUNT_TYPE,
    PROPS:crm_health_status::STRING AS CRM_HEALTH_STATUS,
    PROPS:crm_industry::STRING AS CRM_INDUSTRY,
    PROPS:crm_sub_industry::STRING AS CRM_SUB_INDUSTRY,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_sub_region::STRING AS CRM_SUB_REGION,
    PROPS:crm_market_segment::STRING AS CRM_MARKET_SEGMENT,
    PROPS:crm_market_super_segment::STRING AS CRM_MARKET_SUPER_SEGMENT,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'TransformGongAccountMap';

-- V_TRANSFORMGONGOPPORTUNITIEMAP: Typed view for TransformGongOpportunitieMap (KG path)
CREATE OR REPLACE VIEW V_TRANSFORMGONGOPPORTUNITIEMAP AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_opportunity_id::STRING AS CRM_OPPORTUNITY_ID,
    PROPS:opportunity_name::STRING AS OPPORTUNITY_NAME,
    PROPS:opportunity_type::STRING AS OPPORTUNITY_TYPE,
    PROPS:opportunity_status::STRING AS OPPORTUNITY_STATUS,
    PROPS:stage_2_plus_date_c::DATE AS STAGE_2_PLUS_DATE_C,
    PROPS:closedate::DATE AS CLOSEDATE,
    PROPS:product_list::STRING AS PRODUCT_LIST,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'TransformGongOpportunitieMap';

-- V_TRANSFORMGONGTRACKERTAXONOMY: Typed view for TransformGongTrackerTaxonomy (KG path)
CREATE OR REPLACE VIEW V_TRANSFORMGONGTRACKERTAXONOMY AS
SELECT
    NODE_ID,
    NAME,
    PROPS:tracker_array::VARIANT AS TRACKER_ARRAY,
    PROPS:cat1::STRING AS CAT1,
    PROPS:cat2::STRING AS CAT2,
    PROPS:cat3::STRING AS CAT3,
    PROPS:cat4::STRING AS CAT4,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'TransformGongTrackerTaxonomy';

-- V_UNIFIEDGONGEVENT: Typed view for UnifiedGongEvent (KG path)
CREATE OR REPLACE VIEW V_UNIFIEDGONGEVENT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:call_id::STRING AS CALL_ID,
    PROPS:call_date::DATE AS CALL_DATE,
    PROPS:title::STRING AS TITLE,
    PROPS:call_spotlight_brief::STRING AS CALL_SPOTLIGHT_BRIEF,
    PROPS:call_spotlight_next_steps::STRING AS CALL_SPOTLIGHT_NEXT_STEPS,
    PROPS:call_spotlight_key_points::VARIANT AS CALL_SPOTLIGHT_KEY_POINTS,
    PROPS:call_spotlight::VARIANT AS CALL_SPOTLIGHT,
    PROPS:transcript::VARIANT AS TRANSCRIPT,
    PROPS:call_spotlight_overview::STRING AS CALL_SPOTLIGHT_OVERVIEW,
    PROPS:call_transcript_curated::STRING AS CALL_TRANSCRIPT_CURATED,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'UnifiedGongEvent';

-- V_UNIFIEDUSERVOICEEVENT: Typed view for UnifiedUservoiceEvent (KG path)
CREATE OR REPLACE VIEW V_UNIFIEDUSERVOICEEVENT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:forum_name::STRING AS FORUM_NAME,
    PROPS:category_name::STRING AS CATEGORY_NAME,
    PROPS:suggestion_name::STRING AS SUGGESTION_NAME,
    PROPS:suggestion_body::STRING AS SUGGESTION_BODY,
    PROPS:suggestion_created_at::TIMESTAMP_NTZ AS SUGGESTION_CREATED_AT,
    PROPS:suggestion_updated_at::TIMESTAMP_NTZ AS SUGGESTION_UPDATED_AT,
    PROPS:suggestion_state::STRING AS SUGGESTION_STATE,
    PROPS:request_body::STRING AS REQUEST_BODY,
    PROPS:request_created_at::TIMESTAMP_NTZ AS REQUEST_CREATED_AT,
    PROPS:request_updated_at::TIMESTAMP_NTZ AS REQUEST_UPDATED_AT,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_net_arr_usd::NUMBER AS CRM_NET_ARR_USD,
    PROPS:crm_account_type::STRING AS CRM_ACCOUNT_TYPE,
    PROPS:crm_health_status::STRING AS CRM_HEALTH_STATUS,
    PROPS:crm_industry::STRING AS CRM_INDUSTRY,
    PROPS:crm_sub_industry::STRING AS CRM_SUB_INDUSTRY,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_sub_region::STRING AS CRM_SUB_REGION,
    PROPS:crm_market_segment::STRING AS CRM_MARKET_SEGMENT,
    PROPS:crm_market_super_segment::STRING AS CRM_MARKET_SUPER_SEGMENT,
    PROPS:request_overview::STRING AS REQUEST_OVERVIEW,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'UnifiedUservoiceEvent';

-- V_EDAMLCONTACTACTIVITYDAILYSNAPSHOT: Typed view for EdaMlContactActivityDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLCONTACTACTIVITYDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_id::STRING AS CRM_ACCOUNT_ID,
    PROPS:activity_subject::STRING AS ACTIVITY_SUBJECT,
    PROPS:contact_email::STRING AS CONTACT_EMAIL,
    PROPS:activity_category::STRING AS ACTIVITY_CATEGORY,
    PROPS:activity_type::STRING AS ACTIVITY_TYPE,
    PROPS:activity_zendesk_division::STRING AS ACTIVITY_ZENDESK_DIVISION,
    PROPS:activity_zendesk_user::STRING AS ACTIVITY_ZENDESK_USER,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlContactActivityDailySnapshot';

-- V_EDAMLCONTACTDAILYSNAPSHOT: Typed view for EdaMlContactDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLCONTACTDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_id::STRING AS CRM_ACCOUNT_ID,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:contact_id::STRING AS CONTACT_ID,
    PROPS:contact_last_human_touch::DATE AS CONTACT_LAST_HUMAN_TOUCH,
    PROPS:contact_last_sales_touch_date_time::TIMESTAMP_NTZ AS CONTACT_LAST_SALES_TOUCH_DATE_TIME,
    PROPS:contact_role::STRING AS CONTACT_ROLE,
    PROPS:contact_job_role::STRING AS CONTACT_JOB_ROLE,
    PROPS:contact_intent_score_6_sense::FLOAT AS CONTACT_INTENT_SCORE_6_SENSE,
    PROPS:contact_title::STRING AS CONTACT_TITLE,
    PROPS:contact_email::STRING AS CONTACT_EMAIL,
    PROPS:contact_phone_number::STRING AS CONTACT_PHONE_NUMBER,
    PROPS:contact_name::STRING AS CONTACT_NAME,
    PROPS:contact_created_date::TIMESTAMP_NTZ AS CONTACT_CREATED_DATE,
    PROPS:contact_lead_source::STRING AS CONTACT_LEAD_SOURCE,
    PROPS:num_web_visits_l30d::NUMBER AS NUM_WEB_VISITS_L30D,
    PROPS:num_web_forms_l30d::NUMBER AS NUM_WEB_FORMS_L30D,
    PROPS:num_opened_emails_l30d::NUMBER AS NUM_OPENED_EMAILS_L30D,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlContactDailySnapshot';

-- V_EDAMLCRMACCOUNTDAILYSNAPSHOT: Typed view for EdaMlCrmAccountDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLCRMACCOUNTDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:crm_account_id::STRING AS CRM_ACCOUNT_ID,
    PROPS:crm_owner_id::STRING AS CRM_OWNER_ID,
    PROPS:crm_primary_owner_name::STRING AS CRM_PRIMARY_OWNER_NAME,
    PROPS:crm_industry::STRING AS CRM_INDUSTRY,
    PROPS:crm_sub_industry::STRING AS CRM_SUB_INDUSTRY,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_sub_region::STRING AS CRM_SUB_REGION,
    PROPS:pro_forma_market_segment::STRING AS PRO_FORMA_MARKET_SEGMENT,
    PROPS:pro_forma_market_subsegment::STRING AS PRO_FORMA_MARKET_SUBSEGMENT,
    PROPS:pro_forma_market_super_segment::STRING AS PRO_FORMA_MARKET_SUPER_SEGMENT,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_health_status::STRING AS CRM_HEALTH_STATUS,
    PROPS:crm_date_became_customer::DATE AS CRM_DATE_BECAME_CUSTOMER,
    PROPS:crm_parent_id::STRING AS CRM_PARENT_ID,
    PROPS:crm_account_type::STRING AS CRM_ACCOUNT_TYPE,
    PROPS:crm_net_arr_usd::NUMBER AS CRM_NET_ARR_USD,
    PROPS:crm_next_renewal_date::DATE AS CRM_NEXT_RENEWAL_DATE,
    PROPS:crm_number_of_employees::NUMBER AS CRM_NUMBER_OF_EMPLOYEES,
    PROPS:crm_revenue::NUMBER AS CRM_REVENUE,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlCrmAccountDailySnapshot';

-- V_EDAMLINSTANCEACCOUNTDAILYSNAPSHOT: Typed view for EdaMlInstanceAccountDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLINSTANCEACCOUNTDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:instance_account_id::NUMBER AS INSTANCE_ACCOUNT_ID,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:crm_account_id::STRING AS CRM_ACCOUNT_ID,
    PROPS:instance_account_subdomain::STRING AS INSTANCE_ACCOUNT_SUBDOMAIN,
    PROPS:instance_account_name::STRING AS INSTANCE_ACCOUNT_NAME,
    PROPS:instance_account_arr_usd::NUMBER AS INSTANCE_ACCOUNT_ARR_USD,
    PROPS:seats_capacity::NUMBER AS SEATS_CAPACITY,
    PROPS:seats_occupied::NUMBER AS SEATS_OCCUPIED,
    PROPS:seat_utilization::NUMBER AS SEAT_UTILIZATION,
    PROPS:active_agents_l30d::NUMBER AS ACTIVE_AGENTS_L30D,
    PROPS:csat_score::NUMBER AS CSAT_SCORE,
    PROPS:new_tickets_l30d::NUMBER AS NEW_TICKETS_L30D,
    PROPS:solved_tickets_l30d::NUMBER AS SOLVED_TICKETS_L30D,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlInstanceAccountDailySnapshot';

-- V_EDAMLINSTANCECHANNELMONTHLYSNAPSHOT: Typed view for EdaMlInstanceChannelMonthlySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLINSTANCECHANNELMONTHLYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:month_year::DATE AS MONTH_YEAR,
    PROPS:instance_account_id::NUMBER AS INSTANCE_ACCOUNT_ID,
    PROPS:channel_group::STRING AS CHANNEL_GROUP,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttr_median_hours::NUMBER AS RBA_TTR_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlInstanceChannelMonthlySnapshot';

-- V_EDAMLINSTANCEPRODUCTDAILYSNAPSHOT: Typed view for EdaMlInstanceProductDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLINSTANCEPRODUCTDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_id::STRING AS CRM_ACCOUNT_ID,
    PROPS:instance_account_id::NUMBER AS INSTANCE_ACCOUNT_ID,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:product_offering::STRING AS PRODUCT_OFFERING,
    PROPS:product_offering_grouped::STRING AS PRODUCT_OFFERING_GROUPED,
    PROPS:product_plan::STRING AS PRODUCT_PLAN,
    PROPS:net_arr_usd::NUMBER AS NET_ARR_USD,
    PROPS:seats::NUMBER AS SEATS,
    PROPS:quantity::NUMBER AS QUANTITY,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlInstanceProductDailySnapshot';

-- V_EDAMLOPPORTUNITIEDAILYSNAPSHOT: Typed view for EdaMlOpportunitieDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLOPPORTUNITIEDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_account_id::STRING AS CRM_ACCOUNT_ID,
    PROPS:crm_opportunity_id::STRING AS CRM_OPPORTUNITY_ID,
    PROPS:opportunity_name::STRING AS OPPORTUNITY_NAME,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:opportunity_created_date::TIMESTAMP_NTZ AS OPPORTUNITY_CREATED_DATE,
    PROPS:opportunity_close_date::DATE AS OPPORTUNITY_CLOSE_DATE,
    PROPS:opportunity_type::STRING AS OPPORTUNITY_TYPE,
    PROPS:opportunity_status::STRING AS OPPORTUNITY_STATUS,
    PROPS:opportunity_stage_name::STRING AS OPPORTUNITY_STAGE_NAME,
    PROPS:opportunity_booking_arr_usd::NUMBER AS OPPORTUNITY_BOOKING_ARR_USD,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlOpportunitieDailySnapshot';

-- V_EDAMLUSERDAILYSNAPSHOT: Typed view for EdaMlUserDailySnapshot (KG path)
CREATE OR REPLACE VIEW V_EDAMLUSERDAILYSNAPSHOT AS
SELECT
    NODE_ID,
    NAME,
    PROPS:crm_user_id::STRING AS CRM_USER_ID,
    PROPS:source_snapshot_date::DATE AS SOURCE_SNAPSHOT_DATE,
    PROPS:user_name::STRING AS USER_NAME,
    PROPS:user_email::STRING AS USER_EMAIL,
    PROPS:user_market_segment::STRING AS USER_MARKET_SEGMENT,
    PROPS:user_region::STRING AS USER_REGION,
    PROPS:user_sub_region::STRING AS USER_SUB_REGION,
    PROPS:manager_1_email::STRING AS MANAGER_1_EMAIL,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlUserDailySnapshot';

-- V_EDAMLUSERACCOUNTMAPPING: Typed view for EdaMlUserAccountMapping (KG path)
CREATE OR REPLACE VIEW V_EDAMLUSERACCOUNTMAPPING AS
SELECT
    NODE_ID,
    NAME,
    PROPS:user_name::STRING AS USER_NAME,
    PROPS:user_email::STRING AS USER_EMAIL,
    PROPS:user_role_on_account::STRING AS USER_ROLE_ON_ACCOUNT,
    PROPS
FROM KG_NODE
WHERE NODE_TYPE = 'EdaMlUserAccountMapping';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:instance_account_subdomain::STRING AS INSTANCE_ACCOUNT_SUBDOMAIN
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_HAS_INSTANCE_ACCOUNT: Relationship view for has_instance_account (KG path)
CREATE OR REPLACE VIEW V_HAS_INSTANCE_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:total_active_agents::NUMBER AS TOTAL_ACTIVE_AGENTS,
    PROPS:remaining_agents::NUMBER AS REMAINING_AGENTS,
    PROPS:total_closed_tickets::NUMBER AS TOTAL_CLOSED_TICKETS,
    PROPS:active_agents_for_productivity::NUMBER AS ACTIVE_AGENTS_FOR_PRODUCTIVITY,
    PROPS:num_agents_admin::NUMBER AS NUM_AGENTS_ADMIN,
    PROPS:num_agents_light::NUMBER AS NUM_AGENTS_LIGHT,
    PROPS:num_agents_regular::NUMBER AS NUM_AGENTS_REGULAR
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_instance_account';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:total_active_agents::NUMBER AS TOTAL_ACTIVE_AGENTS,
    PROPS:remaining_agents::NUMBER AS REMAINING_AGENTS,
    PROPS:total_closed_tickets::NUMBER AS TOTAL_CLOSED_TICKETS,
    PROPS:active_agents_for_productivity::NUMBER AS ACTIVE_AGENTS_FOR_PRODUCTIVITY,
    PROPS:num_agents_admin::NUMBER AS NUM_AGENTS_ADMIN,
    PROPS:num_agents_light::NUMBER AS NUM_AGENTS_LIGHT,
    PROPS:num_agents_regular::NUMBER AS NUM_AGENTS_REGULAR
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_BELONGS_TO_DATE: Relationship view for belongs_to_date (KG path)
CREATE OR REPLACE VIEW V_BELONGS_TO_DATE AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:total_active_agents::NUMBER AS TOTAL_ACTIVE_AGENTS,
    PROPS:remaining_agents::NUMBER AS REMAINING_AGENTS,
    PROPS:total_closed_tickets::NUMBER AS TOTAL_CLOSED_TICKETS,
    PROPS:active_agents_for_productivity::NUMBER AS ACTIVE_AGENTS_FOR_PRODUCTIVITY,
    PROPS:num_agents_admin::NUMBER AS NUM_AGENTS_ADMIN,
    PROPS:num_agents_light::NUMBER AS NUM_AGENTS_LIGHT,
    PROPS:num_agents_regular::NUMBER AS NUM_AGENTS_REGULAR
FROM KG_EDGE
WHERE EDGE_TYPE = 'belongs_to_date';

-- V_HAS_INSTANCE_ACCOUNT: Relationship view for has_instance_account (KG path)
CREATE OR REPLACE VIEW V_HAS_INSTANCE_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:count_created_tickets::NUMBER AS COUNT_CREATED_TICKETS,
    PROPS:count_closed_tickets::NUMBER AS COUNT_CLOSED_TICKETS,
    PROPS:count_csat_good::NUMBER AS COUNT_CSAT_GOOD,
    PROPS:count_csat_offered::NUMBER AS COUNT_CSAT_OFFERED,
    PROPS:count_csat_responded::NUMBER AS COUNT_CSAT_RESPONDED
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_instance_account';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:count_created_tickets::NUMBER AS COUNT_CREATED_TICKETS,
    PROPS:count_closed_tickets::NUMBER AS COUNT_CLOSED_TICKETS,
    PROPS:count_csat_good::NUMBER AS COUNT_CSAT_GOOD,
    PROPS:count_csat_offered::NUMBER AS COUNT_CSAT_OFFERED,
    PROPS:count_csat_responded::NUMBER AS COUNT_CSAT_RESPONDED
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_BELONGS_TO_DATE: Relationship view for belongs_to_date (KG path)
CREATE OR REPLACE VIEW V_BELONGS_TO_DATE AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:count_created_tickets::NUMBER AS COUNT_CREATED_TICKETS,
    PROPS:count_closed_tickets::NUMBER AS COUNT_CLOSED_TICKETS,
    PROPS:count_csat_good::NUMBER AS COUNT_CSAT_GOOD,
    PROPS:count_csat_offered::NUMBER AS COUNT_CSAT_OFFERED,
    PROPS:count_csat_responded::NUMBER AS COUNT_CSAT_RESPONDED
FROM KG_EDGE
WHERE EDGE_TYPE = 'belongs_to_date';

-- V_HAS_INSTANCE_ACCOUNT: Relationship view for has_instance_account (KG path)
CREATE OR REPLACE VIEW V_HAS_INSTANCE_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:new_kb_article_views::NUMBER AS NEW_KB_ARTICLE_VIEWS,
    PROPS:new_community_post_views::NUMBER AS NEW_COMMUNITY_POST_VIEWS,
    PROPS:num_published_articles::NUMBER AS NUM_PUBLISHED_ARTICLES,
    PROPS:new_kb_articles_created::NUMBER AS NEW_KB_ARTICLES_CREATED,
    PROPS:new_kb_comments::NUMBER AS NEW_KB_COMMENTS,
    PROPS:new_community_post_answers::NUMBER AS NEW_COMMUNITY_POST_ANSWERS,
    PROPS:new_community_post_questions::NUMBER AS NEW_COMMUNITY_POST_QUESTIONS
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_instance_account';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:new_kb_article_views::NUMBER AS NEW_KB_ARTICLE_VIEWS,
    PROPS:new_community_post_views::NUMBER AS NEW_COMMUNITY_POST_VIEWS,
    PROPS:num_published_articles::NUMBER AS NUM_PUBLISHED_ARTICLES,
    PROPS:new_kb_articles_created::NUMBER AS NEW_KB_ARTICLES_CREATED,
    PROPS:new_kb_comments::NUMBER AS NEW_KB_COMMENTS,
    PROPS:new_community_post_answers::NUMBER AS NEW_COMMUNITY_POST_ANSWERS,
    PROPS:new_community_post_questions::NUMBER AS NEW_COMMUNITY_POST_QUESTIONS
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_BELONGS_TO_DATE: Relationship view for belongs_to_date (KG path)
CREATE OR REPLACE VIEW V_BELONGS_TO_DATE AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:new_kb_article_views::NUMBER AS NEW_KB_ARTICLE_VIEWS,
    PROPS:new_community_post_views::NUMBER AS NEW_COMMUNITY_POST_VIEWS,
    PROPS:num_published_articles::NUMBER AS NUM_PUBLISHED_ARTICLES,
    PROPS:new_kb_articles_created::NUMBER AS NEW_KB_ARTICLES_CREATED,
    PROPS:new_kb_comments::NUMBER AS NEW_KB_COMMENTS,
    PROPS:new_community_post_answers::NUMBER AS NEW_COMMUNITY_POST_ANSWERS,
    PROPS:new_community_post_questions::NUMBER AS NEW_COMMUNITY_POST_QUESTIONS
FROM KG_EDGE
WHERE EDGE_TYPE = 'belongs_to_date';

-- V_HAS_INSTANCE_ACCOUNT: Relationship view for has_instance_account (KG path)
CREATE OR REPLACE VIEW V_HAS_INSTANCE_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_instance_account';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_BELONGS_TO_DATE: Relationship view for belongs_to_date (KG path)
CREATE OR REPLACE VIEW V_BELONGS_TO_DATE AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE
FROM KG_EDGE
WHERE EDGE_TYPE = 'belongs_to_date';

-- V_HAS_INSTANCE_ACCOUNT: Relationship view for has_instance_account (KG path)
CREATE OR REPLACE VIEW V_HAS_INSTANCE_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_instance_account';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_BELONGS_TO_DATE: Relationship view for belongs_to_date (KG path)
CREATE OR REPLACE VIEW V_BELONGS_TO_DATE AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:rba_created_tickets::NUMBER AS RBA_CREATED_TICKETS,
    PROPS:rba_solved_tickets::NUMBER AS RBA_SOLVED_TICKETS,
    PROPS:rba_unique_agents_with_solved_tickets::NUMBER AS RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS,
    PROPS:rba_solved_tickets_per_agent::NUMBER AS RBA_SOLVED_TICKETS_PER_AGENT,
    PROPS:rba_zero_touch_ticket_ratio::NUMBER AS RBA_ZERO_TOUCH_TICKET_RATIO,
    PROPS:rba_one_touch_ticket_ratio::NUMBER AS RBA_ONE_TOUCH_TICKET_RATIO,
    PROPS:rba_reopened_ticket_ratio::NUMBER AS RBA_REOPENED_TICKET_RATIO,
    PROPS:rba_one_plus_touch_tickets::NUMBER AS RBA_ONE_PLUS_TOUCH_TICKETS,
    PROPS:rba_frt_median_hours::NUMBER AS RBA_FRT_MEDIAN_HOURS,
    PROPS:rba_ttc_median_hours::NUMBER AS RBA_TTC_MEDIAN_HOURS,
    PROPS:rba_csat_score::NUMBER AS RBA_CSAT_SCORE,
    PROPS:rba_csat_response_rate::NUMBER AS RBA_CSAT_RESPONSE_RATE
FROM KG_EDGE
WHERE EDGE_TYPE = 'belongs_to_date';

-- V_HAS_CONVERSATION: Relationship view for has_conversation (KG path)
CREATE OR REPLACE VIEW V_HAS_CONVERSATION AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:partner_level_c::STRING AS PARTNER_LEVEL_C,
    PROPS:competitor_c::STRING AS COMPETITOR_C,
    PROPS:top_competitor_c::STRING AS TOP_COMPETITOR_C,
    PROPS:crm_net_arr_usd::NUMBER AS CRM_NET_ARR_USD,
    PROPS:crm_account_type::STRING AS CRM_ACCOUNT_TYPE,
    PROPS:crm_health_status::STRING AS CRM_HEALTH_STATUS,
    PROPS:crm_industry::STRING AS CRM_INDUSTRY,
    PROPS:crm_sub_industry::STRING AS CRM_SUB_INDUSTRY,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_sub_region::STRING AS CRM_SUB_REGION,
    PROPS:crm_market_segment::STRING AS CRM_MARKET_SEGMENT,
    PROPS:crm_market_super_segment::STRING AS CRM_MARKET_SUPER_SEGMENT
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_conversation';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:partner_level_c::STRING AS PARTNER_LEVEL_C,
    PROPS:competitor_c::STRING AS COMPETITOR_C,
    PROPS:top_competitor_c::STRING AS TOP_COMPETITOR_C,
    PROPS:crm_net_arr_usd::NUMBER AS CRM_NET_ARR_USD,
    PROPS:crm_account_type::STRING AS CRM_ACCOUNT_TYPE,
    PROPS:crm_health_status::STRING AS CRM_HEALTH_STATUS,
    PROPS:crm_industry::STRING AS CRM_INDUSTRY,
    PROPS:crm_sub_industry::STRING AS CRM_SUB_INDUSTRY,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_sub_region::STRING AS CRM_SUB_REGION,
    PROPS:crm_market_segment::STRING AS CRM_MARKET_SEGMENT,
    PROPS:crm_market_super_segment::STRING AS CRM_MARKET_SUPER_SEGMENT
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_HAS_CONVERSATION: Relationship view for has_conversation (KG path)
CREATE OR REPLACE VIEW V_HAS_CONVERSATION AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_opportunity_id::STRING AS CRM_OPPORTUNITY_ID,
    PROPS:opportunity_name::STRING AS OPPORTUNITY_NAME,
    PROPS:opportunity_type::STRING AS OPPORTUNITY_TYPE,
    PROPS:opportunity_status::STRING AS OPPORTUNITY_STATUS,
    PROPS:stage_2_plus_date_c::DATE AS STAGE_2_PLUS_DATE_C,
    PROPS:closedate::DATE AS CLOSEDATE,
    PROPS:product_list::STRING AS PRODUCT_LIST
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_conversation';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_opportunity_id::STRING AS CRM_OPPORTUNITY_ID,
    PROPS:opportunity_name::STRING AS OPPORTUNITY_NAME,
    PROPS:opportunity_type::STRING AS OPPORTUNITY_TYPE,
    PROPS:opportunity_status::STRING AS OPPORTUNITY_STATUS,
    PROPS:stage_2_plus_date_c::DATE AS STAGE_2_PLUS_DATE_C,
    PROPS:closedate::DATE AS CLOSEDATE,
    PROPS:product_list::STRING AS PRODUCT_LIST
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_HAS_CRM_ACCOUNT: Relationship view for has_crm_account (KG path)
CREATE OR REPLACE VIEW V_HAS_CRM_ACCOUNT AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:forum_name::STRING AS FORUM_NAME,
    PROPS:category_name::STRING AS CATEGORY_NAME,
    PROPS:suggestion_name::STRING AS SUGGESTION_NAME,
    PROPS:suggestion_body::STRING AS SUGGESTION_BODY,
    PROPS:suggestion_created_at::TIMESTAMP_NTZ AS SUGGESTION_CREATED_AT,
    PROPS:suggestion_updated_at::TIMESTAMP_NTZ AS SUGGESTION_UPDATED_AT,
    PROPS:suggestion_state::STRING AS SUGGESTION_STATE,
    PROPS:request_body::STRING AS REQUEST_BODY,
    PROPS:request_created_at::TIMESTAMP_NTZ AS REQUEST_CREATED_AT,
    PROPS:request_updated_at::TIMESTAMP_NTZ AS REQUEST_UPDATED_AT,
    PROPS:crm_account_name::STRING AS CRM_ACCOUNT_NAME,
    PROPS:crm_net_arr_usd::NUMBER AS CRM_NET_ARR_USD,
    PROPS:crm_account_type::STRING AS CRM_ACCOUNT_TYPE,
    PROPS:crm_health_status::STRING AS CRM_HEALTH_STATUS,
    PROPS:crm_industry::STRING AS CRM_INDUSTRY,
    PROPS:crm_sub_industry::STRING AS CRM_SUB_INDUSTRY,
    PROPS:crm_region::STRING AS CRM_REGION,
    PROPS:crm_sub_region::STRING AS CRM_SUB_REGION,
    PROPS:crm_market_segment::STRING AS CRM_MARKET_SEGMENT,
    PROPS:crm_market_super_segment::STRING AS CRM_MARKET_SUPER_SEGMENT,
    PROPS:request_overview::STRING AS REQUEST_OVERVIEW
FROM KG_EDGE
WHERE EDGE_TYPE = 'has_crm_account';

-- V_AGGINSTANCEAGENTDETAILMONTHLY: Relationship view for agginstanceagentdetailmonthly (KG path)
CREATE OR REPLACE VIEW V_AGGINSTANCEAGENTDETAILMONTHLY AS
SELECT
    SRC_ID,
    DST_ID,
    EDGE_TYPE,
    PROPS,
    WEIGHT,
    EFFECTIVE_START,
    EFFECTIVE_END,
    PROPS:agent_role::STRING AS AGENT_ROLE
FROM KG_EDGE
WHERE EDGE_TYPE = 'agginstanceagentdetailmonthly';
