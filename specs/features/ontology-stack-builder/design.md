---
status: approved
created: 2025-01-17
modified: 2025-01-17
author: tjia
feature: ontology-stack-builder
version: 1.0.0
---

# Design: Ontology Stack Builder Skill

## Architecture Overview

The skill generates a 5-layer Ontology-on-Snowflake stack through a 7-phase gated workflow orchestrated by `SKILL.md`. Six Python scripts handle the heavy lifting, with reference templates providing structural examples.

```
                     ┌────────────────────────────────────┐
                     │          SKILL.md                   │
                     │   (7-Phase Gated Workflow)          │
                     │   Orchestrates all scripts + skills │
                     └──────────┬─────────────────────────┘
                                │
        ┌──────────┬────────────┼────────────┬──────────────┐
        ▼          ▼            ▼            ▼              ▼
  parse_owl.py  introspect   generate     `semantic-    `cortex-
  (OWL path)   _schema.py   _ontology     view` skill   agent` skill
               (Schema path) _sql.py     (Phase 4.5+5)  (Phase 6)
                     │            │            │              │
                     ▼            ▼            ▼              ▼
              classes.json   01-04.sql   Semantic Views  Cortex Agent
              relations.json             (base +         (all tools)
              mappings.json               ontology-layer)
                     │
                     ▼
            visualize_ontology.py
            (Streamlit app)
```

## File Structure

```
ontology-stack-builder/
├── SKILL.md                          # Core skill definition (372 lines)
├── pyproject.toml                    # Project dependencies
├── README.md                         # Usage guide
├── specs/                            # Spec documentation
│   └── features/
│       └── ontology-stack-builder/
│           ├── requirements.md
│           ├── design.md             # This file
│           └── tasks.md
├── scripts/
│   ├── parse_owl.py                  # OWL/RDF parser (340 lines)
│   ├── introspect_schema.py          # Schema-first discovery (394 lines)
│   ├── generate_ontology_sql.py      # Layers 1-3 SQL generator (539 lines)
│   ├── generate_semantic_models.py   # DEPRECATED — replaced by `semantic-view` skill
│   ├── generate_agent_config.py      # DEPRECATED — replaced by `cortex-agent` skill
│   ├── generate_spcs_scaffolding.py  # SPCS graph service scaffolding (optional)
│   └── visualize_ontology.py         # Streamlit visualization (700+ lines)
└── references/
    ├── physical_layer_template.sql
    ├── metadata_tables_template.sql
    ├── abstract_views_template.sql
    ├── semantic_model_template.yaml
    └── agent_config_template.json
```

## Data Flow

### Phase 2: Discovery

Two mutually exclusive paths produce the same intermediate format:

```
Path A: OWL File                     Path B: Schema-First
─────────────────                    ────────────────────
.owl/.rdf/.ttl file                  Table metadata JSON (from DESCRIBE TABLE)
      │                                    │
      ▼                                    ▼
parse_owl.py                         introspect_schema.py
  - rdflib Graph.parse()               - classify_table() heuristics
  - extract_classes()                   - propose_classes()
  - extract_relations()                 - propose_relations()
  - extract_individuals()              - propose_mappings()
      │                                    │
      ▼                                    ▼
┌──────────────────────────────────────────────────┐
│ Intermediate JSON Format (shared):               │
│   classes.json     - name, parent, abstract, uri │
│   relations.json   - name, domain, range, props  │
│   mappings.json    - class_mappings[], relation_  │
│                      mappings[], database, schema │
│   individuals.json - name, types (OWL only)      │
│   stats.json       - counts, depth, namespaces   │
└──────────────────────────────────────────────────┘
```

### Phase 4-6: Generation Pipeline

```
Intermediate JSON ──► generate_ontology_sql.py ──► SQL Files (Layers 1-3)
                  │                                   │
                  │   ┌─────────────────────────┐     │
                  ├──►│ Phase 4.5: Base Semantic │──►  Base Semantic View (Layer 4-base)
                  │   │ via `semantic-view` skill│     │  (skipped if existing semantic
                  │   │ on source tables         │     │   chosen in Phase 1)
                  │   └─────────────────────────┘     │
                  │                                   │
                  │   ┌─────────────────────────┐     │
                  ├──►│ Phase 5: Ontology-layer  │──►  Ontology Semantic Views (Layer 4-ontology)
                  │   │ via `semantic-view` skill│     │  (KG, Ontology, Metadata models)
                  │   │ on VW_ONT_*/V_*/ONT_*   │     │
                  │   └─────────────────────────┘     │
                  │                                   │
                  │   ┌─────────────────────────┐     │
                  └──►│ Phase 6: Agent           │──►  Cortex Agent (Layer 5)
                      │ via `cortex-agent` skill │     │  tools: base + ontology-layer
                      │ all semantic views ──────┤     │  + optional graph UDFs
                      └─────────────────────────┘
```

**Dependencies**:
- Phase 4.5 depends on Phase 4 (source tables must exist; ontology layer deployed)
- Phase 5 depends on Phase 4 (VW_ONT_*, V_*, ONT_* objects must exist)
- Phase 6 depends on Phase 4.5 + Phase 5 (all semantic views must exist)

## Script Design Details

### parse_owl.py

| Aspect | Detail |
|--------|--------|
| **Input** | OWL/RDF/TTL file path |
| **Output** | `classes.json`, `relations.json`, `individuals.json`, `stats.json` |
| **Library** | rdflib (Graph, OWL, RDFS, SKOS, DC, DCTERMS namespaces) |
| **Key Functions** | `extract_classes()`, `extract_relations()`, `extract_individuals()`, `compute_stats()` |
| **URI Handling** | Fragment extraction (`#Name`), path segment fallback |
| **Label Priority** | `rdfs:label` > `skos:prefLabel` > URI parsing |
| **Abstract Detection** | Has subclasses AND no direct instances = abstract |

### introspect_schema.py

| Aspect | Detail |
|--------|--------|
| **Input** | `--metadata-json` (table metadata), `--questions`, `--output-dir` |
| **Output** | `classes.json`, `relations.json`, `mappings.json`, `individuals.json` (empty), `stats.json` |
| **Classification** | `classify_table()` → entity / relationship / lookup |
| **Name Inference** | `infer_class_name()` → strip prefixes, PascalCase, simple singularization |
| **FK Detection** | `FK_SUFFIX` regex: `^(.+)_(ID|KEY|CODE)$` → relation name `has_{prefix}` |
| **Junction Detection** | Composite PK (>=2) + >=2 FKs + <=3 non-FK cols = relationship table |

**Heuristic Patterns** (compiled regexes):
```
ID_PATTERNS    = ^(.*_)?(ID|KEY|CODE|UUID|PK)$
NAME_PATTERNS  = ^(.*_)?(NAME|LABEL|TITLE|DISPLAY_NAME|FULL_NAME)$
DESC_PATTERNS  = ^(.*_)?(DESC|DESCRIPTION|NOTES|COMMENT|BIO)$
TYPE_PATTERNS  = ^(.*_)?(TYPE|CATEGORY|CLASS|STATUS|KIND|GROUP)$
DATE_PATTERNS  = ^(.*_)?(DATE|TIME|TIMESTAMP|CREATED|UPDATED|MODIFIED|_AT|_ON)$
FK_SUFFIX      = ^(.+)_(ID|KEY|CODE)$
```

### generate_ontology_sql.py

| Aspect | Detail |
|--------|--------|
| **Input** | `--classes-json`, `--relations-json`, `--mappings-json`, `--database`, `--schema`, `--ontology-name`, `--kg-path`, `--output-dir` |
| **Output** | 3-4 SQL files depending on KG path |
| **Key Functions** | `generate_physical_layer_sql()`, `generate_metadata_sql()`, `generate_views_sql()`, `generate_view_generator_sp()` |

**Conditional Generation Logic**:
```
if kg_path:
    01_physical_layer.sql    ✓ (KG_NODE, KG_EDGE + INSERT)
    02_metadata_tables.sql   ✓ (maps to KG_NODE/KG_EDGE with filters)
    03_abstract_views.sql    ✓ (VW_ONT_* on KG_NODE WHERE NODE_TYPE=)
    04_view_generator_sp.sql ✓
else:
    01_physical_layer.sql    ✗ (skipped)
    02_metadata_tables.sql   ✓ (maps to source tables directly)
    03_abstract_views.sql    ✓ (VW_ONT_* directly on source tables)
    04_view_generator_sp.sql ✓
```

**Field Mapping Contract** (critical for fixture compatibility):
- `mappings.relation_mappings[].src_column` — source FK column
- `mappings.relation_mappings[].dst_column` — destination FK column
- `mappings.relation_mappings[].rel_name` — relationship name
- `mappings.relation_mappings[].source_table` — fully qualified table name

### generate_semantic_models.py

| Aspect | Detail |
|--------|--------|
| **Input** | Same JSON files + `--models` (comma-separated: kg, ontology, metadata) + `--questions` |
| **Output** | 1-3 YAML files |
| **Format** | Cortex Analyst semantic model YAML |
| **Key Functions** | `generate_kg_model()`, `generate_ontology_model()`, `generate_metadata_model()` |

**Tri-Model Strategy**:

| Model | Tables | Use Case | Routing Keywords |
|-------|--------|----------|-----------------|
| KG | V_{CLASS}, REL_RESOLVED | Concrete lookups, aggregations | "specific", "named entity", "aggregation" |
| Ontology | VW_ONT_{CLASS}, VW_ONT_ALL_ENTITIES, REL_RESOLVED | Cross-type, hierarchy, unification | "abstract", "what types", "across types" |
| Metadata | ONT_CLASS, ONT_RELATION_DEF, ONT_CLASS_MAP | Introspection, governance | "what classes", "how structured", "catalog" |

**Verified Query Generation**: Each model includes 2-4 verified queries. Queries reference actual table/view names from the generated ontology.

### generate_agent_config.py

| Aspect | Detail |
|--------|--------|
| **Input** | `--semantic-models` (comma-separated YAML paths), `--database`, `--schema`, `--stage-name`, `--include-graph-tools`, `--output-dir` |
| **Output** | `cortex_agent_config.json` + optional `spcs_graph_service.py`, `spcs_setup.sql` |
| **Model Detection** | `detect_model_type()` from filename: `kg` in name → kg, `ontology` in name → ontology, `metadata`/`governance` → metadata |
| **Stage Normalization** | Ensures exactly one `@` prefix: `stage_name = "@" + stage_name.lstrip("@")` |

**Agent Config Structure**:
```json
{
  "model_name": "claude-3-5-sonnet",
  "tool_choice": "auto",
  "max_tokens": 4096,
  "tools": [
    { "tool_spec": { "type": "cortex_analyst_tool", "name": "...", "semantic_model_file": "@STAGE/file.yaml" } },
    { "tool_spec": { "type": "function", "name": "graph_centrality", ... } }
  ],
  "instructions": "... dynamic based on included tools ..."
}
```

**Tool Count Matrix**:

| Config | Analyst Tools | Graph Tools | Total |
|--------|:---:|:---:|:---:|
| 1 model, no graph | 1 | 0 | 1 |
| 3 models, no graph | 3 | 0 | 3 |
| 1 model, with graph | 1 | 3 | 4 |
| 3 models, with graph | 3 | 3 | 6 |

**SPCS Graph Service Design**:
- Flask app on port 8080
- NetworkX graph built from KG_NODE/KG_EDGE via Snowpark
- Global graph cache with `/reload` endpoint
- Three algorithms: degree/betweenness/pagerank centrality, Louvain community detection, shortest path
- SPCS service functions bridge HTTP endpoints to SQL-callable functions

### visualize_ontology.py

| Aspect | Detail |
|--------|--------|
| **Input** | `--classes-json`, `--relations-json`, `--semantic-model` (optional), `--stats-json` (optional) |
| **Library** | Streamlit + streamlit-agraph |
| **Layout** | 3 tabs: Class Hierarchy, Ontology Graph, Coverage |
| **Coverage Model** | mapped (direct view) / covered (ancestor view) / unmapped / abstract |

**Graph Coloring Scheme**:
- Mapped → green (#2ecc71)
- Covered → blue (#3498db)
- Unmapped → red (#e74c3c)
- Abstract → gray (#ecf0f1)

**Node Shapes**: Box for concrete, diamond for abstract

## Session Resume Protocol

The SKILL.md defines artifact-based resume detection:

| Existing Artifacts | Resume Phase |
|---|---|
| None | Phase 1 (Gather Inputs) |
| `classes.json` | Phase 3 (Visualize) |
| `*.sql` files | Phase 4.5 (Base Semantic) |
| Base semantic view exists | Phase 5 (Ontology Semantic Views) |
| Ontology semantic views exist | Phase 6 (Agent Config) |
| Agent exists | Phase 7 (Validation) |

## Error Handling Strategy

| Error | Script | Handling |
|-------|--------|----------|
| Missing table in metadata | introspect_schema.py | Skip with warning |
| No FK found for relation | introspect_schema.py | Skip relation |
| Invalid OWL format | parse_owl.py | rdflib exception with format hint |
| Missing semantic model file | generate_agent_config.py | Warning to stderr, skip file |
| No valid model files | generate_agent_config.py | Exit with error code 1 |
| Double `@` in stage name | generate_agent_config.py | Normalized via `lstrip("@")` |
| SQL injection via class names | generate_ontology_sql.py | `sql_escape()` doubles single quotes |

## Dependencies

| Package | Version | Used By |
|---------|---------|---------|
| rdflib | >=7.0.0 | parse_owl.py |
| pyyaml | >=6.0 | introspect_schema.py, generate_semantic_models.py, generate_agent_config.py |
| streamlit | >=1.30.0 | visualize_ontology.py |
| streamlit-agraph | >=0.0.45 | visualize_ontology.py |
| networkx | (SPCS runtime) | spcs_graph_service.py |
| python-louvain | (SPCS runtime) | spcs_graph_service.py |
| flask | (SPCS runtime) | spcs_graph_service.py |
| snowflake-snowpark-python | (Snowflake runtime) | SP_GENERATE_ONTOLOGY_VIEWS, spcs_graph_service.py |
