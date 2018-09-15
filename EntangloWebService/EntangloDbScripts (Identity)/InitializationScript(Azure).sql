/*#######################################################################################################
  #	TYPE: 		Initialization Script								#
  #	NAME:		InitializationScript								#
  #	SUMMARY: 	Initializes all roles, users, databases, tables and stored procedures		#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

/* ######################################################################################
   #				ADDITIONAL LIBRARIES 					#
   ###################################################################################### */

  --CREATE EXTENSION dblink;

/* ######################################################################################
   #				ADDITIONAL LIBRARIES 					#
   ###################################################################################### */

--create database _databaseName;
--PERFORM dblink_exec('dbname=' || current_database(), 'CREATE DATABASE ' || quote_ident('Entanglo.Identity') || ' OWNER admin_dev');
--create database Entanglo_Identity;

/* ######################################################################################
   #					ROLES						#
   ###################################################################################### */

	-- Role: admin_dev

	-- DROP ROLE admin_dev;

	-- CREATE ROLE admin_dev LOGIN
	--   SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

	
	-- ROLE: admin_dev

	-- DROP ROLE admin_dev;

	-- CREATE ROLE admin_dev LOGIN
	--   ENCRYPTED PASSWORD 'MD5533CCBA61FB00F504839AC7F3568F7D2'
	--   SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
	-- GRANT ADMIN_DEV TO admin_dev;

	-- ROLE: admin_dev

	-- DROP ROLE GGIL;

	-- CREATE ROLE admin_dev LOGIN
	--   ENCRYPTED PASSWORD 'MD55A5E088F94C26DFE1ADD6FB563EC7B74'
	--   SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
	-- GRANT ADMIN_DEV TO admin_dev;



/* ######################################################################################
   #				HELPER STORED PROCEDURES				#
   ###################################################################################### */

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		checkaccess									#
  #	SUMMARY: 	Checks a users access to perform a certain task (i.e. create, read, update, 	#
  #			delete a user, database, table or column)					#
  #	PARAMETERS:	user id, task									#
  #	RETURNS:	access status (true/false)							#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/


-- Function: checkaccess(text, text)

-- DROP FUNCTION checkaccess(text, text);

CREATE OR REPLACE FUNCTION checkaccess(
    text,
    text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_email   		ALIAS FOR $1;		-- User id
	_task			ALIAS FOR $2;		-- Task to perform

	_position		integer;		-- User last name starting position
	_userRole		text;			-- User role name (first letter of first name and last name)
	_userName		text;			-- User name

	_userHasAccess		boolean := false;	-- Users access to perform a task
	
  begin

	/* Check that the user id is not null */
	if _email is null or _email = '' then
		raise exception 'checkaccess: ERROR CHECKING USERS ACCESS AS EMAIL IS NULL OR BLANK!';
	end if;

	/* Check that the user id exists */
	if (select exists(select 1 from "AspNetUsers" where "Email" = _email)) is false then
		raise exception 'checkaccess: ERROR CHECKING USERS ACCESS AS USER ID "%" DOES NOT EXIST!', _email;
	end if;

	/* Check that the task is not null or blank */
	if _task is null or _task = '' then
		RAISE EXCEPTION 'checkaccess: ERROR CHECKING USERS ACCESS AS TASK IS NULL OR BLANK!';
	end if;




	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN (ROLE) TABLE
	/* Get user name from user id */
	select "UserName" from "AspNetUsers" where "Email" = _email into _userName;
	
	/* Check that user name was retrieved successfully */
	if _userName is null then
		raise exception 'checkaccess: ERROR CHECKING USER ACCESS AS USER NAME OF USER ID "%" WAS NOT FOUND!', _email;
	end if;
	
	/* Create role name from user name */	
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

	/* Check that the user has access to perform task */
	-- Match user Id with task list and return boolean value stating the users accss rights to the specified task
	-- Complete tasks list, roles not created yet
	-- Complete this process later


	

	/* Check that test was created successfully */
	if _task is null or _task = '' then
		_userHasAccess := false;
	else
		_userHasAccess := true;	-- Set user access status
	end if;

	return _userHasAccess;		-- Return user access status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function checkaccess(text, text)
  owner to admin_dev;
COMMENT ON function checkaccess(text, text)
  IS '[*New* --Marcus--] Checks a users access rights';


/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		databaseexists									#
  #	SUMMARY: 	Verifies the existence of a database						#
  #	PARAMETERS:	database name									#
  #	RETURNS:	status (true/false)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: databaseexists(text)

-- DROP FUNCTION databaseexists(text);

CREATE OR REPLACE FUNCTION databaseexists(
    text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Database name to be checked for existence
	
	_dbExists		boolean := false;	-- Database existence status

  begin

	/* Check that the database exists */
	if not Exists (select 1 from pg_database where datname=_databaseName) then
		--raise exception 'databaseexists: DATABASE "%" DOES NOT EXIST', _databaseName;
		_dbExists := false;
	else
		_dbExists := true;	-- Set database exists status
	end if;

	return _dbExists;		-- Return database exists status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function databaseexists(text)
  owner to admin_dev;
COMMENT ON function databaseexists(text)
  IS '[*Entanglo* --Marcus--] Checks if a database exists';


  
  
/* ######################################################################################
   #				CREATE STORED PROCEDURES				#
   ###################################################################################### */

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
  owner to admin_dev;
COMMENT ON function createuser(integer, text, text, text, text, text)
  IS '[*New* --Marcus--] Creates a new user';



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
  owner to admin_dev;
COMMENT ON function createdatabase(text, text)
  IS '[*New* --Marcus--] Creates a new database';



/*#######################################################################################################
  #	TYPE: 		Stored Procedure																									  #
  #	NAME:		createtable																										  #
  #	SUMMARY: 	Creates a table in a specified database with all columns, column types, column													  #
  #			sizes, column constraints and column default values.																			  #
  #	PARAMETERS:	database name, table name, column names, column types, column sizes,														  #
  #			column constraints, column default values, user name																			  #
  #	RETURNS:	status message (string)																								  #
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin																						  #
  #######################################################################################################*/

-- Function: createtable(text, text, text, text, text, text, text[], text[], text[], text[], text[], text)

-- DROP FUNCTION createtable(text, text, text, text, text, text, text[], text[], text[], text[], text[], text);

CREATE OR REPLACE FUNCTION createtable(
    text,
    text,
    text,
    text,
    text,
    text,
    text[],
    text[],
    text[],
    text[],
    text[],
    text
	)
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

	_columnString := 'tableuuid VARCHAR(100) NOT NULL, jsondata JSONB NOT NULL, rawdataprofile JSONB NOT NULL, dataprofile JSONB, ';
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
  language plpgsql volatile
  cost 100;
alter function createtable(text, text, text, text, text, text, text[], text[], text[], text[], text[], text)
  owner to admin_dev;
COMMENT ON function createtable(text, text, text, text, text, text, text[], text[], text[], text[], text[], text)
  IS '[*New* --Marcus--] Creates a new table';



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
  owner to admin_dev;
COMMENT ON function createcolumn(text, text, text, text, text, text, text, text)
  IS '[*New* --Marcus--] Creates a new column';
  
  
  /*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		createprofile									#
  #	SUMMARY: 	Creates a profile to register the pattern for text of image			#
  #	PARAMETERS:	profile name, profile pattern, user to create pattern				#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: createprofile(text, json, text)

-- DROP FUNCTION createprofile(text, json, text);

CREATE OR REPLACE FUNCTION createprofile(
    text,
    json,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_name   	ALIAS FOR $1;		-- Profile Name
	_pattern	ALIAS FOR $2;		-- Pattern for each profile (Format: {EntityType: Val})
	_user		ALIAS FOR $3;		-- Column name of table
	
	response		text;			-- Response message

  begin

 	/* Verify pattern is not null or blank */
 	if _pattern is null then
		raise exception 'createprofile: ERROR CREATING PROFILE AS PROFILE PATTERN IS NULL OR BLANK!';
	end if;

	begin
	/* Execute the column creation query */
	INSERT INTO public.profile ("Name", "Pattern", "User") VALUES (_name,_pattern, _user);

	/* Check and catch any errors recieved while trying to create table */
  	EXCEPTION 
 		WHEN others 
 		then raise EXCEPTION 'createprofile: ERROR CREATING PROFILE "%", "%"', SQLERRM, SQLSTATE;
	end;

	/* Build response message */
 	response := 'createprofile: PROFILE WAS CREATED SUCCESSFULLY!';
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createprofile(text, json, text)
  owner to admin_dev;
COMMENT ON function createprofile(text, json, text)
  IS '[*New* --Marcus--] Creates a new profile';


  /*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		createprofiledata									#
  #	SUMMARY: 	Creates a profile to register the pattern to extract text for profile			#
  #	PARAMETERS:	profile id in profile table, data table name, extraction pattern				#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: createprofiledata(integer, text, json)

-- DROP FUNCTION createprofiledata(integer, text, json);

CREATE OR REPLACE FUNCTION createprofiledata(
    integer,
    text,
    json
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_profileid   	ALIAS FOR $1;		-- Profile id
	_datatablename	ALIAS FOR $2;		-- data table name
	_recipe		ALIAS FOR $3;		-- pattern
	
	response		text;			-- Response message
  begin

 	/* Verify pattern is not null or blank */
 	if _profileid is null then
		raise exception 'createprofiledata: ERROR CREATING PROFILE DATA AS PROFILE EXTRATION PATTERN IS NULL OR BLANK!';
	end if;

	/* Check table is exist already */
	if (SELECT COUNT(*) FROM public.profiledata WHERE "DataTableName" = _datatablename) > 0 then
		DELETE FROM public.profiledata WHERE "DataTableName" = _datatablename;	
	end if;

	begin
		
	/* Execute the column creation query */
	INSERT INTO public.profiledata ("ProfileId", "DataTableName", "Recipe") VALUES (_profileid, _datatablename, _recipe);

	/* Check and catch any errors recieved while trying to create table */
  	EXCEPTION 
 		WHEN others 
 		then raise EXCEPTION 'createprofile: ERROR CREATING PROFILE DATA "%", "%"', SQLERRM, SQLSTATE;
	end;

	/* Build response message */
 	response := 'createprofile: PROFILE DATA WAS CREATED SUCCESSFULLY!';
	
	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createprofiledata(integer, text, json)
  owner to admin_dev;
COMMENT ON function createprofiledata(integer, text, json)
  IS '[*New* --Marcus--] Creates a new profile data';

  /* ######################################################################################
     #				DELETE STORED PROCEDURES				  #
     ###################################################################################### */

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		deleteuser									#
  #	SUMMARY: 	Deletes a specified user.							#
  #	PARAMETERS:	user key, user name, requesting user						#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: deleteuser(text, text)

-- DROP FUNCTION deleteuser(text, text);

CREATE OR REPLACE FUNCTION deleteuser(
    text, 
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	--_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_userName		ALIAS FOR $1;		-- Users name
	_reqUser		ALIAS FOR $2;		-- Requesting User	

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users delete access rights

	_user_id		text;		-- Returned user id after removal
	_user_removed		boolean := false;	-- User deleted status

	_response		text;			-- Response message

  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'deleteuser: ERROR DELETING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'deleteuser: ERROR DELETING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to delete another user */
	select checkaccess(_reqUser, 'deleteuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'deleteuser: ERROR DELETING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "DELETE USER"!', _reqUser;
	end if;
	

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'deleteuser: ERROR DELETING USER AS USER NAME IS NULL OR BLANK';
	end if;

	/* Check if the user key was given and is not null or blank */
	-- if _userKey is null or _userKey = 0 then 
-- 		select "UserKey" from "AspNetUsers" into _userKey where upper("UserName") = upper(_userName);
-- 		if _userKey is null then
-- 			raise exception 'deleteuser ERROR DELETING USER AS THE USER KEY IS NULL!';
-- 		END IF;
-- 	END IF;

	/* Verify that the users unique user name and user key exists */
 	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
		raise exception 'deleteuser: ERROR DELETING USER AS UNIQUE USER NAME "%" DOES NOT EXIST!', _userName;
	end if;


	/* Delete user */
	delete from "AspNetUsers" where upper("UserName") = upper(_userName);
	
	/* Add user removed timestamp */
	--update "AspNetUsers" set "UserRemoved" = now()::timestamp without time zone where upper("UserName") = upper(_userName) and "UserKey" = _userKey and "UserRemoved" is null;

	/* Verify user was deleted successfully */
	--IF (select exists(select "UserRemoved" from "AspNetUsers" where upper("UserName") = upper(_userName) and "UserKey" = _userKey and "UserRemoved" is null)) is true then
	if (select exists(select "UserName" from "AspNetUsers" where "UserName" = _userName)) is true then
		raise exception 'deleteuser: ERROR DELETING USER AS USERNAME STILL EXISTS!';
	else
		_user_removed := true;
		_response := 'deleteuser: USER "' || _userName || '" WAS DELETED SUCCESSFULLY BY REQUESTING USER "' || _reqUser || '"';
	end if;


	return _response;		-- Return user created response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function deleteuser(text, text)
  owner to admin_dev;
COMMENT ON function deleteuser(text, text)
  IS '[*New* --Marcus--] Deletes a user';



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
  owner to admin_dev;
COMMENT ON function deletedatabase(text, text)
  IS '[*New* --Marcus--] Deletes a database';



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
	--if (SELECT to_regclass(_tableName)) is null then
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
  owner to admin_dev;
COMMENT ON function deletetable(text, text, text)
  IS '[*New* --Marcus--] Deletes a table';



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
  owner to admin_dev;
COMMENT ON function deletecolumn(text, text, text, text)
  IS '[*New* --Marcus--] Deletes a column';


/* ######################################################################################
   #				UPDATE STORED PROCEDURES				#
   ###################################################################################### */

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		updateuser									#
  #	SUMMARY: 	Updates a users specified information.						#
  #	PARAMETERS:	user key, user name, user password, user email, user note, requesting user name	#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: updateuser(text, text, text, text)

-- DROP FUNCTION updateuser(text, text, text, text);

CREATE OR REPLACE FUNCTION updateuser( 
    text, 
    text, 
    text, 
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_userName		ALIAS FOR $1;		-- Users name
	_userPhoneNumber	ALIAS for $2;		-- Users password
	_userEmail		ALIAS FOR $3;		-- Users email
	_reqUser		ALIAS FOR $4;		-- Requesting User

	--udUserKey		boolean := false;	-- Update user key status
	udUserName		boolean := false;	-- Update user name status
	udUserPassword		boolean := false;	-- Update user password status
	udUserEmail		boolean := false;	-- Update user email status
	udUserNote		boolean := false;	-- Update user note status

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users update access rights

	_currentDatabase	text;			-- Users current database name
	
	_user_updated		boolean := false;	-- User created status

	_response		text;			-- Response message

  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'updateuser: ERROR UPDATING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'updateuser: ERROR UPDATING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to create another user */
	select checkaccess(_reqUser, 'updateuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'updateuser: ERROR UPDATING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "UPDATE USER"!', _reqUser;
	end if;

	/* Validate User Name before update */
	if _userName != '' then
		if length(_userName) > 100 then
			RAISE EXCEPTION 'updateuser: ERROR UPDATING USER AS USER NAME IS TOO LARGE!';
		else
			udUserName := true;
		end if;
	end if;

	/* Validate User Password before update */
	if _userPhoneNumber != '' then
		if length(_userPhoneNumber) > 12 then
			RAISE EXCEPTION 'updateuser: ERROR UPDATING USER PHONENUMBER AS PHONENUMBER IS TOO LARGE!';
		else
			udUserPassword := true;
		end if;
	end if;

	/* Validate User Email before update */
	if _userEmail != '' then
		if length(_userEmail) > 50 then
			RAISE EXCEPTION 'updateuser: ERROR UPDATING USER EMAIL AS EMAIL IS TOO LARGE!';
		else
			udUserEmail := true;
		end if;
	end if;


	/* Should check that the new password meets password requirement restrictions */
	-- If not implemented in the backend (Web Service)
	-- Possibly double check here
	-- Force #chars, uppercase, lowercase, numbers, special characters, not same as last password, etc...


	select current_database() into _currentDatabase;

	/* Update user */
	UPDATE "AspNetUsers" SET "UserName" = _userName,
			  "PhoneNumber" = _userPhoneNumber,
			  "Email" = _userEmail
		      where "UserName" = _userName;

	/* Check that the user was updated successfully */
	/* Check that the requesting user exists */

	-- if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
-- 		raise exception 'updateuser: ERROR UPDATING USER AS UPDATE WAS NOT FOUND!';
-- 	else
		--update "AspNetUsers" set "UserModified" = now()::timestamp without time zone;
		_user_updated := true;	-- Set user updated status
		_response := 'updateuser: USER "' || _userName || '" WAS UPDATED SUCCESSFULLY IN DATABASE "' || _currentDatabase || '" BY REQUESTING USER "' || _reqUser || '"';
	--end if; 

	return _response;		-- Return user updated response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updateuser(text, text, text, text)
  owner to admin_dev;
COMMENT ON function updateuser(text, text, text, text)
  IS '[*New* --Marcus--] Updates an existing user';



/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		updatedatabase									#
  #	SUMMARY: 	Updates a specified database (renames).						#
  #	PARAMETERS:	database name, new database name, user name					#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: updatedatabase(text, text, text)

-- DROP FUNCTION updatedatabase(text, text, text);

CREATE OR REPLACE FUNCTION updatedatabase(
    text,
    text,
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_databaseName   	ALIAS FOR $1;		-- Current database name
	_newDatabaseName	ALIAS FOR $2;		-- New database name to update to
	_userName		ALIAS FOR $3;		-- User of database to be created
	
	_dbCreated		boolean := false;	-- Database creation status
	response		text;			-- Database creation response message
	_userRole		text;			-- User Role name tag
	_position		int;			-- Last name start position

	_user_id		text;		-- Requesting users id
	_user_access		boolean := false;	-- Requesting users create access rights

	_updateString		text;			-- Database alter string
	_databaseConnString	text;			-- Database connection change string
	_processIdString	text;			-- Database to update process ID string
	_closeConnString	text;			-- Close current database connections string
	_pid			integer;		-- Process ID of database to update
	

  begin

	/* Validate User Name before checking access */
	if _userName is null or _userName = '' or length(_userName) > 50 then
		RAISE EXCEPTION 'updateuser: ERROR UPDATING DATABASE AS USER NAME IS NULL, BLANK OR TOO LARGE!';
	end if;

	/* Validate current Database name before checking access and updating */
	if _databaseName is null or _databaseName = '' or length(_databaseName) > 50 then
		RAISE EXCEPTION 'updateuser: ERROR UPDATING DATABASE AS CURRENT DATABASE NAME IS NULL, BLANK OR TOO LARGE!';
	end if;

	/* Validate new Database name before checking access and updating */
	if _newDatabaseName is null or _newDatabaseName = '' or length(_newDatabaseName) > 50 then
		RAISE EXCEPTION 'updateuser: ERROR UPDATING DATABASE AS NEW DATABASE NAME IS NULL, BLANK OR TOO LARGE!';
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is true then
		/* Get the user id for checking access rights */
		select "Id" from "AspNetUsers" into _user_id where upper("UserName") = upper(_userName);
		
		if _user_id is null then
			raise exception 'updatedatabase: ERROR UPDATING DATABASE AS USER "%" DOES NOT EXIST', _userName;
		end if;
	END IF;
	
	/* Check that the requesting user has access to create another user */
	select checkaccess(_userName, 'updateuser') into _user_access;
	if _user_access is false then
		raise exception 'updatedatabase: ERROR UPDATING DATABASE AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "UPDATE DATABASE"!', _userName;
	end if;
	
	/* Create role name from user name */	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN TABLE
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

	/* Check that the database doesn't already exist */
	if Exists (select 1 from pg_database where lower(datname) = lower(_newDatabaseName)) then
		raise exception 'updatedatabase: ERROR UPDATING DATABASE AS NEW DATABASE NAME "%" ALREADY EXISTS!', _newDatabaseName;
	else
		/* Rename database */
		_updateString := 'ALTER DATABASE "' || _databaseName || '" RENAME TO "' || _newDatabaseName || '"';

		_databaseConnString := 'SELECT dblink_connect(''user=postgres'')';

		_closeConnString := 'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE lower(datname) = (''' || _databaseName || ''')';

		/* Switch Database connection to default database in order to alter current database */
		begin

		execute _databaseConnString;

		exception
			when others then
				raise exception 'updatedatabase: ERROR UPDATING DATABASE "%" AS "%"', _databaseName, SQLERRM;
		end;

		/* Close any and all connection to current database */
		begin

		execute _closeConnString; 


		exception
			when others then
				raise exception 'updatedatabase: ERROR UPDATING DATABASE "%" AS PROC ERROR "%"', _databaseName, SQLERRM;
		end;

		/* Update database */
		begin
		/* Execute the database alter query */
		execute _updateString;

		/* Check and catch any errors recieved while trying to update the database */
		EXCEPTION 
			WHEN others 
			then raise EXCEPTION 'updatedatabase: ERROR UPDATING DATABASE NAME "%" TO "%" AS "%"!', 
						_databaseName, _newDatabaseName, SQLERRM;
		end;

		/* Verify database updated */
		if not exists (select 1 from pg_database where lower(datname) = lower(_newDatabaseName)) then
			raise exception 'updatedatabase: ERROR UPDATING DATABASE "%" TO "%" AS UPDATED NAME DOES NOT EXIST!', _databaseName, _newDatabaseName;
		else
			response := 'updatedatabase: DATABASE "' || _databaseName || ' OF USER "' || _userName || '" UPDATED TO "' || _newDatabaseName || '" SUCCESSFULLY!';
		end if;
	end if;

	RETURN response;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updatedatabase(text, text, text)
  owner to admin_dev;
COMMENT ON function updatedatabase(text, text, text)
  IS '[*New* --Marcus--] Updates an existing database';



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
	--if (SELECT to_regclass(_newTableName)) is null then
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
  owner to admin_dev;
COMMENT ON function updatetable(text, text, text, text)
  IS '[*New* --Marcus--] Updates an existing table';



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
  owner to admin_dev;
COMMENT ON function updatecolumn(text, text, text, text, text)
  IS '[*New* --Marcus--] Updates an existing column';


/* ######################################################################################
   #				READ STORED PROCEDURES					#
   ###################################################################################### */

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getuser										#
  #	SUMMARY: 	Retrieves a specified users information.					#
  #	PARAMETERS:	user name, requesting user name							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getuser(text, text)

-- DROP FUNCTION getuser(text, text);

CREATE OR REPLACE FUNCTION getuser(
    --integer, 
    text, 
    text
	)
  RETURNS json /*(userid integer, userkey integer, username character varying (50), userpassword character varying (50),
		databasename character varying (50), useremail character varying (50), usernote character varying (200),
		usercreated timestamp without time zone, usermodified timestamp without time zone, 
		userremoved timestamp without time zone)*/
	as
  $BODY$
  DECLARE

	--_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_userName		ALIAS FOR $1;		-- Users name
	_reqUser		ALIAS FOR $2;		-- Requesting User	

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getuser: ERROR RETRIEVING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getuser: ERROR RETRIEVING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_reqUser, 'getuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getuser: ERROR RETRIEVING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USER"!', _reqUser;
	end if;

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'getuser: ERROR RETRIEVING USER AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name doesn't exist */
 	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
		raise exception 'getuser: ERROR RETRIEVING USER AS USER NAME "%" DOES NOT EXIST!', _userName;
	end if;

-- 	/* Check if the user key was given and is not null or blank */
-- 	if _userKey is null or _userKey = 0 then 
-- 		raise exception 'getuser ERROR RETRIEVING USER AS THE USER KEY IS NULL!';
-- 	END IF;
-- 
-- 	/* Verify that the users unique user name and user key doesn't already exist */
--  	if (select exists(select 1 from "user" where "UserKey" = _userKey)) is FALSE then
-- 		raise exception 'getuser: ERROR RETRIEVING USER AS UNIQUE USER KEY "%" DOES NOT EXIST!', _userKey;
-- 	end if;

	/* Query User */
	--return QUERY 
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "Id", "Email", "UserName", "PhoneNumber", "NormalizedUserName"
	from "AspNetUsers" WHERE lower("UserName") = lower(_userName)) r;
	--from "AspNetUsers" WHERE lower("UserName") = lower(_userName) and "UserKey" = _userKey;

-- 	return _response;		-- Return user created response message

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getuser(text, text)
  owner to admin_dev;
COMMENT ON function getuser(text, text)
  IS '[*New* --Marcus--] Returns a specified users information';



/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getusers									#
  #	SUMMARY: 	Retrieves all currently active users.						#
  #	PARAMETERS:	requesting user name								#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getusers(text)

-- DROP FUNCTION getusers(text);

CREATE OR REPLACE FUNCTION getusers(
    text
	)
  RETURNS json as
  $BODY$
  DECLARE

	_reqUser		ALIAS FOR $1;		-- Requesting User	

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getusers: ERROR RETRIEVING USERS AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getusers: ERROR RETRIEVING USERS AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_reqUser, 'getusers') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getusers: ERROR RETRIEVING USERS AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USERS"!', _reqUser;
	end if;


	/* Query Users */
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "Id", "Email", "UserName", "PhoneNumber", "NormalizedUserName"
	from "AspNetUsers") r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getusers(text)
  owner to admin_dev;
COMMENT ON function getusers(text)
  IS '[*New* --Marcus--] Returns all current active users information';



  /*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getdatabases									#
  #	SUMMARY: 	Retrieves all databases owned by a specified user.				#
  #	PARAMETERS:	user name, requesting user							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getdatabases(text, text)

-- DROP FUNCTION getdatabases(text, text);

CREATE OR REPLACE FUNCTION getdatabases(
    text, 
    text
	)
  RETURNS json 
	as
  $BODY$
  DECLARE

	_userName		ALIAS FOR $1;		-- Users name
	_reqUser		ALIAS FOR $2;		-- Requesting User	

	_req_user_id		integer;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users read access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "user" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "user" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_req_user_id, 'getdatabases') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USER DATABASES"!', _reqUser;
	end if;

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name exists */
 	if (select exists(select 1 from "user" where upper("UserName") = upper(_userName))) is false then
		raise exception 'getdatabases: ERROR RETRIEVING USERS DATABASES AS USER NAME "%" DOES NOT EXIST!', _userName;
	end if;


	/* Query User */
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "UserName", "DatabaseName"
	from "user" WHERE lower("UserName") = lower(_userName)) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getdatabases(text, text)
  owner to admin_dev;
COMMENT ON function getdatabases(text, text)
  IS '[*New* --Marcus--] Returns a specified users databases';



/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		gettables									#
  #	SUMMARY: 	Retrieves all tables in a specified database.					#
  #	PARAMETERS:	user name, database name, requesting user name					#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: gettables(text, text, text)

-- DROP FUNCTION gettables(text, text, text);

CREATE OR REPLACE FUNCTION gettables(
    text, 
    text,
    text
	)
  RETURNS json 
	as
  $BODY$
  DECLARE

	_userName		ALIAS FOR $1;		-- Users name
	_databaseName		ALIAS for $2;		-- Users database to return tables from
	_reqUser		ALIAS FOR $3;		-- Requesting User

	_userRole		text;			-- User Role name tag
	_position		int;			-- Last name start position

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users read access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'gettables: ERROR RETRIEVING USERS TABLES AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'gettables: ERROR RETRIEVING USERS TABLES AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_reqUser, 'gettables') into _req_user_access;
	if _req_user_access is false then
		raise exception 'gettables: ERROR RETRIEVING USERS TABLES AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USER TABLES"!', _reqUser;
	end if;

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'gettables: ERROR RETRIEVING USERS TABLES AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name exists */
 	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
		raise exception 'gettables: ERROR RETRIEVING USERS TABLES AS USER NAME "%" DOES NOT EXIST!', _userName;
	end if;

	/* Create role name from user name */	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN TABLE
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

	/* Check that the database name is not null or blank */
	if _databaseName is null OR _databaseName = '' then
		raise exception 'gettables: ERROR RETRIEVING USERS TABLES AS THE USERS DATABASE NAME IS NULL OR BLANK';
	end if;

	/* Verify that the database exists */
	if (select Exists(select 1 from pg_database where lower(datname) = lower(_databaseName))) is false then
		raise exception 'deletedatabase: ERROR RETRIEVING DATABASE AS DATABASE "%" DOES NOT EXIST!', _databaseName;
	end if;


	/* Query User */ --Possibly only return table list
	return
	array_to_json(array_agg(row_to_json(r))) from ( select schemaname, tableowner, tablename 
	from pg_catalog.pg_tables where tableowner = _userRole) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function gettables(text, text, text)
  owner to admin_dev;
COMMENT ON function gettables(text, text, text)
  IS '[*New* --Marcus--] Returns a specified users database tables listing';

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getusertables									#
  #	SUMMARY: 	Retrieves all tables in user schema.					#
  #	PARAMETERS:					#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getusertables()

-- DROP FUNCTION getusertables();

CREATE OR REPLACE FUNCTION public.getusertables()
  RETURNS json AS
$BODY$
  DECLARE

  begin
	return
	array_to_json(array_agg(row_to_json(r))) from ( select table_name
	from information_schema.tables WHERE table_schema = 'user') r;

  end;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.getusertables()
  OWNER TO admin_dev;
COMMENT ON FUNCTION public.getusertables() IS '[*New* --Marcus--] Returns a user tables';

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
  owner to admin_dev;
COMMENT ON function getcolumns(text, text, text, text)
  IS '[*New* --Marcus--] Returns a specified users tables columns listing';


/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getwordrecom										#
  #	SUMMARY: 	Retrieves 20 close words for target word					#
  #	PARAMETERS:	targetWord							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getwordrecom(text)

-- DROP FUNCTION getwordrecom(text);

CREATE OR REPLACE FUNCTION getwordrecom(
    --integer, 
    text
	)
  RETURNS json /*(targetword text, closewords text[])*/
	as
  $BODY$
  DECLARE

	--_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_targetWord		ALIAS FOR $1;		-- Target Word

	_quot_target_word   text;       -- quotated target word -- ex. 'word' -> '"word"'
	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights


  begin
	/* Check that the requesting user is not null or blank */
	if _targetWord is null or _targetWord = '' then
		raise exception 'getwordrecom: ERROR RETRIEVING CLOSE WORD LIST AS REQUESTING TARGET WORD "%" IS NULL OR BLANK', _targetWord;
	end if;
	
	/* Check that the requesting targetWord */
	if (select exists(select 1 from "wordrecom" where "TargetWord" = _targetWord)) is false then
		raise exception 'getwordrecom: ERROR RETRIEVING TargetWord AS REQUESTING TargetWord "%" DOES NOT EXIST!', _targetWord;
	end if;
  
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "TargetWord", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20"
	from "wordrecom" WHERE "TargetWord" = _targetWord) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getwordrecom(text)
  owner to admin_dev;
COMMENT ON function getwordrecom(text)
  IS '[*New* --Marcus--] Returns a specified users information';

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getprofile										#
  #	SUMMARY: 	Retrieves all profiles					#
  #	PARAMETERS:	None							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getprofile()

-- DROP FUNCTION getprofile();

CREATE OR REPLACE FUNCTION getprofile(
	)
  RETURNS json /*(targetword text, closewords text[])*/
	as
  $BODY$
  DECLARE
	
  begin
  
	return
	array_to_json(array_agg(row_to_json(r))) from (SELECT "Id", "Pattern" FROM public.profile) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getprofile()
  owner to admin_dev;
COMMENT ON function getprofile()
  IS '[*New* --Marcus--] Returns all profiles';

/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getprofiledata										#
  #	SUMMARY: 	Retrieves data having profile id					#
  #	PARAMETERS:	None							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getprofiledata()

-- DROP FUNCTION getprofiledata();

CREATE OR REPLACE FUNCTION getprofiledata(
	integer
	)
  RETURNS json /*(targetword text, closewords text[])*/
	as
  $BODY$
  DECLARE

	_profileId		ALIAS FOR $1;		-- Target Word
	
  begin
  
	return
	array_to_json(array_agg(row_to_json(r))) from (SELECT "DataTableName", "Recipe" FROM public.profiledata WHERE "ProfileId" = _profileId) r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getprofiledata(integer)
  owner to admin_dev;
COMMENT ON function getprofiledata(integer)
  IS '[*New* --Marcus--] Returns all profiles extraction patters';


/* ######################################################################################
   #					VIEWS						#
   ###################################################################################### */


/* ######################################################################################
   #					TABLE CREATIONS					#
   ###################################################################################### */

/*#######################################################################################################
  #	TYPE: 		Table Creation									#
  #	NAME:		user										#
  #	SUMMARY: 	Creates the user table which is used for storing all user information		#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Table: "user"

-- DROP TABLE "user";

CREATE TABLE "user"
(
  "Id" serial NOT NULL,
  "DatabaseName" text,
  "Email" text,
  "Note" text,
  "UserCreated" timestamp without time zone,
  "UserKey" integer NOT NULL,
  "UserModified" timestamp without time zone,
  "UserName" text,
  "UserPassword" text,
  "UserRemoved" timestamp without time zone,
  CONSTRAINT "PK_user" PRIMARY KEY ("Id")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public."user"
  OWNER TO admin_dev;
comment on table "user" is '[*New* --Marcus--] Builds the "user" table for storing users information and credentials.';


/*#######################################################################################################
  #	TYPE: 		Table Creation									#
  #	NAME:		profile										#
  #	SUMMARY: 	Creates profile table to provide the patterns for classify text in image		#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Table: "profile"

-- DROP TABLE "profile";

CREATE TABLE "profile"
(
  "Id" serial NOT NULL,
  "Name" text,
  "Pattern" json NOT NULL,
  "User" text,
  CONSTRAINT "PK_profile" PRIMARY KEY ("Id")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public."profile"
  OWNER TO admin_dev;
comment on table "profile" is '[*New* --Marcus--] Builds the "profile" table for storing the patterns for classify text in image';


/*#######################################################################################################
  #	TYPE: 		Table Creation									#
  #	NAME:		profiledata										#
  #	SUMMARY: 	Creates profile data table table to have pattern to extract part and store data table name	#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Table: "profiledata"

-- DROP TABLE "profiledata";

CREATE TABLE "profiledata"
(
  "Id" serial NOT NULL,
  "ProfileId" integer NOT NULL,
  "DataTableName" text,
  "Recipe" json,
  CONSTRAINT "PK_profiledata" PRIMARY KEY ("Id")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public."profiledata"
  OWNER TO admin_dev;
comment on table "profiledata" is '[*New* --Marcus--] Builds the "profiledata" table to have pattern to extract part and store data table name';



/* ######################################################################################
   #					READ FILES						#
   ###################################################################################### */
   
  /*#######################################################################################################
  #	TYPE: 		SQLCODE								#
  #	NAME:		parsewordrecom										#
  #	SUMMARY: 	Parse csv file and insert to table 				#
  #             (Note: change the file path for you)	#
  #	PARAMETERS:							#
  #	RETURNS:										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/
  
--COPY public.wordrecom("TargetWord", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20")
--FROM 'C:\Users\ggil4920\Source\Repos\EntangloWebService\EntangloWebService\EntangloDbScripts (Identity)\data\entanglo_word_rec.csv' DELIMITER ',';


/*#######################################################################################################
  #	TYPE: 		ASP.NET Core 2.0 Identity Library Migration Tables				#
  #	NAME:		AspNetCore - Identity Creation Tables						#
  #	SUMMARY: 	Creates all the tables required by the ASP.NET Core Entity Framework Identity	#
  #			Library that is normally automatically created by the Identity library when 	#
  #			using with Microsofts SQL Server however not easily (auto) created when using	#
  #			PostgreSQL server. That is why the auto-generated tables scripts were copied	#
  #			and manual generated for simplifying PostgreSQL migration.			#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/


/* ######################################################################################
   #				REQUIRED IDENTITY TABLES				#
   ###################################################################################### */


-- CREATE TABLE public."AspNetRoles" (
--     "Id" character varying(450) NOT NULL,
--     "ConcurrencyStamp" text,
--     "Name" character varying(256),
--     "NormalizedName" character varying(256),
--     CONSTRAINT pk_identityrole PRIMARY KEY ("Id")
-- );
-- 
-- CREATE TABLE public."AspNetUsers" (
--     "Id" character varying(450) NOT NULL,
--     "AccessFailedCount" integer NOT NULL,
--     "ConcurrencyStamp" text,
--     "Email" character varying(256),
--     "EmailConfirmed" boolean NOT NULL,
--     "LockoutEnabled" boolean NOT NULL,
--     "LockoutEnd" timestamp without time zone,
--     "NormalizedEmail" character varying(256),
--     "NormalizedUserName" character varying(256),
--     "PasswordHash" text,
--     "PhoneNumber" text,
--     "PhoneNumberConfirmed" boolean NOT NULL,
--     "SecurityStamp" text,
--     "TwoFactorEnabled" boolean NOT NULL,
--     "UserName" character varying(256),
--     CONSTRAINT pk_applicationuser PRIMARY KEY ("Id")
-- );
-- 
-- CREATE TABLE public."AspNetRoleClaims" (
--     "Id" serial NOT NULL,
--     "ClaimType" text,
--     "ClaimValue" text,
--     "RoleId" character varying(450),
--     CONSTRAINT pk_identityroleclaim PRIMARY KEY ("Id"),
--     CONSTRAINT fk_identityroleclaim_identityrole_roleid FOREIGN KEY ("RoleId")
--         REFERENCES public."AspNetRoles" ("Id") MATCH SIMPLE
--         ON UPDATE NO ACTION ON DELETE NO ACTION
-- );
-- 
-- CREATE TABLE public."AspNetUserClaims" (
--     "Id" serial NOT NULL,
--     "ClaimType" text,
--     "ClaimValue" text,
--     "UserId" character varying(450),
--     CONSTRAINT pk_identityuserclaim PRIMARY KEY ("Id"),
--     CONSTRAINT fk_identityuserclaim_applicationuser_userid FOREIGN KEY ("UserId")
--         REFERENCES public."AspNetUsers" ("Id") MATCH SIMPLE
--         ON UPDATE NO ACTION ON DELETE NO ACTION
-- );
-- 
-- CREATE TABLE public."AspNetUserLogins" (
--     "LoginProvider" character varying(450) NOT NULL,
--     "ProviderKey" character varying(450) NOT NULL,
--     "ProviderDisplayName" text,
--     "UserId" character varying(450),
--     CONSTRAINT pk_identityuserlogin PRIMARY KEY ("LoginProvider", "ProviderKey"),
--     CONSTRAINT fk_identityuserlogin_applicationuser_userid FOREIGN KEY ("UserId")
--         REFERENCES public."AspNetUsers" ("Id") MATCH SIMPLE
--         ON UPDATE NO ACTION ON DELETE NO ACTION
-- );
-- 
-- CREATE TABLE public."AspNetUserRoles" (
--     "UserId" character varying(450) NOT NULL,
--     "RoleId" character varying(450) NOT NULL,
--     CONSTRAINT pk_identityuserrole PRIMARY KEY ("UserId", "RoleId"),
--     CONSTRAINT fk_identityuserrole_applicationuser_userid FOREIGN KEY ("UserId")
--         REFERENCES public."AspNetUsers" ("Id") MATCH SIMPLE
--         ON UPDATE NO ACTION ON DELETE NO ACTION,
--     CONSTRAINT fk_identityuserrole_identityrole_roleid FOREIGN KEY ("RoleId")
--         REFERENCES public."AspNetRoles" ("Id") MATCH SIMPLE
--         ON UPDATE NO ACTION ON DELETE NO ACTION
-- );