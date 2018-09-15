-- Function: updateflowseq

-- DROP FUNCTION updateflowseq(integer, integer, text, text, integer[], boolean);

CREATE OR REPLACE FUNCTION updateflowseq(
	integer,
	integer,
	text,
	text,
	integer[],
	boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowseq_id		ALIAS FOR $1;		-- Flow sequence ID of the flow sequence to update
	_flowseq_flow_id   	ALIAS FOR $2;		-- Flow sequence flow ID to be updated
	_flowseq_name		ALIAS for $3;		-- Flow sequence name to be updated
	_flowseq_description 	ALIAS for $4;		-- Flow sequence description to be updated
	_flowseq_test_seq	ALIAS FOR $5;		-- Flow sequence test sequence to be updated
	_flowseq_default	ALIAS for $6;		-- Flow sequence default to be updated

	_returned_flowseq_id	integer;		-- Flow sequence ID of returned query
	_test_seq_length	integer := 0;		-- Amount of sequences in test flow sequence
	_current_seq_default	boolean := false;	-- For comparing current sequence default with updated sequence default
	_flowseqUpdated		boolean := false;	-- Flow sequence updated status

  begin

	/* Check that flow sequence ID is valid */
	if _flowseq_id is null then
		raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE AS FLOW SEQUENCE ID IS NULL';
	END IF;

	/* Check that flow sequence ID exists */
	if (select exists(select 1 from testflowseq where testflowseq_id = _flowseq_id AND testflowseq_void_timestamp is null)) is false then
		raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE AS FLOW SEQUENCE ID "%" DOES NOT EXIST OR IS VOIDED', _flowseq_id;
	end if;

	/* Check if the flow sequence name is not null or blank */
	if _flowseq_name is not null and _flowseq_name != '' then
		/* Check if the flow sequence name already exists with the same flow */
		if (select exists(select 1 from testflowseq where testflowseq_flow_id = _flowseq_flow_id and upper(testflowseq_name) = upper(_flowseq_name))) is true then
			raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE AS FLOW SEQUENCE FLOW ID "%" AND FLOW SEQUENCE NAME "%" ALREADY EXISTS', _flowseq_flow_id, _flowseq_name;
		else	/* Update the flow sequence name */
			update testflowseq set testflowseq_name = _flowseq_name where testflowseq_id = _flowseq_id
			returning testflowseq_id into _returned_flowseq_id;

			/* Check that flow sequence flow name was updated successfully */
			if _returned_flowseq_id is null then
				raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE NAME AS FLOW SEQUENCE ID IS NULL';
			END IF;
		end if;
	end if;

	/* Check if the flow sequence description is not null or blank */
	if _flowseq_description is not null and _flowseq_description != '' then
		/* Update the flow sequence description */
		update testflowseq set testflowseq_description = _flowseq_description where testflowseq_id = _flowseq_id
		returning testflowseq_id into _returned_flowseq_id;

		/* Check that flow sequence flow description was updated successfully */
		if _returned_flowseq_id is null then
			raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE DESCRIPTION AS FLOW SEQUENCE ID IS NULL';
		END IF;
	end if;
	
	/* Update flow sequence flow ID if not null */
	if _flowseq_flow_id is not null then
		/* Check if the flow sequence flow ID is different than it's current flow ID */
		if (select exists(select 1 from testflowseq where testflowseq_id = _flowseq_id
			and testflowseq_flow_id = _flowseq_flow_id)) is false then

			/* Check if the flow sequence name exists within the new flow ID */
			if (select exists(select 1 from testflowseq where testflowseq_flow_id = _flowseq_flow_id
				and upper(testflowseq_name) = upper(_flowseq_name))) is false then
				
				/* Update the test flow sequence flow ID */
				update testflowseq set testflowseq_flow_id = _flowseq_flow_id where testflowseq_id = _flowseq_id
				returning testflowseq_id into _returned_flowseq_id;

				/* Check that flow sequence flow ID was updated successfully */
				if _returned_flowseq_id is null then
					raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE FLOW ID AS FLOW SEQUENCE ID IS NULL';
				END IF;
			else
				raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE FLOW ID AS NEW FLOW ID "%" AND FLOW SEQUENCE NAME "%" ALREADY EXISTS', _flowseq_flow_id, _flowseq_name;
			end if;
		end if;
	end if;

	/* Update flow sequence test sequence if not blank */
	if _flowseq_test_seq is not null then

		/* Get amount of sequences in flow */
		select array_length(_flowseq_test_seq, 1) into _test_seq_length;

-- 		/* Check that there are 2 or more sequences in flow or that the test sequence is not null */
-- 		if _test_seq_length < 2 or _test_seq_length is null then
-- 			raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE AS THERE MUST BE MORE THAN "%" SEQUENCE(S) IN FLOW', _test_seq_length;
-- 		end if;
		
		/* Check if the test flow sequence is different than it's current flow sequence */
		if (select exists(select 1 from testflowseq where testflowseq_id = _flowseq_id
			and testflowseq_test_seq = _flowseq_test_seq)) is false then

			/* Update the test flow sequence */
			update testflowseq set testflowseq_test_seq = _flowseq_test_seq where testflowseq_id = _flowseq_id
			returning testflowseq_id into _returned_flowseq_id;

			/* Check that the test flow sequence was updated successfully */
			if _returned_flowseq_id is null then
				raise exception 'updateflowseq: ERROR UPDATING TEST FLOW SEQUENCE AS FLOW SEQUENCE ID IS NULL';
			END IF;
		end if;
	end if;


	/* Check if flow sequence default is null */
	if _flowseq_default is not null then
		/* Get the current sequence default setting */
		select testflowseq_default from testflowseq where testflowseq_id = _flowseq_id into _current_seq_default;
		/* Check if the current sequence is attempting a switch from default to not default */
		if _current_seq_default is true then
			/* Do not allow the default sequence to be un-defaulted */ 
			if _flowseq_default is false then
				RAISE EXCEPTION 'updateflowseq: ERROR UPDATED FLOW SEQUENCE AS CURRENT DEFAULT CANNOT BE REMOVED BEFORE DEFAULTING ANOTHER SEQUENCE';
			END IF; -- dont't care if sequence is already default (no change)
		else	/* Remove default from other sequence before making current sequence default */
			IF _flowseq_default is true then
				/* Un-default current defaulted sequence */
				update testflowseq set testflowseq_default = false where testflowseq_flow_id = _flowseq_flow_id and testflowseq_default = true
				returning testflowseq_id into _returned_flowseq_id;

				/* Check that the previous flow sequence default was un-defaulted successfully */
				if _returned_flowseq_id is null then
					raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE AS SEQUENCE WITH SAME FLOW ID "%" HAS DEFAULT SET TO TRUE AND IS UNABLE TO SET TO FALSE', _returned_flowseq_id;
				else	/* Set current sequence to default */
					update testflowseq set testflowseq_default = true where testflowseq_id = _flowseq_id;
				end if;
			end if; -- don't care if flow sequence is false
		end if;
	end if; -- don't care if sequence default was not set
	
	/* Check if either flow sequence ID, flow sequence flow ID, flow sequence name, flow sequence description, flow sequence test sequence, or flow sequence default were valid */
	if _returned_flowseq_id is null then
		raise exception 'updateflowseq: ERROR UPDATING TEST FLOW SEQUENCE AS FLOW SEQUENCE ID, FLOW ID, TEST SEQUENCE, AND/OR DEFAULT ARE BLANK, NULL OR UNCHANGED';
	END IF;

	/* Update flow sequence modified timestamp */
	update testflowseq set testflowseq_modified_timestamp = now()::timestamp without time zone
		where testflowseq_id = _flowseq_id;

	/* Check that flow sequence modified timestamp was updated successfully */
	if (select testflowseq_modified_timestamp from testflowseq where testflowseq_id = _flowseq_id) is null then
		raise exception 'updateflowseq: ERROR UPDATING FLOW SEQUENCE AS MODIFIED TIMESTAMP OF FLOW SEQUENCE ID "%" IS NULL', _returned_flowseq_id;
	else
		_flowseqUpdated := true;	-- Set flow sequence updated status
	end if;

	return _flowseqUpdated;			-- Return flow sequence updated status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updateflowseq(integer, integer, text, text, integer[], boolean)
  owner to postgres;
COMMENT ON function updateflowseq(integer, integer, text, text, integer[], boolean)
  IS '[*New* --mrankin--] Updates a flow sequence';