-- Table: testentry

-- DROP TABLE testentry;

CREATE TABLE testentry
(
  testentry_id serial NOT NULL,
  testentry_test_id integer,
  testentry_part_id integer,
  testentry_orig_item_id integer not null,
  testentry_orig_rev text not null,
  testentry_orig_serialnumber text,
  testentry_result text,
  testentry_created_user_id integer not null,
  testentry_created_timestamp timestamp without time zone NOT NULL DEFAULT now(),
  testentry_completed_user_id integer,
  testentry_completed_timestamp timestamp without time zone,
  testentry_void_user_id integer,
  testentry_void_timestamp timestamp without time zone,
  testentry_flag_firstpass boolean NOT NULL DEFAULT false,
  testentry_flag_freshproduction boolean NOT NULL DEFAULT false,
  primary key (testentry_id),
  foreign key (testentry_part_id) references part (part_id) match simple on update no action on delete no action,
  foreign key (testentry_test_id) references testdef (testdef_id) match simple on update no action on delete no action
)
WITH (
  OIDS=FALSE
);
ALTER TABLE testentry
  OWNER TO admin;
-- GRANT ALL ON TABLE testentry TO admin;
-- GRANT ALL ON TABLE testentry TO xtrole;
-- GRANT SELECT ON TABLE testentry TO aeryontrackinguser;
-- GRANT SELECT, UPDATE, INSERT ON TABLE testentry TO progloader_user;
-- GRANT SELECT, UPDATE, INSERT ON TABLE testentry TO at_tools;
-- GRANT SELECT ON TABLE testentry TO accountingodbcrole;
COMMENT ON TABLE testentry
  IS '[*New* --mrankin--] Contains all test record entries and related info';