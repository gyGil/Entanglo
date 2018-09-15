/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		createcolumn									#
  #	SUMMARY: 	Creates a column in a specified table of a specified database.			#
  #	PARAMETERS:	database name, table name, column name, column type, column size,		#
  #			column constraint, column default value, user name				#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: createcolumn(text, text, text, text, text, text, text, text)

-- DROP FUNCTION createcolumn(text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION createcolumn(
    text,
    text,
    text,
    text,
    text,
    text,
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name of table to be created
	_tableName		ALIAS FOR $2;		-- Table name to be created
	_columnName		ALIAS FOR $3;		-- Column name of table
	_columnType		ALIAS FOR $4;		-- Column type
	_columnSize		ALIAS FOR $5;		-- Column size
	_columnConstraint	ALIAS FOR $6;		-- Column constraint
	_columnDefaultValue	ALIAS FOR $7;		-- Default column value
	_userName		ALIAS FOR $8;		-- User name
	
	_columnCreated		boolean := false;	-- Table creation status
	response		text;			-- Table creation response message

	_user_id		text;		-- User id of user
	_user_access		boolean := false;	-- Requesting users create access rights

	_columnString		text := '';		-- Column table creation string
	

  begin

	/* Verify User */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get user id for access rights check */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'createcolumn: ERROR CREATING COLUMN AS USER "%" DOES NOT EXIST', _userName;
		end if;
	end if;

	/* Check that the requesting user has access to create a column */
	select checkaccess(_userName, 'createcolumn') into _user_access;
	if _user_access is false then
		raise exception 'createcolumn: ERROR CREATING COLUMN AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "CREATE COLUMN"!', _userName;
	end if;

	/* Check that the database for the table exists */
 	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_databaseName))) is false then
 		raise exception 'createcolumn: ERROR CREATING COLUMN AS THE TABLES DATABASE "%" DOES NOT EXIST!', _databaseName;
 	end if;

 	/* Check that the columns table exists */
 	if (SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = _tableName)) is true then
 		raise exception 'createcolumn: ERROR CREATING COLUMN AS THE TABLE "%" DOES NOT EXIST!', _tableName;
 	end if;
 	

 	/* Verify column name is not null or blank */
 	if _columnName is null or _columnName = '' then
		raise exception 'createcolumn: ERROR CREATING COLUMN AS COLUMN NAME IS NULL OR BLANK!';
	end if;

	/* Verify column type is not null or blank */
 	if _columnType is null or _columnType = '' then
		raise exception 'createcolumn: ERROR CREATING COLUMN AS COLUMN TYPE IS NULL OR BLANK!';
	end if;


	/* Build column creation string */
	_columnString := 'ALTER TABLE ' || _tableName || ' ADD COLUMN ' || _columnName || ' ' || _columnType;

	/* Check if column type is of a type that requires a size and verify column size */
	if upper(_columnType) = 'VARCHAR' THEN
		if _columnSize is null or _columnSize = '' then
			raise exception 'createcolumn: ERROR CREATING COLUMN AS COLUMN SIZE IS REQUIRED BUT IS NULL OR BLANK!';
		else	/* Add column size to column creation string if exists */
			_columnString := _columnString || ' (' || _columnSize || ')';
		end if;
	end if;
	
	begin
	/* Execute the column creation query */
	execute _columnString;

	/* Check and catch any errors recieved while trying to create table */
  	EXCEPTION 
 		WHEN others 
 		then raise EXCEPTION 'createcolumn: ERROR CREATING COLUMN "%" FOR TABLE "%"! SQL ERROR MESSAGE: "%", SQL STATE: "%"', 
					_columnName, _tableName, SQLERRM, SQLSTATE;
	end;

	/* Build response message */
 	response := 'createcolumn: COLUMN "' || _columnName || '" FOR TABLE "' || _tableName || '" WAS CREATED SUCCESSFULLY!';
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createcolumn(text, text, text, text, text, text, text, text)
  owner to ggil;
COMMENT ON function createcolumn(text, text, text, text, text, text, text, text)
  IS '[*New* --Marcus--] Creates a new column';