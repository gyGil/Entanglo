/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		deletetable									#
  #	SUMMARY: 	Deletes a table in a specified database.					#
  #	PARAMETERS:	database name, table name, user name						#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: deletetable(text, text, text)

-- DROP FUNCTION deletetable(text, text, text);

CREATE OR REPLACE FUNCTION deletetable(
    text,
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name of table to be deleted
	_tableName		ALIAS FOR $2;		-- Table name to be deleted
	_userName		ALIAS FOR $3;		-- User name
	
	_tableDeleted		boolean := false;	-- Table deletion status
	response		text;			-- Table creation response message

	_userRole		text;			-- User Role name tag
	_position		int;			-- Last name start position
	_user_id		text;		-- User id of user
	_user_access		boolean := false;	-- Requesting users create access rights

	_drop_table_string	text;			-- Drop table string
	

  begin

	/* Verify User */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get user id for access rights check */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'deletetable: ERROR DELETING TABLE AS USER "%" DOES NOT EXIST', _userName;
		end if;
	end if;

	/* Check that the requesting user has access to delete a table */
	select checkaccess(_userName, 'deletetable') into _user_access;
	if _user_access is false then
		raise exception 'deletetable: ERROR DELETING TABLE AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "CREATE TABLE"!', _userName;
	end if;

	/* Check that the database for the table exists */
 	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_databaseName))) is false then
 		raise exception 'deletetable: ERROR DELETING TABLE AS THE TABLES DATABASE "%" DOES NOT EXIST!', _databaseName;
 	end if;

	/* Create role name from user name */	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN TABLE
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));
	
	/* Check that the table exists and that the user has ownership to delete */
	--if (select usename from pg_class join pg_user on usesysid = relowner where relname = _tableName) = _userRole then
	
		_drop_table_string := 'DROP TABLE ' || _tableName;
		
		execute _drop_table_string;
		
	--else
		--raise exception 'deletetable: ERROR DELETING TABLE AS EITHER THE TABLE "%" DOES NOT EXIST OR USER "%" IS NOT THE OWNER!', _tableName, _userName;
	--end if;


	/* Verify deletion of table */
	if (SELECT _tableName::regclass) is null then
		response := 'deletetable: TABLE "' || _tableName || '" FOR DATABASE "' || _databaseName || '" WAS DELETED SUCCESSFULLY!';
	else
		raise EXCEPTION 'deletetable: ERROR DELETING TABLE AS TABLE "%" STILL EXISTS!', _tableName;
	end if;
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function deletetable(text, text, text)
  owner to ggil;
COMMENT ON function deletetable(text, text, text)
  IS '[*New* --Marcus--] Deletes a table';