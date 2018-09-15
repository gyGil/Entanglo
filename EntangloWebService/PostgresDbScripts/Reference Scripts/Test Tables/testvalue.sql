-- Table: testvalue

-- DROP TABLE testvalue;

CREATE TABLE testvalue
(
  testvalue_id serial NOT NULL,
  testvalue_field_id integer,
  testvalue_entry_id integer,
  testvalue_value text,
  testvalue_result text,
  testvalue_max_limit text,
  testvalue_min_limit text,
  testvalue_created_timestamp timestamp without time zone NOT NULL DEFAULT now(),
  testvalue_void_timestamp timestamp without time zone,
  primary key (testvalue_id),
  foreign key (testvalue_field_id) references testfield (testfield_id) match simple on update no action on delete no action,
  foreign key (testvalue_entry_id) references testentry (testentry_id) match simple on update no action on delete no action
)
WITH (
  OIDS=FALSE
);
ALTER TABLE testvalue
  OWNER TO admin;
 GRANT ALL ON TABLE testvalue TO admin;
-- GRANT ALL ON TABLE testvalue TO xtrole;
-- GRANT SELECT ON TABLE testvalue TO aeryontrackinguser;
-- GRANT SELECT, UPDATE, INSERT ON TABLE testvalue TO progloader_user;
-- GRANT SELECT, UPDATE, INSERT ON TABLE testvalue TO at_tools;
-- GRANT SELECT ON TABLE testvalue TO accountingodbcrole;
COMMENT ON TABLE testvalue
  IS '[*New* --mrankin--] Contains all the test values associated with each test field of each test entry';