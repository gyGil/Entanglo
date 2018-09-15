-- Function: public.getflowcheck(text, text, integer, integer)

-- DROP FUNCTION public.getflowcheck(text, text, integer, integer);

CREATE OR REPLACE FUNCTION public.getflowcheck(
    IN text,
    IN text,
    IN integer,
    in integer)
  RETURNS TABLE(current_flowcheck boolean, current_station text, last_passed_station text, target_station text) AS
$BODY$
  DECLARE

	_item_number			ALIAS FOR $1;		-- Item number of part
	_serialnumber	  		ALIAS FOR $2;		-- Serial number of part
	_current_test_id		ALIAS for $3;		-- Current test ID (station) that part is at
	_testtype_id			ALIAS for $4;		-- Current test type ID that the part is at

	_item_id			integer;		-- Item ID of item number
	_item_flow_id			integer;		-- Flow item ID
	_part_id			integer;		-- Part ID
	_seq_id				integer;		-- Sequence ID
	_recent_entry_id		integer;		-- The most recent entry ID
	_recent_test_id			integer;		-- The most recent test ID
	_current_test_index		integer;		-- The flow sequence index of the current test
	_recent_test_index		integer;		-- The flow sequence index of the most recent test
	_first_test_index		integer := 1;		-- The flow sequence index of the first test 
	_last_test_index		integer;		-- The flow sequence index of the last test
	_flowcheck			boolean := false;	-- Flowcheck status

	_recent_passed_test_id 		integer;		-- Most recent 'Pass' test ID
	_recent_failed_test_id		integer;		-- Most recent 'Fail' test ID
	_recent_passed_test_index	integer;		-- Most recent passed test flow sequence index
	_recent_failed_test_index	integer;		-- Most recent failed test flow sequence index
	_target_test_id			integer := 0;		-- Target test station ID


  begin

	/* Check if item number is valid */
	if _item_number is null or _item_number = '' then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS ITEM NUMBER IS NULL OR BLANK';
	end if;

	/* Check if the item number exists or is active */
	if (select exists(select item_id from item where upper(item_number) = upper(_item_number)
				AND item_active is true)) is false then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS ITEM NUMBER "%" DOES NOT EXIST OR IS NOT ACTIVE', _item_number;
	end if;

	/* Get the item ID */
	select item_id from item where upper(item_number) = upper(_item_number) into _item_id;

	/* Check if item ID was retrieved successfully */
	if _item_id is null then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS ITEM ID IS NULL';
	end if;

	/* Check if part number is valid */
	if _serialnumber is null or _serialnumber = '' then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS PART NUMBER IS NULL OR BLANK';
	end if;

	-- Get part ID for entry
	select getpartid(_item_number, _serialnumber) into _part_id;

	/* Check if part ID is null */
	if _part_id is null then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS PART ID IS NULL';
	end if;

	/* Check if the part number exists or is not voided */
	if (select exists(select part_id from part where part_active is true)) is false then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS PART ID "%" DOES NOT EXIST OR IS NOT ACTIVE', _part_id;
	end if;

	/* Check if the current test ID is valid */
	if _current_test_id is null then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS CURRENT TEST ID IS NULL';
	end if;

	/* Check if the current test id exists or is not voided */
	if (select exists(select testdef_id from testdef where testdef_id = _current_test_id
				AND testdef_void_timestamp is null)) is false then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS TEST ID "%" DOES NOT EXIST OR IS VOIDED', _current_test_id;
	end if;

	/* Check if the current test type ID is valid */
	if _testtype_id is null then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS CURRENT TEST TYPE ID IS NULL';
	end if;

	/* Check if the current test type id exists or is not voided */
	if (select exists(select testtype_id from testtype where testtype_id = _testtype_id
				AND testtype_void_timestamp is null)) is false then
		raise exception 'getflowcheck: ERROR CHECKING FLOW AS TEST TYPE ID "%" DOES NOT EXIST OR IS VOIDED', _testtype_id;
	end if;

	/* Get item flow ID if a flow exists for the item ID */
	select testflowitem_flow_id from testflowitem where testflowitem_item_id = _item_id and testflowitem_type_id = _testtype_id into _item_flow_id;
	/* Check that the item flow ID was retrieved successfully */
 	if _item_flow_id is null then
		/* If NO flow exists, allow flowcheck to pass in order to submit entry */
		/* Get current test stations name */
		select testdef_name into current_station from testdef where testdef_id = _current_test_id;
		last_passed_station := '';
		target_station := '';		
	else	/* Continue Flow Check if flow exists */

		/* #################### GET ALL SEQUENCE ID'S AND INDEXES ###################### */
		
		/* Get default sequence ID if a sequence exists for the item */
		select testflowseq_id from testflowseq where testflowseq_flow_id = _item_flow_id and testflowseq_default is true
			into _seq_id;
		if _seq_id is null then
			raise exception 'getflowcheck: ERROR CHECKING FLOW AS ITEM NUMBER "%" DOES NOT HAVE A SEQUENCE	', _item_number;
		end if;

		/* Get the most recent entry ID of the part of the specific test type if it exists */
		select testentry_id from testentry te1 
		where testentry_part_id = _part_id 
		and testentry_created_timestamp = (select MAX(testentry_created_timestamp) 
						   from testentry te2 
						   inner join testdef on testentry_test_id = testdef_id 
						   where te2.testentry_part_id = _part_id
						   and testdef_type_id = _testtype_id)
		into _recent_entry_id;
	 	if _recent_entry_id is null then
	 		raise exception 'getflowcheck: ERROR CHECKING FLOW AS PART NUMBER "%" DOES NOT HAVE A TEST ENTRY', _serialnumber;		
	 	end if;

		/* Check if a recent entry id exists */
		if _recent_entry_id is not null then
			/* Get the most recent test ID of the part if it exists */
			select testentry_test_id from testentry where testentry_id = _recent_entry_id into _recent_test_id;
			/* Check if the recent test id was retrieved successfully */
			if _recent_test_id is null then
				raise exception 'getflowcheck: ERROR CHECKING FLOW AS PART NUMBER "%" DOES NOT HAVE A TEST ID', _serialnumber;
			end if;
		else	/* Set recent entry/test id to the same as the current entry/test id as this is the first entry */
			_recent_test_id := _current_test_id;
			select testentry_id from testentry into _recent_entry_id where testentry_test_id = _recent_test_id;
		end if;

		/* Get most recent test ID flow sequence index */
		select idx(testflowseq_test_seq, _recent_test_id) from testflowseq where testflowseq_id = _seq_id into _recent_test_index;
		/* Check if most recent test ID exists in flow sequence */
		if _recent_test_index = 0 then
			/* Recent test entry is not of same sequence and/or test type */
			Select (select testflowseq_test_seq[1] from testflowseq where testflowseq_id = _seq_id) into _recent_test_id;
			/* Because the last test entry was from a different flow set last passed test ID to the recent test ID */
			_recent_passed_test_id := 0;--_recent_test_id;
			/* Get most recent test ID flow sequence index */
			select idx(testflowseq_test_seq, _recent_test_id) from testflowseq where testflowseq_id = _seq_id into _recent_test_index;
			/* Check if most recent test ID exists in flow sequence */
			if _recent_test_index = 0 then
				raise exception 'getflowcheck: ERROR CHECKING FLOW AS MOST RECENT TEST ID "%" DOES NOT EXIST IN CURRENT FLOW SEQUENCE "%"', _recent_test_id, _seq_id;
			end if;
		end if;
		
		/* Get current test ID flow sequence index */
		select idx(testflowseq_test_seq, _current_test_id) from testflowseq where testflowseq_id = _seq_id into _current_test_index;
		/* Check if current test ID exists in flow sequence */
		if _current_test_index = 0 then
			raise exception 'getflowcheck: ERROR CHECKING FLOW AS CURRENT TEST ID "%" DOES NOT EXIST IN CURRENT FLOW SEQUENCE "%"', _current_test_id, _seq_id;
		end if;

		/* Get the last test ID flow sequence index */
		select array_length(testflowseq_test_seq, 1) from testflowseq where testflowseq_id = _seq_id into _last_test_index;
		
		/* #################### SET FLOWCHECK RULES AND CHECK FLOW ###################### */

		/* Check if current test is a valid flow sequence and if the most recent test has passed */
		if (select exists(select testentry_result from testentry where testentry_id = _recent_entry_id and upper(testentry_result) = 'PASS')) is true then
		/* Most recent test entry is a PASS: Only first test and next test in sequence is valid */
			/* Check if current test ID is a valid next flow sequence */
			if _current_test_index = _first_test_index then
				_flowcheck := true;	-- First test in sequence
			elsif _current_test_index = (_recent_test_index + 1) then
				_flowcheck := true;	-- Next test in sequence
			else
				_flowcheck := false;	-- All others
			end if;
		else /* Most recent test entry is a FAIL: Only first test and recent test in sequence is valid */
			if _current_test_index = _recent_test_index then
				_flowcheck := true;	-- Recent test in sequence
			elsif _current_test_index = _first_test_index then
				_flowcheck := true;	-- First test in sequence
			else
				_flowcheck := false;	-- All others
			end if;
		end if;
		/* #################### BUILD FLOWCHECK RETURN TABLE ###################### */
		
		/* Get current test stations flowcheck status */
		current_flowcheck := _flowcheck;
		
		/* Get current test stations name */
		select testdef_name into current_station from testdef where testdef_id = _current_test_id;

		/* Zero indicates start of different flow sequence/test type */
		if _recent_passed_test_id = 0 then
			/* Set to null */
			_recent_passed_test_id := null;
		else
			/* Get the most recent test entry if it is a PASS */
			if upper(testentry_result) = 'PASS' from testentry where testentry_id = _recent_entry_id then
				last_passed_station := (Select testdef_name from testdef where testdef_id = _recent_test_id);
			else	/* Set the last passed station to the prior test as the recent on was a fail */
				select testflowseq_test_seq[_recent_test_index - 1] into _recent_passed_test_id from testflowseq where testflowseq_id = _seq_id;
				last_passed_station := (select testdef_name from testdef where testdef_id = _recent_passed_test_id);
			end if;
		end if;
		

		/* Check if a passed test exists and set to NULL if not */
		if _recent_passed_test_id is null then
			last_passed_station := null;
		else
			/* Get the last passed station name from the recent passed test id */
			select testdef_name into last_passed_station from testdef where testdef_id = _recent_passed_test_id;
		end if;
		
		/* Get the station name of the next test station in the flow sequence */
		if last_passed_station is null then
			/* Get the test ID of the first test station in the flow sequence as there is no passes yet */
			select testflowseq_test_seq[1] into _target_test_id from testflowseq where testflowseq_id = _seq_id;
			/* Get the target test station name */
			select testdef_name into target_station from testdef where testdef_id = _target_test_id;
		else
			/* Get most recent test ID flow sequence index */
			select idx(testflowseq_test_seq, _recent_passed_test_id) from testflowseq where testflowseq_id = _seq_id into _recent_passed_test_index;
			/* Get the test ID of the next test in the flow sequence */
			select testflowseq_test_seq[_recent_passed_test_index + 1] from testflowseq where testflowseq_id = _seq_id into _target_test_id;
			/* Check that there was a next test in the flow sequence */
			if _target_test_id = 0 then
				/* The last passed test station is the last test the sequence and also the target station */
				target_station := last_passed_station;
			else	/* Get the target test station name of the target test ID */
				select testdef_name into target_station from testdef where testdef_id = _target_test_id;
			end if;
		end if;	
	end if;

	return next;
	return;
  end;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.getflowcheck(text, text, integer, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.getflowcheck(text, text, integer, integer) TO ames_admin;
GRANT EXECUTE ON FUNCTION public.getflowcheck(text, text, integer, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.getflowcheck(text, text, integer, integer) TO public;
COMMENT ON FUNCTION public.getflowcheck(text, text, integer, integer) IS '[*New* --mrankin--] Verifies the flow of a part ([Note]: Current implementation TRUE/FALSE, later will have more info returned)';
