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
  owner to ggil;
COMMENT ON function updatedatabase(text, text, text)
  IS '[*New* --Marcus--] Updates an existing database';