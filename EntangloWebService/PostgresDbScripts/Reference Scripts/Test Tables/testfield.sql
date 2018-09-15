-- Table: testfield

-- DROP TABLE testfield;

CREATE TABLE testfield
(
  testfield_id serial NOT NULL,
  testfield_test_id integer,
  testfield_name text NOT NULL,
  testfield_description text not null,
  testfield_datatype_id integer not null,
  testfield_required boolean NOT NULL DEFAULT false,
  testfield_position integer NOT NULL DEFAULT 1,
  testfield_created_timestamp timestamp without time zone NOT NULL DEFAULT now(),
  testfield_modified_timestamp timestamp without time zone,
  testfield_void_timestamp timestamp without time zone,
  testfield_min_limit text,
  testfield_max_limit text,
  testfield_uom text,
  testfield_result_required boolean DEFAULT false,
  testfield_defaultvalue text,
  testfield_comborestricted boolean DEFAULT false,
  testfield_readonly boolean DEFAULT false,
  primary key (testfield_id),
  foreign key (testfield_test_id) references testdef (testdef_id) match simple on update no action on delete no action
--   CONSTRAINT testfield_type_id_fkey FOREIGN KEY (type_id)
--       REFERENCES aeryon_t_field_types (id) MATCH SIMPLE
--       ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE testfield
  OWNER TO admin;
 GRANT ALL ON TABLE testfield TO admin;
-- GRANT ALL ON TABLE testfield TO xtrole;
-- GRANT SELECT ON TABLE testfield TO aeryontrackinguser;
-- GRANT SELECT ON TABLE testfield TO progloader_user;
-- GRANT SELECT ON TABLE testfield TO at_tools;
-- GRANT SELECT ON TABLE testfield TO accountingodbcrole;
COMMENT ON TABLE testfield
  IS '[*New* --mrankin--] Contains all the individual tests within each entry and links the test values to the entry';
  