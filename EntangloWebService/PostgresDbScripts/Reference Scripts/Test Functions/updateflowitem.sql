-- Function: updateflowitem(integer, integer, integer, boolean)

-- DROP FUNCTION updateflowitem(integer, integer, integer, boolean);

CREATE OR REPLACE FUNCTION updateflowitem(
	integer,
	integer,
	integer,
	-- integer,
	boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowitem_id		ALIAS FOR $1;		-- Flow item ID of the flow item to update
	_flowitem_flow_id   	ALIAS FOR $2;		-- Flow item flow ID to be updated
	_flowitem_item_id	ALIAS for $3;		-- Flow item item ID to be updated
-- 	_flowitem_type_id	ALIAS for $5;		-- Flow item type ID to be updated
	_flowitem_override	ALIAS FOR $4;		-- Flow item override to be updated

	_returned_flowitem_id	integer;		-- Flow item ID of returned query
	_flowitemUpdated	boolean := false;	-- Flow item updated status

  begin

	/* Check that flow item ID is valid */
	if _flowitem_id is null then
		raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM AS FLOW ITEM ID IS NULL';
	END IF;

	/* Check that flow item ID exists */
	if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id)) is false then
		raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM AS FLOW ITEM ID "%" DOES NOT EXIST', _flowitem_id;
	end if;
	
	/* Update flow item flow id if not null */
	if _flowitem_flow_id is not null then

		/* Check if the flow item flow id is different than it's current number */
		if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id
			and testflowitem_flow_id = _flowitem_flow_id)) is false then

			/* Update the test flow item number */
			update testflowitem set testflowitem_flow_id = _flowitem_flow_id where testflowitem_id = _flowitem_id
			returning testflowitem_id into _returned_flowitem_id;

			/* Check that flow item name was updated successfully */
			if _returned_flowitem_id is null then
				raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM FLOW ID AS FLOW ITEM ID IS NULL';
			END IF;
		end if;
	end if;

	/* Check that the item ID and type ID change combination is unique */
	

	/* Update flow item item id if not null */
	if _flowitem_item_id is not null then

		/* Check if the flow item item id is different than it's current number */
		if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id
			and testflowitem_item_id = _flowitem_item_id)) is false then

			/* Update the test flow item item ID */
			update testflowitem set testflowitem_item_id = _flowitem_item_id where testflowitem_id = _flowitem_id
			returning testflowitem_id into _returned_flowitem_id;

			/* Check that flow item item ID was updated successfully */
			if _returned_flowitem_id is null then
				raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM ITEM ID AS FLOW ITEM ID IS NULL';
			END IF;
		end if;
	end if;

-- 	/* Update flow item type ID if not null */
-- 	if _flowitem_type_id is not null then
-- 
-- 		/* Check if type ID exists */
-- 		if (select exists(select 1 from testtype where testtype_id = _flowitem_type_id and testtype_void_timestamp is null)) is true then
-- 
-- 			/* Check if the flow item type ID is different than it's current type ID */
-- 			if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id
-- 				and testflowitem_type_id = _flowitem_type_id)) is false then
-- 
-- 				/* Update the test flow item type ID */
-- 				update testflowitem set testflowitem_type_id = _flowitem_type_id where testflowitem_id = _flowitem_id
-- 				returning testflowitem_id into _returned_flowitem_id;
-- 
-- 				/* Check that flow item type ID was updated successfully */
-- 				if _returned_flowitem_id is null then
-- 					raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM TYPE ID AS FLOW ITEM ID IS NULL';
-- 				END IF;
-- 			end if;
-- 		else 
-- 			raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM AS ITEM TYPE ID "%" DOES NOT EXIST', _flowitem_type_id;
-- 		END IF;
-- 	end if;

	/* Update flow item override if not null */
	if _flowitem_override is not null then

		/* Check if the flow item override is different than it's current status */
		if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id
			and testflowitem_override = _flowitem_override)) is false then

			/* Update the test flow item override status */
			update testflowitem set testflowitem_override = _flowitem_override where testflowitem_id = _flowitem_id
			returning testflowitem_id into _returned_flowitem_id;

			/* Check that flow item override was updated successfully */
			if _returned_flowitem_id is null then
				raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM OVERRIDE AS FLOW ITEM ID IS NULL';
			END IF;
		end if;
	end if;

	

	/* Check if either flow item number, flow item override, flow item multiflow, or flow item type ID were valid */
	if _returned_flowitem_id is null then
		raise exception 'updateflowitem: ERROR UPDATING TEST FLOW ITEM AS THE FLOW ID, FLOW ITEM ID, TYPE ID, AND/OR OVERRIDE ARE BLANK, NULL OR UNCHANGED';
	END IF;

	/* Update flow item modified timestamp */
	update testflowitem set testflowitem_modified_timestamp = now()::timestamp without time zone
		where testflowitem_id = _flowitem_id;

	/* Check that flow item modified timestamp was updated successfully */
	if (select testflowitem_modified_timestamp from testflowitem where testflowitem_id = _flowitem_id) is null then
		raise exception 'updateflowitem: ERROR UPDATING FLOW ITEM AS MODIFIED TIMESTAMP OF FLOW ITEM ID "%" IS NULL', _returned_flowitem_id;
	else
		_flowitemUpdated := true;	-- Set flow item updated status
	end if;

	return _flowitemUpdated;		-- Return flow item updated status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updateflowitem(integer, integer, integer, boolean)
  owner to postgres;
COMMENT ON function updateflowitem(integer, integer, integer, boolean)
  IS '[*New* --mrankin--] Updates a flow item';