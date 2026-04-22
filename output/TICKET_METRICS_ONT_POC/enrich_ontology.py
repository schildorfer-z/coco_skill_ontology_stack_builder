"""Enrich introspection output with semantic view metadata and fix namespaces."""
import json

# Load introspection output
with open("/tmp/ontology_parsed/classes.json") as f:
    classes = json.load(f)
with open("/tmp/ontology_parsed/relations.json") as f:
    relations = json.load(f)
with open("/tmp/ontology_parsed/mappings.json") as f:
    mappings = json.load(f)

# ── Fix namespaces for EDA_ML_DATA tables ──
EDA_TABLES = {
    "EDA_ML_CONTACTS_ACTIVITY_DAILY_SNAPSHOT", "EDA_ML_CONTACTS_DAILY_SNAPSHOT",
    "EDA_ML_CRM_ACCOUNTS_DAILY_SNAPSHOT", "EDA_ML_INSTANCE_ACCOUNTS_DAILY_SNAPSHOT",
    "EDA_ML_INSTANCE_CHANNELS_MONTHLY_SNAPSHOT", "EDA_ML_INSTANCE_PRODUCTS_DAILY_SNAPSHOT",
    "EDA_ML_OPPORTUNITIES_DAILY_SNAPSHOT", "EDA_ML_USERS_DAILY_SNAPSHOT",
    "EDA_ML_USER_ACCOUNT_MAPPING",
}

# Map class names back to table names (from the introspection output)
class_to_table = {}
for m in mappings.get("class_mappings", []):
    tbl = m["source_table"].split(".")[-1]
    class_to_table[m["class_name"]] = tbl

for cls in classes:
    tbl = class_to_table.get(cls["name"], "")
    if tbl in EDA_TABLES:
        cls["namespace"] = "FUNCTIONAL.EDA_ML_DATA"
        cls["uri"] = f"urn:FUNCTIONAL:EDA_ML_DATA:{cls['name']}"

# Fix mappings source_table paths for EDA_ML_DATA
for m in mappings.get("class_mappings", []):
    tbl = m["source_table"].split(".")[-1]
    if tbl in EDA_TABLES:
        m["source_table"] = f"FUNCTIONAL.EDA_ML_DATA.{tbl}"

# ── Enrich class descriptions with semantic view context ──
enrichments = {
    "CrmAccount": "CRM (Salesforce) account dimension. Central entity linking all ticket metrics, agent data, and Gong/UserVoice events. Key attributes: account name, region, market segment, success owner.",
    "Date": "Calendar date dimension at monthly grain (MONTH_YEAR). Supports time-based filtering, YoY/MoM comparisons, and quarterly aggregations.",
    "InstanceAccount": "Zendesk instance account dimension. Represents a customer's Zendesk deployment identified by subdomain. Links to CRM account via CRM_ACCOUNT_ID. One CRM account may have multiple instances.",
    "AggInstanceAgentSummaryMonthly": "Monthly aggregated agent staffing metrics per Zendesk instance. Includes total active agents, remaining seats, closed tickets, productivity-eligible agents, and role breakdowns (admin/light/regular).",
    "AggInstanceChannelTicketMonthly": "Monthly ticket volume metrics by channel group per instance. Additive metrics: created tickets, closed tickets, CSAT counts (good/offered/responded). Supports cross-instance aggregation.",
    "AggInstanceGuideMetricMonthly": "Monthly Guide (knowledge base) engagement metrics per instance. Includes KB article views, community post views, published articles, new articles created, comments, and Q&A activity.",
    "AggInstanceRbaChannelMetricMonthly": "Monthly RBA (Rules-Based Analysis) ticket metrics broken out by channel. Non-additive metrics (FRT, TTC, ratios) that must NOT be aggregated across instances. Channel dimension: RBA_CHANNEL_GROUP.",
    "AggInstanceRbaMetricMonthly": "Monthly RBA ticket metrics at instance level (no channel breakdown). Non-additive metrics: median FRT/TTC in hours, CSAT score, touch ratios, reopened ratio. Must be filtered to single instance.",
    "ReferenceAccountLookup": "Simple account ID-to-name lookup reference. Used for Gong and UserVoice event enrichment.",
    "TransformGongAccountMap": "Maps Gong conversations to CRM accounts with enriched account attributes (industry, region, segment, health, ARR).",
    "TransformGongOpportunitieMap": "Maps Gong conversations to CRM opportunities with opportunity details (type, status, stage, close date, products).",
    "TransformGongTrackerTaxonomy": "Hierarchical taxonomy of Gong conversation trackers (up to 4 category levels). Used for topic classification of sales calls.",
    "UnifiedGongEvent": "Unified Gong call events with spotlight summaries, key points, next steps, and curated transcripts. Primary key: CONVERSATION_KEY.",
    "UnifiedUservoiceEvent": "Unified UserVoice product feedback events combining suggestions and requests. Enriched with CRM account data.",
    "EdaMlContactActivityDailySnapshot": "Daily snapshot of Salesforce contact activities (events/tasks). Snapshotted with SOURCE_SNAPSHOT_DATE. Use _BCV view for latest.",
    "EdaMlContactDailySnapshot": "Daily snapshot of CRM contacts with engagement scores, web activity, and role information. Use _BCV view for latest snapshot.",
    "EdaMlCrmAccountDailySnapshot": "Comprehensive daily CRM account snapshot with 100+ attributes including ARR, health, renewal, territory, engagement metrics. Superset of DIM_CRM_ACCOUNT. Use _BCV for latest.",
    "EdaMlInstanceAccountDailySnapshot": "Comprehensive daily Zendesk instance snapshot with 160+ attributes including seat utilization, ticket volumes, CSAT, AR usage, product mix, feature adoption. Use _BCV for latest.",
    "EdaMlInstanceChannelMonthlySnapshot": "Monthly channel-level ticket metrics from EDA_ML pipeline. Similar to CONVERGE RBA channel metrics but includes MoM percent changes. Snapshotted.",
    "EdaMlInstanceProductDailySnapshot": "Daily product subscription snapshot per instance. Includes product offering, plan, billing, seats, ARR. Use _BCV for latest.",
    "EdaMlOpportunitieDailySnapshot": "Daily CRM opportunity snapshot with pipeline details, stage, status, booking ARR by product line. Use _BCV for latest.",
    "EdaMlUserDailySnapshot": "Daily CRM user (account executive) snapshot with role, region, segment. Use _BCV for latest. Joins to accounts via EdaMlUserAccountMapping.",
    "EdaMlUserAccountMapping": "Maps CRM users (AEs, CSMs) to CRM accounts with role designation. Critical for user-context filtering in benchmark queries. Use _BCV for latest.",
}

for cls in classes:
    if cls["name"] in enrichments:
        cls["description"] = enrichments[cls["name"]]

# ── Enrich class labels ──
label_enrichments = {
    "CrmAccount": "CRM Account",
    "Date": "Calendar Month",
    "InstanceAccount": "Zendesk Instance",
    "AggInstanceAgentSummaryMonthly": "Agent Summary (Monthly)",
    "AggInstanceChannelTicketMonthly": "Channel Tickets (Monthly)",
    "AggInstanceGuideMetricMonthly": "Guide Metrics (Monthly)",
    "AggInstanceRbaChannelMetricMonthly": "RBA Channel Metrics (Monthly)",
    "AggInstanceRbaMetricMonthly": "RBA Metrics (Monthly)",
    "ReferenceAccountLookup": "Account Lookup",
    "TransformGongAccountMap": "Gong-Account Map",
    "TransformGongOpportunitieMap": "Gong-Opportunity Map",
    "TransformGongTrackerTaxonomy": "Gong Tracker Taxonomy",
    "UnifiedGongEvent": "Gong Call Event",
    "UnifiedUservoiceEvent": "UserVoice Feedback",
    "EdaMlContactActivityDailySnapshot": "Contact Activity Snapshot",
    "EdaMlContactDailySnapshot": "Contact Snapshot",
    "EdaMlCrmAccountDailySnapshot": "CRM Account Snapshot (Full)",
    "EdaMlInstanceAccountDailySnapshot": "Instance Account Snapshot (Full)",
    "EdaMlInstanceChannelMonthlySnapshot": "Instance Channel Snapshot",
    "EdaMlInstanceProductDailySnapshot": "Product Subscription Snapshot",
    "EdaMlOpportunitieDailySnapshot": "Opportunity Snapshot",
    "EdaMlUserDailySnapshot": "User (AE) Snapshot",
    "EdaMlUserAccountMapping": "User-Account Mapping",
}

for cls in classes:
    if cls["name"] in label_enrichments:
        cls["label"] = label_enrichments[cls["name"]]

# ── Add missing cross-schema relations ──
# These were not detected because EDA_ML tables had no explicit FK metadata

additional_relations = [
    {
        "name": "has_crm_account",
        "label": "Has CRM Account",
        "description": "EDA_ML Contact Activity links to CRM accounts via CRM_ACCOUNT_ID",
        "domain_class": "EdaMlContactActivityDailySnapshot",
        "domain_classes": ["EdaMlContactActivityDailySnapshot"],
        "range_class": "CrmAccount",
        "range_classes": ["CrmAccount"],
        "is_transitive": False, "is_symmetric": False, "is_functional": True,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:1",
        "uri": "urn:rel:eda_contact_activity_to_crm_account"
    },
    {
        "name": "has_crm_account",
        "label": "Has CRM Account",
        "description": "EDA_ML Contact links to CRM accounts via CRM_ACCOUNT_ID",
        "domain_class": "EdaMlContactDailySnapshot",
        "domain_classes": ["EdaMlContactDailySnapshot"],
        "range_class": "CrmAccount",
        "range_classes": ["CrmAccount"],
        "is_transitive": False, "is_symmetric": False, "is_functional": True,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:1",
        "uri": "urn:rel:eda_contact_to_crm_account"
    },
    {
        "name": "maps_user_to_account",
        "label": "Maps User To Account",
        "description": "User-Account mapping links CRM users to CRM accounts. Critical for user-context filtering.",
        "domain_class": "EdaMlUserAccountMapping",
        "domain_classes": ["EdaMlUserAccountMapping"],
        "range_class": "CrmAccount",
        "range_classes": ["CrmAccount"],
        "is_transitive": False, "is_symmetric": False, "is_functional": False,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:N",
        "uri": "urn:rel:user_account_mapping_to_crm_account"
    },
    {
        "name": "maps_user_to_account",
        "label": "Maps User To Account",
        "description": "User-Account mapping links to CRM users from daily snapshot",
        "domain_class": "EdaMlUserAccountMapping",
        "domain_classes": ["EdaMlUserAccountMapping"],
        "range_class": "EdaMlUserDailySnapshot",
        "range_classes": ["EdaMlUserDailySnapshot"],
        "is_transitive": False, "is_symmetric": False, "is_functional": False,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:1",
        "uri": "urn:rel:user_account_mapping_to_user"
    },
    {
        "name": "has_instance_account",
        "label": "Has Instance Account",
        "description": "EDA_ML Instance Products links to instance accounts via INSTANCE_ACCOUNT_ID",
        "domain_class": "EdaMlInstanceProductDailySnapshot",
        "domain_classes": ["EdaMlInstanceProductDailySnapshot"],
        "range_class": "InstanceAccount",
        "range_classes": ["InstanceAccount"],
        "is_transitive": False, "is_symmetric": False, "is_functional": True,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:1",
        "uri": "urn:rel:eda_product_to_instance"
    },
    {
        "name": "snapshot_of_crm_account",
        "label": "Snapshot Of CRM Account",
        "description": "EDA_ML CRM Account Snapshot is a detailed daily version of the CRM Account dimension",
        "domain_class": "EdaMlCrmAccountDailySnapshot",
        "domain_classes": ["EdaMlCrmAccountDailySnapshot"],
        "range_class": "CrmAccount",
        "range_classes": ["CrmAccount"],
        "is_transitive": False, "is_symmetric": False, "is_functional": True,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:1",
        "uri": "urn:rel:eda_crm_snapshot_to_dim"
    },
    {
        "name": "snapshot_of_instance",
        "label": "Snapshot Of Instance",
        "description": "EDA_ML Instance Account Snapshot is a detailed daily version of the Instance Account dimension",
        "domain_class": "EdaMlInstanceAccountDailySnapshot",
        "domain_classes": ["EdaMlInstanceAccountDailySnapshot"],
        "range_class": "InstanceAccount",
        "range_classes": ["InstanceAccount"],
        "is_transitive": False, "is_symmetric": False, "is_functional": True,
        "is_abstract": False, "is_hierarchical": False,
        "parent_name": None, "inverse_name": None,
        "cardinality": "N:1",
        "uri": "urn:rel:eda_instance_snapshot_to_dim"
    },
]

relations.extend(additional_relations)

# ── Write enriched outputs ──
with open("/tmp/ontology_parsed/classes.json", "w") as f:
    json.dump(classes, f, indent=2)

with open("/tmp/ontology_parsed/relations.json", "w") as f:
    json.dump(relations, f, indent=2)

# Update stats
stats = {
    "total_classes": len(classes),
    "abstract_classes": sum(1 for c in classes if c.get("is_abstract")),
    "concrete_classes": sum(1 for c in classes if not c.get("is_abstract")),
    "deprecated_classes": 0,
    "root_classes": len(classes),
    "max_hierarchy_depth": 0,
    "total_relations": len(relations),
    "hierarchical_relations": 0,
    "transitive_relations": 0,
    "total_individuals": 0,
    "top_namespaces": {
        "FUNCTIONAL.CONVERGE": sum(1 for c in classes if c.get("namespace") == "FUNCTIONAL.CONVERGE"),
        "FUNCTIONAL.EDA_ML_DATA": sum(1 for c in classes if c.get("namespace") == "FUNCTIONAL.EDA_ML_DATA"),
    },
}
with open("/tmp/ontology_parsed/stats.json", "w") as f:
    json.dump(stats, f, indent=2)

print("=== Enriched Ontology Summary ===")
print(f"  Classes: {stats['total_classes']} ({stats['concrete_classes']} concrete, {stats['abstract_classes']} abstract)")
print(f"    CONVERGE: {stats['top_namespaces']['FUNCTIONAL.CONVERGE']}")
print(f"    EDA_ML_DATA: {stats['top_namespaces']['FUNCTIONAL.EDA_ML_DATA']}")
print(f"  Relations: {stats['total_relations']}")
print()
print("  === Classes ===")
for cls in classes:
    schema = cls["namespace"].split(".")[-1]
    print(f"    [{schema}] {cls['label']} ({cls['name']})")
print()
print("  === Relations ===")
for rel in relations:
    print(f"    {rel['domain_class']} --[{rel['name']}]--> {rel['range_class']}")
