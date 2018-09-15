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
  owner to ggil;
COMMENT ON function databaseexists(text)
  IS '[*Entanglo* --Marcus--] Checks if a database exists';