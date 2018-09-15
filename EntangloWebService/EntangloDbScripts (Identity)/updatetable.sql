/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		updatetable									#
  #	SUMMARY: 	Updates a table in a specified database.					#
  #	PARAMETERS:	database name, table name, new table name, user name				#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: updatetable(text, text, text, text)

-- DROP FUNCTION updatetable(text, text, text, text);

CREATE OR REPLACE FUNCTION updatetable(
    text,
    text,
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name of table to be updated
	_tableName		ALIAS FOR $2;		-- Table name to be updated
	_newTableName		ALIAS for $3;		-- New table name to update to
	_userName		ALIAS FOR $4;		-- User name
	
	_tableUpdated		boolean := false;	-- Table updated status
	response		text;			-- Table updated response message
	
	_user_id		text;		-- User id of user
	_user_access		boolean := false;	-- Requesting users update access rights

	_tableString		text := '';		-- Table update string
	

  begin

	/* Verify User */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get user id for access rights check */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'updatetable: ERROR UPDATING TABLE AS USER "%" DOES NOT EXIST', _userName;
		end if;
	end if;
	
	/* Check that the requesting user has access to create a table */
	select checkaccess(_userName, 'updatetable') into _user_access;
	if _user_access is false then
		raise exception 'updatetable: ERROR UPDATING TABLE AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "UPDATE TABLE"!', _userName;
	end if;

	/* Verify database name is not null or blank */
 	if _databaseName is null or _databaseName = '' then
		raise exception 'updatetable: ERROR UPDATING DATABASE AS DATABASE NAME IS NULL OR BLANK!';
	end if;

	/* Verify table name is not null or blank */
 	if _tableName is null or _tableName = '' then
		raise exception 'updatetable: ERROR UPDATING TABLE AS TABLE NAME IS NULL OR BLANK!';
	end if;

	/* Verify new table name is not null or blank */
 	if _newTableName is null or _newTableName = '' then
		raise exception 'updatetable: ERROR UPDATING TABLE AS NEW TABLE NAME IS NULL OR BLANK!';
	else
		/* Verify new table name doesn't already exist in current database */
		if (select exists(select 1 from information_schema.tables where table_name = _newTableName)) is TRUE then
			raise exception 'updatetable: ERROR UPDATING TABLE AS NEW TABLE NAME "%" ALREADY EXISTS!', _newTableName;
		END if;
	end if;
	
	/* Check that the database for the table exists */
 	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_databaseName))) is false then
 		raise exception 'updatetable: ERROR UPDATING TABLE AS THE TABLES DATABASE "%" DOES NOT EXIST!', _databaseName;
 	end if;

	/* Build update table string */
	_tableString := 'ALTER TABLE ' || _tableName || ' RENAME TO ' || _newTableName;

	begin
	/* Execute the table update query */
	execute _tableString;

	/* Check and catch any errors recieved while trying to create table */
 	EXCEPTION 
		WHEN others then
 		raise EXCEPTION 'updatetable: ERROR UPDATING TABLE "%" TO TABLE "%" FOR DATABASE "%" AS: "%"!', 
 				_tableName, _newTableName, _databaseName, SQLERRM;
	end;
	
	/* Verify creation of table */
	if (SELECT _newTableName::regclass) is null then
 		raise EXCEPTION 'updatetable: ERROR UPDATING TABLE AS TABLE "%" WAS NOT FOUND!', _newTableName;
	else
		response := 'updatetable: TABLE "' || _tableName || '" FOR DATABASE "' || _databaseName || '" WAS UPDATED SUCCESSFULLY TO TABLE "' || _newTableName || '"!';
	end if;
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updatetable(text, text, text, text)
  owner to ggil;
COMMENT ON function updatetable(text, text, text, text)
  IS '[*New* --Marcus--] Updates an existing table';