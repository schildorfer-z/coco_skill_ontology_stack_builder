# ontology-stack-builder

A [Cortex Code](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code) skill that generates the full **Ontology-on-Snowflake** stack from any relational schema through a 7-phase gated workflow.

You bring your Snowflake tables and business questions. The skill builds the rest — metadata, abstract views, semantic models, and a Cortex Agent — in a single conversational session.

For the architectural foundations, see the original blog series:
- [Part 1 — Overview and Data Model]()
- [Part 2 — Semantic Models]()
- [Part 3 — AI-Powered Intelligence]()

---

## What It Builds

| Layer | What Gets Created |
|-------|-------------------|
| **L1 — Physical Storage** | Source table views or KG_NODE/KG_EDGE graph tables |
| **L2 — Ontology Metadata** | ~22 metadata tables with auto-populated seed data |
| **L3 — Abstract Views** | Per-class abstract views, hierarchy views, view-generator procedure |
| **L4 — Semantic Views** | Up to 3 Cortex Analyst semantic views |
| **L5 — Cortex Agent** | Agent with intent-routed semantic view tools |

---

## Installation

```bash
# User-level (all projects)
git clone https://github.com/sfc-gh-tjia/ontology-stack-builder.git
cp -r ontology-stack-builder ~/.snowflake/cortex/skills/ontology-stack-builder

# Or project-level (single project)
cp -r ontology-stack-builder .cortex/skills/ontology-stack-builder
```

### Prerequisites

- **Cortex Code** CLI
- **Snowflake account** with CREATE TABLE, CREATE VIEW, CREATE PROCEDURE permissions
- **Python 3.10+** (dependencies managed automatically via `uv`)

---

## Usage

A single prompt kicks off the workflow:

```
Use ontology-stack-builder skill. Build an ontology stack on MY_DB.MY_SCHEMA using these inputs:

Database: MY_DB, Schema: MY_SCHEMA
Source tables: TABLE_A, TABLE_B, TABLE_C
Ontology name: MY_ONTOLOGY
Path: Direct table path
Business questions: What products does each customer buy? How are customers segmented?
Semantic views: Ontology + Metadata
```

### Prompt Fields

| Field | Description |
|-------|-------------|
| **Database / Schema** | Snowflake location for all generated objects |
| **Source tables** | Existing tables to introspect for ontology design |
| **Ontology name** | Prefix for all generated objects (e.g., `STOCK`) |
| **Path** | *Knowledge Graph* — universal KG_NODE/KG_EDGE tables with graph analytics; duplicates data. *Direct Table* — views over existing tables; no data movement |
| **Business questions** | Natural-language questions that guide semantic model creation |
| **Semantic views** | Which models to create: *Ontology* (abstract reasoning), *Metadata* (governance/discovery), *KG* (concrete graph queries, KG path only) |

All fields are optional — the skill will ask for anything you omit.

---

## The 7-Phase Workflow

Every phase ends with a mandatory gate — the skill stops and asks for your approval before continuing.

### Phase 1 — Gather Inputs
Collects and validates database, schema, tables, business questions, path choice, and ontology name. Presents a structured summary for confirmation.

### Phase 2 — Analyze & Recommend Ontology
Introspects source tables (or parses an OWL file) and proposes classes, relations, and a class hierarchy. You review and adjust before proceeding.

### Phase 3 — Visualize, Modify & Confirm
Launches an interactive Streamlit visualizer with three tabs — Hierarchy (expandable trees), Ontology Graph (interactive node-edge diagram), and Coverage (design structure). A sidebar editor lets you add, remove, or modify classes and relations visually.

### Phase 4 — Generate & Deploy
Generates SQL for all Layer 1-3 artifacts, runs a completeness check, and deploys to Snowflake. After deployment, generates a coverage manifest and re-launches the visualizer with color-coded mapping (green = deployed, gray = abstract).

### Phase 5 — Semantic Views
Delegates to the native `semantic-view` skill to create the selected models. Tests each model against the business questions from Phase 1.

### Phase 6 — Cortex Agent
Delegates to the native `cortex-agent` skill to create the orchestration layer with intent-routed tools — one per semantic view.

### Phase 7 — End-to-End Validation
Validates the full stack: row counts, sample queries, semantic view checks, and an end-to-end agent test.

---

## Starting Points

| Path | When to Use |
|------|-------------|
| **Schema-First Discovery** | You have Snowflake tables but no ontology. The skill analyzes your schema and proposes one. |
| **OWL Import** | You have a formal ontology (OWL, RDF, Turtle, N-Triples, N3). The skill parses it and maps to your tables. |
| **Hybrid** | Start with schema discovery, export, refine externally, re-import. |

---

## Project Structure

```
ontology-stack-builder/
├── SKILL.md                        # Skill definition (the 7-phase workflow)
├── pyproject.toml                  # Python dependencies
├── README.md
└── scripts/
    ├── introspect_schema.py        # Schema-first ontology discovery
    ├── parse_owl.py                # OWL/RDF parser
    ├── generate_ontology_sql.py    # SQL generator for Layers 1-3
    └── visualize_ontology.py       # Streamlit visualizer
```
