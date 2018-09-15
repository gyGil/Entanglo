-- Table: testentrypart

-- DROP TABLE testentrypart;

CREATE TABLE testentrypart
(
  testentrypart_id serial NOT NULL,
  testentrypart_entry_id integer not null,
  testentrypart_part_id integer,
  testentrypart_orig_item_id integer not null,
  testentrypart_orig_rev text not null,
  testentrypart_orig_partnumber text,
  testentrypart_created_timestamp timestamp without time zone NOT NULL DEFAULT now(),
  testentrypart_void_timestamp timestamp without time zone,
  primary key (testentrypart_id),
  foreign key (testentrypart_part_id) references part (part_id) match simple on update no action on delete no action
)
WITH (
  OIDS=FALSE
);
ALTER TABLE testentrypart
  OWNER TO admin;
GRANT ALL ON TABLE testentrypart TO admin;
COMMENT ON TABLE testentrypart
  IS '[*New* --mrankin--] Contains the test entry part ID for associating all parts with the test entry';