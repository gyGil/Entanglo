-- Function: voidtestvalue(integer)

-- DROP FUNCTION voidtestvalue(integer);

CREATE OR REPLACE FUNCTION voidtestvalue(
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_entry_id 	ALIAS for $1;		-- Test entry ID
	
	_valueVoided	boolean := false;	-- Voided test entry result

  begin

-- 	-- Check if entry exists
-- 	if (select exists(select 1 from testentry where testentry_id = _entry_id)) is false then
-- 		raise exception 'voidtestvalue: TEST ENTRY DOES NOT EXIST';
-- 	end if;

	-- Attempt to void value
	update testvalue set testvalue_void_timestamp = now()::timestamp without time zone
	where testvalue_entry_id = _entry_id;

	-- Check if value voided successfully
	IF (select testvalue_void_timestamp from testvalue where testvalue_entry_id = _entry_id limit 1) IS NULL THEN
		RAISE EXCEPTION 'voidtestvalue: ERROR VOIDING VALUE WITH TEST ENTRY ID: %', _entry_id;
	else 
		_valueVoided := true;
	end if;
	
  return _valueVoided;	-- Return value voided status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function voidtestvalue(integer)
   owner to postgres;		
 COMMENT ON function voidtestvalue(integer)
  IS '[*New* --mrankin--] Voids a specified test entry value';