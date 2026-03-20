---
status: approved
created: 2025-01-17
modified: 2025-01-17
author: tjia
feature: ontology-stack-builder
version: 1.0.0
---

# Requirements: Ontology Stack Builder Skill

## Overview

A Cortex Code skill that generates the complete Ontology-on-Snowflake stack from any relational schema and set of business questions. The skill produces ontology metadata, abstract views, up to 3 semantic models for Cortex Analyst, a Cortex Agent configuration with intent routing, and optional graph analytics scaffolding for SPCS.

## Stakeholders

- **End Users**: Snowflake customers and AFEs who want to build an ontology-powered analytics layer on existing relational data
- **System**: Cortex Code runtime (CoCo skill execution engine)
- **Downstream**: Cortex Analyst (semantic models), Cortex Agent (agent config), SPCS (graph service)

---

## Functional Requirements

### REQ-001: Dual-Path Ontology Discovery

**Type**: Event-Driven

**Statement**:
WHEN the user invokes the skill,
THE SYSTEM SHALL offer two discovery paths: (a) OWL file import via `parse_owl.py` and (b) schema-first discovery via `introspect_schema.py`,
SO THAT users with existing ontologies can reuse them and users without can auto-discover structure from their tables.

**Acceptance Criteria**:
- [x] OWL parser (`parse_owl.py`) accepts `.owl`, `.rdf`, `.ttl`, `.n3`, `.nt` formats
- [x] OWL parser auto-detects format from file extension
- [x] Schema introspector (`introspect_schema.py`) accepts table metadata JSON
- [x] Both paths produce identical output formats: `classes.json`, `relations.json`, `mappings.json`, `individuals.json`

### REQ-002: Schema Introspection with Heuristic Classification

**Type**: Event-Driven

**Statement**:
WHEN the user chooses the schema-first discovery path,
THE SYSTEM SHALL introspect table metadata and classify tables as entity, relationship, or lookup using structural heuristics (PK/FK patterns, column counts, naming conventions),
SO THAT ontology classes and relations are proposed automatically without manual definition.

**Acceptance Criteria**:
- [x] Tables with composite PK + 2+ FKs + few non-FK columns classified as "relationship" (junction tables)
- [x] Tables with <=5 columns, single PK, and a name column classified as "lookup"
- [x] All other tables classified as "entity"
- [x] Junction tables generate N:N relations instead of classes
- [x] FK relationships generate N:1 relations with names derived from FK column names
- [x] Table names converted to PascalCase singular class names (e.g., `CUSTOMERS` -> `Customer`, `ORDER_ITEMS` -> `OrderItem`)
- [x] Common table prefixes stripped: `TBL_`, `T_`, `DIM_`, `FACT_`, `STG_`, `RAW_`

### REQ-003: OWL Ontology Parsing

**Type**: Event-Driven

**Statement**:
WHEN the user provides an OWL file,
THE SYSTEM SHALL parse all OWL classes, object properties, and named individuals using rdflib, extracting hierarchy, property characteristics, and annotations,
SO THAT existing formal ontologies can be mapped onto Snowflake tables.

**Acceptance Criteria**:
- [x] Extracts `owl:Class` and `rdfs:Class` instances
- [x] Builds class hierarchy from `rdfs:subClassOf` triples
- [x] Extracts labels from `rdfs:label` and `skos:prefLabel`
- [x] Extracts descriptions from `rdfs:comment`, `dc:description`, `dcterms:description`, `skos:definition`
- [x] Detects property characteristics: transitive, symmetric, functional
- [x] Detects inverse properties via `owl:inverseOf`
- [x] Extracts `owl:NamedIndividual` instances with their types
- [x] Identifies deprecated classes via `owl:deprecated`
- [x] Determines abstract vs concrete from subclass/instance analysis
- [x] Ensures `subClassOf` relation always present in output
- [x] Supports `--exclude-deprecated` and `--namespace-filter` options

### REQ-004: Dual Storage Path (KG vs Direct Table)

**Type**: Event-Driven

**Statement**:
WHEN the user selects a storage path in Phase 1,
THE SYSTEM SHALL generate either KG_NODE/KG_EDGE physical tables (KG path) or views directly on source tables (direct-table path),
SO THAT users can choose between a unified graph structure or lightweight views on existing data.

**Acceptance Criteria**:
- [x] KG path generates `01_physical_layer.sql` with KG_NODE and KG_EDGE DDL
- [x] KG_NODE clustered by NODE_TYPE, KG_EDGE clustered by (EDGE_TYPE, SRC_ID, DST_ID)
- [x] KG path generates INSERT statements loading source data into KG_NODE/KG_EDGE
- [x] Direct-table path skips physical layer SQL entirely
- [x] Direct-table path creates VW_ONT_* views directly on source tables
- [x] KG path creates VW_ONT_* views on KG_NODE with NODE_TYPE filter
- [x] Both paths produce identical abstract view interfaces (ENTITY_ID, ENTITY_TYPE, ENTITY_NAME, PROPS)

### REQ-005: Ontology Metadata Layer (Layer 2)

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL generate `02_metadata_tables.sql` containing DDL and INSERT statements for ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP, and ONT_REL_MAP tables,
SO THAT the ontology structure is persisted in Snowflake for runtime introspection and view regeneration.

**Acceptance Criteria**:
- [x] ONT_CLASS stores class hierarchy with CLASS_NAME, PARENT_CLASS_NAME, IS_ABSTRACT, TYPE_CLASS
- [x] ONT_RELATION_DEF stores relation definitions with domain/range, cardinality, transitivity, inverse
- [x] ONT_CLASS_MAP maps classes to physical tables with ID_EXPR, NAME_EXPR, filter conditions
- [x] ONT_REL_MAP maps relations to physical tables with SRC_ID_EXPR, DST_ID_EXPR, filter conditions
- [x] KG path uses KG_NODE/KG_EDGE as source with NODE_TYPE/EDGE_TYPE filters
- [x] Direct path uses original source tables as-is

### REQ-006: Abstract Views Layer (Layer 3)

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL generate `03_abstract_views.sql` with per-class entity views (VW_ONT_{CLASS}), a unified entity view (VW_ONT_ALL_ENTITIES), and a resolved relationships view (REL_RESOLVED),
SO THAT downstream semantic models have consistent interfaces regardless of storage path.

**Acceptance Criteria**:
- [x] Per-class views named `VW_ONT_{CLASS_NAME}` with standard columns: ENTITY_ID, ENTITY_TYPE, ENTITY_NAME, PROPS
- [x] VW_ONT_ALL_ENTITIES created as UNION ALL of all per-class views (only when >1 class)
- [x] REL_RESOLVED joins relationships with entity names and types
- [x] KG path REL_RESOLVED joins KG_EDGE with KG_NODE for names
- [x] Direct-table path REL_RESOLVED UNIONs relation mappings with NULL names/types

### REQ-007: View Generator Stored Procedure

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL generate `04_view_generator_sp.sql` containing a Python stored procedure (SP_GENERATE_ONTOLOGY_VIEWS) that reads ONT_CLASS_MAP and regenerates VW_ONT_* views dynamically,
SO THAT views can be refreshed when ontology mappings change without re-running the skill.

**Acceptance Criteria**:
- [x] Procedure uses Python 3.12 runtime with snowflake-snowpark-python
- [x] Reads all rows from ONT_CLASS_MAP
- [x] Generates VW_ONT_{CLASS} views for each mapping
- [x] Generates VW_ONT_ALL_ENTITIES union view when multiple classes exist
- [x] Returns JSON summary of created views
- [x] Includes initial `CALL SP_GENERATE_ONTOLOGY_VIEWS()` invocation

### REQ-008: Tri-Model Semantic Strategy (Layer 4)

**Type**: Event-Driven

**Statement**:
WHEN the user selects semantic models to generate in Phase 5,
THE SYSTEM SHALL produce up to 3 Cortex Analyst YAML files with intent-routing descriptions: (1) KG Model for concrete queries, (2) Ontology Model for abstract cross-type queries, (3) Metadata Model for governance/introspection,
SO THAT the Cortex Agent can route user questions to the most appropriate model.

**Acceptance Criteria**:
- [x] KG Model includes per-class concrete views (V_{CLASS}) and REL_RESOLVED with aggregation facts
- [x] Ontology Model includes VW_ONT_* abstract views with ENTITY_ID/TYPE/NAME interface
- [x] Metadata Model includes ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP definitions
- [x] Each model has intent-routing keywords in its description
- [x] Each model includes verified queries derived from user's business questions
- [x] KG Model only available when KG path is chosen
- [x] Ontology Model always available
- [x] Metadata Model always available
- [x] VW_ONT_ALL_ENTITIES included in Ontology Model only when >1 class exists

### REQ-009: Cortex Agent Configuration (Layer 5)

**Type**: Event-Driven

**Statement**:
WHEN semantic models have been generated in Phase 5,
THE SYSTEM SHALL produce a `cortex_agent_config.json` with one cortex_analyst_tool per selected model, orchestration instructions, and tool_choice set to auto,
SO THAT a Cortex Agent can be registered with proper intent routing across all models.

**Acceptance Criteria**:
- [x] One cortex_analyst_tool entry per semantic model YAML
- [x] Tool names follow convention: kg_analyst, ontology_analyst, metadata_analyst
- [x] Tool descriptions contain intent-routing keywords for model selection
- [x] Instructions adapt to included tool set (only references included tools)
- [x] Stage references use exactly one `@` prefix (normalized)
- [x] Supports custom `--stage-name` or defaults to `@{DATABASE}.{SCHEMA}.ONTOLOGY_STAGE`
- [x] Tool count ranges from 1-6 (1-3 analyst tools + 0-3 graph tools)

### REQ-010: Graph Analytics Scaffolding (Optional)

**Type**: Optional

**Statement**:
WHERE the user chose the KG path AND opts to include graph analytics tools,
THE SYSTEM SHALL generate SPCS scaffolding: (a) `spcs_graph_service.py` Flask service with NetworkX, and (b) `spcs_setup.sql` with compute pool, service, and service function DDL,
SO THAT graph algorithms (centrality, community detection, shortest path) can run on the knowledge graph.

**Acceptance Criteria**:
- [x] Flask service reads KG_NODE/KG_EDGE from Snowflake via Snowpark session
- [x] Three endpoints: `/centrality` (degree, betweenness, pagerank), `/community` (Louvain), `/shortest_path`
- [x] Health check endpoint at `/health`
- [x] Graph reload endpoint at `/reload`
- [x] SPCS setup SQL includes compute pool, image repository, service spec, and 3 service functions
- [x] Agent config includes 3 additional function tools when graph tools enabled
- [x] Graph tools only offered when KG path is chosen

### REQ-011: Ontology Visualization

**Type**: Optional

**Statement**:
WHERE the user reaches Phase 3,
THE SYSTEM SHALL launch a Streamlit visualization app showing interactive class hierarchy, ontology graph with coverage coloring, and a coverage matrix,
SO THAT the user can visually confirm the ontology structure before generation.

**Acceptance Criteria**:
- [x] Three-tab layout: Class Hierarchy, Ontology Graph, Coverage
- [x] Interactive tree with expandable nodes, search, and depth control
- [x] Graph nodes colored by coverage status: mapped (green), covered (blue), unmapped (red), abstract (gray)
- [x] Node click shows detail panel with Snowflake implementation info
- [x] Coverage matrix with status counts (mapped, covered, unmapped, abstract)
- [x] Text-mode fallback when Streamlit not available

### REQ-012: 7-Phase Gated Workflow

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL enforce a 7-phase workflow with mandatory stopping points after each phase: (1) Gather Inputs, (2) Analyze & Recommend, (3) Visualize & Confirm, (4) Generate Ontology Layer, (5) Select & Generate Semantic Models, (6) Generate Cortex Agent, (7) Deploy & Validate,
SO THAT the user reviews and approves each artifact before proceeding.

**Acceptance Criteria**:
- [x] SKILL.md defines all 7 phases with gate descriptions
- [x] Gates override all other instructions including "generate everything at once"
- [x] Each phase has specific script invocations documented
- [x] Phase outputs are saved to `/tmp/generated/` and `/tmp/ontology_parsed/`
- [x] Session resume detects existing artifacts and proposes appropriate restart phase

### REQ-013: Output File Conventions

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL produce all generated artifacts with consistent naming: numbered SQL files (`01_`-`04_`), named semantic model YAMLs, agent config JSON, and optional SPCS files,
SO THAT deployment order is obvious and files are self-documenting.

**Acceptance Criteria**:
- [x] `01_physical_layer.sql` (KG path only)
- [x] `02_metadata_tables.sql` (always)
- [x] `03_abstract_views.sql` (always)
- [x] `04_view_generator_sp.sql` (always)
- [x] `kg_semantic_model.yaml` (if KG model selected)
- [x] `ontology_semantic_model.yaml` (if Ontology model selected)
- [x] `metadata_governance_model.yaml` (if Metadata model selected)
- [x] `cortex_agent_config.json` (always)
- [x] `spcs_graph_service.py` (if graph tools selected)
- [x] `spcs_setup.sql` (if graph tools selected)

### REQ-014: Semantic View Discovery and Reuse

**Type**: Event-Driven

**Statement**:
WHEN the user invokes the skill in Phase 1,
THE SYSTEM SHALL discover existing semantic views in the target schema via `SHOW SEMANTIC VIEWS IN SCHEMA` and offer to reuse one as the base semantic view,
SO THAT users with existing semantic views avoid redundant creation and get enriched ontology proposals from curated metadata.

**Acceptance Criteria**:
- [ ] Phase 1 (Step 1b) runs `SHOW SEMANTIC VIEWS IN SCHEMA {DATABASE}.{SCHEMA}` to detect existing semantic views
- [ ] If found, uses `semantic-view` skill (describe mode) to extract metadata (column descriptions, relationships, metrics)
- [ ] Prompts user to choose: reuse existing semantic as base, or create from scratch
- [ ] If existing chosen: records `existing_base_semantic` FQN and `existing_semantic_tables` list
- [ ] Existing semantic metadata enriches ontology proposals in Phase 2 (column descriptions, relationships, verified queries)
- [ ] Phase 4.5 skips creation when existing semantic is selected

### REQ-015: Base Semantic View Guarantee

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL ensure a base semantic view covering the original source tables is always present in the final delivery (either reused from existing or created in Phase 4.5 via the `semantic-view` skill),
SO THAT the Cortex Agent always has a tool for concrete data queries against source tables, separate from ontology-layer semantic views.

**Acceptance Criteria**:
- [ ] Phase 4.5 creates `{ONTOLOGY_NAME}_BASE` semantic view if no existing semantic was selected in Phase 1
- [ ] Phase 4.5 invokes the native `semantic-view` skill (creation mode) on source tables
- [ ] Phase 4.5 tests the base semantic view via `semantic-view` skill (audit mode) with 2-3 business questions
- [ ] Phase 6 agent always includes `base_query_tool` pointing to the base semantic view (existing or Phase 4.5)
- [ ] Phase 7 validation counts base semantic + ontology-layer semantics separately

---

## Non-Functional Requirements

### REQ-NF-001: Dependency Management

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL use inline PEP 723 script metadata (`# /// script`) for per-script dependencies and a `pyproject.toml` for project-level dependencies, all compatible with `uv run`,
SO THAT the skill runs without manual pip install steps.

**Acceptance Criteria**:
- [x] Each script declares its own dependencies in PEP 723 header
- [x] `parse_owl.py` requires `rdflib>=7.0.0`
- [x] `introspect_schema.py`, `generate_ontology_sql.py`, `generate_semantic_models.py`, `generate_agent_config.py` require `pyyaml>=6.0`
- [x] `visualize_ontology.py` requires `streamlit>=1.30.0`, `streamlit-agraph>=0.0.45`, `pyyaml>=6.0`
- [x] All scripts require Python >= 3.10

### REQ-NF-002: CoCo Skill Conventions

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL follow Cortex Code skill conventions: SKILL.md with YAML frontmatter, `scripts/` folder for executables, `references/` for templates, `allowed-tools` declaration,
SO THAT the skill integrates correctly with the CoCo skill execution engine.

**Acceptance Criteria**:
- [x] SKILL.md has `name`, `description`, `allowed-tools`, and `metadata` in YAML frontmatter
- [x] `allowed-tools` includes: Read, Write, Edit, Bash(python*), Bash(uv*), Bash(pip*), Bash(mkdir*), Bash(ls*), Bash(cp*), snowflake_sql_execute, ask_user_question, notebook_actions
- [x] All scripts in `scripts/` directory
- [x] Reference templates in `references/` directory
- [x] `pyproject.toml` at project root

### REQ-NF-003: SQL Safety

**Type**: Ubiquitous

**Statement**:
THE SYSTEM SHALL use proper SQL escaping (single-quote doubling) for all generated INSERT values and `CREATE IF NOT EXISTS` / `CREATE OR REPLACE` patterns for idempotent re-execution,
SO THAT generated SQL is injection-safe and can be safely re-run.

**Acceptance Criteria**:
- [x] `sql_escape()` function doubles single quotes in string values
- [x] NULL values rendered as SQL `NULL` (unquoted)
- [x] Metadata tables use `CREATE TABLE IF NOT EXISTS`
- [x] Views use `CREATE OR REPLACE VIEW`
- [x] Physical tables use `CREATE OR REPLACE TABLE`
