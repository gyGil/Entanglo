-- Table: testflowseq

-- DROP TABLE testflowseq;

CREATE TABLE testflowseq
(
  testflowseq_id serial NOT NULL,
  testflowseq_name text not null,
  testflowseq_description text not null,
  testflowseq_flow_id integer not null default 1,
  testflowseq_test_seq integer[][],
  testflowseq_created_timestamp timestamp without time zone DEFAULT now(),
  testflowseq_modified_timestamp timestamp without time zone,
  testflowseq_void_timestamp timestamp without time zone,
  testflowitem_default boolean default false,
  primary key (testflowseq_id)
)
WITH (
  OIDS=false
);
ALTER TABLE testflowseq
  OWNER TO admin;-- 
 GRANT ALL ON TABLE testflowseq TO admin;
-- GRANT ALL ON TABLE testflowseq TO xtrole;
-- GRANT SELECT ON TABLE testflowseq TO aeryontrackinguser;
-- GRANT SELECT ON TABLE testflowseq TO accountingodbcrole;
-- GRANT SELECT ON TABLE testflowseq TO at_tools;
COMMENT ON TABLE testflowseq
  IS '[*New* --mrankin--] Contains all possible flowcheck sequences for all parts';