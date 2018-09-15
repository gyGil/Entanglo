-- Table: testcombovalue

-- DROP TABLE testcombovalue;

CREATE TABLE testcombovalue
(
  testcombovalue_id serial NOT NULL,
  testcombovalue_field_id integer,
  testcombovalue_value text,
  testcombovalue_created_timestamp timestamp without time zone DEFAULT now(),
  testcombovalue_void_timestamp timestamp without time zone,
  primary key (testcombovalue_id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE testcombovalue
  OWNER TO admin;
GRANT ALL ON TABLE testcombovalue TO admin;
-- GRANT ALL ON TABLE testcombovalue TO xtrole;
-- GRANT SELECT ON TABLE testcombovalue TO aeryontrackinguser;
-- GRANT SELECT ON TABLE testcombovalue TO progloader_user;
-- GRANT SELECT ON TABLE testcombovalue TO at_tools;
-- GRANT SELECT ON TABLE testcombovalue TO accountingodbcrole;

COMMENT ON TABLE testcombovalue
  IS '[*New* --mrankin--] Contains the test combobox values allowed';