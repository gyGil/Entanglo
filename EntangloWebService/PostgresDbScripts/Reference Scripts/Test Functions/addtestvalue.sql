-- Function: addtestvalue(integer, text, text, text, text, text)

-- DROP FUNCTION addtestvalue(integer, text, text, text, text, text);

CREATE OR REPLACE FUNCTION addtestvalue(
	integer,
	text,
	text,
	text,
	text,
	text
	)
  RETURNS integer AS
  $BODY$
  DECLARE

  _entry_id 		ALIAS for $1;
  
  _field_id		ALIAS FOR $2; 
  _value		ALIAS FOR $3; 
  _result		ALIAS FOR $4; 
  _max_limit		ALIAS FOR $5; 
  _min_limit		ALIAS FOR $6;

  _value_id		INTEGER;
  _testentry_test_id	integer;
  _testfield_test_id	integer;

  begin

	/* Check if entry ID is null */
	if _entry_id is null then
		raise exception 'addtestvalue: ERROR UPDATING ENTRY AS THE ENTRY ID IS NULL';
	END IF;

	/* Check if entry ID exists */
	if (select exists(select 1 from testentry where testentry_id = _entry_id)) is false then
		raise exception 'addtestvalue: ERROR UPDATING ENTRY AS THE ENTRY ID DOES NOT EXIST';
	end if;

	/* Check if field ID is null or blank */
	if _field_id is null or _field_id = '' then
		raise exception 'addtestvalue: ERROR UPDATING ENTRY AS THE FIELD ID IS NULL AND/OR BLANK';
	END IF;

	/* Check if field ID exists */
	if (select exists(select 1 from testfield where testfield_id = _field_id::integer)) is false then
		raise exception 'addtestvalue: ERROR UPDATING ENTRY AS THE FIELD ID DOES NOT EXIST';
	end if;

	/* Check if value is null or blank */
	if _value is null or _value = '' then
		raise exception 'addtestvalue: ERROR UPDATING ENTRY AS THE VALUE IS NULL AND/OR BLANK';
	END IF;

	/* Check that field ID of the values are for the proper test ID */
	select testentry_test_id from testentry where testentry_id = _entry_id into _testentry_test_id;
	select testfield_test_id from testfield where testfield_id = _field_id::integer into _testfield_test_id;
	if _testentry_test_id != _testfield_test_id then
		raise exception 'addtestvalue: ERROR ADDING TEST VALUE AS FIELD ID "%" IS NOT PART OF TEST ID "%"', _field_id, _testentry_test_id;
	end if;


	-- Default result and limits to NULL if specified
	IF lower(_result) = 'null' THEN
		_result = null;
	END IF;
	
	IF lower(_max_limit) = 'null' THEN
		_max_limit = null;
	END IF;
	
	IF lower(_min_limit) = 'null' THEN
		_min_limit = null;
	END IF;

	-- Add test value data to test entry
	INSERT INTO testvalue (testvalue_field_id, 
				testvalue_entry_id, 
				testvalue_value, 
				testvalue_result, 
				testvalue_max_limit, 
				testvalue_min_limit)
	VALUES	(CAST(_field_id AS INTEGER), 
				_entry_id, 
				_value, 
				_result, 
				_min_limit, 
				_max_limit)
	RETURNING testvalue_id INTO _value_id;

	-- Check if test value was submitted successfully
	IF _value_id IS NULL THEN
		RAISE EXCEPTION 'addtestvalue: ERROR SUBMITTING VALUE FOR ENTRY ID: %', _entry_id;
	else 
		return _value_id;
	end if;
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function addtestvalue(integer, TEXT, TEXT, TEXT, text, text)
   owner to postgres;		
 COMMENT ON function addtestvalue(integer, TEXT, TEXT, TEXT, text, text)
  IS '[*New* --mrankin--] Adds a test value to an entry and returns the value ID';