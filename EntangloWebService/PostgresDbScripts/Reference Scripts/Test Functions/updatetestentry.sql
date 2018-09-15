-- Function: updatetestentry(integer, text, text, text[], boolean)

-- DROP FUNCTION updatetestentry(integer, text, text, text[], boolean);

CREATE OR REPLACE FUNCTION updatetestentry(
	integer,
	text,
	text,
	text[],
	boolean)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_entry_id	ALIAS FOR $1;
	_username 	ALIAS FOR $2;
	_entry_result	ALIAS FOR $3;
	_valueArray   	ALIAS for $4;
	_entry_closed	ALIAS FOR $5;	-- Closed Entry status

	_totalValues	integer;	-- Total amount of value fields
	_amtValues	integer;	-- Total amount of value groups	

	i		integer := 0;	-- Value group counter
	j		integer := 1;	-- Value array incrementer

	_item_number	text;		-- Item Number of the Entry
	_serialnumber	text;		-- Serialnumber of the Entry
	_test_id	integer;	-- Test ID of the Entry
	_flow_check  	boolean := false;	-- Flow Check result of current Entry
	_entryClosed	boolean := false;	-- Result of closing entry

	_field_id	text;
	_value		text;
	_value_result	text;
	_max_limit	text;
	_min_limit	text;

	_value_id	integer;
	_user_id	integer;
	_orig_result	text;
	_voidCheck text;
	_entryUpdated 	boolean := false;

	_testtype_id	integer;	-- Test type ID of test entry
  
  begin

  	/* Check if entry ID is valid */
	IF _entry_id IS NULL THEN
		RAISE EXCEPTION 'updatetestentry: ERROR UPDATING ENTRY FOR THE FOLOWING ENTRY ID: %', _entry_id;
	end if;

	/* Check if entry ID exists */
	if (select exists(select 1 from testentry where testentry_id = _entry_id)) is false then
		raise exception 'updatetestentry: ERROR UPDATING ENTRY AS THE ENTRY ID DOES NOT EXIST';
	end if;

	/* Check that the entry is not closed */
	if (select testentry_completed_timestamp from testentry where testentry_id = _entry_id) is not null then
		raise exception 'updatetestentry: ERROR UPDATING ENTRY AS THE ENTRY WITH ID "%" IS ALREADY CLOSED', _entry_id;
	end if;

	/* Get the test type ID */
	select testdef_type_id into _testtype_id from testdef inner join testentry on testdef_id = testentry_test_id where testentry_id = _entry_id;

	/* Get the item number of the entry */
	Select item_number into _item_number from item 
	inner join testentry on item_id = testentry_orig_item_id
	where testentry_id = _entry_id;

	/* Get the serialnumber of the entry */
	Select testentry_orig_serialnumber into _serialnumber from testentry where testentry_id = _entry_id;

	/* Get the test ID of the entry */
	Select testentry_test_id into _test_id from testentry where testentry_id = _entry_id;

	/* Check flow-check for validity prior to preparing entry submission */
	select current_flowcheck from getflowcheck(_item_number, _serialnumber, _test_id, _testtype_id) into _flow_check;
	if _flow_check is false then
		raise exception 'updatetestentry: ERROR UPDATING ENTRY FOR PART "%" AS THE PART HAS FAILED FLOW CHECK', _serialnumber;
 	end if;

	/* Get user ID for closing/completing test entry */
	select usr_id from usr where usr_username = _username into _user_id;

	/* Check if user id was found */
	if _user_id is null then
		raise exception 'updatetestentry: UNABLE TO FIND USER ID BASED ON USERNAME';
	end if;
	
	
	/* Get the amount of value groups in the entered value array (each value entry has 5 fields) */
	select array_length(_valueArray, 1) into _totalValues;	-- Get total fields
	_amtValues := _totalValues / 5;			-- Get total groups

	/* Update entry result if different */
	if ((select upper(testentry_result) from testentry where testentry_id = _entry_id) != upper(_entry_result)) then
		--and upper(testentry_result) = upper(_entry_result)) then
		update testentry set testentry_result = _entry_result where testentry_id = _entry_id;
	end if;

	/* Check if entry update was successful */
	if (select testentry_result from testentry where testentry_id = _entry_id) is null then
		raise exception 'updatetestentry: ERROR UPDATING ENTRY. RESULT IS NULL';
	END IF;

	/* Update values associated with entry if new values exist */
	if (_amtValues <= 0 or _amtValues is null) then
		_entryUpdated := true;
	else
		/* Void current test values */
		PERFORM voidtestvalue(_entry_id);

		/* Check if test values were voided successfully */
		select testvalue_void_timestamp from testvalue where testvalue_entry_id = _entry_id into _voidCheck;
		if (_voidCheck) is not null then
		--if (select testvalue_void_timestamp from testvalue where testvalue_entry_id = _entry_id) is not null then
			/* Loop through all value group entries */
			while i < _amtValues
			loop	/* Copy from value array to field names merely for readability */
				_field_id := 		_valueArray[j];
				_value := 		_valueArray[j+1];
				_value_result :=	_valueArray[j+2];
				_max_limit :=		_valueArray[j+3];
				_min_limit :=		_valueArray[j+4];

				/* Add/Enter new test value and return the value id */
				select addtestvalue(_entry_id, _field_id, _value, _value_result, _max_limit, _min_limit) into _value_id;

				/* Check if new value entry was successful */
				IF _value_id IS NULL THEN
					RAISE EXCEPTION 'submittestentry: ERROR SUBMITTING VALUE FOR ENTRY ID: %', _entry_id;
				end if;

				i := i + 1;	-- increment value entry loop
				j := j + 5;	-- increment to next value group (5)
				
			end Loop;

			_entryUpdated := true;	-- Set status to successful once new values added successfully

		else 
			raise exception 'updatetestentry: ERROR VOIDING PREVIOUS TEST VALUES AND ADDING NEW VALUES FOR ENTRY ID %', _entry_id;
		end if;

		/* Check that new updated test entry was closed on submission/update */
 		if (_entryUpdated) is true then
			/* Check if entry was set to closed and close it */
			if _entry_closed is true then
				select closetestentry(_entry_id, _user_id) into _entryClosed;
				/* Check that the entry was closed successfully */
				if _entryClosed is false then
					raise exception 'updatetestentry: ERROR CLOSING TEST ENTRY FOR ENTRY ID %', _entry_id;
				end if;
			end if;
		end if;
	end if;

	return _entryUpdated;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updatetestentry(integer, text, text, text[], boolean)
  owner to postgres;
COMMENT ON function updatetestentry(integer, text, text, text[], boolean)
  IS '[*New* --mrankin--] Updates an entry and its value data';