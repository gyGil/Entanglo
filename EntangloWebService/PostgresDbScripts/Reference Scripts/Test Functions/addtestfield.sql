-- Function: addtestfield(integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean)

-- DROP FUNCTION addtestfield(integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean);

CREATE OR REPLACE FUNCTION addtestfield(
	integer,
	text,
	text,
	integer,
	boolean,
	integer,
	text,
	text,
	text,
	boolean,
	text,
	boolean,
	boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_test_id 		ALIAS for $1;
	_field_name		ALIAS FOR $2; 
	_field_description	ALIAS for $3;
	_datatype		ALIAS FOR $4;
	_required		ALIAS FOR $5; 
	_position		ALIAS FOR $6; 
	_min_limit		ALIAS FOR $7; 
	_max_limit		ALIAS FOR $8;
	_unit_of_measure	ALIAS FOR $9;
	_result_required	ALIAS FOR $10;
	_defaultvalue		ALIAS for $11;
	_comborestricted	ALIAS FOR $12;
	_readonly		ALIAS FOR $13;

	_testdef_name		text;			-- For displaying test name in error message
	_testfield_id		INTEGER;		-- For checking if test field creation was successful
	_previous_datatype	integer;		-- For comparing datatypes between voided and new fields
	_fieldAdded		boolean := false;	-- Test field creation status

  begin

	/* Check if test ID exists */
	if (select exists(select 1 from testdef where testdef_id = _test_id)) is false then
		raise exception 'addtestfield: ERROR ADDING TEST FIELD AS TEST ID "%" DOES NOT EXIST', _test_id;
	end if;

	/* Check that the field name isn't blank or null */
	if _field_name is null or _field_name = '' then
		raise exception 'addtestfield: ERROR ADDING TEST FIELD AS THE FIELD NAME IS NULL OR BLANK';
	end if;

	/* Check that the field description isn't blank or null */
	if _field_description is null or _field_description = '' then
		raise exception 'addtestfield: ERROR ADDING TEST FIELD AS THE FIELD DESCRIPTION IS NULL OR BLANK';
	end if;

	/* Check if data type exists */
	if (select exists (select 1 from datatype where datatype_id = _datatype)) is false then
		raise exception 'addtestfield: ERROR ADDING TEST FIELD AS DATA TYPE ID "%" DOES NOT EXIST', _datatype;
	end if; 

	/* Check if field name already exists and is part of the same test (prevent from adding the same field name to the same test) */
	if (select exists(select 1 from testfield where upper(testfield_name) = upper(_field_name) and testfield_test_id = _test_id)) is true then
		/* Get test field ID */
		select testfield_id from testfield where upper(testfield_name) = upper(_field_name) and testfield_test_id = _test_id into _testfield_id;
		/* Check if existing field has been voided */
		if (select testfield_void_timestamp from testfield where testfield_id = _testfield_id) is null then
			raise exception 'addtestfield: ERROR ADDING TEST FIELD AS FIELD "%" ALREADY EXISTS', _field_name;
		else
			/* Remove voided field if test id and field id are the same (instead of creating a new one) */
			update testfield set testfield_void_timestamp = null where testfield_id = _testfield_id;
			/* Check that the fields void was removed successfully */
			if (select testfield_void_timestamp from testfield where testfield_id = _testfield_id) is not null then
				raise exception 'addtestfield: ERROR ADDING TEST FIELD AS UNABLE TO REMOVE TEST FIELD VOID TIMESTAMP OF FIELD ID "%"', _testfield_id;
			end if;

			/* Update test field after void is removed */
			Select updatetestfield (_test_id,
						_testfield_id,
						_field_name,
						_field_description,
						_datatype,
						_required,
						_position,
						_min_limit,
						_max_limit,
						_unit_of_measure,
						_result_required,
						_defaultvalue,
						_comborestricted,
						_readonly);
			if not FOUND then 
				raise exception 'addtestfield: ERROR ADDING TEST FIELD AS UPDATE OF FIELD "%" AFTER VOID REMOVED WAS UNSUCCESSFUL', _field_name;
			else
				_fieldAdded := true;
			end if;
		end if;
	else
		/* Get test name from test ID */
		select testdef_name from testdef where testdef_id = _test_id into _testdef_name;
		/* Add test field data to testfield table */
		insert into testfield (testfield_test_id,
					testfield_name,
					testfield_description,
					testfield_datatype_id,
					testfield_required,
					testfield_position,
					testfield_created_timestamp,
					testfield_min_limit,
					testfield_max_limit,
					testfield_uom,
					testfield_result_required,
					testfield_defaultvalue,
					testfield_comborestricted,
					testfield_readonly)
		values 			(_test_id,
					  _field_name,
					  _field_description,
					  _datatype,
					  _required,
					  _position,
					  now()::timestamp without time zone,
					  _min_limit,
					  _max_limit,
					  _unit_of_measure,
					  _result_required,
					  _defaultvalue,
					  _comborestricted,
					  _readonly)
		returning testfield_id into _testfield_id;

		/* Check if test field was submitted successfully */
		if _testfield_id is null then
			raise exception 'addtestfield: ERROR SUBMITTING "%" FIELD FOR "%" TEST', _field_name, _testdef_name;
		else
			_fieldAdded := true;	-- Set test field creation status
		end if;
	end if;

	return _fieldAdded;		-- Return field creation status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function addtestfield(integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean)
   owner to postgres;		
 COMMENT ON function addtestfield(integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean)
  IS '[*New* --mrankin--] Adds a test field to a specified test';