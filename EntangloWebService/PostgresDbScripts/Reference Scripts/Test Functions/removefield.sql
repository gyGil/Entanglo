-- Function: removefield(integer, integer)

-- DROP FUNCTION removefield(integer, integer);

CREATE OR REPLACE FUNCTION removefield(
	integer,
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_test_id 		ALIAS for $1;
	_field_id		ALIAS FOR $2; 

	_field_name		text;			-- For displaying field name in error message
	_fieldRemoved		boolean := false;	-- Test field removal status

  begin

	/* Check if test ID exists */
	if (select exists(select 1 from testdef where testdef_id = _test_id)) is false then
		raise exception 'removetfield: ERROR REMOVING TEST FIELD AS TEST ID "%" DOES NOT EXIST', _test_id;
	end if;

	/* Check if field id exists */
	if (select exists(select 1 from testfield where testfield_id = _field_id)) is false then
		raise exception 'removefield: ERROR REMOVING TEST FIELD AS FIELD ID "%" DOES NOT EXIST', _field_id;
	end if;

	/* Get the test field name */
	select testfield_name from testfield where testfield_id = _field_id into _field_name;

	/* Remove test field */
	update testfield set testfield_removed = now()::timestamp without time zone
	where testfield_id = _field_id;

	/* Check if field was removed successfully */
	if (select testfield_removed from testfield where testfield_id = _field_id) is null then
		raise exception 'removefield: ERROR REMOVING TEST FIELD "%" WITH TEST FIELD ID "%" AS FIELD REMOVED TIMESTAMP IS NULL', _field_name, _field_id;
	else
		_fieldRemoved := true;	-- Set field removed status
	end if;

	return _fieldRemoved;		-- Return field removed status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function removefield(integer, integer)
   owner to postgres;		
 COMMENT ON function removefield(integer, integer)
  IS '[*New* --mrankin--] Removes a test field from the specified test';