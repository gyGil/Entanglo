-- Function: removetestfield(integer)

-- DROP FUNCTION removetestfield(integer);

CREATE OR REPLACE FUNCTION removetestfield(
	integer--,
	--integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	--_test_id 		ALIAS for $1;
	_field_id		ALIAS FOR $1; 

	_field_name		text;			-- For displaying field name in error message
	_fieldVoid		boolean := false;	-- Test field removal status

  begin

	/* Check if test ID is null */
-- 	if _test_id is null then
-- 		raise exception 'removetestfield: ERROR REMOVING TEST FIELD AS TEST ID IS NULL';	
-- 	end if;

	/* Check if field ID is null */
	if _field_id is null then
		raise exception 'removetestfield: ERROR REMOVING TEST FIELD AS FIELD ID IS NULL';
	end if;
	
	/* Check if test ID exists */
-- 	if (select exists(select 1 from testdef where testdef_id = _test_id)) is false then
-- 		raise exception 'removetestfield: ERROR REMOVING TEST FIELD AS TEST ID "%" DOES NOT EXIST', _test_id;
-- 	end if;

	/* Check if field id exists */
	if (select exists(select 1 from testfield where testfield_id = _field_id)) is false then
		raise exception 'removetestfield: ERROR REMOVING TEST FIELD AS FIELD ID "%" DOES NOT EXIST', _field_id;
	end if;

	/* Get the test field name if the test id and field id combo exists */
-- 	select testfield_name from testfield where testfield_id = _field_id into _field_name;

	/* Check that test field is not already voided */
	if (select testfield_void_timestamp from testfield where testfield_id = _field_id) is not null then
		raise exception 'removetestfield: ERROR REMOVING TEST FIELD WITH FIELD ID "%" AS IT HAS ALREADY BEEN VOIDED', _field_id;
	end if;

	/* Remove test field */
	update testfield set testfield_void_timestamp = now()::timestamp without time zone
	where testfield_id = _field_id;

	/* Check if field was void successfully */
	if (select testfield_void_timestamp from testfield where testfield_id = _field_id) is null then
		raise exception 'removetestfield: ERROR REMOVING TEST FIELD "%" WITH TEST FIELD ID "%" AS FIELD VOID TIMESTAMP IS NULL', _field_name, _field_id;
	else
		_fieldVoid := true;	-- Set field void status
	end if;

	return _fieldVoid;		-- Return field void status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function removetestfield(integer)
   owner to postgres;		
 COMMENT ON function removetestfield(integer)
  IS '[*New* --mrankin--] Voids a test field from the specified test';