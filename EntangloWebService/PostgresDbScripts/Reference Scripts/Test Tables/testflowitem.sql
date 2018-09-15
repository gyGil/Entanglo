-- Table: testflowitem

-- DROP TABLE testflowitem;

CREATE TABLE testflowitem
(
  testflowitem_id serial NOT NULL,
  testflowitem_flow_id integer not null,
  testflowitem_item_id integer not null, -- testflowitem_item_id and testflowitem_type_id combo unique
  testflowitem_type_id integer not null, -- populated from testflowdef by testflowitem_flow_id
  testflowitem_override boolean default false,
  testflowitem_created_timestamp timestamp without time zone DEFAULT now(),
  testflowitem_modified_timestamp timestamp without time zone,
  unique (testflowitem_item_id, testflowitem_type_id),
  primary key (testflowitem_id),
  Foreign Key (testflowitem_flow_id) references testflowdef (testflowdef_id)
  --foreign key (testflowitem_flow_id) references testflowseq (testflowseq_id, testflowseq_flow_id)
)
WITH (
  OIDS=false
);
ALTER TABLE testflowitem
  OWNER TO admin;-- 
 GRANT ALL ON TABLE testflowitem TO admin;
COMMENT ON TABLE testflowitem
  IS '[*New* --mrankin--] Contains the flow index for all parts';