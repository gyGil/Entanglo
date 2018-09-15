-- Function: voidtestentry(integer)

-- DROP FUNCTION voidtestentry(integer);

CREATE OR REPLACE FUNCTION voidtestentry(
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_entry_id	ALIAS FOR $1;

	_valueVoided	boolean := false;
	_entryVoided 	boolean := false;
	
  begin

  	-- Check if entry exists
	if (select exists(select 1 from testentry where testentry_id = _entry_id)) is false then
		raise exception 'voidtestentry: TEST ENTRY DOES NOT EXIST';
	end if;
	
	-- Check if the test entry has already been voided
	if (select testentry_void_timestamp from testentry where testentry_id = _entry_id) is not null then
		return true;
	end if;

	-- Check if the test values have already been voided
	if (select testvalue_void_timestamp from testvalue where testvalue_entry_id = _entry_id limit 1) is not null then
		_valueVoided := True;
	else
		-- Void values associated with test entry to be voided
		select voidtestvalue(_entry_id) into _valueVoided;
	end if;

	-- Attempt to void test entry if voiding of values was successful
	if (_valueVoided) then
		-- Check if test entry completed timestamp exists
		if (select testentry_complete_timestamp from testentry where testentry_id = _entry_id) is null then
			update testentry set testentry_complete_timestamp = now()::timestamp without time zone
			where testentry_id = _entry_id;
		end if;
		-- If completed timestamp exists submit void timestamp
		if (select testentry_complete_timestamp from testentry where testentry_id = _entry_id) is not null then
			update testentry set testentry_void_timestamp = now()::timestamp without time zone
			where testentry_id = _entry_id;
		else
			raise exception 'voidtestentry: TEST ENTRY COMPLETE TIMESTAMP IS NULL AND UNABLE TO COMPLETE FOR TEST ENTRY ID: %', _entry_id;
		end if;
	else
		raise exception 'voidtestentry: UNABLE TO VOID VALUES ASSOCIATED WITH TEST ENTRY ID: %', _entry_id;
	end if;

	-- Check if entry voided successfully
	if (select testentry_void_timestamp from testentry where testentry_id = _entry_id) is null then
		raise exception 'voidtestentry: ERROR VOIDING TEST ENTRY WITH ENTRY ID: %', _entry_id;
	else
		_entryVoided := true;
	end if;

  return _entryVoided;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function voidtestentry(integer)
  owner to postgres;
COMMENT ON function voidtestentry(integer)
  IS '[*New* --mrankin--] Voids a specified test entry and its values';