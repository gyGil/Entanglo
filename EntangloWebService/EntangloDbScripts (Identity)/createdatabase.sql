/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		createdatabase									#
  #	SUMMARY: 	Creates a database for a specified user						#
  #	PARAMETERS:	database name, user name							#
  #	RETURNS:	status message	(string)							#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: createdatabase(text, text)

-- DROP FUNCTION createdatabase(text, text);

CREATE OR REPLACE FUNCTION createdatabase(
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name to be created
	_userName		ALIAS FOR $2;		-- User of database to be created
	
	_dbCreated		boolean := false;	-- Database creation status
	response		text;			-- Database creation response message
	_userRole		text;			-- User Role name tag
	_position		int;			-- Last name start position

	_user_id		integer;		-- Requesting users id
	_user_access		boolean := false;	-- Requesting users create access rights
	

  begin
	
	/* Check that the requesting user exists */
	if (select exists(select 1 from "user" where upper("UserName") = upper(_userName))) is true then
		/* Get the user id for checking access rights */
		select "Id" from "user" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'createdatabase: ERROR CREATING DATABASE AS USER "%" DOES NOT EXIST', _userName;
		end if;
	END IF;

	/* Check that the requesting user has access to create another user */
	select checkaccess(_user_id, 'createuser') into _user_access;
	if _user_access is false then
		raise exception 'createdatabase: ERROR CREATING DATABASE AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "CREATE DATABASE"!', _userName;
	end if;
	
	/* Create role name from user name */	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN TABLE
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

	/* Check that database doesn't already exist */
	if Exists (select 1 from pg_database where datname=_databaseName) then
		raise exception 'createdatabase: ERROR CREATING DATABASE AS DATABASE "%" ALREADY EXISTS!', _databaseName;
	else
		--create database _databaseName;
		PERFORM dblink_exec('dbname=' || current_database(), 'CREATE DATABASE ' || quote_ident(_databaseName) || ' OWNER "' || _userRole || '"');
		
		if not exists (select 1 from pg_database where datname=_databaseName) then
			raise exception 'createdatabase: ERROR CREATING DATABASE "%" (DOES NOT EXIST)!', _databaseName;
		else
			--_dbCreated := true;	-- Set test create status
			response := 'createdatabase: DATABASE "' || _databaseName || ' OF USER "' || _userName || '" CREATED SUCCESSFULLY!';
		end if;
	end if;

	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createdatabase(text, text)
  owner to mrankin;
COMMENT ON function createdatabase(text, text)
  IS '[*New* --Marcus--] Creates a new database';