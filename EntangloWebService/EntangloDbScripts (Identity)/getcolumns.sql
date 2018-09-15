/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getcolumns									#
  #	SUMMARY: 	Retrieves all columns in a specified table of a specified database.		#
  #	PARAMETERS:	user name, database name, table name, requesting user name			#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getcolumns(text, text, text, text)

-- DROP FUNCTION getcolumns(text, text, text, text);

CREATE OR REPLACE FUNCTION getcolumns(
    text, 
    text,
    text,
    text
	)
  RETURNS json 
	as
  $BODY$
  DECLARE

	_userName		ALIAS FOR $1;		-- Users name
	_databaseName		ALIAS for $2;		-- Users database of table
	_tableName		ALIAS FOR $3;		-- User table of columns to return
	_reqUser		ALIAS FOR $4;		-- Requesting User

	_userRole		text;			-- User Role name tag
	_position		int;			-- Last name start position

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users read access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_reqUser, 'getcolumns') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USER COLUMNS"!', _reqUser;
	end if;

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name exists */
 	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
		raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS USER NAME "%" DOES NOT EXIST!', _userName;
	end if;

	/* Create role name from user name */	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN TABLE
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

	/* Check that the database name is not null or blank */
	if _databaseName is null OR _databaseName = '' then
		raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS THE USERS DATABASE NAME IS NULL OR BLANK';
	end if;

	/* Verify that the database exists */
	if (select Exists(select 1 from pg_database where lower(datname) = lower(_databaseName))) is false then
		raise exception 'deletedatabase: ERROR RETRIEVING COLUMNS AS DATABASE "%" DOES NOT EXIST!', _databaseName;
	end if;

	/* Check that the table name is not null or blank */
	if _tableName is null OR _tableName = '' then
		raise exception 'getcolumns: ERROR RETRIEVING USERS COLUMNS AS THE USERS TABLE NAME IS NULL OR BLANK';
	end if;

	/* Verify that the table exists within the correct database */
	if (select Exists(select 1 from information_schema.columns where lower(table_catalog) = lower(_databaseName) and table_name = _tableName)) is false then
		raise exception 'deletedatabase: ERROR RETRIEVING COLUMNS AS TABLE "%" DOES NOT EXIST IN DATABASE "%"!', _tableName, _databaseName;
	end if;


	/* Query User */ --Possibly only return column list
	return
	array_to_json(array_agg(row_to_json(r))) from ( select table_catalog, table_name, column_name 
	from information_schema.columns where lower(table_catalog) = _databaseName and table_name = _tableName) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getcolumns(text, text, text, text)
  owner to ggil;
COMMENT ON function getcolumns(text, text, text, text)
  IS '[*New* --Marcus--] Returns a specified users tables columns listing';