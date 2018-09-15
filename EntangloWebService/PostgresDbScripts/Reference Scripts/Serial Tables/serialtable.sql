-- Table: serialtable

-- DROP TABLE serialtable;

CREATE TABLE serialtable
(
  serialtable_partkey serial NOT NULL,
  serialtable_partnumber text NOT NULL,
  serialtable_serialnumber text NOT NULL,
  serialtable_transactionid integer DEFAULT 0,
  serialtable_printed boolean DEFAULT false,
  serialtable_workorder integer DEFAULT 0,
  serialtable_activedate date DEFAULT ('now'::text)::date,
  serialtable_expireddate date,
  serialtable_active boolean DEFAULT true,
  serialtable_itemid integer,
  serialtable_parent_partkey integer,
  serialtable_inv_loc_id integer NOT NULL DEFAULT 130,
  serialtable_notes text,
  serialtable_con_id integer,
  serialtable_thirdpartyserial text,
  serialtable_thirdpartyid integer,
  serialtable_genby text,
  serialtable_inv_cust_id integer NOT NULL DEFAULT 0,
  serialtable_show_on_sr boolean,
  serialtable_serial_seq_num text,
  serialtable_workorder_subnumber integer,
  serialtable_allocorder integer DEFAULT 0,
  serialtable_refurb boolean NOT NULL DEFAULT false,
  primary key (serialtable_partkey)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE serialtable
  OWNER TO admin;
GRANT ALL ON TABLE serialtable TO admin;
-- GRANT ALL ON TABLE serialtable TO xtrole;
-- GRANT SELECT ON TABLE serialtable TO aeryontrackinguser;
-- GRANT SELECT ON TABLE serialtable TO progloader_user;
-- GRANT SELECT ON TABLE serialtable TO report;
-- GRANT SELECT ON TABLE serialtable TO at_tools;
-- GRANT SELECT ON TABLE serialtable TO accountingodbcrole;
COMMENT ON TABLE serialtable
  IS '[*New* --mrankin--] Contains the serial numbers of all serialized parts';

-- Index: serialtable_partnumber_index

-- DROP INDEX serialtable_partnumber_index;

CREATE INDEX serialtable_partnumber_index
  ON serialtable
  USING btree
  (serialtable_partnumber COLLATE pg_catalog."default");
