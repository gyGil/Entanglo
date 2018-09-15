/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		updatecolumn									#
  #	SUMMARY: 	Updates a column in a specified table of a specified database.			#
  #	PARAMETERS:	database name, table name, column name, new column name, user name		#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: updatecolumn(text, text, text, text, text)

-- DROP FUNCTION updatecolumn(text, text, text, text, text);

CREATE OR REPLACE FUNCTION updatecolumn(
    text,
    text,
    text,
    text,
--     text,
--     text,
--     text,
--     text, 
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name of table to be updated
	_tableName		ALIAS FOR $2;		-- Table name to be updated
	_columnName		ALIAS FOR $3;		-- Column name of table
	_newColumnName		ALIAS FOR $4;		-- New column name to be updated to
-- 	_dataType		ALIAS FOR $5;		-- Data type of column
-- 	_newDataType		ALIAS FOR $6;		-- New data type of column
-- 	_dataSize		ALIAS FOR $7;		-- Size of column data
-- 	_newDataSize		ALIAS FOR $8;		-- New size of column data
	_userName		ALIAS FOR $5;		-- User name

	_updateColumnName	boolean := false;	-- Column name update status
	_updateDataType		boolean := false;	-- Column data type update status
	_updateDataSize		boolean := false;	-- Column data size update status
	
	_columnCreated		boolean := false;	-- Column update status
	response		text;			-- Column update response message

	_user_id		text;		-- User id of user
	_user_access		boolean := false;	-- Requesting users update access rights

	_columnString		text := '';		-- Column update string
	

  begin

	/* Verify User */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get user id for access rights check */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'updatecolumn: ERROR UPDATING COLUMN AS USER "%" DOES NOT EXIST', _userName;
		end if;
	end if;

	/* Check that the requesting user has access to update a column */
	select checkaccess(_userName, 'updatecolumn') into _user_access;
	if _user_access is false then
		raise exception 'updatecolumn: ERROR UPDATING COLUMN AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "UPDATE COLUMN"!', _userName;
	end if;

	/* Verify the database name of the table of the column is not null or blank */
 	if _databaseName is null or _databaseName = '' then
		raise exception 'updatecolumn: ERROR UPDATING COLUMN AS THE TABLES DATABASE NAME IS NULL OR BLANK!';
	end if;

	/* Check that the database for the table of the column exists */
 	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_databaseName))) is false then
 		raise exception 'updatecolumn: ERROR UPDATING COLUMN AS THE TABLES DATABASE "%" DOES NOT EXIST!', _databaseName;
 	end if;

 	/* Verify the table name of the column is not null or blank */
 	if _tableName is null or _tableName = '' then
		raise exception 'updatecolumn: ERROR UPDATING COLUMN AS THE TABLE NAME IS NULL OR BLANK!';
	end if;

 	/* Check that the columns table exists */
 	if (SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = _tableName)) is false then
 		raise exception 'updatecolumn: ERROR UPDATING COLUMN AS THE TABLE "%" DOES NOT EXIST!', _tableName;
 	end if;
 	
 	
 	/* Verify the column name is not null or blank */
 	if _columnName is NOT null AND _columnName != '' then
		/* Check that the column name exists */
		if (select exists(select column_name from information_schema.columns where table_name = _tableName and column_name = _columnName)) is false then
			raise exception 'updatecolumn: ERROR UPDATING COLUMN AS THE COLUMN "%" DOES NOT EXIST!', _columnName;
		end if;
	ELSE
		RAISE EXCEPTION	'updatecolumn: ERROR UPDATING COLUMN AS THE COLUMN NAME IS NULL OR BLANK!';
	end if;
	

	/* Verify the new column name is not null or blank */
 	if _newColumnName is NOT null AND _newColumnName != '' then
		/* Check that the new column name doesn't already exist */
		if (select exists(select column_name from information_schema.columns where table_name = _tableName and column_name = _newColumnName)) is true then
			raise exception 'updatecolumn: ERROR UPDATING COLUMN AS THE NEW COLUMN NAME "%" ALREADY EXISTS!', _newColumnName;
		end if;

		_updateColumnName := true;
	end if;

	
	/* POSSIBLY REQUIRE THE OPTION TO UPDATE A COLUMNS DATA TYPE OR SIZE HOWEVER THAT MAY REQUIRE A COLUMN
	   DROP AND REBUILD IF DATA ALREADY EXISTS IN THAT COLUMN OR THAT COLUMN HAS ANY CONSTRAINTS           */	
	   
	if _updateColumnName then
		/* Build column update string */
		_columnString := 'ALTER TABLE ' || _tableName || ' RENAME COLUMN ' || _columnName || ' TO ' || _newColumnName;
	else
		raise exception 'updatecolumn: ERROR UPDATING COLUMN AS INSUFFICIENT INFORMATION GIVE TO PERFORM UPDATE!';
	end if;


	begin
	/* Execute the column update query */
	execute _columnString;

	/* Check and catch any errors recieved while trying to create table */
  	EXCEPTION 
 		WHEN others 
 		then raise EXCEPTION 'updatecolumn: ERROR UPDATING COLUMN "%" FOR TABLE "%" FROM DATABASE "%" AS "%"!', 
					_columnName, _tableName, _databaseName, SQLERRM;
	end;

	if _updateColumnName then
		/* Build column name response message */
		response := 'updatecolumn: COLUMN "' || _columnName || '" UPDATED TO COLUMN "' || _newColumnName || '" FOR TABLE "' || _tableName || '" OF DATABASE "' || _databaseName || '" SUCCESSFULLY!';
	else
		/* Build response message */
		response := 'updatecolumn: COLUMN "' || _columnName || '" FOR TABLE "' || _tableName || '" OF DATABASE "' || _databaseName || '" WAS CREATED SUCCESSFULLY!';
	end if;
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updatecolumn(text, text, text, text, text)
  owner to ggil;
COMMENT ON function updatecolumn(text, text, text, text, text)
  IS '[*New* --Marcus--] Updates an existing column';