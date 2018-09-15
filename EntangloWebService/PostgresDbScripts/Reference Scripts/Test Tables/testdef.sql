-- Table: testdef
-- DROP TABLE testdef;

CREATE TABLE testdef
(
  testdef_id serial NOT NULL,
  testdef_name text NOT NULL,
  testdef_description text NOT NULL,
  testdef_created_timestamp timestamp without time zone NOT NULL DEFAULT now(),
  testdef_modified_timestamp timestamp without time zone,
  testdef_void_timestamp timestamp without time zone,
  testdef_type_id integer not null,
  testdef_locked boolean DEFAULT false,
  primary key (testdef_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE testdef
  OWNER TO admin;
 GRANT ALL ON TABLE testdef TO admin;
-- GRANT ALL ON TABLE testdef TO xtrole;
-- GRANT SELECT ON TABLE testdef TO aeryontrackinguser;
-- GRANT SELECT ON TABLE testdef TO progloader_user;
-- GRANT SELECT ON TABLE testdef TO at_tools;
-- GRANT SELECT ON TABLE testdef TO accountingodbcrole;
COMMENT ON TABLE testdef
  IS '[*New* --mrankin--] Contains all the current test stations and related info';