CREATE OR REPLACE SEMANTIC VIEW _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.SV_META_TICKET_METRICS
  COMMENT = 'Ontology metadata catalog semantic view for governance, introspection, and ontology schema exploration queries.'
  tables (
    -- Core ontology catalog tables
    CLASSES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_CLASS
      primary key (CLASS_NAME)
      comment = 'Ontology class definitions catalog. 23 classes defining the entity types in the TICKET_METRICS_ONT_POC ontology.',
    RELATIONS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_RELATION_DEF
      primary key (REL_NAME)
      comment = 'Ontology relation definitions catalog. 29 relations defining how entity types connect.',
    CLASS_MAPPINGS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_CLASS_MAP
      primary key (MAP_ID)
      comment = 'Class-to-source-table mapping. Shows which Snowflake table backs each ontology class, with ID/name expressions.',
    RELATION_MAPPINGS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_REL_MAP
      primary key (MAP_ID)
      comment = 'Relation-to-source-table mapping. Shows which Snowflake table provides the join columns for each relation.',

    -- Property catalog
    PROPERTIES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_PROPERTY
      primary key (CLASS_NAME, PROP_NAME)
      comment = 'Per-class property definitions. 217 properties across 23 classes with data types and descriptions.',
    SHARED_PROPERTIES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_SHARED_PROPERTY
      primary key (SHARED_PROP_NAME)
      comment = 'Shared (cross-class) property definitions. 33 properties shared across multiple classes.',

    -- Interface catalog
    INTERFACES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_INTERFACE
      primary key (INTERFACE_NAME)
      comment = 'Interface definitions. 33 interfaces defining reusable property contracts.',
    INTERFACE_IMPLS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_INTERFACE_IMPL
      primary key (INTERFACE_NAME, CLASS_NAME)
      comment = 'Interface implementations showing which classes implement which interfaces. 117 implementations.',

    -- Source provenance
    OBJECT_SOURCES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_OBJECT_SOURCE
      primary key (CLASS_NAME)
      comment = 'Source provenance for each ontology class — which database, schema, table provides the data.',
    LINK_SOURCES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_LINK_SOURCE
      primary key (REL_NAME)
      comment = 'Source provenance for each relationship — which table provides the edge data.',

    -- RBAC and governance
    ROLES as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_ROLE
      primary key (ROLE_NAME)
      comment = 'Ontology role definitions. 4 roles for access control.',
    PERMISSIONS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_PERMISSION
      primary key (ROLE_NAME, CLASS_NAME, ACTION_TYPE)
      comment = 'Role-class permission matrix. 46 permission entries defining which roles can read/write which classes.',

    -- View catalog
    VIEW_DEFS as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.OBJ_VIEW_DEF
      primary key (VIEW_NAME)
      comment = 'Generated view definitions catalog. Lists all VW_ONT_* views and their properties.',

    -- Ontology metadata
    ONTOLOGY as _SANDBOX_ONTOLOGY_POC.TICKET_METRICS.ONT_ONTOLOGY
      primary key (ONTOLOGY_NAME)
      comment = 'Top-level ontology record. Contains the ontology name, version, and description.'
  )
  relationships (
    -- Class → Properties (a class has many properties)
    PROP_BELONGS_TO_CLASS as PROPERTIES(CLASS_NAME) references CLASSES(CLASS_NAME),
    -- Class → Class Mappings (a class has one or more source mappings)
    CLASS_MAP_TO_CLASS as CLASS_MAPPINGS(CLASS_NAME) references CLASSES(CLASS_NAME),
    -- Relation → Domain Class
    REL_DOMAIN_CLASS as RELATIONS(DOMAIN_CLASS) references CLASSES(CLASS_NAME),
    -- Relation → Range Class
    REL_RANGE_CLASS as RELATIONS(RANGE_CLASS) references CLASSES(CLASS_NAME),
    -- Relation → Relation Mappings
    REL_MAP_TO_REL as RELATION_MAPPINGS(REL_NAME) references RELATIONS(REL_NAME),
    -- Class → Parent Class (hierarchy)
    CLASS_HIERARCHY as CLASSES(PARENT_CLASS_NAME) references CLASSES(CLASS_NAME),
    -- Interface Impl → Class
    IMPL_TO_CLASS as INTERFACE_IMPLS(CLASS_NAME) references CLASSES(CLASS_NAME),
    -- Interface Impl → Interface
    IMPL_TO_INTERFACE as INTERFACE_IMPLS(INTERFACE_NAME) references INTERFACES(INTERFACE_NAME),
    -- Property → Shared Property
    PROP_TO_SHARED as PROPERTIES(SHARED_PROP_NAME) references SHARED_PROPERTIES(SHARED_PROP_NAME),
    -- Object Source → Class
    SOURCE_TO_CLASS as OBJECT_SOURCES(CLASS_NAME) references CLASSES(CLASS_NAME),
    -- Permission → Role
    PERM_TO_ROLE as PERMISSIONS(ROLE_NAME) references ROLES(ROLE_NAME),
    -- Permission → Class
    PERM_TO_CLASS as PERMISSIONS(CLASS_NAME) references CLASSES(CLASS_NAME),
    -- View Def → Class (view name maps to class)
    VIEW_TO_CLASS as VIEW_DEFS(CLASS_NAME) references CLASSES(CLASS_NAME)
  )
  dimensions (
    -- Class dimensions
    CLASSES.CLASS_NAME as class_name
      with synonyms = ('entity_type', 'class', 'type', 'node_type')
      comment = 'Name of the ontology class (e.g. CrmAccount, InstanceAccount, AggInstanceRbaMetricMonthly).',
    CLASSES.PARENT_CLASS_NAME as parent_class
      with synonyms = ('superclass', 'parent_type')
      comment = 'Parent class in the ontology hierarchy (NULL for root classes).',
    CLASSES.IS_ABSTRACT as is_abstract
      comment = 'Whether the class is abstract (no direct instances) or concrete.',
    CLASSES.DESCRIPTION as class_description
      comment = 'Human-readable description of what this class represents.',
    CLASSES.TYPE_CLASS as type_class
      comment = 'Classification of the class (ANALYTICAL, DIMENSION, etc.).',

    -- Relation dimensions
    RELATIONS.REL_NAME as relation_name
      with synonyms = ('relationship', 'edge_type', 'relation')
      comment = 'Name of the ontology relation (e.g. has_crm_account, belongs_to_date).',
    RELATIONS.DOMAIN_CLASS as domain_class
      with synonyms = ('source_class', 'from_class')
      comment = 'Class that is the source (domain) of this relation.',
    RELATIONS.RANGE_CLASS as range_class
      with synonyms = ('target_class', 'to_class')
      comment = 'Class that is the target (range) of this relation.',
    RELATIONS.CARDINALITY as cardinality
      comment = 'Cardinality of the relation (N:1, 1:N, N:N, 1:1).',
    RELATIONS.IS_HIERARCHICAL as is_hierarchical
      comment = 'Whether this relation represents a hierarchy (parent-child).',
    RELATIONS.IS_TRANSITIVE as is_transitive
      comment = 'Whether this relation is transitive (A→B→C implies A→C).',
    RELATIONS.INVERSE_REL_NAME as inverse_relation
      comment = 'Name of the inverse relation (if defined).',
    RELATIONS.DESCRIPTION as relation_description
      comment = 'Human-readable description of the relation.',

    -- Property dimensions
    PROPERTIES.PROP_NAME as property_name
      with synonyms = ('column_name', 'field_name', 'attribute')
      comment = 'Name of the property/column on a class.',
    PROPERTIES.DATA_TYPE as property_data_type
      with synonyms = ('data_type', 'type')
      comment = 'Data type of the property (VARCHAR, NUMBER, DATE, etc.).',
    PROPERTIES.SHARED_PROP_NAME as shared_property
      comment = 'Name of the shared property this property maps to (if any).',
    PROPERTIES.IS_REQUIRED as is_required
      comment = 'Whether this property is required (NOT NULL).',
    PROPERTIES.DESCRIPTION as property_description
      comment = 'Description of the property.',

    -- Source mapping dimensions
    CLASS_MAPPINGS.SOURCE_DATABASE as source_database
      comment = 'Source database for the class data.',
    CLASS_MAPPINGS.SOURCE_SCHEMA as source_schema
      comment = 'Source schema for the class data.',
    CLASS_MAPPINGS.SOURCE_TABLE as source_table
      comment = 'Source table backing the ontology class.',
    CLASS_MAPPINGS.ID_EXPR as id_expression
      comment = 'SQL expression used to derive the entity ID from the source table.',
    CLASS_MAPPINGS.NAME_EXPR as name_expression
      comment = 'SQL expression used to derive the entity name from the source table.',

    -- Interface dimensions
    INTERFACES.INTERFACE_NAME as interface_name
      comment = 'Name of the interface (reusable property contract).',
    INTERFACES.DESCRIPTION as interface_description
      comment = 'Description of the interface.',

    -- Role dimensions
    ROLES.ROLE_NAME as role_name
      comment = 'Ontology role name for access control.',

    -- Permission dimensions
    PERMISSIONS.ACTION_TYPE as action_type
      comment = 'Type of action permitted (READ, WRITE, etc.).',

    -- View definition dimensions
    VIEW_DEFS.VIEW_NAME as view_name
      comment = 'Name of the generated ontology view (VW_ONT_*).',
    VIEW_DEFS.CLASS_NAME as view_class_name
      comment = 'Class name associated with this view definition.'
  )
  metrics (
    -- No numeric aggregation metrics in the metadata catalog — all dimensions
  )
  ai_instructions (
    sql_generation = '
RULES FOR METADATA SEMANTIC VIEW QUERIES:
1. This semantic view is for ontology METADATA exploration — it describes the schema, not the data itself.
2. Common patterns:
   - "What classes exist?" → SELECT CLASS_NAME, DESCRIPTION, IS_ABSTRACT FROM CLASSES
   - "What relations connect class X?" → SELECT * FROM RELATIONS WHERE DOMAIN_CLASS = X OR RANGE_CLASS = X
   - "What properties does class Y have?" → SELECT PROP_NAME, DATA_TYPE, DESCRIPTION FROM PROPERTIES WHERE CLASS_NAME = Y
   - "What source table backs class Z?" → SELECT SOURCE_DATABASE, SOURCE_SCHEMA, SOURCE_TABLE FROM CLASS_MAPPINGS WHERE CLASS_NAME = Z
   - "What interfaces does class W implement?" → SELECT INTERFACE_NAME FROM INTERFACE_IMPLS WHERE CLASS_NAME = W
   - "Who can access class V?" → SELECT ROLE_NAME, ACTION_TYPE FROM PERMISSIONS WHERE CLASS_NAME = V
3. There are 23 classes, 29 relations, 217 properties, 33 shared properties, 33 interfaces, 117 interface implementations, 4 roles, and 46 permissions.
4. The ontology name is TICKET_METRICS_ONT_POC.
5. Class hierarchy: most classes are root-level (no parent). Use PARENT_CLASS_NAME to explore any hierarchy.
6. Cardinality values: N:1 (many-to-one), 1:N (one-to-many), N:N (many-to-many).
'
  )
;
