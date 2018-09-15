/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getdatabases									#
  #	SUMMARY: 	Retrieves all databases owned by a specified user.				#
  #	PARAMETERS:	user name, requesting user							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getdatabases(text, text)

-- DROP FUNCTION getdatabases(text, text);

CREATE OR REPLACE FUNCTION getdatabases(
    text, 
    text
	)
  RETURNS json 
	as
  $BODY$
  DECLARE

	_userName		ALIAS FOR $1;		-- Users name
	_reqUser		ALIAS FOR $2;		-- Requesting User	

	_req_user_id		integer;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users read access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "user" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "user" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_req_user_id, 'getdatabases') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USER DATABASES"!', _reqUser;
	end if;

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name exists */
 	if (select exists(select 1 from "user" where upper("UserName") = upper(_userName))) is false then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS USER NAME "%" DOES NOT EXIST!', _userName;
	end if;


	/* Query User */
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "UserName", "DatabaseName"
	from "user" WHERE lower("UserName") = lower(_userName)) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getdatabases(text, text)
  owner to postgres;
COMMENT ON function getdatabases(text, text)
  IS '[*New* --Marcus--] Returns a specified users databases';