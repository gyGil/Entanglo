/*#######################################################################################################
  #	TYPE: 		Table Creation									#
  #	NAME:		user										#
  #	SUMMARY: 	Creates the user table which is used for storing all user information		#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Table: json

-- DROP TABLE json

CREATE TABLE json
(
  json_id serial NOT NULL,
  jsondata jsonb not null,
  CONSTRAINT "PK_json" PRIMARY KEY (json_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.json
  OWNER TO mrankin;
comment on table json is '[*New* --Marcus--] Builds a test table for testing json data.';
