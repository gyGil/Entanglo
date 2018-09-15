-- Table: testtype
-- DROP TABLE testtype;

CREATE TABLE testtype
(
  testtype_id serial NOT NULL,
  testtype_name text not null,
  testtype_description text default 'N/A',
  testflowseq_created_timestamp timestamp without time zone DEFAULT now(),
  testflowseq_modified_timestamp timestamp without time zone,
  testflowseq_void_timestamp timestamp without time zone,
  primary key (testtype_id)
)
WITH (
  OIDS=false
);
ALTER TABLE testtype
  OWNER TO admin;
 GRANT ALL ON TABLE testtype TO admin;
COMMENT ON TABLE testtype
  IS '[*New* --mrankin--] Contains all possible test types that the test definitions belong to';