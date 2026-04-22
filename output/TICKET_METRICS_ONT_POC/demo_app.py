"""
Ontology Stack Demo — TICKET_METRICS_ONT_POC
=============================================
Multi-tab Streamlit app showcasing the 5-layer Ontology-on-Snowflake stack:
  Physical KG → Concrete Views → Metadata → Abstract Views → Semantic Views → Cortex Agent

Tabs:
  1. Ask the Agent — Chat UI calling the Cortex Agent
  2. Knowledge Graph Explorer — Browse KG_NODE / KG_EDGE
  3. Ontology Metadata — Class/relation tables + graph visualization
  4. Source Data Validation — Compare semantic view vs raw source tables

Usage:
  streamlit run demo_app.py
"""

import json
import time as _time
import streamlit as st
import pandas as pd
import snowflake.connector
from pathlib import Path
from collections import defaultdict

from streamlit_agraph import agraph, Node, Edge, Config

try:
    import tomllib as toml_lib
except ImportError:
    import tomli as toml_lib

# ---------------------------------------------------------------------------
# Page config
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="Ontology Stack Demo",
    page_icon=":material/hub:",
    layout="wide",
    initial_sidebar_state="expanded",
)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
AGENT_FQN = "_SANDBOX_ONTOLOGY_POC.TICKET_METRICS.TICKET_METRICS_ONTOLOGY_AGENT"
DB = "_SANDBOX_ONTOLOGY_POC"
SCHEMA = "TICKET_METRICS"
SOURCE_SCHEMA = "FUNCTIONAL.CONVERGE"

TOOL_LABELS = {
    "query_ticket_metrics": ("Ticket Metrics", "blue"),
    "query_knowledge_graph": ("Knowledge Graph", "green"),
    "query_ontology_model": ("Ontology Model", "violet"),
    "query_metadata_catalog": ("Metadata Catalog", "orange"),
}

SAMPLE_QUESTIONS = [
    "What is the total ticket volume across all accounts last month?",
    "For the CRM account 'Datadog', show the ticket volume trend over the last 12 months",
    "What is the average CSAT score for Datadog?",
    "Show me the top 10 accounts by ticket volume",
    "Which Zendesk instances does Datadog have?",
    "What is the median first reply time for Datadog's instances?",
    "How many active agents does Datadog have?",
    "Show me accounts with declining CSAT over the last 6 months",
]

# ---------------------------------------------------------------------------
# Data file paths (relative to this script)
# ---------------------------------------------------------------------------
APP_DIR = Path(__file__).parent
CLASSES_PATH = APP_DIR / "classes.json"
RELATIONS_PATH = APP_DIR / "relations.json"
DEPLOYED_OBJECTS_PATH = APP_DIR / "deployed_objects.json"

# ---------------------------------------------------------------------------
# Snowflake connection
# ---------------------------------------------------------------------------

SNOWFLAKE_CONFIG_PATH = Path.home() / ".snowflake" / "config.toml"


@st.cache_resource
def get_connection():
    """Establish Snowflake connection from ~/.snowflake/config.toml."""
    config_path = SNOWFLAKE_CONFIG_PATH
    if config_path.exists():
        with open(config_path, "rb") as f:
            config = toml_lib.load(f)
        conn_cfg = config.get("connections", {}).get("main", {})
    else:
        conn_cfg = {}

    return snowflake.connector.connect(
        account=conn_cfg.get("account", ""),
        user=conn_cfg.get("user", ""),
        authenticator=conn_cfg.get("authenticator", "externalbrowser"),
        database=conn_cfg.get("database", DB),
        warehouse=conn_cfg.get("warehouse", ""),
        role=conn_cfg.get("role", ""),
        schema=SCHEMA,
    )



def run_query(sql: str, ttl: int = 60) -> pd.DataFrame:
    """Execute a query and return a DataFrame with session-state caching.

    Uses ``st.session_state`` instead of ``@st.cache_data`` to avoid
    Streamlit's Arrow-based serialization which corrupts column indices
    under Pandas 3.x + Snowflake Connector 4.x, causing KeyError on
    normal ``df["COL"]`` access.
    """
    cache_key = f"_qcache_{hash(sql)}"
    ts_key = f"_qcache_ts_{hash(sql)}"
    now = _time.time()

    if cache_key in st.session_state:
        cached_at = st.session_state.get(ts_key, 0)
        if now - cached_at < ttl:
            stored = st.session_state[cache_key]
            cols = [str(c) for c in stored["cols"]]
            rows = stored["rows"]
            if not rows:
                return pd.DataFrame(columns=cols)
            return pd.DataFrame(rows, columns=cols)

    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(sql)
        cols = [str(desc[0]).upper() for desc in cur.description]
        rows = [list(row) for row in cur.fetchall()]
    finally:
        cur.close()

    st.session_state[cache_key] = {"cols": cols, "rows": rows}
    st.session_state[ts_key] = now

    if not rows:
        return pd.DataFrame(columns=cols)
    return pd.DataFrame(rows, columns=cols)


def run_query_no_cache(sql: str) -> pd.DataFrame:
    """Execute a query without caching (for agent calls)."""
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(sql)
        cols = [str(desc[0]).upper() for desc in cur.description]
        rows = cur.fetchall()
        if not rows:
            return pd.DataFrame(columns=cols)
        return pd.DataFrame([dict(zip(cols, row)) for row in rows])
    finally:
        cur.close()


# ---------------------------------------------------------------------------
# Load local JSON files
# ---------------------------------------------------------------------------

@st.cache_data
def load_classes():
    with open(CLASSES_PATH) as f:
        return json.load(f)


@st.cache_data
def load_relations():
    with open(RELATIONS_PATH) as f:
        return json.load(f)


@st.cache_data
def load_deployed_objects():
    with open(DEPLOYED_OBJECTS_PATH) as f:
        return json.load(f)


# ---------------------------------------------------------------------------
# Sidebar
# ---------------------------------------------------------------------------

with st.sidebar:
    st.title(":material/hub: Ontology Demo")
    st.caption("TICKET_METRICS_ONT_POC")
    st.divider()

    # Connection status
    try:
        conn = get_connection()
        if conn and not conn.is_closed():
            st.success("Connected to Snowflake", icon=":material/check_circle:")
        else:
            st.warning("Connection closed — will reconnect on next query")
    except Exception as e:
        st.error(f"Connection failed: {e}", icon=":material/error:")

    st.divider()

    # Stack stats
    st.subheader("Stack Statistics")
    col1, col2 = st.columns(2)
    col1.metric("Classes", "23")
    col2.metric("Relations", "29")
    col1.metric("Objects", "97")
    col2.metric("Layers", "9")
    col1.metric("KG Nodes", "49.5M")
    col2.metric("KG Edges", "109M")

    st.divider()
    st.caption("Layers: Physical KG → Concrete Views → Metadata → Abstract Views → Semantic Views → Agent")

# ---------------------------------------------------------------------------
# Tabs
# ---------------------------------------------------------------------------

tab1, tab2, tab3, tab4, tab5, tab6, tab7 = st.tabs([
    ":material/smart_toy: Ask the Agent",
    ":material/share: Knowledge Graph",
    ":material/schema: Ontology Metadata",
    ":material/verified: Source Validation",
    ":material/account_tree: Hierarchy",
    ":material/hub: Ontology Graph",
    ":material/grid_view: Coverage Matrix",
])

# ===========================================================================
# TAB 1: Ask the Agent
# ===========================================================================

with tab1:
    st.header("Ask the Ontology Agent")
    st.caption(
        "Chat with the Cortex Agent backed by 4 semantic views covering "
        "ticket metrics, knowledge graph, ontology model, and metadata catalog."
    )

    # Session state for chat
    if "chat_messages" not in st.session_state:
        st.session_state.chat_messages = []
    if "thread_id" not in st.session_state:
        st.session_state.thread_id = None
    if "parent_message_id" not in st.session_state:
        st.session_state.parent_message_id = None

    # Sample question selector
    if not st.session_state.chat_messages:
        selected = st.pills(
            "Try a sample question:",
            SAMPLE_QUESTIONS,
            label_visibility="collapsed",
        )
        if selected:
            st.session_state.chat_messages.append({"role": "user", "content": selected})
            st.rerun()

    # Display chat history
    for msg in st.session_state.chat_messages:
        with st.chat_message(msg["role"]):
            if msg["role"] == "assistant":
                # Show tool badge if present
                if msg.get("tool_name"):
                    label, color = TOOL_LABELS.get(
                        msg["tool_name"], (msg["tool_name"], "gray")
                    )
                    st.markdown(f":{color}-background[**{label}**]")
                st.markdown(msg["content"])
                # Show SQL in expander if present
                if msg.get("sql"):
                    with st.expander("View generated SQL"):
                        st.code(msg["sql"], language="sql")
            else:
                st.markdown(msg["content"])

    # Chat input
    if prompt := st.chat_input("Ask a question about ticket metrics..."):
        st.session_state.chat_messages.append({"role": "user", "content": prompt})

        with st.chat_message("user"):
            st.markdown(prompt)

        with st.chat_message("assistant"):
            with st.spinner("Agent is thinking..."):
                # Build request body
                request_body_dict = {
                    "messages": [{"role": "user", "content": [{"type": "text", "text": prompt}]}],
                    "stream": False,
                }
                if st.session_state.thread_id is not None:
                    request_body_dict["thread_id"] = st.session_state.thread_id
                if st.session_state.parent_message_id is not None:
                    request_body_dict["parent_message_id"] = st.session_state.parent_message_id
                request_body = json.dumps(request_body_dict)

                # Call the agent
                agent_sql = f"""
                    SELECT TRY_PARSE_JSON(
                        SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
                            '{AGENT_FQN}',
                            $${request_body}$$
                        )
                    ) AS resp
                """

                try:
                    result = run_query_no_cache(agent_sql)
                    raw = result.iloc[0]["RESP"]

                    # Handle both str and already-parsed dict/variant
                    if isinstance(raw, str):
                        resp_json = json.loads(raw)
                    elif isinstance(raw, dict):
                        resp_json = raw
                    else:
                        resp_json = json.loads(str(raw))

                    # If resp_json is still a string (double-encoded), parse again
                    if isinstance(resp_json, str):
                        resp_json = json.loads(resp_json)

                    # Parse response
                    answer_text = ""
                    tool_name = None
                    generated_sql = None

                    for item in resp_json.get("content", []):
                        item_type = item.get("type")
                        if item_type == "text":
                            answer_text = item.get("text", "").strip()
                        elif item_type == "tool_use":
                            tool_use = item.get("tool_use", {})
                            if tool_use.get("name"):
                                tool_name = tool_use["name"]
                        elif item_type == "tool_result":
                            tool_result = item.get("tool_result", item)
                            # Extract SQL from tool_result content
                            for content_item in tool_result.get("content", []):
                                if content_item.get("type") == "json":
                                    result_data = content_item.get("json", {})
                                    if isinstance(result_data, dict):
                                        sql_val = result_data.get("sql") or result_data.get("query")
                                        if sql_val:
                                            generated_sql = sql_val

                    # Display tool badge
                    if tool_name:
                        label, color = TOOL_LABELS.get(tool_name, (tool_name, "gray"))
                        st.markdown(f":{color}-background[**{label}**]")

                    # Display answer
                    if answer_text:
                        st.markdown(answer_text)
                    else:
                        st.info("The agent processed the request but returned no text response.")

                    # Show SQL
                    if generated_sql:
                        with st.expander("View generated SQL"):
                            st.code(generated_sql, language="sql")

                    # Store message
                    st.session_state.chat_messages.append({
                        "role": "assistant",
                        "content": answer_text or "(no text response)",
                        "tool_name": tool_name,
                        "sql": generated_sql,
                    })

                    # Update thread tracking
                    metadata = resp_json.get("metadata", {})
                    if "thread_id" in metadata:
                        st.session_state.thread_id = metadata["thread_id"]
                    if "message_id" in metadata:
                        st.session_state.parent_message_id = metadata["message_id"]

                except Exception as e:
                    import traceback
                    error_msg = f"Error calling agent: {str(e)}"
                    st.error(error_msg)
                    with st.expander("Debug details"):
                        st.code(traceback.format_exc())
                    st.session_state.chat_messages.append({
                        "role": "assistant",
                        "content": error_msg,
                    })

    # Reset button
    if st.session_state.chat_messages:
        if st.button("Clear conversation", type="secondary"):
            st.session_state.chat_messages = []
            st.session_state.thread_id = None
            st.session_state.parent_message_id = None
            st.rerun()


# ===========================================================================
# TAB 2: Knowledge Graph Explorer
# ===========================================================================

with tab2:
  try:
    st.header("Knowledge Graph Explorer")
    st.caption(
        f"Browse the knowledge graph: **49.5M nodes** (22 types) and "
        f"**109M edges** (5 types) in `{DB}.{SCHEMA}`."
    )

    col_left, col_right = st.columns([1, 2])

    with col_left:
        # Node type selector
        node_types_df = run_query(
            f"SELECT DISTINCT NODE_TYPE, COUNT(*) AS CNT "
            f"FROM {DB}.{SCHEMA}.KG_NODE "
            f"GROUP BY NODE_TYPE ORDER BY CNT DESC",
            ttl=300,
        )

        if not node_types_df.empty:
            type_options = node_types_df["NODE_TYPE"].tolist()
            selected_type = st.selectbox(
                "Entity type",
                type_options,
                help="Select a node type to browse entities",
            )

            # Show count for selected type
            count = node_types_df[node_types_df["NODE_TYPE"] == selected_type]["CNT"].iloc[0]
            st.metric(f"{selected_type} count", f"{count:,.0f}")

            # Search within type
            search_term = st.text_input(
                "Search by name",
                placeholder="e.g. Datadog, Salesforce...",
            )
        else:
            st.warning("Could not load node types.")
            selected_type = None
            search_term = ""

    with col_right:
        if selected_type:
            # Build query for entities
            search_clause = ""
            if search_term:
                safe_term = search_term.replace("'", "''")
                search_clause = f"AND LOWER(NAME) LIKE LOWER('%{safe_term}%')"

            entities_df = run_query(
                f"SELECT NODE_ID, NAME, NODE_TYPE, PROPS "
                f"FROM {DB}.{SCHEMA}.KG_NODE "
                f"WHERE NODE_TYPE = '{selected_type}' {search_clause} "
                f"LIMIT 50",
                ttl=60,
            )

            if not entities_df.empty:
                st.subheader(f"{selected_type} Entities")
                st.dataframe(
                    entities_df[["NAME", "NODE_TYPE", "NODE_ID"]],
                    use_container_width=True,
                    hide_index=True,
                )

                # Entity detail + relationships
                entity_names = entities_df["NAME"].tolist()
                selected_entity = st.selectbox(
                    "Select entity to explore relationships",
                    entity_names,
                    key="kg_entity_select",
                )

                if selected_entity:
                    entity_row = entities_df[entities_df["NAME"] == selected_entity].iloc[0]
                    node_id = entity_row["NODE_ID"]

                    # Show properties
                    props = entity_row.get("PROPS")
                    if props:
                        try:
                            props_dict = json.loads(props) if isinstance(props, str) else props
                            with st.expander("Entity properties", expanded=True):
                                st.json(props_dict)
                        except (json.JSONDecodeError, TypeError):
                            pass

                    # Fetch relationships
                    st.subheader("Relationships")
                    edges_df = run_query(
                        f"SELECT e.EDGE_TYPE, e.DST_ID, t.NAME AS TARGET_NAME, t.NODE_TYPE AS TARGET_TYPE "
                        f"FROM {DB}.{SCHEMA}.KG_EDGE e "
                        f"JOIN {DB}.{SCHEMA}.KG_NODE t ON e.DST_ID = t.NODE_ID "
                        f"WHERE e.SRC_ID = '{node_id}' "
                        f"LIMIT 100",
                        ttl=60,
                    )

                    if not edges_df.empty:
                        display_cols = [c for c in edges_df.columns if c != "DST_ID"]
                        st.dataframe(
                            edges_df[display_cols],
                            use_container_width=True,
                            hide_index=True,
                        )
                    else:
                        # Try reverse direction
                        edges_rev_df = run_query(
                            f"SELECT e.EDGE_TYPE, e.SRC_ID, s.NAME AS SOURCE_NAME, s.NODE_TYPE AS SOURCE_TYPE "
                            f"FROM {DB}.{SCHEMA}.KG_EDGE e "
                            f"JOIN {DB}.{SCHEMA}.KG_NODE s ON e.SRC_ID = s.NODE_ID "
                            f"WHERE e.DST_ID = '{node_id}' "
                            f"LIMIT 100",
                            ttl=60,
                        )
                        if not edges_rev_df.empty:
                            display_cols = [c for c in edges_rev_df.columns if c != "SRC_ID"]
                            st.dataframe(
                                edges_rev_df[display_cols],
                                use_container_width=True,
                                hide_index=True,
                            )
                        else:
                            st.info("No relationships found for this entity.")
            else:
                st.info("No entities found. Try a different search term.")
  except Exception as _tab2_err:
    st.error(f"Knowledge Graph Explorer encountered an error: {_tab2_err}")
    st.caption("The other tabs are unaffected — click a different tab to continue.")


# ===========================================================================
# TAB 3: Ontology Metadata
# ===========================================================================

with tab3:
 try:
    st.header("Ontology Metadata")
    st.caption("Explore the 23 ontology classes, 29 relations, and the full deployment manifest.")

    meta_tab1, meta_tab2, meta_tab3 = st.tabs([
        "Classes", "Relations", "Deployment Stack"
    ])

    # --- Classes ---
    with meta_tab1:
        classes = load_classes()
        st.subheader(f"Ontology Classes ({len(classes)})")

        # Build display table
        class_rows = []
        for cls in classes:
            class_rows.append({
                "Name": cls.get("name", ""),
                "Label": cls.get("label", ""),
                "Description": cls.get("description", ""),
                "Namespace": cls.get("namespace", ""),
                "Parent": cls.get("parent_name", "—"),
                "Abstract": "Yes" if cls.get("is_abstract") else "No",
            })

        st.dataframe(class_rows, use_container_width=True, hide_index=True)

        # Class detail expander
        selected_class = st.selectbox(
            "Select class for details",
            [c["name"] for c in classes],
            key="class_detail_select",
        )
        if selected_class:
            cls_detail = next(c for c in classes if c["name"] == selected_class)
            with st.expander(f"Details: {selected_class}", expanded=True):
                st.json(cls_detail)

    # --- Relations ---
    with meta_tab2:
        relations = load_relations()
        st.subheader(f"Ontology Relations ({len(relations)})")

        rel_rows = []
        for rel in relations:
            rel_rows.append({
                "Name": rel.get("name", ""),
                "Label": rel.get("label", ""),
                "Domain": rel.get("domain_class", ""),
                "Range": rel.get("range_class", ""),
                "Cardinality": rel.get("cardinality", ""),
                "Transitive": "Yes" if rel.get("is_transitive") else "No",
            })

        st.dataframe(rel_rows, use_container_width=True, hide_index=True)

    # --- Deployment Stack ---
    with meta_tab3:
        deployed = load_deployed_objects()
        st.subheader("Deployment Manifest")

        # Summary metrics from 'totals' key
        totals = deployed.get("totals", {})
        if totals:
            cols = st.columns(4)
            cols[0].metric("Tables", totals.get("tables", 0))
            cols[1].metric("Views", totals.get("views", 0))
            cols[2].metric("Semantic Views", totals.get("semantic_views", 0))
            cols[3].metric("Agent", totals.get("agents", 0))

            cols2 = st.columns(4)
            cols2[0].metric("Stored Procs", totals.get("stored_procedures", 0))
            cols2[1].metric("UDFs", totals.get("udfs", 0))
            cols2[2].metric("Total Objects", totals.get("total_objects", 0))
            cols2[3].metric("Layers", len(deployed.get("layers", {})))

        # KG Stats from totals
        st.subheader("Knowledge Graph Statistics")
        col_a, col_b = st.columns(2)
        col_a.metric("Total Nodes", f"{totals.get('kg_nodes', 0):,.0f}")
        col_b.metric("Total Edges", f"{totals.get('kg_edges', 0):,.0f}")
        col_c, col_d = st.columns(2)
        col_c.metric("Node Types", totals.get("node_types", 0))
        col_d.metric("Edge Types", totals.get("edge_types", 0))

        # Layer breakdown
        layers = deployed.get("layers", {})
        if layers:
            st.subheader("Objects by Layer")
            for layer_name, layer_data in layers.items():
                desc = layer_data.get("description", "") if isinstance(layer_data, dict) else ""
                # Count objects within the layer
                obj_names = []
                if isinstance(layer_data, dict):
                    for key, val in layer_data.items():
                        if key == "description":
                            continue
                        if isinstance(val, list):
                            for item in val:
                                if isinstance(item, dict):
                                    obj_names.append(item.get("name", item.get("fqn", str(item))))
                                else:
                                    obj_names.append(str(item))

                with st.expander(f"{layer_name} — {desc} ({len(obj_names)} objects)"):
                    if obj_names:
                        st.dataframe(
                            [{"Object": obj} for obj in obj_names],
                            use_container_width=True,
                            hide_index=True,
                        )
                    elif isinstance(layer_data, dict):
                        # Show raw structure for layers without simple lists
                        st.json(layer_data)
 except Exception as _tab3_err:
    st.error(f"Ontology Metadata encountered an error: {_tab3_err}")
    st.caption("The other tabs are unaffected — click a different tab to continue.")


# ===========================================================================
# TAB 4: Source Data Validation
# ===========================================================================

with tab4:
 try:
    st.header("Source Data Validation")
    st.caption(
        "Compare semantic view results against raw source tables to verify "
        "the ontology stack doesn't introduce data errors."
    )

    # Account picker
    accounts_df = run_query(
        f"SELECT CRM_ACCOUNT_ID, CRM_ACCOUNT_NAME "
        f"FROM {SOURCE_SCHEMA}.DIM_CRM_ACCOUNT "
        f"WHERE CRM_ACCOUNT_NAME IS NOT NULL "
        f"ORDER BY CRM_ACCOUNT_NAME "
        f"LIMIT 500",
        ttl=300,
    )

    if not accounts_df.empty:
        account_names = accounts_df["CRM_ACCOUNT_NAME"].tolist()
        # Default to Datadog if available
        default_idx = account_names.index("Datadog") if "Datadog" in account_names else 0

        selected_account = st.selectbox(
            "Select CRM Account",
            account_names,
            index=default_idx,
            key="validation_account",
        )

        account_id = accounts_df[
            accounts_df["CRM_ACCOUNT_NAME"] == selected_account
        ]["CRM_ACCOUNT_ID"].iloc[0]

        if st.button("Run Validation", type="primary"):
            st.subheader(f"Ticket Volume Trend: {selected_account}")

            col_src, col_sv = st.columns(2)

            # Query 1: Raw source table
            with col_src:
                st.markdown("**Source Table** (`FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY`)")
                source_sql = f"""
                    SELECT
                        MONTH_YEAR,
                        SUM(COUNT_CREATED_TICKETS) AS TOTAL_CREATED,
                        SUM(COUNT_CLOSED_TICKETS) AS TOTAL_CLOSED
                    FROM {SOURCE_SCHEMA}.FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY
                    WHERE CRM_ACCOUNT_ID = '{account_id}'
                    GROUP BY MONTH_YEAR
                    ORDER BY MONTH_YEAR DESC
                    LIMIT 12
                """
                with st.spinner("Querying source table..."):
                    source_df = run_query(source_sql, ttl=30)

                if not source_df.empty:
                    st.dataframe(source_df, use_container_width=True, hide_index=True)
                    st.line_chart(
                        source_df.set_index("MONTH_YEAR")[["TOTAL_CREATED", "TOTAL_CLOSED"]],
                    )
                else:
                    st.warning("No source data found for this account.")

            # Query 2: Via semantic view (through the ontology layer)
            with col_sv:
                st.markdown("**Ontology Layer** (`VW_ONT_AGGINSTANCECHANNELTICKETMONTHLY`)")
                ontology_sql = f"""
                    SELECT
                        MONTH_YEAR,
                        SUM(COUNT_CREATED_TICKETS) AS TOTAL_CREATED,
                        SUM(COUNT_CLOSED_TICKETS) AS TOTAL_CLOSED
                    FROM {DB}.{SCHEMA}.VW_ONT_AGGINSTANCECHANNELTICKETMONTHLY
                    WHERE CRM_ACCOUNT_ID = '{account_id}'
                    GROUP BY MONTH_YEAR
                    ORDER BY MONTH_YEAR DESC
                    LIMIT 12
                """
                with st.spinner("Querying ontology view..."):
                    try:
                        ontology_df = run_query(ontology_sql, ttl=30)

                        if not ontology_df.empty:
                            st.dataframe(ontology_df, use_container_width=True, hide_index=True)
                            st.line_chart(
                                ontology_df.set_index("MONTH_YEAR")[["TOTAL_CREATED", "TOTAL_CLOSED"]],
                            )
                        else:
                            st.warning("No ontology view data found for this account.")
                    except Exception as e:
                        st.error(f"Ontology view query failed: {e}")
                        st.info("This may indicate the view name differs. Check deployed_objects.json for exact names.")

            # Comparison
            if not source_df.empty:
                st.divider()
                st.subheader("Validation Result")
                try:
                    if not ontology_df.empty:
                        # Merge and compare
                        merged = source_df.merge(
                            ontology_df,
                            on="MONTH_YEAR",
                            suffixes=("_SOURCE", "_ONTOLOGY"),
                        )
                        if not merged.empty:
                            merged["MATCH"] = (
                                merged["TOTAL_CREATED_SOURCE"] == merged["TOTAL_CREATED_ONTOLOGY"]
                            ) & (
                                merged["TOTAL_CLOSED_SOURCE"] == merged["TOTAL_CLOSED_ONTOLOGY"]
                            )
                            all_match = merged["MATCH"].all()

                            if all_match:
                                st.success(
                                    "All values match between source and ontology layer. "
                                    "The ontology stack does not introduce data errors.",
                                    icon=":material/check_circle:",
                                )
                            else:
                                st.warning(
                                    "Some values differ between source and ontology layer.",
                                    icon=":material/warning:",
                                )
                                st.dataframe(
                                    merged[~merged["MATCH"]],
                                    use_container_width=True,
                                    hide_index=True,
                                )
                except NameError:
                    st.info("Ontology view query did not return results for comparison.")
    else:
        st.warning("Could not load account list from DIM_CRM_ACCOUNT.")

    # Show the queries used
    with st.expander("SQL Queries Used"):
        st.markdown("**Source Table Query:**")
        st.code(
            f"""SELECT MONTH_YEAR,
       SUM(COUNT_CREATED_TICKETS) AS TOTAL_CREATED,
       SUM(COUNT_CLOSED_TICKETS) AS TOTAL_CLOSED
FROM {SOURCE_SCHEMA}.FACT_AGG_INSTANCE_CHANNEL_TICKETS_MONTHLY
WHERE CRM_ACCOUNT_ID = '<account_id>'
GROUP BY MONTH_YEAR
ORDER BY MONTH_YEAR DESC
LIMIT 12""",
            language="sql",
        )
        st.markdown("**Ontology View Query:**")
        st.code(
            f"""SELECT MONTH_YEAR,
       SUM(COUNT_CREATED_TICKETS) AS TOTAL_CREATED,
       SUM(COUNT_CLOSED_TICKETS) AS TOTAL_CLOSED
FROM {DB}.{SCHEMA}.VW_ONT_AGGINSTANCECHANNELTICKETMONTHLY
WHERE CRM_ACCOUNT_ID = '<account_id>'
GROUP BY MONTH_YEAR
ORDER BY MONTH_YEAR DESC
LIMIT 12""",
            language="sql",
        )
 except Exception as _tab4_err:
    st.error(f"Source Data Validation encountered an error: {_tab4_err}")
    st.caption("The other tabs are unaffected — click a different tab to continue.")


# ===========================================================================
# Helper functions for Hierarchy / Graph / Coverage tabs
# ===========================================================================

def build_tree(classes: list[dict]) -> tuple[dict, list, dict]:
    """Build a parent->children tree structure for classes."""
    children_map = defaultdict(list)
    roots = []
    name_to_cls = {}
    for cls in classes:
        name_to_cls[cls["name"]] = cls
        parent = cls.get("parent_name")
        if parent:
            children_map[parent].append(cls["name"])
        else:
            roots.append(cls["name"])
    return children_map, roots, name_to_cls


def build_relation_tree(relations: list[dict]) -> tuple[dict, list, list, dict]:
    """Build a parent->children tree structure for relations.

    Returns (rel_children_map, rel_roots, flat_concrete, rel_by_name).
    """
    rel_by_name = {r["name"]: r for r in relations if r["name"] != "subClassOf"}
    rel_children_map: dict[str, list[str]] = defaultdict(list)
    has_parent = set()

    for rel in relations:
        if rel["name"] == "subClassOf":
            continue
        parent_rel = rel.get("parent_name")
        if parent_rel and parent_rel in rel_by_name:
            rel_children_map[parent_rel].append(rel["name"])
            has_parent.add(rel["name"])

    rel_roots = []
    for name, r in rel_by_name.items():
        if name in has_parent:
            continue
        if r.get("is_abstract") or name in rel_children_map:
            rel_roots.append(name)

    flat_concrete = [
        name for name, r in rel_by_name.items()
        if name not in has_parent
        and not r.get("is_abstract")
        and name not in rel_children_map
    ]

    return rel_children_map, rel_roots, flat_concrete, rel_by_name


def render_interactive_tree(name: str, children_map: dict, name_to_cls: dict,
                            depth: int = 0, max_depth: int = 6, search: str = "") -> None:
    """Render an interactive Streamlit tree with colored nodes."""
    if depth > max_depth:
        return
    cls = name_to_cls.get(name, {})
    label = cls.get("label", name)
    is_abstract = cls.get("is_abstract", False)
    description = cls.get("description", "")
    kids = sorted(children_map.get(name, []))
    has_children = len(kids) > 0

    if is_abstract:
        icon = "\U0001f539"  # blue diamond
        display = f"{icon} **{label}**  `abstract`"
    else:
        icon = "\U0001f7e2"  # green circle
        display = f"{icon} {label}"

    if search and search.lower() in label.lower():
        display += "  \U0001f50d"

    indent_px = depth * 24

    if has_children:
        st.markdown(
            f'<div style="margin-left:{indent_px}px; padding:4px 0; font-weight:bold;">{display}</div>',
            unsafe_allow_html=True
        )
        if description:
            st.markdown(
                f'<div style="margin-left:{indent_px + 16}px; color:gray; font-size:0.85em;">{description}</div>',
                unsafe_allow_html=True
            )
        for child in kids:
            render_interactive_tree(child, children_map, name_to_cls,
                                    depth + 1, max_depth, search)
    else:
        st.markdown(
            f'<div style="margin-left:{indent_px}px; padding:2px 0;">{display}</div>',
            unsafe_allow_html=True
        )
        if description and search and search.lower() in label.lower():
            st.markdown(
                f'<div style="margin-left:{indent_px + 16}px; color:gray; font-size:0.85em;">{description}</div>',
                unsafe_allow_html=True
            )


def render_interactive_rel_tree(name: str, rel_children_map: dict, rel_by_name: dict,
                                depth: int = 0, max_depth: int = 6) -> None:
    """Render an interactive Streamlit tree for relations."""
    if depth > max_depth:
        return
    r = rel_by_name.get(name, {})
    label = r.get("label", name)
    is_abstract = r.get("is_abstract", False)
    domain = r.get("domain_class", "?")
    rng = r.get("range_class", "?")
    description = r.get("description", "")
    kids = sorted(rel_children_map.get(name, []))
    has_children = len(kids) > 0

    if is_abstract:
        icon = "\U0001f537"  # large blue diamond
        display = f"{icon} **{label}**  `abstract`  ({domain} -> {rng})"
    else:
        icon = "\U0001f7e3"  # purple circle
        display = f"{icon} {label}  ({domain} -> {rng})"

    indent_px = depth * 24

    if has_children:
        st.markdown(
            f'<div style="margin-left:{indent_px}px; padding:4px 0; font-weight:bold;">{display}</div>',
            unsafe_allow_html=True
        )
        if description:
            st.markdown(
                f'<div style="margin-left:{indent_px + 16}px; color:gray; font-size:0.85em;">{description}</div>',
                unsafe_allow_html=True
            )
        for child in kids:
            render_interactive_rel_tree(child, rel_children_map, rel_by_name,
                                       depth + 1, max_depth)
    else:
        st.markdown(
            f'<div style="margin-left:{indent_px}px; padding:2px 0;">{display}</div>',
            unsafe_allow_html=True
        )
        if description:
            st.markdown(
                f'<div style="margin-left:{indent_px + 16}px; color:gray; font-size:0.85em;">{description}</div>',
                unsafe_allow_html=True
            )


def build_coverage_map(classes: list[dict], deployed_objects: dict | None = None) -> dict[str, dict]:
    """Classify each class by its coverage status using deployed_objects manifest."""
    result: dict[str, dict] = {}

    if not deployed_objects:
        for cls in classes:
            result[cls["name"]] = {"status": "abstract" if cls.get("is_abstract") else "unmapped"}
        return result

    class_to_objects = deployed_objects.get("class_to_objects", {})
    name_to_cls = {c["name"]: c for c in classes}

    def _has_view(cls_name: str) -> list[str]:
        entry = class_to_objects.get(cls_name, {})
        return entry.get("views", [])

    def _find_deployed_ancestor(cls: dict) -> tuple[str, list[str]] | None:
        visited = set()
        current = cls.get("parent_name")
        while current and current not in visited:
            visited.add(current)
            parent_cls = name_to_cls.get(current)
            if parent_cls:
                views = _has_view(current)
                if views:
                    return (parent_cls.get("label", current), views)
                current = parent_cls.get("parent_name")
            else:
                break
        return None

    for cls in classes:
        name = cls["name"]
        views = _has_view(name)
        entry = class_to_objects.get(name, {})
        sf_objs = views + ([entry["metadata_row"]] if entry.get("metadata_row") else [])

        if views:
            result[name] = {
                "status": "mapped",
                "view_name": views[0],
                "sf_objects": sf_objs,
            }
        elif cls.get("is_abstract"):
            result[name] = {"status": "abstract", "sf_objects": sf_objs}
        else:
            ancestor = _find_deployed_ancestor(cls)
            if ancestor:
                result[name] = {
                    "status": "covered",
                    "covering_ancestor": ancestor[0],
                    "covering_view": ancestor[1][0],
                    "sf_objects": sf_objs,
                }
            else:
                result[name] = {"status": "unmapped", "sf_objects": sf_objs}

    return result


def build_agraph_nodes_edges(classes: list[dict], relations: list[dict],
                              coverage_map: dict[str, dict],
                              max_nodes: int = 100,
                              show_relations: bool = True,
                              layer_filter: str = "all") -> tuple[list, list]:
    """Build streamlit-agraph Node and Edge lists with coverage coloring."""
    if layer_filter == "concrete":
        classes = [c for c in classes if not c.get("is_abstract")]
    elif layer_filter == "abstract":
        classes = [c for c in classes if c.get("is_abstract")]

    colors = {
        "mapped":   {"background": "#2ecc71", "border": "#27ae60", "font": "#ffffff"},
        "covered":  {"background": "#3498db", "border": "#2980b9", "font": "#ffffff"},
        "unmapped": {"background": "#e74c3c", "border": "#c0392b", "font": "#ffffff"},
        "abstract": {"background": "#ecf0f1", "border": "#95a5a6", "font": "#2c3e50"},
    }

    name_to_cls = {c["name"]: c for c in classes}
    nodes = []
    edges = []
    displayed = set()

    for cls in classes[:max_nodes]:
        name = cls["name"]
        label = cls.get("label", name)
        cov = coverage_map.get(name, {"status": "unmapped"})
        status = cov["status"]
        c = colors[status]

        # Build hover tooltip
        tooltip_parts = [f"<b>{label}</b>"]
        if cls.get("is_abstract"):
            tooltip_parts.append("<i>Abstract class</i>")
        if cls.get("description"):
            tooltip_parts.append(cls["description"][:150])
        tooltip_parts.append(f"<br/>Coverage: <b>{status.upper()}</b>")
        if status == "mapped":
            vn = cov.get("view_name", "")
            short = vn
            if "VW_ONT_" in vn.upper():
                short = "VW_ONT_" + vn.upper().split("VW_ONT_", 1)[1]
            tooltip_parts.append(f"View: <code>{short}</code>")
        elif status == "covered":
            tooltip_parts.append(f"Covered via: {cov.get('covering_ancestor', '?')}")
        tooltip = "<br/>".join(tooltip_parts)

        is_abs = cls.get("is_abstract", False)
        font_color = "#2c3e50" if is_abs else c["font"]

        nodes.append(Node(
            id=name,
            label=label,
            title=tooltip,
            color={"background": c["background"], "border": c["border"]},
            shape="diamond" if is_abs else "box",
            size=25,
            font={"color": font_color, "size": 12},
            borderWidth=2,
            borderWidthSelected=3,
        ))
        displayed.add(name)

    # subClassOf edges (hierarchy)
    for cls in classes[:max_nodes]:
        parent = cls.get("parent_name")
        if parent and cls["name"] in displayed:
            if parent not in displayed:
                parent_cls = name_to_cls.get(parent, {})
                nodes.append(Node(
                    id=parent,
                    label=parent_cls.get("label", parent),
                    title=f"<b>{parent_cls.get('label', parent)}</b><br/><i>Not in visible set</i>",
                    color={"background": "#ecf0f1", "border": "#bdc3c7"},
                    shape="diamond",
                    size=25,
                    font={"color": "#95a5a6", "size": 12},
                    borderWidth=2,
                ))
                displayed.add(parent)
            edges.append(Edge(
                source=cls["name"],
                target=parent,
                color="#5dade2",
                label="subClassOf",
                width=1.5,
                arrows="to",
                dashes=False,
                font={"size": 8, "color": "#5dade2", "strokeWidth": 0},
            ))

    # Relation edges
    if show_relations:
        for rel in relations:
            if rel["name"] == "subClassOf":
                continue
            is_abstract_rel = rel.get("is_abstract", False)
            if layer_filter == "concrete" and is_abstract_rel:
                continue
            if layer_filter == "abstract" and not is_abstract_rel:
                continue

            domain = rel.get("domain_class", "")
            rng = rel.get("range_class", "")
            if domain in displayed and rng in displayed:
                if is_abstract_rel:
                    edge_color = "#8e44ad"
                    edge_width = 2.5
                elif rel.get("is_hierarchical"):
                    edge_color = "#e67e22"
                    edge_width = 1.0
                else:
                    edge_color = "#9b59b6"
                    edge_width = 1.0
                edges.append(Edge(
                    source=domain,
                    target=rng,
                    color=edge_color,
                    label=rel["name"],
                    width=edge_width,
                    arrows="to",
                    dashes=not is_abstract_rel,
                    font={"size": 8, "color": edge_color, "strokeWidth": 0},
                ))

    return nodes, edges


def render_node_detail(cls_name: str, classes: list[dict], relations: list[dict],
                       coverage_map: dict[str, dict],
                       deployed_objects: dict | None = None) -> None:
    """Render the detail inspector panel for a clicked node."""
    name_to_cls = {c["name"]: c for c in classes}
    cls = name_to_cls.get(cls_name)
    if not cls:
        st.warning(f"Class '{cls_name}' not found.")
        return

    label = cls.get("label", cls_name)
    cov = coverage_map.get(cls_name, {"status": "unmapped"})
    status = cov["status"]

    badge_colors = {
        "mapped": "#2ecc71", "covered": "#3498db",
        "unmapped": "#e74c3c", "abstract": "#95a5a6",
    }
    badge_labels = {
        "mapped": "MAPPED TO VIEW", "covered": "COVERED AS ROWS",
        "unmapped": "UNMAPPED", "abstract": "ABSTRACT",
    }
    bc = badge_colors.get(status, "#95a5a6")
    bl = badge_labels.get(status, status.upper())
    st.markdown(
        f'<h3 style="margin-bottom:0;">{label}</h3>'
        f'<span style="background:{bc};color:white;padding:2px 10px;border-radius:10px;'
        f'font-size:0.75em;font-weight:bold;">{bl}</span>',
        unsafe_allow_html=True,
    )

    if cls.get("description"):
        st.caption(cls["description"])

    st.divider()

    type_label = "Abstract" if cls.get("is_abstract") else "Concrete"
    st.markdown(f"**Type:** {type_label}")
    if cls.get("parent_name"):
        parent_cls = name_to_cls.get(cls["parent_name"], {})
        st.markdown(f"**Parent:** {parent_cls.get('label', cls['parent_name'])}")

    children = [c for c in classes if c.get("parent_name") == cls_name]
    if children:
        child_labels = ", ".join(sorted(c.get("label", c["name"]) for c in children))
        st.markdown(f"**Children ({len(children)}):** {child_labels}")

    st.divider()

    # Snowflake Implementation
    st.markdown("#### Snowflake Implementation")
    sf_objs = cov.get("sf_objects", [])
    if sf_objs:
        st.markdown("**Deployed objects:**")
        for obj in sf_objs:
            st.write(f"- `{obj}`")

    if status == "mapped":
        view_name = cov.get("view_name", "")
        short = view_name
        if "VW_ONT_" in view_name.upper():
            short = "VW_ONT_" + view_name.upper().split("VW_ONT_", 1)[1]
        st.markdown(f"**View:** `{short}`")
    elif status == "covered":
        ancestor = cov.get("covering_ancestor", "?")
        covering_view = cov.get("covering_view", "")
        short_cv = covering_view
        if "VW_ONT_" in covering_view.upper():
            short_cv = "VW_ONT_" + covering_view.upper().split("VW_ONT_", 1)[1]
        st.markdown(f"**Covered by ancestor:** {ancestor}")
        st.markdown(f"**Ancestor's view:** `{short_cv}`")
        st.info(f"Rows for *{label}* exist as typed rows within the ancestor's view.")
    elif status == "unmapped":
        st.error("No view or ancestor view covers this class.")
    elif status == "abstract":
        st.markdown("**No dedicated view** — abstract classes are structural groupings.")
        if children:
            st.info(f"This class organizes {len(children)} child classes.")

    # Relations involving this class
    involved_rels = [r for r in relations
                     if r.get("domain_class") == cls_name or r.get("range_class") == cls_name]
    if involved_rels:
        st.divider()
        st.markdown("#### Relations")
        for r in involved_rels:
            direction = "domain" if r.get("domain_class") == cls_name else "range"
            other = r.get("range_class") if direction == "domain" else r.get("domain_class")
            other_label = name_to_cls.get(other, {}).get("label", other)
            if direction == "domain":
                arrow = f"{label} \u2014[{r['name']}]\u2192 {other_label}"
            else:
                arrow = f"{other_label} \u2014[{r['name']}]\u2192 {label}"
            st.markdown(f"- {arrow}")


def render_default_detail(classes: list[dict], relations: list[dict],
                          coverage_map: dict[str, dict],
                          deployed_objects: dict | None = None) -> None:
    """Render the default detail panel when no node is selected."""
    st.markdown("#### Click a node to inspect")
    st.caption("Click any node in the graph to see its Snowflake implementation details.")

    st.divider()

    status_counts = defaultdict(int)
    for cov in coverage_map.values():
        status_counts[cov["status"]] += 1

    cols = st.columns(4)
    cols[0].metric("Mapped", status_counts.get("mapped", 0))
    cols[1].metric("Covered", status_counts.get("covered", 0))
    cols[2].metric("Unmapped", status_counts.get("unmapped", 0))
    cols[3].metric("Abstract", status_counts.get("abstract", 0))

    if deployed_objects:
        st.divider()
        st.markdown("#### Snowflake Artifacts")
        n_views = len(deployed_objects.get("views", []))
        n_tables = len(deployed_objects.get("tables", []))
        n_procs = len(deployed_objects.get("procedures", []))
        n_udfs = len(deployed_objects.get("udfs", []))
        st.write(f"- **{n_views}** views, **{n_tables}** tables")
        st.write(f"- **{n_procs}** procedures, **{n_udfs}** UDFs")


# ===========================================================================
# TAB 5: Hierarchy
# ===========================================================================

with tab5:
 try:
    st.header("Class & Relation Hierarchy")
    classes_data = load_classes()
    relations_data = load_relations()

    # -- Class Hierarchy --
    with st.expander("Class Hierarchy", expanded=True):
        children_map, roots, name_to_cls = build_tree(classes_data)

        col_ctrl1, col_ctrl2 = st.columns([1, 1])
        with col_ctrl1:
            max_depth_cls = st.slider("Max display depth", 1, 15, 6, key="hier_cls_depth")
        with col_ctrl2:
            cls_search = st.text_input("Search classes", "", placeholder="Type to filter...",
                                       key="hier_cls_search")

        st.markdown(
            "\U0001f539 = abstract (no data rows) &nbsp;&nbsp; "
            "\U0001f7e2 = concrete (has data) &nbsp;&nbsp; "
            "\U0001f50d = search match",
            unsafe_allow_html=True
        )
        st.divider()

        if cls_search:
            matches = [c for c in classes_data
                       if cls_search.lower() in c.get("label", "").lower()
                       or cls_search.lower() in c["name"].lower()]
            st.write(f"**{len(matches)} matches** for \"{cls_search}\":")
            for m in matches[:50]:
                path_parts = []
                current = m.get("parent_name")
                while current:
                    path_parts.insert(0, name_to_cls.get(current, {}).get("label", current))
                    current = name_to_cls.get(current, {}).get("parent_name")
                path_str = " \u2192 ".join(path_parts) if path_parts else "root"
                icon = "\U0001f539" if m.get("is_abstract") else "\U0001f7e2"
                st.markdown(f"{icon} **{m.get('label', m['name'])}**")
                st.caption(f"Path: {path_str}")
                if m.get("description"):
                    st.caption(m["description"][:200])
        else:
            for root in sorted(roots):
                render_interactive_tree(root, children_map, name_to_cls,
                                        max_depth=max_depth_cls, search=cls_search)

    # -- Relation Hierarchy --
    with st.expander("Relation Hierarchy", expanded=True):
        rel_children_map, rel_roots, flat_concrete, rel_by_name = build_relation_tree(relations_data)

        st.markdown(
            "\U0001f537 = abstract relation &nbsp;&nbsp; \U0001f7e3 = concrete relation",
            unsafe_allow_html=True
        )
        st.divider()

        if not rel_roots and not flat_concrete:
            st.info("No relations defined.")
        else:
            for root_rel in sorted(rel_roots):
                render_interactive_rel_tree(root_rel, rel_children_map, rel_by_name)
            if flat_concrete:
                st.markdown("**Ungrouped concrete relations**")
                for name in sorted(flat_concrete):
                    r = rel_by_name[name]
                    domain = r.get("domain_class", "?")
                    rng = r.get("range_class", "?")
                    desc = r.get("description", "")
                    st.markdown(
                        f'<div style="padding:2px 0;">\U0001f7e3 {r.get("label", name)}  ({domain} -> {rng})</div>',
                        unsafe_allow_html=True)
                    if desc:
                        st.markdown(
                        f'<div style="margin-left:16px; color:gray; font-size:0.85em;">{desc}</div>',
                        unsafe_allow_html=True)
 except Exception as _tab5_err:
    st.error(f"Hierarchy tab encountered an error: {_tab5_err}")
    st.caption("The other tabs are unaffected — click a different tab to continue.")


# ===========================================================================
# TAB 6: Ontology Graph
# ===========================================================================

with tab6:
 try:
    st.header("Ontology Graph")
    classes_data_g = load_classes()
    relations_data_g = load_relations()
    deployed_objects_g = load_deployed_objects()
    coverage_map_g = build_coverage_map(classes_data_g, deployed_objects_g)

    # Controls row
    col_g1, col_g2, col_g3, col_g4 = st.columns([1, 1, 1, 1])
    with col_g1:
        max_nodes = st.slider("Max nodes", 10, 500, min(len(classes_data_g), 50), key="graph_max")
    with col_g2:
        show_rels = st.checkbox("Show relation edges", value=True, key="graph_rels")
    with col_g3:
        physics_on = st.checkbox("Physics simulation", value=True, key="graph_physics")
    with col_g4:
        layer_mode = st.radio("Layer", ["All", "Concrete", "Abstract"],
                              horizontal=True, key="graph_layer")
        layer_filter = layer_mode.lower()

    # Legend
    st.markdown(
        '<div style="display:flex;gap:16px;flex-wrap:wrap;margin:4px 0 8px 0;font-size:0.85em;">'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:14px;height:14px;background:#2ecc71;border:2px solid #27ae60;border-radius:3px;display:inline-block;"></span>'
        ' Mapped to View</span>'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:14px;height:14px;background:#3498db;border:2px solid #2980b9;border-radius:3px;display:inline-block;"></span>'
        ' Covered as Rows</span>'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:14px;height:14px;background:#e74c3c;border:2px solid #c0392b;border-radius:3px;display:inline-block;"></span>'
        ' Unmapped</span>'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:14px;height:14px;background:#ecf0f1;border:2px solid #95a5a6;'
        'transform:rotate(45deg);display:inline-block;"></span>'
        ' Abstract Class</span>'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:20px;border-top:2px solid #5dade2;display:inline-block;"></span>'
        ' subClassOf</span>'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:20px;border-top:2px dashed #9b59b6;display:inline-block;"></span>'
        ' Concrete Rel</span>'
        '<span style="display:inline-flex;align-items:center;gap:4px;">'
        '<span style="width:20px;border-top:3px solid #8e44ad;display:inline-block;"></span>'
        ' Abstract Rel</span>'
        '</div>',
        unsafe_allow_html=True,
    )

    # Two-panel layout: graph (left) + detail (right)
    col_graph, col_detail = st.columns([7, 3])

    with col_graph:
        ag_nodes, ag_edges = build_agraph_nodes_edges(
            classes_data_g, relations_data_g, coverage_map_g,
            max_nodes=max_nodes, show_relations=show_rels,
            layer_filter=layer_filter,
        )

        config = Config(
            width=900,
            height=600,
            physics=physics_on,
            layout={"hierarchical": False},
        )

        selected_node = agraph(nodes=ag_nodes, edges=ag_edges, config=config)

    with col_detail:
        if selected_node:
            render_node_detail(selected_node, classes_data_g, relations_data_g,
                               coverage_map_g, deployed_objects_g)
        else:
            render_default_detail(classes_data_g, relations_data_g,
                                  coverage_map_g, deployed_objects_g)
 except Exception as _tab6_err:
    st.error(f"Ontology Graph encountered an error: {_tab6_err}")
    st.caption("The other tabs are unaffected — click a different tab to continue.")


# ===========================================================================
# TAB 7: Coverage Matrix
# ===========================================================================

with tab7:
 try:
    classes_data_c = load_classes()
    deployed_objects_c = load_deployed_objects()
    cov_map = build_coverage_map(classes_data_c, deployed_objects_c)

    source_label = deployed_objects_c.get("source", "Ontology Design")
    db_label = deployed_objects_c.get("database", "")
    schema_label = deployed_objects_c.get("schema", "")
    target_label = f"{db_label}.{schema_label}" if db_label and schema_label else "Snowflake"
    st.header("Original Design \u2192 Snowflake Implementation")
    st.caption(
        f"Mapping from **{source_label}** to deployed objects in **{target_label}**"
    )

    directly_mapped = [c for c in classes_data_c if cov_map[c["name"]]["status"] == "mapped"]
    covered_by_parent = [
        (c, cov_map[c["name"]]["covering_ancestor"])
        for c in classes_data_c if cov_map[c["name"]]["status"] == "covered"
    ]
    truly_unmapped = [c for c in classes_data_c if cov_map[c["name"]]["status"] == "unmapped"]

    # Summary metrics
    total_concrete = sum(1 for c in classes_data_c if not c.get("is_abstract"))
    total_abstract = sum(1 for c in classes_data_c if c.get("is_abstract"))
    concrete_mapped = [c for c in directly_mapped if not c.get("is_abstract")]
    concrete_covered_count = len(concrete_mapped) + len(covered_by_parent)

    mcol1, mcol2, mcol3, mcol4 = st.columns(4)
    mcol1.metric("Total Classes", len(classes_data_c))
    mcol2.metric("Abstract (no view needed)", total_abstract)
    mcol3.metric("Concrete Implemented", concrete_covered_count)
    mcol4.metric("Not Yet Mapped", len(truly_unmapped))

    if total_concrete > 0:
        ratio = min(concrete_covered_count / total_concrete, 1.0)
        st.progress(ratio,
                    text=f"{concrete_covered_count}/{total_concrete} concrete classes "
                         f"mapped to Snowflake ({100 * ratio:.0f}%)")

    # Three-column detail view
    col1, col2, col3 = st.columns(3)
    with col1:
        st.subheader(f"Mapped to Snowflake ({len(directly_mapped)})")
        st.caption("Ontology class has dedicated Snowflake view(s)")
        for c in sorted(directly_mapped, key=lambda x: x.get("label", x["name"])):
            view_name = cov_map[c["name"]].get("view_name", "")
            short = view_name
            if "VW_ONT_" in view_name.upper():
                short = "VW_ONT_" + view_name.upper().split("VW_ONT_", 1)[1]
            sf_objs = cov_map[c["name"]].get("sf_objects", [])
            if sf_objs and len(sf_objs) > 1:
                st.write(f"- **{c.get('label', c['name'])}** \u2192")
                for obj in sf_objs:
                    st.write(f"  - `{obj}`")
            else:
                st.write(f"- **{c.get('label', c['name'])}** \u2192 `{short}`")
    with col2:
        st.subheader(f"Covered by Ancestor ({len(covered_by_parent)})")
        st.caption("No own view, but included as rows in a parent's view")
        by_ancestor: dict[str, list] = defaultdict(list)
        for cls, ancestor in covered_by_parent:
            by_ancestor[ancestor].append(cls)
        for ancestor in sorted(by_ancestor.keys()):
            children_list = by_ancestor[ancestor]
            with st.expander(f"via **{ancestor}** ({len(children_list)} classes)"):
                for c in sorted(children_list, key=lambda x: x.get("label", x["name"])):
                    st.write(f"- {c.get('label', c['name'])}")
    with col3:
        st.subheader(f"Unmapped ({len(truly_unmapped)})")
        st.caption("No Snowflake view or ancestor view covers this class")
        for c in sorted(truly_unmapped, key=lambda x: x.get("label", x["name"])):
            st.write(f"- {c.get('label', c['name'])}")
        if not truly_unmapped:
            st.success("All concrete classes are implemented in Snowflake!")

    # Full Artifact Inventory
    st.divider()
    with st.expander("Full Artifact Inventory \u2014 All Snowflake Objects Generated"):
        inv_col1, inv_col2 = st.columns(2)
        with inv_col1:
            views = deployed_objects_c.get("views", [])
            if views:
                st.markdown(f"**Views ({len(views)})**")
                for v in sorted(views):
                    st.write(f"- `{v}`")
            tables = deployed_objects_c.get("tables", [])
            if tables:
                st.markdown(f"**Tables ({len(tables)})**")
                for t in sorted(tables):
                    st.write(f"- `{t}`")
        with inv_col2:
            procs = deployed_objects_c.get("procedures", [])
            if procs:
                st.markdown(f"**Stored Procedures ({len(procs)})**")
                for p in sorted(procs):
                    st.write(f"- `{p}`")
            udfs = deployed_objects_c.get("udfs", [])
            if udfs:
                st.markdown(f"**UDFs / Graph Tools ({len(udfs)})**")
                for u in sorted(udfs):
                    st.write(f"- `{u}`")

    # Relation mapping
    relation_to_objects = deployed_objects_c.get("relation_to_objects", {})
    if relation_to_objects:
        st.divider()
        st.subheader("Relation \u2192 Snowflake Mapping")
        for rel_name, rel_info in sorted(relation_to_objects.items()):
            view = rel_info.get("view", "")
            meta = rel_info.get("metadata_row", "")
            parts = [f"`{view}`" if view else None, f"`{meta}`" if meta else None]
            mapped_to = ", ".join(p for p in parts if p)
            st.write(f"- **{rel_name}** \u2192 {mapped_to}")
 except Exception as _tab7_err:
    st.error(f"Coverage Matrix encountered an error: {_tab7_err}")
    st.caption("The other tabs are unaffected — click a different tab to continue.")
