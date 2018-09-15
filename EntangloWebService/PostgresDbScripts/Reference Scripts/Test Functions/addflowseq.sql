-- Function: removeflowitem(text)

-- DROP FUNCTION removeflowitem(text);

CREATE OR REPLACE FUNCTION removeflowitem(
	text
    )
  RETURNS boolean AS
  $BODY$
  DECLARE

	_item_number   		ALIAS FOR $1;		-- Test flow item number

	_flowitem_id		integer;		-- For checking successful test flow item existence and removal
	_flowItemRemoved	boolean := false;	-- Flow sequence removal status

  begin

	/* Check if item number is null or blank*/
	if _item_number is null or _item_number = '' then
		raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM AS ITEM NUMBER IS NULL OR BLANK';
	end if;

	/* Get flow item ID */
	select testflowitem_id from testflowitem where testflowitem_item_number = _item_number into _flowitem_id;

	/* Check if flow item ID exists */
	if _flowitem_id is null then
		raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM AS ITEM NUMBER "%" DOES NOT EXIST', _item_number;
	end if;

	update testflowitem set testflowitem_void = now()::timestamp without time zone
	where testflowitem_id = _flowitem_id;

	/* Check if flow item was removed successfully */
	if (select testflowitem_void from testflowitem where testflowitem_id = _flowitem_id) is null then
		raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM "%" WITH FLOW ID "%" AS FLOW ITEM REMOVED TIMESTAMP IS NULL', _item_number, _flowitem_id;
	else
		_flowItemRemoved := true;	-- Set flow item removed status
	end if;

	return _flowItemRemoved;		-- Return flow item removed status
	
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function removeflowitem(text)
  owner to postgres;
COMMENT ON function removeflowitem(text)
  IS '[*New* --mrankin--] Removes an item from the test flow item table';