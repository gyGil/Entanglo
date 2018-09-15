-- Function: removeflowdef(text)

-- DROP FUNCTION removeflowdef(text);

CREATE OR REPLACE FUNCTION removeflowdef(
	text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowdef_name  		ALIAS FOR $1;		-- Test flow definition name

	_flowdef_id		integer;		-- For checking successful test flow definition existence and removal
	
	i 			integer := 0;		-- Item/Sequence flow removal incrementer

	_temp_flowitem_number	text;			-- Temporary flow item number for removing flow items
	_amtItems		integer := 0;		-- Amount of flow items
	_temp_flowseq_id	integer;		-- Temporary flow sequence ID for removal checking
	_amtSequences		integer := 0;		-- Amount of flow sequences

	_flowDefRemoved		boolean := false;	-- Flow definition removal status

  begin

	/* Check if definition name is null or blank*/
	if _flowdef_name is null or _flowdef_name = '' then
		raise exception 'removeflowdef: ERROR REMOVING FLOW DEFINITION AS DEFINITION NAME IS NULL OR BLANK';
	end if;

	/* Get flow definition ID */
	select testflowdef_id from testflowdef where upper(testflowdef_name) = upper(_flowdef_name) into _flowdef_id;

	/* Check if flow definition ID exists */
	if _flowdef_id is null then
		raise exception 'removeflowdef: ERROR REMOVING FLOW DEFINITION AS DEFINITION NAME "%" DOES NOT EXIST', _flowdef_name;
	end if;

	/* Get flow item flow ID count */
	select count(*) from testflowitem where testflowitem_flow_id = _flowdef_id into _amtItems;

	/* Loop through and remove all flow sequences related to the item */
	while i < _amtItems
	loop	/* Get first found flow item number of definition flow ID */
		select testflowitem_item_number from testflowitem where testflowitem_flow_id = _flowdef_id
		and testflowitem_void_timestamp is null limit 1 into _temp_flowitem_number;

		/* Remove flow item found */
		if (select removeflowitem(_temp_flowitem_number)) is false then
			raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM AS FALSE WAS RETURNED FROM REMOVEFLOWITEM()';
		END IF;
		
		/* Check if flow sequence was removed successfully */
		if (select testflowitem_void_timestamp from testflowitem where upper(testflowitem_item_number) = upper(_temp_flowitem_number)) is null then
			raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM WITH FLOW ITEM NUMBER "%" AS FLOW ITEM VOID TIMESTAMP IS NULL', _temp_flowitem_number;
		end if;

		i := i + 1;	-- Increment sequence removal counter
		
	end loop;

	i := 0;			-- Reset 

	/* Get flow sequence flow ID count */
	select count(*) from testflowseq where testflowseq_flow_id = _flowdef_id into _amtSequences;

	/* Loop through and remove all flow sequences related to the item */
	while i < _amtSequences
	loop	/* Get first found flow sequence ID of item flow ID */
		select testflowseq_id from testflowseq where testflowseq_flow_id = _flowdef_id 
		and testflowseq_void_timestamp is null limit 1 into _temp_flowseq_id;
		
		/* Remove flow sequence found */
		if (select removeflowseq(_temp_flowseq_id)) is false then
			raise exception 'removeflowitem: ERROR REMOVING FLOW SEQUENCE FLOW ITEM AS FALSE WAS RETURNED FROM REMOVEFLOWSEQ()';
		END IF;
		
		/* Check if flow sequence was removed successfully */
		if (select testflowseq_void_timestamp from testflowseq where testflowseq_id = _temp_flowseq_id) is null then
			raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM SEQUENCE WITH FLOW SEQUENCE ID "%" AS FLOW SEQUENCE VOID TIMESTAMP IS NULL', _temp_flowseq_id;
		end if;

		i := i + 1;	-- increment sequence removal counter
		
	end loop;

	/* Remove the flow definition */
	update testflowdef set testflowdef_void_timestamp = now()::timestamp without time zone
	where testflowdef_id = _flowdef_id;

	/* Check if flow definition was removed successfully */
	if (select testflowdef_void_timestamp from testflowdef where testflowdef_id = _flowdef_id) is null then
		raise exception 'removeflowdef: ERROR REMOVING FLOW DEFINITION "%" WITH FLOW DEFINITION ID "%" AS FLOW DEFINITION REMOVED TIMESTAMP IS NULL', _flowdef_name, _flowdef_id;
	else
		_flowDefRemoved := true;	-- Set flow definition removed status
	end if;

	return _flowDefRemoved;		-- Return flow definition removed status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function removeflowdef(text)
  owner to postgres;
COMMENT ON function removeflowdef(text)
  IS '[*New* --mrankin--] Removes a flow definition';