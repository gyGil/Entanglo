-- Table: testflowitem

-- DROP TABLE testflowitme;

CREATE TABLE testflowitem
(
  testflowitem_id serial NOT NULL,
  testflowitem_flow_id integer not null default 1,
  testflowitem_item_number text,
  testflowitem_override boolean default false,
  testflowitem_multiflow boolean default false,
  testflowitem_created timestamp without time zone DEFAULT now(),
  testflowitem_removed timestamp without time zone,
  primary key (testflowitem_id)
  --foreign key (testflowitem_flow_id) references testflowseq (testflowseq_id, testflowseq_flow_id)
)
WITH (
  OIDS=false
);
ALTER TABLE testflowitem
  OWNER TO admin;-- 
 GRANT ALL ON TABLE testflowitem TO admin;
-- GRANT ALL ON TABLE testflowitem TO xtrole;
-- GRANT SELECT ON TABLE testflowitem TO aeryontrackinguser;
-- GRANT SELECT ON TABLE testflowitem TO accountingodbcrole;
-- GRANT SELECT ON TABLE testflowitem TO at_tools;
COMMENT ON TABLE testflowitem
  IS '[*New* --mrankin--] Contains the flow index for all parts';