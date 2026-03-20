---
status: complete
created: 2025-01-17
modified: 2025-01-17
author: tjia
feature: ontology-stack-builder
version: 1.0.0
---

# Tasks: Ontology Stack Builder Skill

All tasks are complete. This checklist documents the implementation work performed across multiple sessions.

---

## Task 1: Project Scaffolding

**Status**: Complete

- [x] Create project directory structure (`scripts/`, `references/`, `specs/`)
- [x] Write `pyproject.toml` with dependencies (rdflib, pyyaml, streamlit, streamlit-agraph)
- [x] Write `README.md` with usage guide
- [x] Create reference templates (5 files: physical_layer, metadata_tables, abstract_views, semantic_model, agent_config)

## Task 2: SKILL.md — Core Workflow Definition

**Status**: Complete

- [x] Write YAML frontmatter (name, description, allowed-tools, metadata)
- [x] Document 5-layer architecture overview
- [x] Define 7-phase gated workflow with mandatory stopping points
- [x] Document Phase 1: Gather Inputs (schema, questions, OWL, KG/direct path)
- [x] Document Phase 2: Analyze & Recommend (script invocation, output tables)
- [x] Document Phase 3: Visualize & Confirm (Streamlit launch, ASCII fallback)
- [x] Document Phase 4: Generate Ontology Layer (SQL generation)
- [x] Document Phase 5: Select & Generate Semantic Models (1-3 model selection)
- [x] Document Phase 6: Generate Cortex Agent (agent config + graph tools)
- [x] Document Phase 7: Deploy & Validate (execution order, validation queries)
- [x] Document degrees of freedom table
- [x] Document error handling guidance
- [x] Document session resume protocol

## Task 3: parse_owl.py — OWL Ontology Parser

**Status**: Complete

- [x] Implement URI-to-name extraction (fragment + path fallback)
- [x] Implement label resolution (rdfs:label, skos:prefLabel)
- [x] Implement description extraction (rdfs:comment, dc/dcterms:description, skos:definition)
- [x] Implement `extract_classes()` — owl:Class, rdfs:Class, subClassOf references
- [x] Implement hierarchy detection from rdfs:subClassOf triples
- [x] Implement abstract vs concrete detection (subclasses without instances = abstract)
- [x] Implement deprecated class detection via owl:deprecated
- [x] Implement `extract_relations()` — owl:ObjectProperty, rdf:Property
- [x] Implement property characteristics: transitive, symmetric, functional
- [x] Implement inverse property detection via owl:inverseOf
- [x] Ensure subClassOf relation always present in output
- [x] Implement `extract_individuals()` — owl:NamedIndividual with types
- [x] Implement `compute_stats()` — BFS hierarchy depth, namespace breakdown
- [x] Implement CLI with `--owl-file`, `--output-dir`, `--format`, `--exclude-deprecated`, `--namespace-filter`
- [x] Write output: classes.json, relations.json, individuals.json, stats.json

## Task 4: introspect_schema.py — Schema-First Discovery

**Status**: Complete

- [x] Define heuristic regex patterns (ID, NAME, DESC, TYPE, DATE, FK_SUFFIX)
- [x] Implement `classify_table()` — entity/relationship/lookup classification
- [x] Implement junction table detection (composite PK + 2+ FKs + few non-FK cols)
- [x] Implement lookup table detection (<=5 cols, single PK, has name column)
- [x] Implement `infer_class_name()` — prefix stripping, PascalCase, singularization
- [x] Implement `propose_classes()` — per-entity-table class proposals
- [x] Implement `propose_relations()` — FK-based N:1 relations + junction table N:N relations
- [x] Implement `propose_mappings()` — class-to-table mappings with id/name columns
- [x] Implement `propose_rel_mappings()` — relation-to-table mappings with src_column/dst_column
- [x] Implement `compute_stats()` — summary statistics
- [x] Output format compatible with parse_owl.py (classes.json, relations.json, mappings.json)
- [x] Clean output (strip internal `_` prefixed keys)

## Task 5: generate_ontology_sql.py — Layers 1-3 SQL Generator

**Status**: Complete

- [x] Implement `sql_escape()` — single-quote doubling, NULL handling
- [x] Implement `generate_physical_layer_sql()` — KG_NODE/KG_EDGE DDL + INSERT
- [x] KG_NODE: NODE_ID, NODE_TYPE, NAME, PROPS (VARIANT), TS_INGESTED, clustered by NODE_TYPE
- [x] KG_EDGE: EDGE_ID, SRC_ID, DST_ID, EDGE_TYPE, WEIGHT, PROPS, EFFECTIVE_START/END, clustered
- [x] Node INSERT: SELECT from source tables with OBJECT_CONSTRUCT(*) for PROPS
- [x] Edge INSERT: UUID_STRING() for EDGE_ID, src_column/dst_column from mappings
- [x] Implement `generate_metadata_sql()` — ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP, ONT_REL_MAP
- [x] ONT_CLASS: hierarchy, abstract flag, type_class (ANALYTICAL/OPERATIONAL)
- [x] ONT_RELATION_DEF: domain/range, cardinality, transitivity, inverse
- [x] ONT_CLASS_MAP: conditional mapping (KG_NODE with filter vs direct source table)
- [x] ONT_REL_MAP: conditional mapping (KG_EDGE with filter vs direct source table)
- [x] Implement `generate_views_sql()` — per-class VW_ONT_*, VW_ONT_ALL_ENTITIES, REL_RESOLVED
- [x] KG path: views on KG_NODE with WHERE NODE_TYPE filter
- [x] Direct path: views on source tables with OBJECT_CONSTRUCT(*)
- [x] VW_ONT_ALL_ENTITIES only when >1 class
- [x] REL_RESOLVED: KG path joins KG_EDGE+KG_NODE; direct path UNIONs relation mappings
- [x] Implement `generate_view_generator_sp()` — Python SP with Snowpark
- [x] Conditional file generation (physical layer only for KG path)

## Task 6: generate_semantic_models.py — Layer 4 YAML Generator

**Status**: Complete

- [x] Implement `generate_kg_model()` — concrete V_{CLASS} views + REL_RESOLVED
- [x] Per-class table with dimensions (ID, NAME) and base_table reference
- [x] REL_RESOLVED with dimensions (REL_NAME, SRC/DST_ID/NAME/TYPE) and WEIGHT fact
- [x] Implement `generate_ontology_model()` — abstract VW_ONT_* views
- [x] Per-class table with ENTITY_ID/TYPE/NAME interface and primary_key
- [x] VW_ONT_ALL_ENTITIES only when >1 class mapping
- [x] REL_RESOLVED for cross-type relationship queries
- [x] Implement `generate_metadata_model()` — ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP
- [x] Full dimension definitions with descriptions
- [x] 4 verified queries: list classes, list relations, class-to-table map, hierarchy roots
- [x] Implement verified query generation tied to user's business questions
- [x] Intent-routing descriptions in each model's top-level description
- [x] YAML output via `yaml.dump()` with `sort_keys=False`, `allow_unicode=True`

## Task 7: generate_agent_config.py — Layer 5 Agent + SPCS

**Status**: Complete

- [x] Implement `detect_model_type()` — filename-based model type detection
- [x] Implement `build_agent_tools()` — cortex_analyst_tool entries per model
- [x] Intent-routing descriptions: MODEL_DESCRIPTIONS dict with routing keywords
- [x] Tool naming convention: MODEL_TOOL_NAMES dict (kg_analyst, ontology_analyst, metadata_analyst)
- [x] Implement `build_graph_tools()` — 3 function tool specs (centrality, community, shortest_path)
- [x] Full JSON Schema parameters for each graph tool
- [x] Implement `build_instructions()` — dynamic instructions based on included tools
- [x] Model selection strategy numbered by available models
- [x] Graph analytics instructions only when graph tools included
- [x] Implement stage name normalization (exactly one `@` prefix)
- [x] Default stage: `@{DATABASE}.{SCHEMA}.ONTOLOGY_STAGE`
- [x] Implement `generate_spcs_graph_service()` — Flask + NetworkX service
- [x] Graph caching with reload endpoint
- [x] Three algorithms: centrality (3 metrics), Louvain community, shortest path
- [x] Snowpark session from SPCS environment variables
- [x] Implement `generate_spcs_setup_sql()` — compute pool, service, functions
- [x] Conditional SPCS generation (only when `--include-graph-tools true`)

## Task 8: visualize_ontology.py — Streamlit Visualization

**Status**: Complete

- [x] Implement tree building from class hierarchy
- [x] Implement interactive tree renderer with Streamlit expanders
- [x] Implement text-based tree renderer (ASCII fallback)
- [x] Implement search filter across class names and labels
- [x] Implement coverage map computation (mapped/covered/unmapped/abstract)
- [x] Implement agraph node/edge construction with coverage coloring
- [x] Four coverage colors: green (mapped), blue (covered), red (unmapped), gray (abstract)
- [x] Node shapes: box (concrete), diamond (abstract)
- [x] Implement node detail inspector panel
- [x] Coverage badge display
- [x] Snowflake implementation details (view name, base table, dimensions)
- [x] Hierarchy edge and relation display
- [x] Implement 3-tab layout: Class Hierarchy, Ontology Graph, Coverage
- [x] Sidebar summary stats
- [x] Graph controls: max nodes, show relations, physics toggle

## Task 9: Testing & Validation

**Status**: Complete

- [x] Design 4 test scenarios with fixture data
  - S1: Full KG path, all 3 models, graph tools (healthcare domain, 3 classes)
  - S2: Direct-table path, ontology + metadata models (e-commerce, 3 classes)
  - S3: KG path, metadata-only model (social network, 2 classes)
  - S4: Direct-table path, ontology-only model (single class, edge case)
- [x] Create master fixture generator (`setup_all_fixtures.py`)
- [x] Fix fixture field names: `src_column`/`dst_column` (not `src_key`/`dst_key`)
- [x] Run all 4 scenarios through generate_ontology_sql.py — verified correct file counts
- [x] Run all 4 scenarios through generate_semantic_models.py — verified YAML generation
- [x] Run all 4 scenarios through generate_agent_config.py — verified tool counts
- [x] Validate conditional generation:
  - Physical layer SQL only for KG path (S1, S3 have it; S2, S4 don't)
  - SPCS files only for graph tools (S1 only)
  - VW_ONT_ALL_ENTITIES only for >1 class (S1, S2, S3 have it; S4 doesn't)
- [x] Design S5: comparison scenario for graph tools on/off + stage name fix
- [x] Discover and fix double `@` bug in stage name handling
  - Added normalization: `stage_name = "@" + stage_name.lstrip("@")`
  - Fixed semantic_model_file reference: removed redundant `@` prefix
- [x] Verify fix with 3 variants: with `@`, without `@`, and default stage name

## Task 10: Spec Documentation

**Status**: Complete

- [x] Create `specs/features/ontology-stack-builder/` directory
- [x] Write `requirements.md` — 13 functional + 3 non-functional requirements in EARS format
- [x] Write `design.md` — architecture, data flow, script details, error handling
- [x] Write `tasks.md` — 10 task groups with implementation checklist (this file)

---

## Summary

| Metric | Count |
|--------|-------|
| Total tasks | 10 |
| Tasks complete | 10 |
| Scripts implemented | 6 |
| Reference templates | 5 |
| Lines of code (scripts) | ~3,000 |
| Test scenarios executed | 5 |
| Bugs found & fixed | 1 (double `@` in stage name) |
| Functional requirements | 13 |
| Non-functional requirements | 3 |
