/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		deletecolumn									#
  #	SUMMARY: 	Deletes a column in a specified table of a specified database.			#
  #	PARAMETERS:	database name, table name, column name, user name				#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: deletecolumn(text, text, text, text)

-- DROP FUNCTION deletecolumn(text, text, text, text);

CREATE OR REPLACE FUNCTION deletecolumn(
    text,
    text,
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name of table to be deleted
	_tableName		ALIAS FOR $2;		-- Table name to be deleted
	_columnName		ALIAS FOR $3;		-- Column name of table
	_userName		ALIAS FOR $4;		-- User name
	
	_columnDeleted		boolean := false;	-- Table creation status
	response		text;			-- Table creation response message

	_user_id		text;		-- User id of user
	_user_access		boolean := false;	-- Requesting users create access rights
	_userRole		text;			-- User Role name tag
	_position		int;			-- Last name start position

	_columnString		text := '';		-- Column table creation string
	

  begin

	/* Verify User */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get user id for access rights check */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'deletecolumn: ERROR DELETING COLUMN AS USER "%" DOES NOT EXIST', _userName;
		end if;
	end if;

	/* Check that the requesting user has access to create a column */
	select checkaccess(_userName, 'deletecolumn') into _user_access;
	if _user_access is false then
		raise exception 'deletecolumn: ERROR DELETING COLUMN AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "DELETE COLUMN"!', _userName;
	end if;

	/* Check that the database for the table exists */
 	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_databaseName))) is false then
 		raise exception 'deletecolumn: ERROR DELETING COLUMN AS THE TABLES DATABASE "%" DOES NOT EXIST!', _databaseName;
 	end if;

 	/* Check that the columns table exists */
 	if (SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = _tableName)) is true then
 		raise exception 'deletecolumn: ERROR DELETING COLUMN AS THE TABLE "%" DOES NOT EXIST!', _tableName;
 	end if;
 	
 	/* Verify column name is not null or blank */
 	if _columnName is null or _columnName = '' then
		raise exception 'deletecolumn: ERROR DELETING COLUMN AS COLUMN NAME IS NULL OR BLANK!';
	end if;

	/* Verify column exists before attempting to delete */
	If (select exists(select table_name, column_name from information_schema.columns 
			where lower(table_name) = lower(_tableName) and lower(column_name) = lower(_columnName))) is true then
		
		/* Create role name from user name */	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN TABLE
		_position := position(' ' in _userName) + 1;
		_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

		/* Check that the table exists and that the user has ownership to delete */
		-- if (select exists(select usename from pg_class join pg_user on usesysid = relowner where lower(relname) = lower(_tableName) and lower(usename) = lower(_userRole))) is true then
-- 			
-- 			_columnString := 'ALTER TABLE ' || lower(_tableName) || ' DROP COLUMN ' || _columnName;
-- 
-- 			execute _columnString;
-- 		else
-- 			raise exception 'deletecolumn: ERROR DELETING COLUMN AS USER "%" OF ROLE "%" IS NOT THE TABLE OWNER!', _userName, _userRole;
-- 		end if;
	else
		raise exception 'deletecolumn: ERROR DELETING COLUMN AS COLUMN "%" DOES NOT EXIST!', _columnName;
	end if;

	if (select exists(SELECT column_name FROM information_schema.columns WHERE table_name = _tableName and column_name = _columnName)) is false then
		/* Build response message */
		response := 'deletecolumn: COLUMN "' || _columnName || '" FOR TABLE "' || _tableName || '" WAS DELETED SUCCESSFULLY!';
	else
		raise exception 'deletecolumn: ERROR DELETING COLUMN AS COLUMN "%" STILL EXISTS!', _columnName;
	end if;
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function deletecolumn(text, text, text, text)
  owner to ggil;
COMMENT ON function deletecolumn(text, text, text, text)
  IS '[*New* --Marcus--] Deletes a column';