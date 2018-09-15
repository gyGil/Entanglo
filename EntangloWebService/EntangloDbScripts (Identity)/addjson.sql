/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		addjson										#
  #	SUMMARY: 	Adds JSON data (string) to the json (test/debugging) table.			#
  #	PARAMETERS:	_json_data									#
  #	RETURNS:	status message (json, string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: addjson(jsonb)

-- DROP FUNCTION addjson(jsonb);

CREATE OR REPLACE FUNCTION addjson(
    jsonb
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_json_data   		ALIAS FOR $1;		-- Added JSON data

	_json_id		integer;		-- Returned json table ID

	_json_status		boolean := false;	-- JSON added status

	_currentDatabase	text;			-- Current database
	
	_response		text;			-- Response message

  begin

	/* Check that the data is not null or blank */
	if _json_data is null then
		raise exception 'addjson: ERROR ADDING JSON DATA AS DATA IS NULL OR BLANK';
	end if;

	select current_database() into _currentDatabase;

	/* Create new user */
	insert into json (jsondata)
	values (_json_data)
	returning json_id into _json_id;

	/* Check that test was created successfully */
	if _json_id is null then
		raise exception 'addjson: ERROR ADDING JSON DATA AS ID IS NULL';
	else
		_json_status := true;	-- Set json added status
		_response := 'addjson: JSON data was added successfully to database: ' || _currentDatabase || ' table: json. JSON MSG: ' || _json_data;
	end if; 

	return _response;		-- Return json added response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function addjson(jsonb)
  owner to postgres;
COMMENT ON function addjson(jsonb)
  IS '[*New* --Marcus--] Adds JSON data for testing/debugging';