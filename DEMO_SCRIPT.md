# Ontology Stack Builder — Demo Script

**Format:** Live talk-track with presenter notes
**Audience:** Internal team (Snowflake engineers/PMs familiar with Cortex Code, semantic views, agents)
**Duration:** ~15 minutes
**Dataset:** TICKET_METRICS_ONT_POC (Zendesk ticket metrics + Gong + UserVoice + EDA ML data)

---

## Pre-Demo Setup

- [ ] Cortex Code CLI open in a terminal
- [ ] Browser tab with the Streamlit demo app running (`streamlit run demo_app.py --server.port 8510`)
- [ ] Browser tab with Snowflake Intelligence open to the TICKET_METRICS_ONTOLOGY_AGENT
- [ ] Snowsight open to `_SANDBOX_ONTOLOGY_POC.TICKET_METRICS` schema (for showing deployed objects)
- [ ] This script open on a secondary screen

---

## Act 1: The Problem (2 min)

### Slide / talking point — no screen share yet

> "You've got 24 source tables spread across two schemas — CONVERGE and EDA_ML_DATA. Ticket volumes, CSAT scores, agent staffing, Gong calls, UserVoice feedback, CRM snapshots. Different grains, different join keys, some metrics that can't be aggregated across instances.
>
> A single semantic view can handle the additive ticket metrics fine. But what if someone asks 'What classes of data exist and how are they related?' or 'Traverse from a CRM account through its instances to the agent detail?' or 'What ontology properties does the InstanceAccount class have?'
>
> A flat semantic view can't answer those. You need a data model that understands entities, relationships, and metadata — an ontology layer. Building that by hand takes weeks of SQL scripting. The ontology-stack-builder skill does it in a single conversational session."

---

## Act 2: What We Built (3 min)

### Screen: Snowsight — object browser on _SANDBOX_ONTOLOGY_POC.TICKET_METRICS

> "Let me show you what the skill produced. One CoCo session, 7 gated phases, and we now have **97 Snowflake objects** deployed."

Walk through the object counts (keep it quick, just read from the schema browser):

| Layer | What | Count |
|-------|------|-------|
| L1 Physical | KG_NODE (49.5M rows, 22 types), KG_EDGE (109M rows, 5 types) | 2 tables |
| L2 Concrete Views | V_CRMACCOUNT, V_AGGINSTANCECHANNELTICKETMONTHLY, ... | 28 views |
| L3 Metadata | ONT_CLASS, ONT_RELATION_DEF, ONT_PROPERTY, ... | 26 tables |
| L3 Abstract | VW_ONT_CRMACCOUNT, VW_ONT_ALL_ENTITIES, REL_RESOLVED, ... | 25 views |
| L3 Logic | SP_GENERATE_ONTOLOGY_VIEWS, inference engine (5 SPs), graph UDFs (4) | 10 procs/UDFs |
| L4 Semantic | SV_CUSTOMER_TRENDED_TICKET_METRICS (base), SV_KG_*, SV_ONT_*, SV_META_* | 4 semantic views |
| L5 Agent | TICKET_METRICS_ONTOLOGY_AGENT with 4 tools | 1 agent |

> "Every one of those objects was generated, reviewed, and deployed through the skill's 7-phase gated workflow. No manual SQL. The skill stops at each phase and waits for approval before continuing — you stay in control."

---

## Act 3: The 7-Phase Workflow (3 min)

### Screen: Terminal — Cortex Code (just show SKILL.md briefly, or narrate over a diagram)

Walk through each phase at high level. Emphasize the gates.

> **Phase 1 — Gather Inputs.** "I gave it the two source schemas, 30 benchmark questions from a CSV, told it I wanted the KG path, and pointed it at an existing semantic view we'd already built. Gate: confirm inputs."
>
> **Phase 2 — Analyze & Recommend.** "The skill ran `introspect_schema.py` against all 24 tables. It classified each table as entity, fact, or lookup using FK patterns and column counts. Proposed 23 ontology classes and 29 relations. Because we had an existing semantic view, it enriched the proposals with curated column descriptions and metric definitions from that model. Gate: confirm ontology design."
>
> **Phase 3 — Visualize & Confirm.** "It launched a Streamlit visualizer with an interactive graph — nodes for classes, edges for relations, color-coded by coverage. There's a sidebar editor where you can add, remove, or rename classes before committing. Gate: visual confirmation."
>
> **Phase 4 — Generate & Deploy.** "The skill generated 7 SQL files — physical KG tables, concrete views, metadata tables with seed data, abstract views, view generator SP, inference engine, and graph traversal UDFs. It ran a self-check counting expected vs. actual objects, then deployed everything. Gate: deployment verified."
>
> **Phase 4.5 — Base Semantic View.** "We already had SV_CUSTOMER_TRENDED_TICKET_METRICS, so this phase was skipped — reused as the base tool."
>
> **Phase 5 — Ontology Semantic Views.** "The skill delegated to the native `semantic-view` skill three times — building the KG semantic view (over concrete V_* views), the ontology semantic view (over VW_ONT_* abstract views), and the metadata semantic view (over ONT_* catalog tables). Each was tested. Gate: all three generating valid SQL."
>
> **Phase 6 — Cortex Agent.** "Delegated to the native `cortex-agent` skill. Created TICKET_METRICS_ONTOLOGY_AGENT with 4 tools — one per semantic view. The agent's instructions include intent-routing logic so it picks the right tool based on the question. Gate: agent tested."
>
> **Phase 7 — Validation.** "End-to-end: row counts, sample queries on each layer, semantic view SQL generation checks, agent test. All passed."

---

## Act 4: Live Demo (5 min)

### Part A: Cortex Agent in Snowflake Intelligence (3 min)

### Screen: Browser — Snowflake Intelligence (TICKET_METRICS_ONTOLOGY_AGENT)

> "Let's start with the end-user experience. The Cortex Agent we built is accessible directly in Snowflake Intelligence — no custom app needed."

Run 2-3 questions live. Suggested sequence:

1. **Simple additive metric:**
   > Type: `How many tickets were created for Sprinter Health?`
   >
   > "Notice the tool routing — it picked **Ticket Metrics** (the base semantic view). You can see the generated SQL and the result right here in Snowflake Intelligence."

2. **Knowledge graph traversal:**
   > Type: `Which Zendesk instances does Datadog have?`
   >
   > "This time it used the **Knowledge Graph** tool — querying the concrete V_* views over KG_NODE/KG_EDGE. The agent's intent-routing logic picks the right tool based on the question."

3. **Metadata / ontology question:**
   > Type: `What ontology classes exist and how many properties does each have?`
   >
   > "Now it routed to **Metadata Catalog** — querying ONT_CLASS joined to ONT_PROPERTY. This kind of question is impossible with a flat semantic view. The ontology layer is what makes it work."

> "That's the production-ready experience — Snowflake Intelligence gives you a polished chat UI, suggested follow-ups, and chart generation out of the box. No custom app to maintain."

### Part B: Streamlit Explorer App (2 min)

### Screen: Browser — Streamlit demo app (http://localhost:8510)

> "Now let's look under the hood at the data structures powering those answers."

### Tab 2: Knowledge Graph Explorer

> "For power users who want to browse the graph directly."

- Select **CrmAccount** as entity type
- Search for **Datadog**
- Click on Datadog to show its properties (JSON) and outgoing relationships (edges to instances)

> "49.5 million nodes, 109 million edges, all queryable through typed views."

### Tab 6: Ontology Graph (if time allows)

> "This is the ontology structure — 23 classes, 29 relations. Green nodes are fully mapped to Snowflake objects. CrmAccount is the hub — everything connects through it."

### Tab 7: Coverage Matrix (quick glance)

> "100% coverage. All 23 classes have dedicated views. The progress bar and three-column breakdown give you a governance dashboard for the ontology."

---

## Act 5: Architecture Highlights & Wrap-Up (2 min)

### Screen: Back to Snowsight or slides

Key points to land:

1. **Two storage paths.** "KG path gives you physical graph tables and graph analytics. Direct-table path gives you the same ontology layer with zero data duplication — just views. The skill handles both."

2. **Skill delegation pattern.** "Phases 4.5, 5, and 6 delegate to native CoCo skills — `semantic-view` and `cortex-agent`. The ontology skill orchestrates, the native skills do the detailed work. This means ontology semantic views and agents always use the latest best practices from those skills."

3. **Session resume.** "If CoCo disconnects mid-workflow, the skill can detect what's already deployed in Snowflake and resume from where it left off — no re-running earlier phases."

4. **Non-additive metric awareness.** "The ontology design captured that RBA metrics — median FRT, TTC, ratios — cannot be summed across instances. This flows through to the semantic views so the agent handles these correctly."

5. **Scale.** "24 source tables, 23 classes, 29 relations, 97 deployed objects, 49.5M nodes, 109M edges, 4 semantic views, 1 agent — generated in a single conversational session."

> "That's the ontology-stack-builder. Questions?"

---

## Backup Queries (if audience asks to see more)

| Question | Expected tool | What it shows |
|----------|--------------|---------------|
| "What is the CSAT score for Sprinter Health?" | Ticket Metrics | Simple aggregation |
| "Show me the top 10 accounts by ticket volume" | Ticket Metrics | Ranking query |
| "How many active agents does Datadog have?" | Ticket Metrics | Agent staffing metric |
| "What is the median first reply time for Datadog's instances?" | Knowledge Graph | Non-additive metric, per-instance |
| "List all ontology relations and their cardinality" | Metadata Catalog | Ontology introspection |
| "Show accounts with declining CSAT over the last 6 months" | Ticket Metrics | Trend analysis |

---

## Timing Guide

| Section | Duration | Cumulative |
|---------|----------|------------|
| Act 1 — The Problem | 2 min | 2 min |
| Act 2 — What We Built | 3 min | 5 min |
| Act 3 — 7-Phase Workflow | 3 min | 8 min |
| Act 4A — Agent in Snowflake Intelligence | 3 min | 11 min |
| Act 4B — Streamlit Explorer App | 2 min | 13 min |
| Act 5 — Architecture & Wrap-Up | 2 min | 15 min |
