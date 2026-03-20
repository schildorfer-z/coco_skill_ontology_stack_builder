<p align="center">
  <img src="assets/ontology-graph.png" alt="Ontology-on-Snowflake — 8 Classes, 8 Relations, Fully Mapped" width="100%"/>
</p>

# ontology-stack-builder

A [Cortex Code](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code) skill that generates the full **Ontology-on-Snowflake** stack from any relational schema through a 7-phase gated workflow.

You bring your Snowflake tables and business questions. The skill builds the rest — metadata, abstract views, semantic models, and a Cortex Agent — in a single conversational session.

For the architectural foundations, see the original blog series:
- [Part 1 — Overview and Data Model](https://medium.com/snowflake/ontology-on-snowflake-part-1-overview-and-data-model-9e8eeaac7363)
- [Part 2 — Semantic Models](https://medium.com/snowflake/ontology-on-snowflake-part-2-semantic-models-9aa0fa9b9312)
- [Part 3 — AI-Powered Intelligence](https://medium.com/snowflake/ontology-on-snowflake-part-3-ai-powered-intelligence-bbace87c6be1)

---

## What It Builds

| Layer | What Gets Created |
|-------|-------------------|
| **L1 — Physical Storage** | Source table views or KG_NODE/KG_EDGE graph tables |
| **L2 — Ontology Metadata** | ~22 metadata tables with auto-populated seed data |
| **L3 — Abstract Views** | Per-class abstract views, hierarchy views, view-generator procedure |
| **L4 — Semantic Views** | Base semantic view (source tables) + ontology-layer semantic views |
| **L5 — Cortex Agent** | Agent with intent-routed tools: base + ontology + optional graph UDFs |

---

## Installation

```bash
# User-level (all projects)
git clone https://github.com/sfc-gh-tjia/coco_skill_ontology_stack_builder.git
cp -r coco_skill_ontology_stack_builder ~/.snowflake/cortex/skills/ontology-stack-builder

# Or project-level (single project)
cp -r coco_skill_ontology_stack_builder .cortex/skills/ontology-stack-builder
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
Collects and validates database, schema, tables, business questions, path choice, and ontology name. Discovers existing semantic views in the target schema and asks whether to reuse one as the base or create from scratch. Presents a structured summary for confirmation.

### Phase 2 — Analyze & Recommend Ontology
Introspects source tables (or parses an OWL file) and proposes classes, relations, and a class hierarchy. If an existing semantic view was found in Phase 1, its curated metadata (column descriptions, relationships, metrics) enriches the proposals. You review and adjust before proceeding.

### Phase 3 — Visualize, Modify & Confirm
Launches an interactive Streamlit visualizer with three tabs — Hierarchy (expandable trees), Ontology Graph (interactive node-edge diagram), and Coverage (design structure). A sidebar editor lets you add, remove, or modify classes and relations visually.

### Phase 4 — Generate & Deploy
Generates SQL for all Layer 1-3 artifacts, runs a completeness check, and deploys to Snowflake. After deployment, generates a coverage manifest and re-launches the visualizer with color-coded mapping (green = deployed, gray = abstract).

### Phase 4.5 — Ensure Base Semantic View
If you have an existing semantic view over your source tables, the skill reuses it. Otherwise, it delegates to the native `semantic-view` skill to create a base semantic view covering your source tables directly. This ensures the final agent always has a tool for concrete data queries.

### Phase 5 — Ontology Semantic Views
Delegates to the native `semantic-view` skill to create ontology-layer models (KG, Ontology, Metadata) over the objects deployed in Phase 4. Tests each model against the business questions from Phase 1.

### Phase 6 — Cortex Agent
Delegates to the native `cortex-agent` skill to create the orchestration layer with intent-routed tools — base semantic (Phase 4.5) + ontology-layer semantics (Phase 5) + optional graph tools.

### Phase 7 — End-to-End Validation
Validates the full stack: row counts, sample queries, semantic view checks, and an end-to-end agent test.

---

## Starting Points

The skill adapts to what you already have:

### By Ontology Source

| Path | When to Use |
|------|-------------|
| **Schema-First Discovery** | You have Snowflake tables but no ontology. The skill analyzes your schema and proposes one. |
| **OWL Import** | You have a formal ontology (OWL, RDF, Turtle, N-Triples, N3). The skill parses it and maps to your tables. |
| **Hybrid** | Start with schema discovery, export, refine externally, re-import. |

### By Existing Semantics

| Scenario | What Happens |
|----------|-------------|
| **Have existing semantic view** | The skill discovers it in Phase 1, reuses it as the base semantic tool, and skips Phase 4.5. Existing metadata (column descriptions, relationships, metrics) enriches the ontology proposals in Phase 2. |
| **Tables only (no semantic)** | The skill creates a base semantic view in Phase 4.5 via the `semantic-view` skill before building ontology-layer semantics. |

Both scenarios also support KG path or direct-table path — the 2x2 combination (KG/Direct x Has Semantic/No Semantic) is fully handled.

---

## Project Structure

```
ontology-stack-builder/
├── SKILL.md                        # Skill definition (the 7-phase workflow)
├── pyproject.toml                  # Python dependencies
├── README.md
├── scripts/
│   ├── introspect_schema.py        # Schema-first ontology discovery
│   ├── parse_owl.py                # OWL/RDF parser
│   ├── generate_ontology_sql.py    # SQL generator for Layers 1-3
│   ├── generate_spcs_scaffolding.py # SPCS graph service scaffolding (optional)
│   └── visualize_ontology.py       # Streamlit visualizer
└── specs/
    └── features/ontology-stack-builder/
        ├── requirements.md         # REQ-001 through REQ-015
        ├── design.md               # Architecture, data flow, script details
        └── tasks.md                # Implementation task tracking
```

Semantic views (L4) and the Cortex Agent (L5) are created by native bundled skills (`semantic-view`, `cortex-agent`), not scripts.
