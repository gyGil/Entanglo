-- Table: testflowdef

-- DROP TABLE testflowdef;

CREATE TABLE testflowdef
(
  testflowdef_id serial NOT NULL,
  testflowdef_name text not null,
  testflowdef_description text not null,
  testflowdef_type_id integer not null,
  testflowdef_multiflow boolean not null default false,
  testflowdef_override boolean not null default false,
  testflowdef_created_timestamp timestamp without time zone DEFAULT now(),
  testflowdef_modified_timestamp timestamp without time zone,
  testflowdef_void_timestamp timestamp without time zone,
  primary key (testflowdef_id),
  foreign key (testflowdef_type_id) references testtype (testtype_id) match simple on update no action on delete no action
)
WITH (
  OIDS=false
);
ALTER TABLE testflowdef
  OWNER TO admin;-- 
 GRANT ALL ON TABLE testflowdef TO admin;
-- GRANT ALL ON TABLE testflowdef TO xtrole;
-- GRANT SELECT ON TABLE testflowdef TO aeryontrackinguser;
-- GRANT SELECT ON TABLE testflowdef TO accountingodbcrole;
-- GRANT SELECT ON TABLE testflowdef TO at_tools;
COMMENT ON TABLE testflowdef
  IS '[*New* --mrankin--] Contains the test stations info and flowcheck order numbers';