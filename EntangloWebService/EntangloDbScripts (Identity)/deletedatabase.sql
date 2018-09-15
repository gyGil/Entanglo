/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		deletedatabase									#
  #	SUMMARY: 	Deletes a database. 								#
  #	PARAMETERS:	database name, user name							#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: deletedatabase(text, text)

-- DROP FUNCTION deletedatabase(text, text);

CREATE OR REPLACE FUNCTION deletedatabase(
    text, 
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Unique user identifier
	_reqUser		ALIAS FOR $2;		-- Users name

	_req_user_id		integer;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users delete access rights

	--_user_id		integer;		-- Returned user id after removal
	_database_deleted	boolean := false;	-- Database deleted status

	_response		text;			-- Response message

  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'deletedatabase: ERROR DELETING DATABASE AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "user" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "user" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'deletedatabase: ERROR DELETING DATABASE AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to delete a database */
	select checkaccess(_req_user_id, 'deletedatabase') into _req_user_access;
	if _req_user_access is false then
		raise exception 'deletedatabase: ERROR DELETING DATABASE AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "DELETE DATABASE"!', _reqUser;
	end if;
	
	/* Verify that the database exists */
	if (select Exists(select 1 from pg_database where datname=_databaseName)) is false then
		raise exception 'deletedatabase: ERROR DELETING DATABASE AS DATABASE "%" DOES NOT EXIST!', _databaseName;
	end if;

	/* Add database removed timestamp */
	--update "Database" set "DatabaseRemoved" = now()::timestamp without time zone where upper("UserName") = upper(_userName) and "UserKey" = _userKey;
	--create database _databaseName;
	PERFORM dblink_exec('dbname=' || current_database(), 'DROP DATABASE ' || quote_ident(_databaseName)); -- || ' OWNER "' || _userRole || '"');

	/* Verify database was deleted successfully */
	if (select Exists(select 1 from pg_database where datname=_databaseName)) is true then
		raise exception 'deletedatabase: ERROR DELETING DATABASE AS DATABASE "%" STILL EXISTS!', _databaseName;
	else
		_database_deleted := true;
		_response := 'deletedatabase: DATABASE "' || _databaseName || '" WAS DELETED SUCCESSFULLY BY REQUESTING USER "' || _reqUser || '"';
	end if;


	return _response;		-- Return database deleted response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function deletedatabase(text, text)
  owner to postgres;
COMMENT ON function deletedatabase(text, text)
  IS '[*New* --Marcus--] Deletes a database';