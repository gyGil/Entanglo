-- Function: removeflowitem(integer)

-- DROP FUNCTION removeflowitem(integer);

CREATE OR REPLACE FUNCTION removeflowitem(
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowitem_id   		ALIAS FOR $1;		-- Test flow item ID

	_flowItemRemoved	boolean := false;	-- Flow sequence removal status

  begin

	/* Check if item number is null or blank*/
	if _flowitem_id is null then
		raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM AS ITEM ID IS NULL';
	end if;

	/* Check if item ID exists */
	if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id)) is false then
		raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM AS ITEM ID "%" DOES NOT EXIST', _flowitem_id;
	end if;

	/* Remove the item from the flow */
	delete from testflowitem where testflowitem_id = _flowitem_id;

	/* Check if flow item was removed successfully */
	if (select exists(select 1 from testflowitem where testflowitem_id = _flowitem_id)) is TRUE then
		raise exception 'removeflowitem: ERROR REMOVING FLOW ITEM AS ITEM ID "%" STILL EXISTS', _flowitem_id;
	else
		_flowItemRemoved := true;	-- Set flow item removed status
	end if;

	return _flowItemRemoved;		-- Return flow item removed status
	
  end;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION removeflowitem(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION removeflowitem(integer) 
  IS '[*New* --mrankin--] Removes an item from the test flow item table';
