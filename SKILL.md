---
name: ontology-stack-builder
description: >
  Generates the full Ontology-on-Snowflake stack from any relational schema and business questions.
  Creates ontology metadata, abstract views, semantic models (up to 3), Cortex Agent config,
  and optional graph analytics scaffolding. Supports OWL import or schema-first discovery.
  Use when: build ontology stack, generate ontology from tables, ontology on snowflake,
  create semantic models from schema, ontology layer generation, knowledge graph on snowflake,
  map tables to ontology, generate cortex agent config, ontology stack builder.
allowed-tools: "Read Write Edit Bash(python*) Bash(uv*) Bash(pip*) Bash(mkdir*) Bash(ls*) Bash(cp*) snowflake_sql_execute ask_user_question notebook_actions skill"
metadata:
  author: tjia
  version: 1.0.0
  category: workflow-automation
  tags: [ontology, semantic-model, cortex-analyst, cortex-agent, knowledge-graph, snowflake]
---

# Ontology Stack Builder

Generate the complete Ontology-on-Snowflake stack from any relational schema and set of business questions.

## When to Use

- You have Snowflake tables and want to build an ontology-powered analytics layer
- You want Cortex Agent to intelligently route questions across semantic models
- You need abstract ontology views that unify entity types across tables
- You have an OWL ontology file to map onto existing Snowflake tables
- You want graph analytics (centrality, community detection, shortest path) on your data

## Architecture Overview

The skill generates a 5-layer stack:

```
Layer 5: Cortex Agent (intent routing across semantic models + graph tools)
Layer 4: Semantic Models (KG concrete, Ontology abstract, Metadata governance)
Layer 3: Generated Abstract Views (VW_ONT_* via stored procedure)
Layer 2: Ontology Metadata (~22 ONT_* tables: classes, properties, rules, roles, etc.)
Layer 1: Physical Storage (existing tables, or KG_NODE/KG_EDGE if KG path)
       + Concrete Views (V_{CLASS} entity views, V_{REL} relationship views)
```

## Workflow Overview

This skill follows a 7-phase gated workflow. Each phase requires user confirmation before proceeding.

```
Phase 1: GATHER INPUTS
  ├── Collect schema, business questions, optional OWL
  ├── Ask: KG path or direct-table path?
  └── ⚠️ GATE: Inputs confirmed
      │
Phase 2: ANALYZE & RECOMMEND ONTOLOGY
  ├── Introspect schema OR parse OWL
  ├── Propose classes, relations, mappings
  └── ⚠️ GATE: Ontology design confirmed
      │
Phase 3: VISUALIZE, MODIFY & CONFIRM
  ├── Show ontology graph (Streamlit agraph)
  ├── Show coverage matrix
  ├── Sidebar editor: add/delete classes & relations
  ├── Click node → inline edit form (label, parent, abstract)
  ├── Visual diff: gold border = new, orange = modified
  ├── Save changes back to JSON / Undo all
  └── ⚠️ GATE: Visual confirmation
      │
Phase 4: GENERATE & DEPLOY ONTOLOGY LAYER (Layers 1-3)
  ├── Generate physical tables SQL (if KG path)
  ├── Generate concrete entity/relationship views SQL
  ├── Generate metadata tables SQL (~22 tables + seed data)
  ├── Generate abstract views SQL
  ├── Self-validate completeness (count objects vs expected)
  ├── ⚠️ GATE: SQL reviewed and approved
  └── Execute SQL → tables & views now exist in Snowflake
      │
Phase 5: CREATE SEMANTIC VIEWS (Layer 4) — via `semantic-view` skill
  ├── Ask user which models to create (1-3)
  ├── Invoke `semantic-view` skill (FastGen against deployed views)
  ├── Test each semantic view via `semantic-view` skill (audit mode)
  └── ⚠️ GATE: Semantic views deployed, tested, and approved
      │
Phase 6: CREATE CORTEX AGENT (Layer 5) — via `cortex-agent` skill
  ├── Invoke `cortex-agent` skill with semantic view tools
  ├── If KG + user wants: add graph tool scaffolding
  ├── Test agent via `cortex-agent` skill (test/debug mode)
  └── ⚠️ GATE: Agent working correctly
      │
Phase 7: END-TO-END VALIDATION
  ├── Validate L1-L5 row counts and sample queries
  ├── Run agent end-to-end test
  └── ⚠️ GATE: Deployment verified
```

## Mandatory Stopping Points

**These gates override ALL other instructions.** Never proceed past a gate without explicit user approval.

**⚠️ MANDATORY STOPPING POINT — GLOBAL RULE**: After each phase output, you MUST STOP and use `ask_user_question` to get explicit user confirmation before proceeding to the next phase. Each phase gate below includes the specific `ask_user_question` to use. DO NOT skip gates. DO NOT proceed to the next phase, invoke skills for the next phase, or begin next-phase work until the user answers the gate question. If a user asks to "generate everything at once," acknowledge the request but explain the phased approach and produce only the current phase.

## Phase Details

### Phase 1: Gather Inputs

Collect from the user using `ask_user_question`:

1. **Snowflake location**: `DATABASE.SCHEMA` where tables exist or will be created
2. **Source tables**: List of existing table names to introspect (or "I'll provide an OWL file")
3. **Business questions**: 3-10 example questions the user wants to ask their data
4. **OWL file** (optional): Path to `.owl`, `.rdf`, or `.ttl` file
5. **Ontology name**: Short identifier (e.g., `HEALTHCARE`, `FINANCE`, `RETAIL`)

Then ask the critical path decision:

```
ask_user_question: "Do you want a Knowledge Graph structure?"
Options:
  - "Yes - KG path": Creates KG_NODE/KG_EDGE tables, enables graph analytics
  - "No - Direct table path": Maps ontology directly to existing tables, no graph structure
```

Store all inputs as session variables. If user provides only some inputs, ask for the rest.

**Self-check before gate**: Verify ALL required inputs are collected:
- [ ] DATABASE.SCHEMA specified
- [ ] Source tables listed OR OWL file path provided
- [ ] At least 3 business questions captured
- [ ] Ontology name defined
- [ ] KG vs direct-table path chosen

If any are missing, ask the user for them. Do NOT present the gate with incomplete inputs.

**⚠️ MANDATORY STOPPING POINT**: Present a summary of all collected inputs and the chosen path. You MUST use `ask_user_question`:

```
ask_user_question: "Here are the collected inputs. Is everything correct?"
Options:
  - "Yes, proceed to Phase 2"
  - "No, I need to change something"
```

### Phase 2: Analyze & Recommend Ontology

**If OWL file provided:**

Run the OWL parser:
```bash
uv run --project <SKILL_DIR> python <SKILL_DIR>/scripts/parse_owl.py \
  --owl-file "<owl_path>" \
  --output-dir "/tmp/ontology_parsed"
```

Then map parsed classes to existing tables using `DESCRIBE TABLE` on each source table.

**If no OWL file (schema-first discovery):**

Run schema introspection:
```bash
uv run --project <SKILL_DIR> python <SKILL_DIR>/scripts/introspect_schema.py \
  --database "<DATABASE>" \
  --schema "<SCHEMA>" \
  --tables "<TABLE1>,<TABLE2>,..." \
  --questions "<Q1>|<Q2>|..." \
  --output-dir "/tmp/ontology_parsed"
```

This script:
1. Calls `DESCRIBE TABLE` and `SHOW PRIMARY KEYS` for each table via Snowflake SQL
2. Analyzes foreign key relationships and column patterns
3. Proposes ontology classes (one per table or entity type)
4. Proposes relations from FK relationships and naming conventions
5. Outputs `classes.json`, `relations.json`, `mappings.json`

**`classes.json` schema** — each entry MUST use these exact keys:
```json
[
  {
    "name": "ClassName",
    "label": "Display Name",
    "description": "What this class represents",
    "parent_name": null,
    "is_abstract": false,
    "is_deprecated": false,
    "namespace": "DB.SCHEMA",
    "uri": "urn:db:schema:ClassName",
    "_source_table": "TABLE_NAME",
    "_id_column": "ID_COL",
    "_name_column": "NAME_COL"
  }
]
```

**`relations.json` schema** — each entry MUST use these exact keys:
```json
[
  {
    "name": "relation_name",
    "label": "Relation Name",
    "description": "What this relation represents",
    "domain_class": "SourceClass",
    "domain_classes": ["SourceClass"],
    "range_class": "TargetClass",
    "range_classes": ["TargetClass"],
    "is_transitive": false,
    "is_symmetric": false,
    "is_functional": true,
    "is_abstract": false,
    "is_hierarchical": false,
    "parent_name": null,
    "inverse_name": null,
    "cardinality": "N:1",
    "uri": "urn:rel:relation_name",
    "_source_table": "TABLE_NAME",
    "_src_column": "SRC_COL",
    "_dst_column": "DST_COL"
  }
]
```

**IMPORTANT**: When editing `classes.json` or `relations.json` directly (e.g., adding a class via prompt), use the exact field names above. In particular: `is_abstract` (not `abstract`), `parent_name` (not `parent`), `is_deprecated` (not `deprecated`), `is_hierarchical` (not `hierarchical`). For abstract relations, set `is_abstract: true` and leave `_source_table`/`_src_column`/`_dst_column` as `null`. Concrete child relations reference their abstract parent via `parent_name`.

Present the proposed ontology to the user as a table:

| Class Name | Source Table | Type | ID Column | Name Column | Parent Class |
|------------|-------------|------|-----------|-------------|--------------|

And proposed relations:

| Relation | Domain Class | Range Class | Source | Cardinality |
|----------|-------------|-------------|--------|-------------|

**Self-check before gate**: Verify the ontology design is complete:
- [ ] Every source table maps to at least one class
- [ ] Every class has a `_source_table`, `_id_column`, and `_name_column` (unless abstract)
- [ ] Every foreign key relationship has a corresponding relation entry
- [ ] No duplicate class names or relation names
- [ ] `classes.json` and `relations.json` use exact field names from the schema above
- [ ] At least one concrete class exists

If any check fails, fix the issue before presenting to the user. Do NOT ask the user to approve an incomplete ontology.

**⚠️ MANDATORY STOPPING POINT**: You MUST use `ask_user_question`:

```
ask_user_question: "Please review the proposed ontology above. Want to proceed, or make changes?"
Options:
  - "Looks good, proceed to Phase 3"
  - "I want to add/remove/change classes or relations"
```

### Phase 3: Visualize, Modify & Confirm

Launch the visualization & editing app:
```bash
uv run --project <SKILL_DIR> python <SKILL_DIR>/scripts/visualize_ontology.py -- \
  --classes-json "/tmp/ontology_parsed/classes.json" \
  --relations-json "/tmp/ontology_parsed/relations.json" \
  --port 8501
```

This shows:
- **Hierarchy** tab with two expandable sections: **Class Hierarchy** (interactive/text toggle, search, depth slider) and **Relation Hierarchy** (interactive/text toggle, abstract/concrete grouping)
- Ontology graph with coverage coloring and **Layer toggle** (All / Concrete / Abstract)
- Coverage tab showing the ontology design structure (implementation mapping becomes available after Phase 4 deployment)

The **Layer toggle** on the Ontology Graph tab controls visibility:
- **All**: shows both abstract and concrete classes/relations (abstract items rendered distinctly)
- **Concrete**: hides abstract classes and abstract relations
- **Abstract**: shows only abstract classes and abstract relations (the schema blueprint)

The sidebar **Ontology Editor** allows the user to modify the ontology before generation:
- **Add Class**: name, label, description, parent (dropdown), abstract toggle
- **Add Relation**: name, source/target class dropdowns, cardinality, description
- **Delete Class**: re-parents children to root, removes involved relations
- **Delete Relation**: removes the selected relation
- **Save Changes**: writes modified `classes.json` and `relations.json` back to disk
- **Undo All**: resets to the original loaded state

When a node is clicked in the Ontology Graph tab, an **Edit Class** form appears below the
detail panel with label, description, parent, and abstract fields.

**Visual diff markers** show what changed this session:
- Gold border (thick) = newly added class or relation
- Orange border (thick) = modified class
- Tooltips show NEW / MODIFIED tags

**Edge styling** distinguishes relation types:
- Solid blue = subClassOf (class hierarchy)
- Dashed purple = concrete relation
- Solid deep purple (thick) = abstract relation
- Dotted light purple = specializes (child relation → parent relation)

If Streamlit is not available or user prefers text, render an ASCII tree instead:
```
Entity
├── Person
│   ├── Employee
│   └── Customer
├── Organization
│   ├── Department
│   └── Supplier
└── Event
    ├── Order
    └── Meeting
```

**Self-check before gate**: If user made edits in the visualizer, verify:
- [ ] Modified `classes.json` and `relations.json` were saved (check file timestamps or diff)
- [ ] Any added classes still follow the schema (all required fields present)
- [ ] Any added relations reference valid domain/range classes that exist in `classes.json`
- [ ] No orphaned relations pointing to deleted classes

If the visualizer was used, re-read the JSON files to pick up user edits.

**⚠️ MANDATORY STOPPING POINT**: You MUST use `ask_user_question`:

```
ask_user_question: "The visualizer is running. Please review the ontology structure. Ready to proceed to SQL generation (Phase 4)?"
Options:
  - "Yes, proceed to Phase 4"
  - "No, I need to make changes first"
```

### Phase 4: Generate & Deploy Ontology Layer (Layers 1-3)

**If KG path:**
Generate `01_physical_layer.sql`:
- `CREATE TABLE KG_NODE` with NODE_ID, NODE_TYPE, NAME, PROPS (VARIANT), TS_INGESTED
- `CREATE TABLE KG_EDGE` with EDGE_ID, SRC_ID, DST_ID, EDGE_TYPE, WEIGHT, PROPS, EFFECTIVE_START/END
- Both clustered by type columns
- INSERT statements to load data from source tables into KG_NODE/KG_EDGE

Generate `02_concrete_views.sql`:
- Per-class entity views: `V_{CLASS}` — typed projections from KG_NODE using `PROPS:field::TYPE`
- Per-relation relationship views: `V_{REL}` — typed projections from KG_EDGE with SRC_ID, DST_ID, WEIGHT, EFFECTIVE_START/END
- Direct-table path: thin SELECT wrappers over source tables

**For both paths:**
Generate `03_metadata_tables.sql` (~22 tables):
- Core: ONT_ONTOLOGY, ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP, ONT_REL_MAP
- Source mappings: ONT_OBJECT_SOURCE, ONT_LINK_SOURCE
- Properties: ONT_SHARED_PROPERTY, ONT_PROPERTY, ONT_DERIVED_PROPERTY
- Interfaces: ONT_INTERFACE, ONT_INTERFACE_PROPERTY, ONT_INTERFACE_IMPL
- Inference: ONT_RULE, REL_EDGE_INFERRED
- Data quality: ONT_CONSTRAINT_VIOLATION
- Actions: ACT_TYPE, ACT_DEF
- Functions: ONT_FUNCTION, ONT_FUNCTION_BINDING
- Views: OBJ_VIEW_DEF, OBJ_VIEW_FIELD
- RBAC: ONT_ROLE, ONT_ROLE_BINDING, ONT_PERMISSION
- Auto-populated INSERT statements derived from class/relation metadata

Generate `04_abstract_views.sql`:
- Per-class views: `VW_ONT_{CLASS_NAME}` — UNION ALL of all source tables for that class
- Hierarchy views: `VW_ONT_SUBCLASS_OF`, `VW_DESCENDANTS`, `VW_ANCESTORS`
- Unified entity view: `VW_ONT_ALL_ENTITIES`
- Stats view: `VW_ONT_HIERARCHY_STATS`
- Resolved relationships view: `REL_RESOLVED` (joins edges with node names)

Generate `05_view_generator_sp.sql`:
- `SP_GENERATE_ONTOLOGY_VIEWS()` stored procedure that reads ONT_CLASS_MAP and regenerates views dynamically

**Optional — KG path only:**
Ask the user:
```
ask_user_question: "Generate inference engine stored procedures?"
Options:
  - "Yes": Generates SP_INFER_TRANSITIVE, SP_INFER_INVERSE, SP_RUN_ONTOLOGY_INFERENCE, 
    SP_CHECK_CARDINALITY_SINGLE, SP_CHECK_REFERENTIAL — enables rule-based inference and data quality checks
  - "No": Skip inference engine (can be added later)
```

If yes, generate `06_inference_engine.sql`:
- `SP_INFER_TRANSITIVE(TARGET_REL, RULE_ID)` — recursive transitive closure (depth ≤ 5)
- `SP_INFER_INVERSE(RULE_ID)` — materialise inverse relationships from ONT_RELATION_DEF
- `SP_RUN_ONTOLOGY_INFERENCE()` — master runner for all enabled ONT_RULE entries
- `SP_CHECK_CARDINALITY_SINGLE(REL, CHECK_NAME)` — validate 1:1/N:1 constraints
- `SP_CHECK_REFERENTIAL(REL, CHECK_NAME)` — validate edge endpoint integrity
- Results written to `REL_EDGE_INFERRED` and `ONT_CONSTRAINT_VIOLATION`

**KG path only**: Ask the user about SQL graph traversal tools:
```
ask_user_question: "Generate SQL graph traversal tools for the agent?"
Options:
  - "Yes": Generates 4 SQL UDF tools (EXPAND_DESCENDANTS_TOOL, GET_ANCESTORS_TOOL,
    GET_HIERARCHY_PATH_TOOL, GET_DIRECT_CHILDREN_TOOL) — zero infrastructure, pure SQL
    against KG_NODE/KG_EDGE. These are registered as generic tools in the Cortex Agent.
  - "No": Skip graph traversal tools (agent uses only semantic view tools)
```

If yes, generate `07_graph_traversal_tools.sql`:
- `EXPAND_DESCENDANTS_TOOL(ROOT_CONCEPT)` — recursive downward traversal, returns all descendants with depth and path
- `GET_ANCESTORS_TOOL(CONCEPT)` — recursive upward traversal, returns all ancestors with shortest depth
- `GET_HIERARCHY_PATH_TOOL(START_CONCEPT, END_CONCEPT)` — finds path between two concepts via subClassOf edges
- `GET_DIRECT_CHILDREN_TOOL(PARENT_CONCEPT)` — single-hop children lookup

These are complementary to SPCS graph tools (Phase 6b). SQL UDF tools handle hierarchy traversal with zero infrastructure. SPCS tools handle advanced graph algorithms (centrality, community detection) but require a container service.

Use the generator script:
```bash
uv run --project <SKILL_DIR> python <SKILL_DIR>/scripts/generate_ontology_sql.py \
  --classes-json "/tmp/ontology_parsed/classes.json" \
  --relations-json "/tmp/ontology_parsed/relations.json" \
  --mappings-json "/tmp/ontology_parsed/mappings.json" \
  --database "<DATABASE>" \
  --schema "<SCHEMA>" \
  --ontology-name "<NAME>" \
  --kg-path <true|false> \
  --include-inference <true|false> \
  --include-graph-tools <true|false> \
  --output-dir "/tmp/generated"
```

Present all generated SQL files to the user for review.

**Step 4a-verify: Completeness check (MANDATORY before asking for approval)**

Before presenting the gate, self-validate that ALL expected objects are present in the generated SQL:

| File | Expected objects |
|------|-----------------|
| `01_physical_layer.sql` (KG only) | `KG_NODE`, `KG_EDGE` tables + INSERT statements |
| `02_concrete_views.sql` | One `V_{CLASS}` view per concrete class, one `V_{REL}` view per relation |
| `03_metadata_tables.sql` | All ~22 `ONT_*` tables + INSERT seed data |
| `04_abstract_views.sql` | One `VW_ONT_{CLASS}` per class, plus `VW_ONT_SUBCLASS_OF`, `VW_DESCENDANTS`, `VW_ANCESTORS`, `VW_ONT_ALL_ENTITIES`, `VW_ONT_HIERARCHY_STATS`, `REL_RESOLVED` |
| `05_view_generator_sp.sql` | `SP_GENERATE_ONTOLOGY_VIEWS` stored procedure |
| `06_inference_engine.sql` (if selected) | `SP_INFER_TRANSITIVE`, `SP_INFER_INVERSE`, `SP_RUN_ONTOLOGY_INFERENCE`, `SP_CHECK_CARDINALITY_SINGLE`, `SP_CHECK_REFERENTIAL` |
| `07_graph_traversal_tools.sql` (if selected) | `EXPAND_DESCENDANTS_TOOL`, `GET_ANCESTORS_TOOL`, `GET_HIERARCHY_PATH_TOOL`, `GET_DIRECT_CHILDREN_TOOL` |

Cross-check: count the CREATE VIEW/TABLE/PROCEDURE statements in each file against the expected counts derived from `classes.json` and `relations.json`. If anything is missing, fix the generation before presenting to the user. Do NOT ask the user to approve incomplete SQL.

**⚠️ MANDATORY STOPPING POINT — DO NOT EXECUTE SQL**: Present the completeness summary and all generated SQL files. You MUST use `ask_user_question` to get explicit approval before executing any SQL:

```
ask_user_question: "Phase 4 SQL generation complete. I've generated the SQL files listed above. Ready to deploy to Snowflake?"
Options:
  - "Yes, deploy all SQL"
  - "No, I need to review/change something first"
```

DO NOT execute any SQL statements, DO NOT proceed to Step 4b, until the user explicitly approves via the question above.

**Step 4b: Deploy SQL artifacts (Layers 1-3)**

After approval, execute all SQL scripts in order so that tables and views exist for Phases 5-6:

1. **Physical layer** (if KG path): Execute `01_physical_layer.sql`
2. **Concrete views**: Execute `02_concrete_views.sql` (V_{CLASS} entity views, V_{REL} relationship views)
3. **Metadata tables**: Execute `03_metadata_tables.sql` (~22 tables + auto-populated seed data)
4. **Abstract views**: Execute `04_abstract_views.sql`
5. **View generator SP**: Execute `05_view_generator_sp.sql`
6. **Inference engine** (if selected): Execute `06_inference_engine.sql`
7. **SPCS graph service** (if selected): Execute `spcs_setup.sql`
8. **Graph traversal tools** (if selected): Execute `07_graph_traversal_tools.sql`

Quick-validate that key objects exist:
```sql
SHOW VIEWS LIKE 'VW_ONT_%' IN SCHEMA {DATABASE}.{SCHEMA};
SHOW TABLES LIKE 'ONT_%' IN SCHEMA {DATABASE}.{SCHEMA};
-- If graph traversal tools selected:
SHOW USER FUNCTIONS LIKE '%_TOOL' IN SCHEMA {DATABASE}.{SCHEMA};
```

Present a deployment summary to the user:
- Number of tables created (KG tables + ONT_* metadata tables)
- Number of views created (V_* concrete views + VW_ONT_* abstract views)
- Number of stored procedures created
- Number of UDFs created (if graph traversal tools selected)
- Any warnings or errors encountered during execution

**⚠️ MANDATORY STOPPING POINT — DO NOT PROCEED TO PHASE 5**

Before you can present the gate question, you MUST complete ALL of the following steps in order. Do NOT skip any step. Do NOT present the gate question until all 3 steps are done.

**Required Step A: Generate deployed-objects manifest**

Build a `deployed_objects.json` manifest from the SHOW commands output. The manifest maps each ontology concept to its generated Snowflake artifact(s), enabling the visualizer to show the "Original Design → Snowflake Implementation" mapping.

Write the manifest to `/tmp/ontology_parsed/deployed_objects.json`:
```json
{
  "source": "<original input — e.g. 'healthcare_ontology.owl' or 'User-described ontology'>",
  "database": "{DATABASE}",
  "schema": "{SCHEMA}",
  "views": ["V_DOCTOR", "V_PATIENT", "VW_ONT_PERSON", "VW_ONT_ALL_ENTITIES", ...],
  "tables": ["KG_NODE", "KG_EDGE", "ONT_CLASS_DEF", "ONT_RELATION_DEF", ...],
  "procedures": ["SP_GENERATE_ONTOLOGY_VIEWS", ...],
  "udfs": ["EXPAND_DESCENDANTS_TOOL", ...],
  "class_to_objects": {
    "Doctor": {"views": ["V_DOCTOR", "VW_ONT_DOCTOR"], "metadata_row": "ONT_CLASS_DEF"},
    "Patient": {"views": ["V_PATIENT", "VW_ONT_PATIENT"], "metadata_row": "ONT_CLASS_DEF"},
    "Person": {"views": ["VW_ONT_PERSON"], "metadata_row": "ONT_CLASS_DEF"}
  },
  "relation_to_objects": {
    "treats": {"view": "V_TREATS", "metadata_row": "ONT_RELATION_DEF"},
    "subClassOf": {"view": "VW_ONT_SUBCLASS_OF", "metadata_row": "ONT_RELATION_DEF"}
  }
}
```

Build the `class_to_objects` mapping by iterating `classes.json`:
- For each concrete class: look for `V_{CLASS_NAME}` in the views list → add to views array
- For each class (abstract or concrete): look for `VW_ONT_{CLASS_NAME}` in the views list → add to views array
- Every class gets `"metadata_row": "ONT_CLASS_DEF"` since all classes are seeded into that table

Build the `relation_to_objects` mapping by iterating `relations.json`:
- For each relation: look for `V_{RELATION_NAME}` in the views list → set as view
- Every relation gets `"metadata_row": "ONT_RELATION_DEF"`

**Required Step B: Re-launch the visualizer with coverage mapping**

Stop the Phase 3 visualizer if still running, then re-launch with the `--deployed-objects` flag:
```bash
uv run --project <SKILL_DIR> python <SKILL_DIR>/scripts/visualize_ontology.py -- \
  --classes-json "/tmp/ontology_parsed/classes.json" \
  --relations-json "/tmp/ontology_parsed/relations.json" \
  --deployed-objects "/tmp/ontology_parsed/deployed_objects.json" \
  --port 8501
```

Without re-launching, the graph will show all nodes as unmapped (red). After re-launch with `--deployed-objects`, nodes will be colored by implementation status:
- **Coverage tab**: "Original Design → Snowflake Implementation" with progress bar, 3-column breakdown (Mapped / Covered by Ancestor / Unmapped), and full artifact inventory
- **Graph tab**: Nodes colored green (mapped), blue (covered by ancestor), red (unmapped), gray (abstract)
- **Node detail**: Click any node to see its deployed Snowflake objects

**Required Step C: Verify the visualizer shows coverage (NOT all red/unmapped)**

Open the visualizer and confirm that concrete classes show as green (mapped) or blue (covered), NOT red (unmapped). If everything is still red, the manifest was not loaded — check the `--deployed-objects` path and re-launch.

**Only after Steps A, B, C are done**, present the gate question using `ask_user_question`:

```
ask_user_question: "Phase 4 deployment complete. All Layer 1-3 objects are deployed. The visualizer is showing the coverage mapping. Ready to proceed to Phase 5 (Semantic Views)?"
Options:
  - "Yes, proceed to Phase 5"
  - "No, I need to fix something first"
```

DO NOT invoke the `semantic-view` skill, DO NOT start Phase 5, and DO NOT continue until the user explicitly confirms via the question above.

### Phase 5: Create Semantic Views (Layer 4) — via `semantic-view` skill

Ask the user which semantic views to create:

```
ask_user_question: "Which semantic views should I create?"
multiSelect: true
Options:
  - "KG Semantic View": Concrete entity views (V_{CLASS}) and relationship views (V_{REL}) for fast direct queries
    [Only available if KG path chosen]
  - "Ontology Semantic View": Abstract views (VW_ONT_*) for cross-type reasoning
  - "Metadata & Governance Semantic View": All ~22 ONT_* introspection tables for governance and data quality
```

**For each selected semantic view**, invoke the native **`semantic-view` skill** (creation mode) to generate, validate, and deploy the semantic view. The skill uses Snowflake's FastGen system function which auto-discovers columns, infers primary keys, generates dimensions/measures/metrics/relationships, and creates verified queries.

**Step 5a: Determine base tables for each model**

Gather the base tables from the ontology objects deployed in Phase 4:

- **KG Semantic View**: List all `V_{CLASS}` entity views and `V_{REL}` relationship views:
  ```sql
  SHOW VIEWS LIKE 'V_%' IN SCHEMA {DATABASE}.{SCHEMA};
  ```
- **Ontology Semantic View**: List all `VW_ONT_%` abstract views:
  ```sql
  SHOW VIEWS LIKE 'VW_ONT_%' IN SCHEMA {DATABASE}.{SCHEMA};
  ```
- **Metadata Semantic View**: List all `ONT_%` metadata tables:
  ```sql
  SHOW TABLES LIKE 'ONT_%' IN SCHEMA {DATABASE}.{SCHEMA};
  ```

**Step 5b: Invoke the `semantic-view` skill for each selected model**

For each selected model, invoke the skill with this context:

```
skill: semantic-view

Context to provide when the skill asks:
  - Semantic view name: {ONTOLOGY_NAME}_KG_MODEL (or _ONTOLOGY_MODEL or _METADATA_MODEL)
  - Target database: {DATABASE}
  - Target schema: {SCHEMA}
  - Table references: The base tables gathered in Step 5a
  - SQL queries: Convert the business questions from Phase 1 into SELECT statements
    against the base tables (these become VQRs in the semantic model)
  - Business context: Describe the model's purpose and intent-routing role
```

The `semantic-view` skill will:
1. Call FastGen to auto-generate the semantic model YAML from the actual Snowflake metadata
2. Validate the YAML via `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(..., TRUE)`
3. Present the generated model for review
4. Offer options: audit, deploy, or refine

**Step 5c: Deploy each semantic view**

Use the `semantic-view` skill's upload workflow to deploy each approved semantic view to Snowflake:
```sql
-- The skill handles this via upload_semantic_view_yaml.py, which runs:
-- CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML('{DATABASE}.{SCHEMA}', $${yaml}$$, FALSE);
```

Verify deployment:
```sql
SHOW SEMANTIC VIEWS IN SCHEMA {DATABASE}.{SCHEMA};
```

**Step 5d: Test each semantic view**

For each deployed semantic view, invoke the `semantic-view` skill in **audit/test** mode to validate it returns correct results:

```
skill: semantic-view

Context: Audit the semantic view {DATABASE}.{SCHEMA}.{SEMANTIC_VIEW_NAME}
  - Run 2-3 of the business questions from Phase 1 against each semantic view
  - Verify the generated SQL executes without errors
  - Verify the results contain expected data (non-empty, reasonable values)
  - If any query fails, use the skill's refine workflow to fix the semantic model
```

The `semantic-view` skill will test queries via Cortex Analyst, show generated SQL and results, and flag any issues.

**Self-check before gate**: Verify all semantic views are complete:
- [ ] `SHOW SEMANTIC VIEWS IN SCHEMA {DATABASE}.{SCHEMA}` returns one row per selected model
- [ ] Each semantic view name matches expected naming ({ONTOLOGY_NAME}_KG_MODEL, _ONTOLOGY_MODEL, _METADATA_MODEL)
- [ ] Step 5d tests passed — at least 2 business questions per view returned non-empty results
- [ ] No unresolved validation errors from the `semantic-view` skill

If any semantic view is missing or tests failed, fix before presenting the gate.

**⚠️ MANDATORY STOPPING POINT — DO NOT PROCEED TO PHASE 6**: You MUST use `ask_user_question`:

```
ask_user_question: "All semantic views are deployed. Please review and test them. Ready to proceed to Phase 6 (Agent creation)?"
Options:
  - "Yes, proceed to Phase 6"
  - "No, I need to fix a semantic view"
```

### Phase 6: Create Cortex Agent (Layer 5) — via `cortex-agent` skill

**Step 6a: Gather semantic view references**

List all semantic views deployed in Phase 5:
```sql
SHOW SEMANTIC VIEWS IN SCHEMA {DATABASE}.{SCHEMA};
```

Build the tool list: one `cortex_analyst_text_to_sql` tool per deployed semantic view. Each tool needs:
- **Name**: Derived from the semantic view name (e.g., `kg_query_tool`, `ontology_query_tool`, `metadata_query_tool`)
- **Description**: Intent-routing description explaining what questions the tool answers
- **Semantic view FQN**: `{DATABASE}.{SCHEMA}.{SEMANTIC_VIEW_NAME}`

**Step 6b: Check for graph analytics tools (KG path only)**

If KG path, check what graph tools were deployed in Phase 4:

- **SQL UDF graph traversal tools**: If `07_graph_traversal_tools.sql` was generated and deployed, the 4 UDFs (`EXPAND_DESCENDANTS_TOOL`, `GET_ANCESTORS_TOOL`, `GET_HIERARCHY_PATH_TOOL`, `GET_DIRECT_CHILDREN_TOOL`) are already available and should be registered as `generic` tools in the agent.
- **SPCS graph analytics tools**: If user also wants advanced graph algorithms (centrality, community detection), offer SPCS:

```
ask_user_question: "Include SPCS graph analytics tools in the agent? (SQL hierarchy tools are already deployed)"
Options:
  - "Yes": Adds centrality, community detection, shortest path tools (requires SPCS container service)
  - "No": Agent uses semantic view tools + SQL graph traversal tools only
```

If SPCS selected, generate SPCS scaffolding only (no agent spec):
```bash
uv run --project <SKILL_DIR> python <SKILL_DIR>/scripts/generate_spcs_scaffolding.py \
  --database "<DATABASE>" \
  --schema "<SCHEMA>" \
  --output-dir "/tmp/generated"
```
This produces:
- `spcs_graph_service.py` — NetworkX-based graph analytics service
- `spcs_setup.sql` — SPCS service creation, compute pool, service functions

Guide the user through deploying the SPCS service before proceeding:
```sql
-- Execute spcs_setup.sql to create the compute pool, image repository,
-- service, and service functions in {DATABASE}.{SCHEMA}
```

**Step 6c: Invoke the `cortex-agent` skill to create the agent**

Invoke the native `cortex-agent` skill in **create** mode:

```
skill: cortex-agent

Context to provide when the skill asks:
  - Agent name: {ONTOLOGY_NAME}_AGENT
  - Target database: {DATABASE}
  - Target schema: {SCHEMA}

  - Tools:

    1. Semantic view tools (cortex_analyst_text_to_sql):
       List each semantic view deployed in Phase 5:
       Tool: name={name}, type=cortex_analyst_text_to_sql, semantic_view="{FQN}"
         description: Include "When to Use" and "When NOT to Use" sections.
         Example for a KG semantic view:
           "Query concrete entity data and relationships. When to Use: specific entity
            lookups, filtering by attributes, aggregations over typed views. When NOT
            to Use: hierarchy traversal questions (use graph tools instead)."

    2. SQL UDF graph tools (generic) — only if deployed in Phase 4:
       Each tool needs type=generic with tool_resources type=function, a detailed
       description with routing hints, and an input_schema matching the UDF parameters.

       Tool: name=expand_descendants_tool, type=generic
         function: {DATABASE}.{SCHEMA}.EXPAND_DESCENDANTS_TOOL
         input_schema: { "ROOT_CONCEPT": { "type": "string", "description": "The concept name to expand (e.g., 'Vehicle', 'Manager')" } }
         required: ["ROOT_CONCEPT"]
         description: "Get ALL descendants of a root concept in the ontology hierarchy.
           Returns NODE_ID, NODE_NAME, DEPTH, PATH for the root and every descendant.
           When to Use: questions with 'all types of', 'subtypes', 'derived from',
           'everything under X', cohort expansion.
           When NOT to Use: single entity lookups (use semantic view), ancestor
           questions (use get_ancestors_tool)."

       Tool: name=get_ancestors_tool, type=generic
         function: {DATABASE}.{SCHEMA}.GET_ANCESTORS_TOOL
         input_schema: { "CONCEPT": { "type": "string", "description": "The concept name to find ancestors for" } }
         required: ["CONCEPT"]
         description: "Get all ancestors (parents, grandparents, etc.) of a concept.
           Returns ANCESTOR_ID, ANCESTOR_NAME, DEPTH (shortest path to each ancestor).
           When to Use: 'what is X?', 'what category does X belong to?', 'where does
           X sit in the hierarchy?', classification questions.
           When NOT to Use: descendant listing (use expand_descendants_tool), path
           between two specific concepts (use get_hierarchy_path_tool)."

       Tool: name=get_hierarchy_path_tool, type=generic
         function: {DATABASE}.{SCHEMA}.GET_HIERARCHY_PATH_TOOL
         input_schema: {
           "START_CONCEPT": { "type": "string", "description": "The more specific (child) concept" },
           "END_CONCEPT": { "type": "string", "description": "The more general (ancestor) concept" }
         }
         required: ["START_CONCEPT", "END_CONCEPT"]
         description: "Find the path between two concepts in the ontology hierarchy.
           Traverses upward from START to END via subClassOf edges.
           Returns STEP, NODE_ID, NODE_NAME, RELATIONSHIP for each hop.
           When to Use: 'how is X related to Y?', 'path from X to Y', lineage
           questions, understanding the chain between two concepts.
           When NOT to Use: listing all ancestors (use get_ancestors_tool), listing
           all descendants (use expand_descendants_tool)."

       Tool: name=get_direct_children_tool, type=generic
         function: {DATABASE}.{SCHEMA}.GET_DIRECT_CHILDREN_TOOL
         input_schema: { "PARENT_CONCEPT": { "type": "string", "description": "The parent concept name" } }
         required: ["PARENT_CONCEPT"]
         description: "Get immediate children (depth=1 only) of a concept.
           Returns CHILD_ID, CHILD_NAME, CHILD_TYPE.
           When to Use: incremental hierarchy exploration, 'what are the direct
           subtypes of X?', browsing one level at a time.
           When NOT to Use: need ALL descendants recursively (use expand_descendants_tool)."

  - Orchestration instructions (provide this as the agent's orchestration prompt):

    "You are an ontology-driven analytics agent for the {ONTOLOGY_NAME} domain.

    ## Tool Selection Strategy

    Step 1: Classify the question type:
    - DATA QUERY: specific entity lookups, filtering, aggregation → semantic view tools
    - HIERARCHY TRAVERSAL: descendants, ancestors, paths, subtypes → graph traversal tools
    - METADATA/GOVERNANCE: coverage, mapping status, data quality → metadata semantic view

    Step 2: Route to the correct tool:

    **Use semantic view tools when:**
    - Question asks about specific entities by name or attribute
    - Need aggregations, counts, or statistics over entity data
    - Filtering by properties (dates, amounts, types, etc.)
    - Questions do NOT involve hierarchy traversal keywords

    **Use expand_descendants_tool when:**
    - 'All types of X', 'everything under X', 'subtypes of X'
    - Cohort expansion — need to find all members of a category
    - Keywords: 'derived', 'all types', 'subtypes', 'descendants', 'under'

    **Use get_ancestors_tool when:**
    - 'What is X?', 'What category does X belong to?'
    - Understanding classification or lineage of a specific concept
    - Keywords: 'ancestors', 'parent', 'category', 'belongs to', 'classified as'

    **Use get_hierarchy_path_tool when:**
    - 'How is X related to Y?', 'Path from X to Y'
    - Understanding the chain of relationships between two concepts
    - Keywords: 'path', 'related to', 'connection between', 'lineage from...to'

    **Use get_direct_children_tool when:**
    - 'Direct subtypes of X', 'immediate children of X'
    - Browsing the hierarchy one level at a time
    - Keywords: 'direct', 'immediate', 'one level'

    ## Combining Tools
    For complex questions, you may call multiple tools:
    - First expand a hierarchy, then query data about the expanded set
    - First find ancestors to understand classification, then query related entities
    "

  - Response instructions: Return structured answers with source attribution.
    When showing hierarchy results, include depth and path information.
    When combining tools, explain the reasoning chain.
```

The `cortex-agent` skill will:
1. Verify admin setup (warehouse, role, permissions)
2. Gather requirements and confirm tool selection
3. Build the agent spec with all tools (semantic views + graph UDFs) and `tool_resources`
4. Execute `CREATE OR REPLACE AGENT` via `$spec$` DDL
5. Run verification queries to confirm the agent is functional

**IMPORTANT**: For the graph traversal UDF tools, ensure the `tool_resources` uses `"type": "function"` (not `"procedure"`), since these are SQL UDFs not stored procedures:
```json
"tool_resources": {
  "expand_descendants_tool": {
    "type": "function",
    "identifier": "{DATABASE}.{SCHEMA}.EXPAND_DESCENDANTS_TOOL",
    "execution_environment": { "type": "warehouse", "query_timeout": 180 }
  }
}
```

**Step 6d: Add SPCS graph tools to the agent (if selected in 6b)**

If SPCS graph tools were selected in Step 6b, invoke the `cortex-agent` skill again in **edit** mode to add the SPCS service functions as stored-procedure tools:

```
skill: cortex-agent

Context: Edit agent {DATABASE}.{SCHEMA}.{ONTOLOGY_NAME}_AGENT
  - Add tools: Each SPCS service function as a stored-procedure tool
    (e.g., graph_centrality, graph_community_detection, graph_shortest_path)
  - Update orchestration instructions to include graph analytics routing
```

**Step 6e: Test the agent via `cortex-agent` skill**

Invoke the `cortex-agent` skill in **test/debug** mode to validate the agent works end-to-end:

```
skill: cortex-agent

Context: Test the agent {DATABASE}.{SCHEMA}.{ONTOLOGY_NAME}_AGENT
  - Run one sample question per tool to confirm intent routing:
    - KG semantic view question (if applicable): e.g., "List all entities of type X"
    - Ontology semantic view question: e.g., "How many classes are mapped?"
    - Metadata semantic view question (if applicable): e.g., "Show all class mappings"
    - If graph tools deployed, test each:
      - expand_descendants_tool: "Show all subtypes of {ROOT_CLASS}" (use a root class from the ontology)
      - get_ancestors_tool: "What categories does {LEAF_CLASS} belong to?" (use a leaf class)
      - get_hierarchy_path_tool: "What is the path from {LEAF_CLASS} to {ROOT_CLASS}?"
      - get_direct_children_tool: "What are the direct subtypes of {ROOT_CLASS}?"
  - Verify each question routes to the correct tool (semantic view vs graph UDF)
  - Verify responses contain expected data (non-empty, hierarchy depths make sense)
  - If a graph tool question routes to a semantic view instead (or vice versa), the
    orchestration instructions need refinement — update tool descriptions or orchestration
  - If any test fails, use the skill's debug workflow to diagnose and fix
```

The `cortex-agent` skill will run the queries, show which tool was invoked, and flag routing or response issues.

**Self-check before gate**: Verify the agent is complete and functional:
- [ ] `SHOW AGENTS IN SCHEMA {DATABASE}.{SCHEMA}` returns the agent ({ONTOLOGY_NAME}_AGENT)
- [ ] Agent has one tool per deployed semantic view (count tools = count semantic views)
- [ ] If SQL UDF graph tools deployed: 4 generic tools registered (expand_descendants, get_ancestors, get_hierarchy_path, get_direct_children)
- [ ] If SPCS graph tools selected: SPCS service functions are registered as additional tools
- [ ] Step 6e tests passed — each tool received at least one routed question with non-empty response
- [ ] No unresolved errors from the `cortex-agent` skill

If agent is missing, has wrong tool count, or tests failed, fix before presenting the gate.

**⚠️ MANDATORY STOPPING POINT — DO NOT PROCEED TO PHASE 7**: You MUST use `ask_user_question`:

```
ask_user_question: "The Cortex Agent is deployed. Please test it with the questions above. Ready to proceed to Phase 7 (Validation)?"
Options:
  - "Yes, proceed to Phase 7"
  - "No, I need to fix the agent"
```

### Phase 7: End-to-End Validation

> **Note**: SQL artifacts (L1-L3) were deployed in Phase 4b. Semantic views (L4) and Cortex Agent (L5) were deployed by native skills in Phases 5 and 6. This phase validates the full stack.

**Step 7a: Validate all layers**

Run validation queries across the full stack:

- **L1 Physical**: Row counts for KG_NODE and KG_EDGE (if KG path)
- **L2 Metadata**: Row counts for all ~22 ONT_* tables
- **L3 Abstract Views**: Sample queries against each VW_ONT_* view
- **L4 Semantic Views**: Verify via `SHOW SEMANTIC VIEWS IN SCHEMA {DATABASE}.{SCHEMA}`
- **L5 Cortex Agent**: Run one end-to-end question through the agent:
  ```sql
  SELECT SNOWFLAKE.CORTEX.AGENT(
    '{DATABASE}.{SCHEMA}.{ONTOLOGY_NAME}_AGENT',
    PARSE_JSON('{"messages": [{"role": "user", "content": "<domain question from Phase 1>"}]}')
  );
  ```

Present a summary table of all deployed objects with row counts and status.

**Self-check before gate**: Verify the full stack is healthy:
- [ ] L1: KG_NODE and KG_EDGE have non-zero row counts (if KG path)
- [ ] L2: All ~22 ONT_* tables exist and have seed data (row count > 0 for at least ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP)
- [ ] L3: Every VW_ONT_* view returns rows without errors
- [ ] L4: `SHOW SEMANTIC VIEWS` count matches expected (from Phase 5 selections)
- [ ] L5: Agent query returned a meaningful response (not an error or empty)

If any layer fails validation, report the specific failure and attempt to fix (re-execute SQL, re-deploy view, etc.) before presenting the gate. Do NOT present a "deployment complete" gate with known failures.

**⚠️ MANDATORY STOPPING POINT — FINAL GATE**: You MUST use `ask_user_question`:

```
ask_user_question: "End-to-end validation complete. All layers are deployed and verified. Is the deployment complete?"
Options:
  - "Yes, deployment is complete"
  - "No, there are issues to address"
```

## Degrees of Freedom

| Decision | Freedom | Default |
|----------|---------|---------|
| KG vs direct-table path | **High** | Ask in Phase 1 |
| Which semantic models (1-3) | **High** | All 3 if KG, 2 if direct |
| Graph analytics tools | **High** | Only offered if KG path |
| Ontology class/relation design | **Medium** | AI recommends, user confirms |
| View naming convention | **Low** | `VW_ONT_` prefix |
| Agent routing instructions | **Low** | Auto-generated from model descriptions |

## Error Handling

- **No tables found**: Verify DATABASE.SCHEMA exists and user has SELECT permission
- **OWL parse failure**: Check file format (OWL/XML, Turtle, RDF/XML). Parser auto-detects.
- **SQL execution error**: Show exact error, suggest GRANT statements if permission issue
- **Empty views**: Verify filter conditions in ONT_CLASS_MAP match actual data values
- **Semantic model validation failure**: Check that all referenced views exist and have data

## Session Resume

If invoked mid-session, check `/tmp/generated/`, `/tmp/ontology_parsed/`, and Snowflake objects for existing artifacts:
- If `classes.json` exists → resume from Phase 3 (visualize)
- If `*.sql` files exist but not yet executed → resume from Phase 4b (deploy SQL)
- If `VW_ONT_*` views exist but no semantic views → resume from Phase 5 (semantic views via `semantic-view` skill)
- If semantic views exist (`SHOW SEMANTIC VIEWS`) but no agent → resume from Phase 6 (agent via `cortex-agent` skill)
- If agent exists → resume from Phase 7 (validation)

Always confirm the detected state with the user before proceeding.

## Output Files

SQL artifacts are saved to `/tmp/generated/` during the session. Semantic views and the Cortex Agent are deployed directly to Snowflake by the native skills (no local YAML or JSON files).

```
/tmp/generated/
├── 01_physical_layer.sql        (KG path only)
├── 02_concrete_views.sql        (V_{CLASS}, V_{REL} typed views)
├── 03_metadata_tables.sql       (~22 tables + auto-populated seed data)
├── 04_abstract_views.sql
├── 05_view_generator_sp.sql
├── 06_inference_engine.sql      (optional, KG path + user opted in)
├── 07_graph_traversal_tools.sql (optional, KG path + user opted in — 4 SQL UDF tools)
├── spcs_graph_service.py        (if SPCS graph tools selected)
└── spcs_setup.sql               (if SPCS graph tools selected)

Deployed directly to Snowflake (via native skills):
├── Semantic views              (created by `semantic-view` skill in Phase 5)
└── Cortex Agent                (created by `cortex-agent` skill in Phase 6)
```
