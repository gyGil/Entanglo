/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		createuser									#
  #	SUMMARY: 	Creates a user with all required user information.				#
  #	PARAMETERS:	user key, user name, user password, user email, user note, requesting user	#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: createuser(integer, text, text, text, text, text)

-- DROP FUNCTION createuser(integer, text, text, text, text, text);

CREATE OR REPLACE FUNCTION createuser(
    integer, 
    text, 
    text, 
    text, 
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_userName		ALIAS FOR $2;		-- Users name
	_userPassword		ALIAS for $3;		-- Users password
	_userEmail		ALIAS FOR $4;		-- Users email
-- 	_userDatabaseName	ALIAS FOR $5;		-- Users database name
	_userNote		ALIAS FOR $5;		-- User note
	_reqUser		ALIAS FOR $6;		-- Requesting User	

	_req_user_id		integer;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights
	_user_created_id	integer;		-- Returned id of created user
	_user_created		boolean := false;	-- User created status

	_currentDatabase	TEXT;			-- Current database
	_response		text;			-- Response message

  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'createuser: ERROR CREATING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "user" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "user" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'createuser: ERROR CREATING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to create another user */
	select checkaccess(_req_user_id, 'createuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'createuser: ERROR CREATING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "CREATE USER"!', _reqUser;
	end if;


-- 	/* Check that the users database name is not null or blank */
-- 	if _userDatabaseName is null OR _userDatabaseName = '' then
-- 		raise exception 'createuser: ERROR CREATING USER AS USERS DATABASE NAME IS NULL OR BLANK';
-- 	end if;
-- 
-- 	/* Check that the users database exists */
-- 	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_userDatabaseName))) is false then
-- 		raise exception 'createuser: ERROR CREATING USER AS USERS DATABASE "%" DOES NOT EXIST!', _userDatabaseName;
-- 	end if;


	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'createuser: ERROR CREATING USER AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name doesn't exist or hasn't been removed previously */
 	if (select exists(select 1 from "user" where upper("UserName") = upper(_userName) and "UserRemoved" is null)) is true then
		raise exception 'createuser: ERROR CREATING USER AS USER NAME "%" ALREADY EXISTS!', _userName;
	end if;

	/* Check if the user key was given and is not null or blank */
	if _userKey is null or _userKey = 0 then 
		raise exception 'createuser ERROR CREATING USER AS THE USER KEY IS NULL!';
	END IF;

	/* Verify that the users unique user name and user key doesn't already exist disregarding removed users */
 	if (select exists(select 1 from "user" where upper("UserName") = upper(_userName) and "UserRemoved" is null 
				or "UserKey" = _userKey and "UserRemoved" is null)) is true then
		raise exception 'createuser: ERROR CREATING USER AS UNIQUE USER NAME "%" AND/OR UNIQUE USER KEY "%" ALREADY EXISTS!', _userName, _userKey;
	end if;

	/* Check that user password is not null or blank */
	if _userPassword is null or _userPassword = '' then
		raise exception 'createuser: ERROR CREATING USER AS USER PASSWORD IS NULL OR BLANK';
	end if;

	/* Should check that the new password meets password requirement restrictions */
	-- If not implemented in the backend (Web Service)
	-- Possibly double check here
	-- Force #chars, uppercase, lowercase, numbers, special characters, not same as last password, etc...

	select current_database() into _currentDatabase;

	/* Create new user */
	insert into "user" ("UserKey", "UserName", "UserPassword", "Email", "Note", "UserCreated")
	values (_userKey, _userName, _userPassword, _userEmail, _userNote, now()::timestamp without time zone)
	returning "Id" into _user_created_id;

	/* Check that test was created successfully */
	if _user_created_id is null then
		raise exception 'createuser: ERROR CREATING USER AS CREATED USERS ID IS NULL';
	else
		_user_created := true;	-- Set user created status
		_response := 'createuser: USER "' || _userName || '" WAS CREATED SUCCESSFULLY IN DATABASE "' || _currentDatabase || '" BY REQUESTING USER "' || _reqUser || '"';
	end if; 

	return _response;		-- Return user created response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createuser(integer, text, text, text, text, text)
  owner to postgres;
COMMENT ON function createuser(integer, text, text, text, text, text)
  IS '[*New* --Marcus--] Creates a new user';