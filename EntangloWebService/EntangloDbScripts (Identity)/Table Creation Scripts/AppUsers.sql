/*#######################################################################################################
  #	TYPE: 		Table Creation									#
  #	NAME:		AppUsers										#
  #	SUMMARY: 	Creates the AppUsers table which is used for storing all user information		#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Table: AppUsers

-- DROP TABLE AppUsers;

CREATE TABLE AppUsers
(
  UserId serial NOT NULL,
  DisplayName text,
  Notes text,
  Type integer,
  Flags integer,
  UserCreated timestamp without time zone,
  UserModified timestamp without time zone,
  UserRemoved timestamp without time zone,
  constraint UserId Primary key (UserId)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.AppUsers
  OWNER TO mrankin;
comment on table AppUsers is '[*New* --Marcus--] Builds the AppUsers table for storing users information and credentials.';
