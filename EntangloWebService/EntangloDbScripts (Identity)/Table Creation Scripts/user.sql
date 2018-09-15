/*#######################################################################################################
  #	TYPE: 		Table Creation									#
  #	NAME:		user										#
  #	SUMMARY: 	Creates the user table which is used for storing all user information		#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Table: "user"

-- DROP TABLE "user";

CREATE TABLE "user"
(
  "Id" serial NOT NULL,
  "DatabaseName" text,
  "Email" text,
  "Note" text,
  "UserCreated" timestamp without time zone,
  "UserKey" integer NOT NULL,
  "UserModified" timestamp without time zone,
  "UserName" text,
  "UserPassword" text,
  "UserRemoved" timestamp without time zone,
  CONSTRAINT "PK_user" PRIMARY KEY ("Id")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public."user"
  OWNER TO mrankin;
comment on table "user" is '[*New* --Marcus--] Builds the "user" table for storing users information and credentials.';
