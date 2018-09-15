-- Function: createtest(integer, text, text, integer[], boolean)

-- DROP FUNCTION createtest(integer, text, text, integer[], boolean);

CREATE OR REPLACE FUNCTION createtestflow(
    integer,
    text,
    text,
    integer[],
    boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flow_id   		ALIAS FOR $1;		-- Test flow ID
	_seq_name		ALIAS for $2;		-- Test flow sequence name
	_seq_description        ALIAS for $3;		-- Test flow sequence description
	_test_seq		ALIAS FOR $4;		-- Flow sequence
	_default_seq		ALIAS FOR $5;		-- Default flow sequence

	i			integer := 1;		-- Flow sequence iterator

	_test_seq_length	integer;		-- Amount of sequences in flow
	_flowseq_id		integer;		-- For checking successful test flow sequence creation
	_other_flowseq_id	integer;		-- For checking if previous sequence default was flipped
	_flowCreated		boolean := false;	-- Test creation status

  begin

	/* Check if flow ID is null */
	if _flow_id is null then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS FLOW ID IS NULL';
	end if;

	/* Check if test sequence name is null or blank */
	if _seq_name is null or _seq_name = '' then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS TEST FLOW SEQUENCE NAME IS NULL OR BLANK';
	end if;

	/* Check if test sequence description is null or blank */
	if _seq_description is null or _seq_description = '' then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS TEST FLOW SEQUENCE DESCRIPTION IS NULL OR BLANK';
	end if;

	/* Check if flow ID exists */
	if (select exists(select 1 from testflowitem where testflowitem_flow_id = _flow_id)) is false then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS FLOW ID "%" DOES NOT EXIST OR IS VOIDED', _flow_id;
	end if;

	/* Check if test sequence is null */
	if _test_seq is null then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS TEST SEQUENCE IS NULL';
	end if;

	/* Get amount of sequences in flow */
	select array_length(_test_seq, 1) into _test_seq_length;

-- 	/* Check that there are 2 or more sequences in flow */
-- 	if _test_seq_length < 2 or _test_seq_length is null then
-- 		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS THERE MUST BE MORE THAN "%" SEQUENCE IN FLOW', _test_seq_length;
-- 	end if;

	/* Check if flow sequence exists */
	if (select exists(select 1 from testflowseq where testflowseq_flow_id = _flow_id and testflowseq_test_seq = _test_seq and array_length(_test_seq, 1) > 0 )) is true then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS FLOW SEQUENCE "%" ALREADY EXISTS FOR FLOW ID "%"', _test_seq, _flow_id;
	end if;

	/* Check that the sequence name does not already exist for specified flow */
	if (select exists(select 1 from testflowseq where testflowseq_flow_id = _flow_id and upper(testflowseq_name) = upper(_seq_name))) is true then
		raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS FLOW SEQUENCE NAME "%" FOR FLOW "%" ALREADY EXISTS', _seq_name, _flow_id;
	end if;

	/* Verify that the flow sequences exist as test definitions */
	while i <= _test_seq_length
	loop	/* Check each flow sequence against each test definition */
		if (select exists(select 1 from testdef where testdef_id = _test_seq[i])) is false then
			raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS SEQUENCE "%" DOES NOT EXIST AS A TEST DEFINITION', _test_seq[i];
		end if;

		i := i + 1;	-- Increment flow sequence iterator
	end loop;

	/* Check if a flow sequence already exists and is the default sequence */
	if (select exists(select 1 from testflowseq where testflowseq_flow_id = _flow_id and testflowseq_default = true)) is true then
		/* Check if the new sequence is set as the default */
		if (_default_seq = true) then
			/* Remove default from previously defaulted sequence */
			update testflowseq set testflowseq_default = false where testflowseq_flow_id = _flow_id and testflowseq_default = true
			returning testflowseq_id into _flowseq_id;
	
			/* Check that the flow sequence default was set successfully */
			if _flowseq_id is null then
				raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS SEQUENCE WITH SAME FLOW ID "%" HAS DEFAULT SET TO TRUE AND IS UNABLE TO SET TO FALSE', _flow_id;
			end if;
		END IF;
	ELSE	/* Set new sequence to default if the first one */
		_default_seq := true;
	end if;

-- 	/* Check if default sequence is false */
-- 	if _default_seq is false then
-- 		/* Check if this is the first sequence for this flow */
-- 		if ((select testflowseq_flow_id from testflowseq where testflowseq_flow_id = _flow_id) > 0) then
-- 			if (select testflowseq_default from testflowseq where testflowseq_flow_id = _flow_id) is false then
-- 				/* If this is the first flow of this sequence set default to true */
-- 				update testflowseq set testflowseq_default = true where testflowseq_flow_id = _flow_id
-- 				returning testflowseq_id into _flowseq_id;
-- 			
-- 			/* Check that the flow sequence default was set successfully */
-- 			if _flowseq_id is null then
-- 				raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS SEQUENCE WITH SAME FLOW ID "%" HAS DEFAULT SET TO FALSE AND IS UNABLE TO SET TO TRUE', _flow_id;
-- 			end if;
-- 		else
-- 			_default_seq := true;	-- Set flow sequence default
-- 		end if;
-- 	else 	/* If default sequence is true check if another exists that is set to true */
-- 		if (select exists(select testflowseq_flow_id from testflowseq where testflowseq_flow_id = _flow_id AND testflowseq_default = true)) is true then
-- 			/* Set other sequence default to false prior to setting new to true */
-- 			update testflowseq set testflowseq_default = false where testflowseq_flow_id = _flow_id and testflowseq_default = true
-- 			returning testflowseq_id into _other_flowseq_id;
-- 		end if;
-- 
-- 		/* Check that previous default was changed */
-- 		if (select testflowseq_default from testflowseq where testflowseq_id = _other_flowseq_id) is true then
-- 			raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS SEQUENCE WITH SAME FLOW ID "%" EXISTS AND DEFAULT IS UNABLE TO SWITCH FROM TRUE TO FALSE', _flow_id;
-- 		end if;
-- 	end if;

	/* Create new test flow sequence */
	insert into testflowseq (testflowseq_flow_id, 
				testflowseq_name,
				testflowseq_description,
				testflowseq_test_seq,
				testflowseq_default,
				testflowseq_created_timestamp)
	values 			(_flow_id,
				_seq_name,
				_seq_description,
				_test_seq,
				_default_seq,
				now()::timestamp without time zone)
	returning testflowseq_id into _flowseq_id;

	/* Check that test flow sequence was created successfully */
	if _flowseq_id is null then
		raise exception 'createtestflow: ERROR CREATING TEST FLOW AS FLOW ID IS NULL';
	ELSE 
		_flowCreated := true;	-- Set test flow creation status
	end if;

	return _flowCreated;		-- Return test flow creation status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createtestflow(integer, text, text, integer[], boolean)
  owner to postgres;
COMMENT ON function createtestflow(integer, text, text, integer[], boolean)
  IS '[*New* --mrankin--] Creates a new test flow and sequence';