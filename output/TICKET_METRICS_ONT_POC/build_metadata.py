"""Build metadata JSON files for both schemas from pre-fetched column data."""
import json
import csv
import sys

# ── CONVERGE schema metadata ──
converge_tables = {
    "DIM_CRM_ACCOUNT": {
        "columns": [
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_ACCOUNT_NAME", "type": "TEXT", "nullable": True},
            {"name": "CRM_OWNER_NAME", "type": "TEXT", "nullable": True},
            {"name": "CRM_REGION", "type": "TEXT", "nullable": True},
            {"name": "CRM_MARKET_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUCCESS_OWNER_NAME", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["CRM_ACCOUNT_ID"],
        "foreign_keys": [],
    },
    "DIM_DATE": {
        "columns": [
            {"name": "MONTH_DATE", "type": "DATE", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True, "primary_key": True},
            {"name": "MONTH_YEAR_NUMBER", "type": "NUMBER", "nullable": True},
            {"name": "CALENDAR_YEAR", "type": "NUMBER", "nullable": True},
            {"name": "CALENDAR_QUARTER", "type": "NUMBER", "nullable": True},
            {"name": "CALENDAR_MONTH", "type": "NUMBER", "nullable": True},
            {"name": "MONTH_NAME", "type": "TEXT", "nullable": True},
            {"name": "YEAR_QUARTER", "type": "TEXT", "nullable": True},
            {"name": "YEAR_MONTH_LABEL", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["MONTH_YEAR"],
        "foreign_keys": [],
    },
    "DIM_INSTANCE_ACCOUNT": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True, "primary_key": True},
            {"name": "INSTANCE_ACCOUNT_SUBDOMAIN", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_ID"],
        "foreign_keys": [
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"}
        ],
    },
    "FACT_AGG_INSTANCE_AGENTS_DETAIL_MONTHLY": {
        "columns": [
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "AGENT_ROLE", "type": "TEXT", "nullable": True},
            {"name": "AGENT_ID", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["MONTH_YEAR", "INSTANCE_ACCOUNT_ID", "AGENT_ID"],
        "foreign_keys": [
            {"column": "INSTANCE_ACCOUNT_ID", "ref_table": "DIM_INSTANCE_ACCOUNT", "ref_column": "INSTANCE_ACCOUNT_ID"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
            {"column": "MONTH_YEAR", "ref_table": "DIM_DATE", "ref_column": "MONTH_YEAR"},
        ],
    },
    "FACT_AGG_INSTANCE_AGENTS_SUMMARY_MONTHLY": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "TOTAL_ACTIVE_AGENTS", "type": "NUMBER", "nullable": True},
            {"name": "REMAINING_AGENTS", "type": "NUMBER", "nullable": True},
            {"name": "TOTAL_CLOSED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "ACTIVE_AGENTS_FOR_PRODUCTIVITY", "type": "NUMBER", "nullable": True},
            {"name": "NUM_AGENTS_ADMIN", "type": "NUMBER", "nullable": True},
            {"name": "NUM_AGENTS_LIGHT", "type": "NUMBER", "nullable": True},
            {"name": "NUM_AGENTS_REGULAR", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_ID", "MONTH_YEAR"],
        "foreign_keys": [
            {"column": "INSTANCE_ACCOUNT_ID", "ref_table": "DIM_INSTANCE_ACCOUNT", "ref_column": "INSTANCE_ACCOUNT_ID"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
            {"column": "MONTH_YEAR", "ref_table": "DIM_DATE", "ref_column": "MONTH_YEAR"},
        ],
    },
    "FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "TICKET_CHANNEL_GROUP", "type": "TEXT", "nullable": True},
            {"name": "COUNT_CREATED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "COUNT_CLOSED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "COUNT_CSAT_GOOD", "type": "NUMBER", "nullable": True},
            {"name": "COUNT_CSAT_OFFERED", "type": "NUMBER", "nullable": True},
            {"name": "COUNT_CSAT_RESPONDED", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_ID", "MONTH_YEAR", "TICKET_CHANNEL_GROUP"],
        "foreign_keys": [
            {"column": "INSTANCE_ACCOUNT_ID", "ref_table": "DIM_INSTANCE_ACCOUNT", "ref_column": "INSTANCE_ACCOUNT_ID"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
            {"column": "MONTH_YEAR", "ref_table": "DIM_DATE", "ref_column": "MONTH_YEAR"},
        ],
    },
    "FACT_AGG_INSTANCE_GUIDE_METRICS_MONTHLY": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "NEW_KB_ARTICLE_VIEWS", "type": "NUMBER", "nullable": True},
            {"name": "NEW_COMMUNITY_POST_VIEWS", "type": "NUMBER", "nullable": True},
            {"name": "NUM_PUBLISHED_ARTICLES", "type": "NUMBER", "nullable": True},
            {"name": "NEW_KB_ARTICLES_CREATED", "type": "NUMBER", "nullable": True},
            {"name": "NEW_KB_COMMENTS", "type": "NUMBER", "nullable": True},
            {"name": "NEW_COMMUNITY_POST_ANSWERS", "type": "NUMBER", "nullable": True},
            {"name": "NEW_COMMUNITY_POST_QUESTIONS", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_ID", "MONTH_YEAR"],
        "foreign_keys": [
            {"column": "INSTANCE_ACCOUNT_ID", "ref_table": "DIM_INSTANCE_ACCOUNT", "ref_column": "INSTANCE_ACCOUNT_ID"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
            {"column": "MONTH_YEAR", "ref_table": "DIM_DATE", "ref_column": "MONTH_YEAR"},
        ],
    },
    "FACT_AGG_INSTANCE_RBA_CHANNEL_METRICS_MONTHLY": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "RBA_CHANNEL_GROUP", "type": "TEXT", "nullable": True},
            {"name": "RBA_CREATED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_SOLVED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_SOLVED_TICKETS_PER_AGENT", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ZERO_TOUCH_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ONE_TOUCH_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_REOPENED_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ONE_PLUS_TOUCH_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_FRT_MEDIAN_HOURS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_TTC_MEDIAN_HOURS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_CSAT_SCORE", "type": "NUMBER", "nullable": True},
            {"name": "RBA_CSAT_RESPONSE_RATE", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_ID", "MONTH_YEAR", "RBA_CHANNEL_GROUP"],
        "foreign_keys": [
            {"column": "INSTANCE_ACCOUNT_ID", "ref_table": "DIM_INSTANCE_ACCOUNT", "ref_column": "INSTANCE_ACCOUNT_ID"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
            {"column": "MONTH_YEAR", "ref_table": "DIM_DATE", "ref_column": "MONTH_YEAR"},
        ],
    },
    "FACT_AGG_INSTANCE_RBA_METRICS_MONTHLY": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "RBA_CREATED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_SOLVED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_SOLVED_TICKETS_PER_AGENT", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ZERO_TOUCH_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ONE_TOUCH_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_REOPENED_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ONE_PLUS_TOUCH_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_FRT_MEDIAN_HOURS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_TTC_MEDIAN_HOURS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_CSAT_SCORE", "type": "NUMBER", "nullable": True},
            {"name": "RBA_CSAT_RESPONSE_RATE", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_ID", "MONTH_YEAR"],
        "foreign_keys": [
            {"column": "INSTANCE_ACCOUNT_ID", "ref_table": "DIM_INSTANCE_ACCOUNT", "ref_column": "INSTANCE_ACCOUNT_ID"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
            {"column": "MONTH_YEAR", "ref_table": "DIM_DATE", "ref_column": "MONTH_YEAR"},
        ],
    },
    "REFERENCE_ACCOUNT_LOOKUP": {
        "columns": [
            {"name": "ACCOUNT_ID", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "ACCOUNT_NAME", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["ACCOUNT_ID"],
        "foreign_keys": [],
    },
    "TRANSFORM_GONG_ACCOUNTS_MAP": {
        "columns": [
            {"name": "CONVERSATION_KEY", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_NAME", "type": "TEXT", "nullable": True},
            {"name": "PARTNER_LEVEL_C", "type": "TEXT", "nullable": True},
            {"name": "COMPETITOR_C", "type": "TEXT", "nullable": True},
            {"name": "TOP_COMPETITOR_C", "type": "TEXT", "nullable": True},
            {"name": "CRM_NET_ARR_USD", "type": "NUMBER", "nullable": True},
            {"name": "CRM_ACCOUNT_TYPE", "type": "TEXT", "nullable": True},
            {"name": "CRM_HEALTH_STATUS", "type": "TEXT", "nullable": True},
            {"name": "CRM_INDUSTRY", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUB_INDUSTRY", "type": "TEXT", "nullable": True},
            {"name": "CRM_REGION", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUB_REGION", "type": "TEXT", "nullable": True},
            {"name": "CRM_MARKET_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "CRM_MARKET_SUPER_SEGMENT", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["CONVERSATION_KEY"],
        "foreign_keys": [
            {"column": "CONVERSATION_KEY", "ref_table": "UNIFIED_GONG_EVENTS", "ref_column": "CONVERSATION_KEY"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
        ],
    },
    "TRANSFORM_GONG_OPPORTUNITIES_MAP": {
        "columns": [
            {"name": "CONVERSATION_KEY", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_NAME", "type": "TEXT", "nullable": True},
            {"name": "CRM_OPPORTUNITY_ID", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_NAME", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_TYPE", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_STATUS", "type": "TEXT", "nullable": True},
            {"name": "STAGE_2_PLUS_DATE_C", "type": "DATE", "nullable": True},
            {"name": "CLOSEDATE", "type": "DATE", "nullable": True},
            {"name": "PRODUCT_LIST", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["CONVERSATION_KEY"],
        "foreign_keys": [
            {"column": "CONVERSATION_KEY", "ref_table": "UNIFIED_GONG_EVENTS", "ref_column": "CONVERSATION_KEY"},
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
        ],
    },
    "TRANSFORM_GONG_TRACKER_TAXONOMY": {
        "columns": [
            {"name": "TRACKER_ID", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "NAME", "type": "TEXT", "nullable": True},
            {"name": "TRACKER_ARRAY", "type": "ARRAY", "nullable": True},
            {"name": "CAT1", "type": "TEXT", "nullable": True},
            {"name": "CAT2", "type": "TEXT", "nullable": True},
            {"name": "CAT3", "type": "TEXT", "nullable": True},
            {"name": "CAT4", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["TRACKER_ID"],
        "foreign_keys": [],
    },
    "UNIFIED_GONG_EVENTS": {
        "columns": [
            {"name": "CALL_ID", "type": "TEXT", "nullable": True},
            {"name": "CONVERSATION_KEY", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CALL_DATE", "type": "DATE", "nullable": True},
            {"name": "TITLE", "type": "TEXT", "nullable": True},
            {"name": "CALL_SPOTLIGHT_BRIEF", "type": "TEXT", "nullable": True},
            {"name": "CALL_SPOTLIGHT_NEXT_STEPS", "type": "TEXT", "nullable": True},
            {"name": "CALL_SPOTLIGHT_KEY_POINTS", "type": "ARRAY", "nullable": True},
            {"name": "CALL_SPOTLIGHT", "type": "VARIANT", "nullable": True},
            {"name": "TRANSCRIPT", "type": "VARIANT", "nullable": True},
            {"name": "CALL_SPOTLIGHT_OVERVIEW", "type": "TEXT", "nullable": True},
            {"name": "CALL_TRANSCRIPT_CURATED", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["CONVERSATION_KEY"],
        "foreign_keys": [],
    },
    "UNIFIED_USERVOICE_EVENTS": {
        "columns": [
            {"name": "SUGGESTION_ID", "type": "NUMBER", "nullable": True},
            {"name": "REQUEST_ID", "type": "NUMBER", "nullable": True},
            {"name": "FORUM_NAME", "type": "TEXT", "nullable": True},
            {"name": "CATEGORY_NAME", "type": "TEXT", "nullable": True},
            {"name": "SUGGESTION_NAME", "type": "TEXT", "nullable": True},
            {"name": "SUGGESTION_BODY", "type": "TEXT", "nullable": True},
            {"name": "SUGGESTION_CREATED_AT", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "SUGGESTION_UPDATED_AT", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "SUGGESTION_STATE", "type": "TEXT", "nullable": True},
            {"name": "REQUEST_BODY", "type": "TEXT", "nullable": True},
            {"name": "REQUEST_CREATED_AT", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "REQUEST_UPDATED_AT", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_NAME", "type": "TEXT", "nullable": True},
            {"name": "CRM_NET_ARR_USD", "type": "NUMBER", "nullable": True},
            {"name": "CRM_ACCOUNT_TYPE", "type": "TEXT", "nullable": True},
            {"name": "CRM_HEALTH_STATUS", "type": "TEXT", "nullable": True},
            {"name": "CRM_INDUSTRY", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUB_INDUSTRY", "type": "TEXT", "nullable": True},
            {"name": "CRM_REGION", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUB_REGION", "type": "TEXT", "nullable": True},
            {"name": "CRM_MARKET_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "CRM_MARKET_SUPER_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "REQUEST_OVERVIEW", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["SUGGESTION_ID", "REQUEST_ID"],
        "foreign_keys": [
            {"column": "CRM_ACCOUNT_ID", "ref_table": "DIM_CRM_ACCOUNT", "ref_column": "CRM_ACCOUNT_ID"},
        ],
    },
}

# ── EDA_ML_DATA schema metadata (key tables only - trimmed to important columns) ──
eda_ml_tables = {
    "EDA_ML_CONTACTS_ACTIVITY_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "ACTIVITY_ID", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "ACTIVITY_SUBJECT", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_EMAIL", "type": "TEXT", "nullable": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "ACTIVITY_CATEGORY", "type": "TEXT", "nullable": True},
            {"name": "ACTIVITY_TYPE", "type": "TEXT", "nullable": True},
            {"name": "ACTIVITY_ZENDESK_DIVISION", "type": "TEXT", "nullable": True},
            {"name": "ACTIVITY_ZENDESK_USER", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["ACTIVITY_ID", "SOURCE_SNAPSHOT_DATE"],
        "foreign_keys": [],
    },
    "EDA_ML_CONTACTS_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "CRM_CONTACT_SKEY", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "CONTACT_ID", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_LAST_HUMAN_TOUCH", "type": "DATE", "nullable": True},
            {"name": "CONTACT_LAST_SALES_TOUCH_DATE_TIME", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "CONTACT_ROLE", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_JOB_ROLE", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_INTENT_SCORE_6_SENSE", "type": "FLOAT", "nullable": True},
            {"name": "CONTACT_TITLE", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_EMAIL", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_PHONE_NUMBER", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_NAME", "type": "TEXT", "nullable": True},
            {"name": "CONTACT_CREATED_DATE", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "CONTACT_LEAD_SOURCE", "type": "TEXT", "nullable": True},
            {"name": "NUM_WEB_VISITS_L30D", "type": "NUMBER", "nullable": True},
            {"name": "NUM_WEB_FORMS_L30D", "type": "NUMBER", "nullable": True},
            {"name": "NUM_OPENED_EMAILS_L30D", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["CRM_CONTACT_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_CRM_ACCOUNTS_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_ACCOUNT_SKEY", "type": "TEXT", "nullable": True},
            {"name": "CRM_OWNER_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_PRIMARY_OWNER_NAME", "type": "TEXT", "nullable": True},
            {"name": "CRM_INDUSTRY", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUB_INDUSTRY", "type": "TEXT", "nullable": True},
            {"name": "CRM_REGION", "type": "TEXT", "nullable": True},
            {"name": "CRM_SUB_REGION", "type": "TEXT", "nullable": True},
            {"name": "PRO_FORMA_MARKET_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "PRO_FORMA_MARKET_SUBSEGMENT", "type": "TEXT", "nullable": True},
            {"name": "PRO_FORMA_MARKET_SUPER_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_NAME", "type": "TEXT", "nullable": True},
            {"name": "CRM_HEALTH_STATUS", "type": "TEXT", "nullable": True},
            {"name": "CRM_DATE_BECAME_CUSTOMER", "type": "DATE", "nullable": True},
            {"name": "CRM_PARENT_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_TYPE", "type": "TEXT", "nullable": True},
            {"name": "CRM_NET_ARR_USD", "type": "NUMBER", "nullable": True},
            {"name": "CRM_NEXT_RENEWAL_DATE", "type": "DATE", "nullable": True},
            {"name": "CRM_NUMBER_OF_EMPLOYEES", "type": "NUMBER", "nullable": True},
            {"name": "CRM_REVENUE", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["CRM_ACCOUNT_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_INSTANCE_ACCOUNTS_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True, "primary_key": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_SKEY", "type": "TEXT", "nullable": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_SUBDOMAIN", "type": "TEXT", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_NAME", "type": "TEXT", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_ARR_USD", "type": "NUMBER", "nullable": True},
            {"name": "SEATS_CAPACITY", "type": "NUMBER", "nullable": True},
            {"name": "SEATS_OCCUPIED", "type": "NUMBER", "nullable": True},
            {"name": "SEAT_UTILIZATION", "type": "NUMBER", "nullable": True},
            {"name": "ACTIVE_AGENTS_L30D", "type": "NUMBER", "nullable": True},
            {"name": "CSAT_SCORE", "type": "NUMBER", "nullable": True},
            {"name": "NEW_TICKETS_L30D", "type": "NUMBER", "nullable": True},
            {"name": "SOLVED_TICKETS_L30D", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_INSTANCE_CHANNELS_MONTHLY_SNAPSHOT": {
        "columns": [
            {"name": "INSTANCE_ACCOUNT_CHANNEL_SKEY", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "MONTH_YEAR", "type": "DATE", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "CHANNEL_GROUP", "type": "TEXT", "nullable": True},
            {"name": "RBA_CREATED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_SOLVED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_UNIQUE_AGENTS_WITH_SOLVED_TICKETS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_SOLVED_TICKETS_PER_AGENT", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ZERO_TOUCH_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_ONE_TOUCH_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_REOPENED_TICKET_RATIO", "type": "NUMBER", "nullable": True},
            {"name": "RBA_FRT_MEDIAN_HOURS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_TTR_MEDIAN_HOURS", "type": "NUMBER", "nullable": True},
            {"name": "RBA_CSAT_SCORE", "type": "NUMBER", "nullable": True},
            {"name": "RBA_CSAT_RESPONSE_RATE", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["INSTANCE_ACCOUNT_CHANNEL_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_INSTANCE_PRODUCTS_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "PRODUCT_SKEY", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "INSTANCE_ACCOUNT_ID", "type": "NUMBER", "nullable": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "PRODUCT_OFFERING", "type": "TEXT", "nullable": True},
            {"name": "PRODUCT_OFFERING_GROUPED", "type": "TEXT", "nullable": True},
            {"name": "PRODUCT_PLAN", "type": "TEXT", "nullable": True},
            {"name": "NET_ARR_USD", "type": "NUMBER", "nullable": True},
            {"name": "SEATS", "type": "NUMBER", "nullable": True},
            {"name": "QUANTITY", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["PRODUCT_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_OPPORTUNITIES_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_OPPORTUNITY_ID", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_OPPORTUNITY_SKEY", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_NAME", "type": "TEXT", "nullable": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "OPPORTUNITY_CREATED_DATE", "type": "TIMESTAMP_NTZ", "nullable": True},
            {"name": "OPPORTUNITY_CLOSE_DATE", "type": "DATE", "nullable": True},
            {"name": "OPPORTUNITY_TYPE", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_STATUS", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_STAGE_NAME", "type": "TEXT", "nullable": True},
            {"name": "OPPORTUNITY_BOOKING_ARR_USD", "type": "NUMBER", "nullable": True},
        ],
        "primary_keys": ["CRM_OPPORTUNITY_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_USERS_DAILY_SNAPSHOT": {
        "columns": [
            {"name": "CRM_USER_SKEY", "type": "TEXT", "nullable": True, "primary_key": True},
            {"name": "CRM_USER_ID", "type": "TEXT", "nullable": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "USER_NAME", "type": "TEXT", "nullable": True},
            {"name": "USER_EMAIL", "type": "TEXT", "nullable": True},
            {"name": "USER_MARKET_SEGMENT", "type": "TEXT", "nullable": True},
            {"name": "USER_REGION", "type": "TEXT", "nullable": True},
            {"name": "USER_SUB_REGION", "type": "TEXT", "nullable": True},
            {"name": "MANAGER_1_EMAIL", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["CRM_USER_SKEY"],
        "foreign_keys": [],
    },
    "EDA_ML_USER_ACCOUNT_MAPPING": {
        "columns": [
            {"name": "CRM_ACCOUNT_ID", "type": "TEXT", "nullable": True},
            {"name": "CRM_USER_ID", "type": "TEXT", "nullable": True},
            {"name": "SOURCE_SNAPSHOT_DATE", "type": "DATE", "nullable": True},
            {"name": "USER_NAME", "type": "TEXT", "nullable": True},
            {"name": "USER_EMAIL", "type": "TEXT", "nullable": True},
            {"name": "USER_ROLE_ON_ACCOUNT", "type": "TEXT", "nullable": True},
        ],
        "primary_keys": ["CRM_ACCOUNT_ID", "CRM_USER_ID", "SOURCE_SNAPSHOT_DATE"],
        "foreign_keys": [],
    },
}


def build_metadata(schema_name, tables_dict):
    tables = []
    for tbl_name, tbl_data in tables_dict.items():
        tables.append({
            "name": tbl_name,
            "columns": tbl_data["columns"],
            "primary_keys": tbl_data["primary_keys"],
            "foreign_keys": tbl_data["foreign_keys"],
            "row_count": 0,
        })
    return {
        "database": "FUNCTIONAL",
        "schema": schema_name,
        "tables": tables,
    }


converge_meta = build_metadata("CONVERGE", converge_tables)
eda_ml_meta = build_metadata("EDA_ML_DATA", eda_ml_tables)

with open("/tmp/ontology_parsed/converge_metadata.json", "w") as f:
    json.dump(converge_meta, f, indent=2)
print(f"Wrote CONVERGE metadata: {len(converge_meta['tables'])} tables")

with open("/tmp/ontology_parsed/eda_ml_metadata.json", "w") as f:
    json.dump(eda_ml_meta, f, indent=2)
print(f"Wrote EDA_ML_DATA metadata: {len(eda_ml_meta['tables'])} tables")

# Also build combined metadata for the introspection script
combined = {
    "database": "FUNCTIONAL",
    "schema": "CONVERGE",  # Primary schema
    "tables": converge_meta["tables"] + eda_ml_meta["tables"],
}
with open("/tmp/ontology_parsed/combined_metadata.json", "w") as f:
    json.dump(combined, f, indent=2)
print(f"Wrote combined metadata: {len(combined['tables'])} tables")

# Extract questions from CSV
questions = []
csv_path = "/Users/felix.schildorfer/Documents/GitHub/coco_skill_ontology_stack_builder/questions/benchmark_v13 - benchmark_v13.csv"
with open(csv_path, "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        q = row.get("QUESTION", "").strip()
        if q:
            questions.append(q)

print(f"Extracted {len(questions)} questions from benchmark CSV")
with open("/tmp/ontology_parsed/questions.txt", "w") as f:
    f.write("|".join(questions))
