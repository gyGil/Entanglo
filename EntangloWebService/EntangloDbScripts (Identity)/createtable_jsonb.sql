-- Function: public.createtable(text, text, text, jsonb, jsonb, jsonb, text[], text[], text[], text[], text[], text)

-- DROP FUNCTION public.createtable(text, text, text, jsonb, jsonb, jsonb, text[], text[], text[], text[], text[], text);

CREATE OR REPLACE FUNCTION public.createtable(
    text,
    text,
    text,
    jsonb,
    jsonb,
    jsonb,
    text[],
    text[],
    text[],
    text[],
    text[],
    text)
  RETURNS text AS
$BODY$
  DECLARE

	_schema		   			ALIAS FOR $1;		-- Schema name for table to be created (usersname)
	_tableName				ALIAS FOR $2;		-- Table name to be created
	_tableUuid				ALIAS for $3;		-- Table unique identifier
	_jsonDataString			ALIAS FOR $4;		-- Table attribute information for UI
	_rawDataProfileString		ALIAS for $5;		-- Raw data profile template for data comparison
	_dataProfile				ALIAS FOR $6;		-- Chosen data profile template for acutal data save
	_columnNames			ALIAS FOR $7;		-- Columns names of table
	_columnTypes				ALIAS FOR $8;		-- Column types 
	_columnSizes				ALIAS FOR $9;		-- Column sizes
	_columnConstraints			ALIAS FOR $10;		-- Column constraints
	_columnDefaultValues		ALIAS FOR $11;		-- Default column values
	_userName				ALIAS FOR $12;		-- User name
	
	_tableCreated				boolean := false;	-- Table creation status
	response					text;			-- Table creation response message
	
	_amtColumnNames			integer := 0;		-- Amount of column names
	_amtColumnTypes			integer := 0;		-- Amount of column types
	_amtColumnSizes			integer := 0;		-- Amount of column sizes
	_amtColumnConstraints		integer := 0;		-- Amount of column constraints
	_amtColumnDefaultValues	integer := 0;		-- Amount of column default values

	_user_id					text;			-- User id of user
	_user_access				boolean := false;	-- Requesting users create access rights
	i						integer := 1;		-- Column interval

	_columnString				text := '';		-- Column table creation string
	_tableString				text := '';		-- Table creation string
	_schemaString				text := '';		-- Schema creation string
	_tableCheckString			text := '';		-- Table creation check string

	jsonData					jsonb;		
	rawDataProfile				jsonb;			
	_insertString				text :='';			-- Table data insert string

  begin

	raise exception 'json: %', _jsonDataString;
	-- jsonData := to_jsonb(_jsonDataString);
	
	--raise exception 'to jsonb: %', jsonData;
	
	/* Verify User */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get user id for access rights check */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		if _user_id is null then
			raise exception 'createtable: ERROR CREATING TABLE AS USER "%" DOES NOT EXIST', _userName;
		end if;
	end if;

	/* Check that the requesting user has access to create a table */
	select checkaccess(_userName, 'createtable') into _user_access;
	if _user_access is false then
		raise exception 'createtable: ERROR CREATING TABLE AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "CREATE TABLE"!', _userName;
	end if;

-- 	/* Check that the database for the table exists */
--  	if (select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(_databaseName))) is false then
--  		raise exception 'createtable: ERROR CREATING TABLE AS THE TABLES DATABASE "%" DOES NOT EXIST!', _databaseName;
--  	end if;

 	/* Verify column list is not null */
 	if _columnNames is null then
		raise exception 'createtable: ERROR CREATING TABLE AS COLUMNS ARE NULL';
	end if;


	/* Build schema creation string */
	_schemaString := 'CREATE SCHEMA IF NOT EXISTS "' || _schema || '" AUTHORIZATION "admin_dev"';

	/* Check if schema exists and if not create it */
	begin
	/* Execute the schema creation query */
	execute _schemaString;

	/* Check and catch any errors recieved while trying to create schema */
 	EXCEPTION 
		WHEN others then
 		raise EXCEPTION 'createtable: ERROR CREATING SCHEMA "%"! SQL ERROR MESSAGE: "%", SQL STATE: "%"', 
 				_schema, SQLERRM, SQLSTATE;
	end;


 	/* Get amount of columns */
 	select array_length(_columnNames, 1) into _amtColumnNames;
 	/* Get amount of columns types */
 	IF array_length(_columnTypes, 1) > 0 THEN 
		select array_length(_columnTypes, 1) into _amtColumnTypes;
	end if;
	/* Get amount of columns types */
 	IF array_length(_columnSizes, 1) > 0 THEN 
		select array_length(_columnSizes, 1) into _amtColumnSizes;
	end if;
 	/* Get amount of column default types */
 	IF array_length(_columnConstraints, 1) > 0 THEN
		Select array_length(_columnConstraints, 1) into _amtColumnConstraints;
	end if;
 	/* Get amount of column default values */
 	IF array_length(_columnDefaultValues, 1) > 0 THEN
		select array_length(_columnDefaultValues, 1) into _amtColumnDefaultValues;
	end if;

	_columnString := 'id SERIAL, tableuuid VARCHAR(100) NOT NULL, jsondata JSONB NOT NULL, rawdataprofile JSONB NOT NULL, dataprofile JSONB, ';
	--raise exception 'column string: %', _columnString;
 	/* Loop through column data to create table */
	while i <= _amtColumnNames
	loop	/* Build columns */
		_columnString := _columnString || _columnNames[i] || ' ' || _columnTypes[i] || ' '; 
		if upper(_columnTypes[i]) = 'VARCHAR' THEN
			_columnString := _columnString || '(' || _columnSizes[i] || ') ' || _columnConstraints[i] || ' ';
		else
			_columnString := _columnString || _columnConstraints[i] || ' ';
		end if;

		if _amtColumnDefaultValues > 0 then
			_columnString := _columnString || _columnDefaultValues[i];
		end if;

		_columnString := _columnString || ', ';
		
		i := i + 1;	-- Increment flow sequence iterator
	end loop;

	/* Remove last char ',' from string */
	_columnString := substring(_columnString, 1, length(_columnString) - 2);

	/* Enclose table creation string */
	_tableString := 'CREATE TABLE "' || _schema || '".' || _tableName || '(' || _columnString || ')';

	begin
	/* Execute the table creation query */
	execute _tableString;

	_tableCreated := true;
	
	/* Check and catch any errors recieved while trying to create table */
 	EXCEPTION 
		WHEN others then
 		raise EXCEPTION 'createtable: ERROR CREATING TABLE "%" IN SCHEMA "%"! SQL ERROR MESSAGE: "%", SQL STATE: "%"', 
 				_tableName, _schema, SQLERRM, SQLSTATE;
	end;

	/* Verify creation of table */
	if _tableCreated then
		response := 'createtable: TABLE "' || _tableName || '" FOR SCHEMA "' || _schema || '" WAS CREATED SUCCESSFULLY!';
	else
		raise EXCEPTION 'createtable: ERROR CREATING TABLE AS TABLE "%" WAS NOT FOUND!', _tableName;
	end if;

	jsonData := to_jsonb(_jsonDataString);
	rawDataProfile := to_jsonb(_rawDataProfileString);

 	_insertString := 'INSERT INTO "' || _schema || '".' || _tableName || ' (tableuuid, jsondata, rawdataprofile) VALUES (''' || _tableUuid || ''', ''' || jsonData || ''', ''' || rawDataProfile || ''')';

	/* Check if schema exists and if not create it */
	begin
	/* Execute the schema creation query */
	execute _insertString;

	/* Check and catch any errors recieved while trying to create schema */
 	EXCEPTION 
		WHEN others then
 		raise EXCEPTION 'createtable: ERROR INSERTING DATA INTO TABLE "%"! SQL ERROR MESSAGE: "%", SQL STATE: "%"', 
 				_tableName, SQLERRM, SQLSTATE;
	end;
	
	
	RETURN response;
  end;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.createtable(text, text, text, jsonb, jsonb, jsonb, text[], text[], text[], text[], text[], text)
  OWNER TO ggil;
COMMENT ON FUNCTION public.createtable(text, text, text, jsonb, jsonb, jsonb, text[], text[], text[], text[], text[], text) IS '[*New* --Marcus--] Creates a new table';
