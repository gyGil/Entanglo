-- Function: public.submittestentry(text, text, integer, integer, text, text, text[], boolean)

-- DROP FUNCTION public.submittestentry(text, text, integer, integer, text, text, text[], boolean);

CREATE OR REPLACE FUNCTION public.submittestentry(
    text,
    text,
    integer,
    integer,
    text,
    text,
    text[],
    boolean)
  RETURNS boolean AS
$BODY$
  DECLARE

	  _item_number		ALIAS FOR $1;
	  _serialnumber		ALIAS FOR $2;
	  _test_id		ALIAS FOR $3;
	  _testtype_id		ALIAS for $4;
	  _username 		ALIAS FOR $5;
	  _entry_result		ALIAS FOR $6;
	  _valueArray   	ALIAS for $7;
	  _entry_closed		ALIAS for $8;

	  _valueGroup		text[];		-- Single value group from value array
	  _entry_id		integer;	
	  _part_id		integer;	-- Part ID of part number

	  _totalValues		integer;	-- Total amount of value fields
	  _amtEntries		integer;	-- Total amount of value groups	

	  i			integer := 0;	-- Value group counter
	  j			integer := 1;	-- Value array incrementer

	  _field_id		text;
	  _value		text;
	  _value_result		text;
	  _max_limit		text;
	  _min_limit		text;
	  _part_rev		text;

	  _value_id		integer;
	  _user_id		integer;
	  _testfield_test_id	integer;
	  _flow_check  		boolean := false;
	  _entryClosed	 	boolean := false;
	  _entrySubmitted	boolean := false;
  
  begin

	/* Check flow-check for validity prior to preparing entry submission */
-- 	if (select getflowcheck(_item_number, _serialnumber, _test_id)) is false then
-- 		raise exception 'submittestentry: ERROR SUBMITTING ENTRY FOR PART "%" AS THE PART HAS FAILED FLOW CHECK', _serialnumber;
-- 	end if;
	select current_flowcheck from getflowcheck(_item_number, _serialnumber, _test_id, _testtype_id) into _flow_check;
	if _flow_check is false then
		raise exception 'submittestentry: ERROR SUBMITTING ENTRY FOR PART "%" AS THE PART HAS FAILED FLOW CHECK', _serialnumber;
 	end if;
	
	/* Get the amount of value groups in the entered value array (each value entry has 5 fields) */
	select array_length(_valueArray, 1) into _totalValues;	-- Get total fields
	_amtEntries := _totalValues / 5;			-- Get total groups

	/* Add/Enter new test entry and return the entry id */
	select createtestentry(_item_number, _serialnumber, _test_id, _username, _entry_result) into _entry_id;

	/* Check if new entry creation was successfull */
	IF _entry_id IS NULL THEN
		RAISE EXCEPTION 'submittestentry: ERROR SUBMITTING ENTRY FOR THE FOLLOWING ENTRY ID: %', _entry_id;
	end if;

	/* Get user ID for closing/completing test entry */
	select usr_id from usr where usr_username = _username into _user_id;

	/* Check if user id was found */
	if _user_id is null then
		raise exception 'submittestentry: UNABLE TO FIND USER ID BASED ON USERNAME';
	end if;

	/* Get part ID for entry part sub-assemblies */
	select getpartid(_item_number, _serialnumber) into _part_id;

	/* Check if part number was retrieved successfully */
	IF _serialnumber IS NULL or _serialnumber = '' THEN
		RAISE EXCEPTION 'submittestentry: ERROR SUBMITTING TEST ENTRY AS PART NUMBER IS NULL OR BLANK';
	end if;
	
	/* Get rev for entry part sub-assemblies */
	select part_rev into _part_rev from part where part_id = _part_id;
	
	/* Check if part rev was retrieved successfully */
	IF _part_rev IS NULL or _part_rev = '' THEN
		RAISE EXCEPTION 'submittestentry: ERROR SUBMITTING TEST ENTRY AS PART REV IS NULL OR BLANK';
	end if;
			
	/* Loop through all value group entries */
	while i < _amtEntries
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
			RAISE EXCEPTION 'submittestentry: ERROR SUBMITTING VALUE FOR FIELD ID: %', _field_id;
		end if;

		i := i + 1;	-- increment value entry loop
		j := j + 5;	-- increment to next value group (5)
		
	end Loop;

	/* Add test entry part sub-assemblies to part */
	select addtestentrypart(_item_number, _part_rev, _serialnumber, _entry_id) into _entrySubmitted;

	/* Close test entry if entry submission was successful */
	if _entrySubmitted is true then
		/* Check if entry was set to closed and close it */
		if _entry_closed is true then
			select closetestentry(_entry_id, _user_id) into _entryClosed;
		end if;
	else
		raise exception 'submittestentry: ERROR SUBMITTING TEST ENTRY AS PART SUB-ASSEMBLY ADDITION FOR ENTRY ID "%" WAS UNSUCCESSFUL', _entry_id;
	end if;

	return _entrySubmitted;		-- Return submitted test entry status
  end;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.submittestentry(text, text, integer, integer, text, text, text[], boolean)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.submittestentry(text, text, integer, integer, text, text, text[], boolean) TO ames_admin;
GRANT EXECUTE ON FUNCTION public.submittestentry(text, text, integer, integer, text, text, text[], boolean) TO postgres;
GRANT EXECUTE ON FUNCTION public.submittestentry(text, text, integer, integer, text, text, text[], boolean) TO public;
COMMENT ON FUNCTION public.submittestentry(text, text, integer, integer, text, text, text[], boolean) IS '[*New* --mrankin--] Creates an entry, adds all entry values and closes/completes the entry';
